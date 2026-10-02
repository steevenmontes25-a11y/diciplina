import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/colors.dart';
import '../../core/database/db_helper.dart';
import '../../core/models/goal.dart';
import '../../providers/goals_provider.dart';
import 'widgets/italian_levels_expanded.dart';
import 'widgets/stage_card.dart' show italianStageId;
import 'widgets/stage_completion_dialog.dart';

/// Detalle completo de una etapa: header con progreso, y tabs de tareas,
/// recursos e historial.
///
/// Recibe el [GoalStage] directamente (vía `extra` de GoRouter) como snapshot
/// inicial, pero sigue observando `goalStagesProvider` para reflejar cambios
/// en vivo (marcar tareas, agregar recursos, etc.).
class StageDetailScreen extends ConsumerWidget {
  const StageDetailScreen({super.key, required this.stage});

  final GoalStage stage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stagesAsync = ref.watch(goalStagesProvider(stage.goalId));
    final goalAsync = ref.watch(activeGoalProvider);

    final liveStages = stagesAsync.valueOrNull;
    final liveStage = _findById(liveStages, stage.id) ?? stage;
    final goalCreatedAt = goalAsync.valueOrNull?.createdAt ?? DateTime.now();

    return _StageDetailScaffold(
      stage: liveStage,
      allStages: liveStages ?? [stage],
      goalCreatedAt: goalCreatedAt,
    );
  }

  GoalStage? _findById(List<GoalStage>? stages, String id) {
    if (stages == null) return null;
    for (final s in stages) {
      if (s.id == id) return s;
    }
    return null;
  }
}

class _StageDetailScaffold extends ConsumerStatefulWidget {
  const _StageDetailScaffold({
    required this.stage,
    required this.allStages,
    required this.goalCreatedAt,
  });

  final GoalStage stage;
  final List<GoalStage> allStages;
  final DateTime goalCreatedAt;

  @override
  ConsumerState<_StageDetailScaffold> createState() =>
      _StageDetailScaffoldState();
}

class _StageDetailScaffoldState extends ConsumerState<_StageDetailScaffold>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 3,
    vsync: this,
  )..addListener(_onTabChanged);

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) setState(() {});
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  bool get _isItalian => widget.stage.id == italianStageId;
  bool get _isLocked => widget.stage.status == StageStatus.locked;

  Future<void> _toggleTask(StageTask task) async {
    if (task.status == TaskStatus.done) return;

    await HapticFeedback.mediumImpact();
    await DbHelper.instance.completeTask(task.id);

    final freshStages = await DbHelper.instance.getStagesForGoal(
      widget.stage.goalId,
    );
    if (!mounted) return;
    ref.invalidate(goalStagesProvider(widget.stage.goalId));

    GoalStage? freshStage;
    for (final s in freshStages) {
      if (s.id == widget.stage.id) {
        freshStage = s;
        break;
      }
    }
    if (freshStage == null || freshStage.status == StageStatus.completed) {
      return;
    }

    final allDone =
        freshStage.tasks.isNotEmpty &&
        freshStage.tasks.every((t) => t.status == TaskStatus.done);
    if (!allDone) return;

    await _completeStage(freshStage, freshStages);
  }

  Future<void> _completeStage(
    GoalStage stage,
    List<GoalStage> allStages,
  ) async {
    final completedDates = stage.tasks
        .map((t) => t.completedAt)
        .whereType<DateTime>()
        .toList();

    var days = 0;
    if (completedDates.isNotEmpty) {
      final earliest = completedDates.reduce((a, b) => a.isBefore(b) ? a : b);
      final latest = completedDates.reduce((a, b) => a.isAfter(b) ? a : b);
      days = latest.difference(earliest).inDays;
    }

    final milestone = Milestone(
      id: '${stage.id}_milestone_${DateTime.now().millisecondsSinceEpoch}',
      goalId: stage.goalId,
      stageId: stage.id,
      title: '${stage.title} completada',
      description: 'Completaste todas las tareas de "${stage.title}".',
      daysToComplete: days,
      achievedAt: DateTime.now(),
    );
    await DbHelper.instance.insertMilestone(milestone);
    await DbHelper.instance.updateStageStatus(stage.id, StageStatus.completed);

    GoalStage? nextStage;
    for (final s in allStages) {
      if (s.order == stage.order + 1) {
        nextStage = s;
        break;
      }
    }
    if (nextStage != null && nextStage.status == StageStatus.locked) {
      await DbHelper.instance.updateStageStatus(
        nextStage.id,
        StageStatus.inProgress,
      );
    }

    if (!mounted) return;
    ref.invalidate(goalStagesProvider(stage.goalId));
    ref.invalidate(goalMilestonesProvider(stage.goalId));

    final unlockedNext = nextStage?.copyWith(status: StageStatus.inProgress);
    await showStageCompletedDialog(
      context,
      stage: stage,
      daysToComplete: days,
      onViewNextStage: unlockedNext == null
          ? null
          : () => context.pushReplacement(
              '/metas/stage/${unlockedNext.id}',
              extra: unlockedNext,
            ),
    );
  }

  Future<void> _addTask(String title) async {
    final task = StageTask(
      id: '${widget.stage.id}_custom_${DateTime.now().millisecondsSinceEpoch}',
      stageId: widget.stage.id,
      title: title,
      status: TaskStatus.pending,
    );
    await DbHelper.instance.insertStageTask(task);
    if (!mounted) return;
    ref.invalidate(goalStagesProvider(widget.stage.goalId));
  }

  Future<void> _addResource({
    required String title,
    required ResourceType type,
    required String url,
  }) async {
    final resource = StageResource(
      id: '${widget.stage.id}_res_${DateTime.now().millisecondsSinceEpoch}',
      stageId: widget.stage.id,
      title: title,
      type: type,
      url: url,
    );
    await DbHelper.instance.insertStageResource(resource);
    if (!mounted) return;
    ref.invalidate(goalStagesProvider(widget.stage.goalId));
  }

  void _openAddTaskSheet() {
    final controller = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 20,
          bottom: 24 + MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nueva tarea',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Título de la tarea',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  final title = controller.text.trim();
                  if (title.isEmpty) return;
                  Navigator.of(sheetContext).pop();
                  await _addTask(title);
                },
                child: const Text('Guardar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAddResourceSheet() {
    final titleController = TextEditingController();
    final urlController = TextEditingController();
    var selectedType = ResourceType.link;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: 24 + MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nuevo recurso',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                autofocus: true,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ResourceType>(
                initialValue: selectedType,
                dropdownColor: AppColors.surface,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: ResourceType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(_typeLabel(type)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setSheetState(() => selectedType = value);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: urlController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'URL'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final title = titleController.text.trim();
                    final url = urlController.text.trim();
                    if (title.isEmpty || url.isEmpty) return;
                    Navigator.of(sheetContext).pop();
                    await _addResource(
                      title: title,
                      type: selectedType,
                      url: url,
                    );
                  },
                  child: const Text('Guardar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _typeLabel(ResourceType type) => switch (type) {
    ResourceType.video => 'Video',
    ResourceType.pdf => 'PDF',
    ResourceType.exercise => 'Ejercicio',
    ResourceType.link => 'Link',
    ResourceType.book => 'Libro',
  };

  @override
  Widget build(BuildContext context) {
    final stage = widget.stage;
    final showFab = !_isLocked && _tabController.index != 2;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: '📋 Tareas'),
            Tab(text: '📚 Recursos'),
            Tab(text: '📅 Historial'),
          ],
        ),
      ),
      floatingActionButton: !showFab
          ? null
          : FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              onPressed: _tabController.index == 0
                  ? _openAddTaskSheet
                  : _openAddResourceSheet,
              icon: const Icon(Icons.add),
              label: Text(
                _tabController.index == 0 ? 'Agregar tarea' : 'Agregar recurso',
              ),
            ),
      body: SafeArea(
        child: Column(
          children: [
            _StageHeader(stage: stage),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _isItalian
                      ? ItalianLevelsExpanded(
                          stage: stage,
                          referenceDate: widget.goalCreatedAt,
                        )
                      : _TasksTab(stage: stage, onToggleTask: _toggleTask),
                  _ResourcesTab(resources: stage.resources),
                  _HistoryTab(stage: stage),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StageHeader extends StatelessWidget {
  const _StageHeader({required this.stage});

  final GoalStage stage;

  @override
  Widget build(BuildContext context) {
    final (badgeText, badgeColor) = switch (stage.status) {
      StageStatus.inProgress => ('EN CURSO', AppColors.success),
      StageStatus.locked => ('🔒 BLOQUEADA', AppColors.textMuted),
      StageStatus.completed => ('✅ COMPLETADA', AppColors.warning),
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(stage.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  stage.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: stage.progress,
                  minHeight: 12,
                  backgroundColor: const Color(0xFF2A2D3E),
                  valueColor: AlwaysStoppedAnimation(badgeColor),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${(stage.progress * 100).round()}%',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TasksTab extends StatelessWidget {
  const _TasksTab({required this.stage, required this.onToggleTask});

  final GoalStage stage;
  final Future<void> Function(StageTask task) onToggleTask;

  @override
  Widget build(BuildContext context) {
    if (stage.tasks.isEmpty) {
      return const Center(
        child: Text(
          'Sin tareas todavía',
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: stage.tasks.length,
      separatorBuilder: (context, index) =>
          const Divider(color: Color(0xFF2A2D3E), height: 1),
      itemBuilder: (context, index) {
        final task = stage.tasks[index];
        return _TaskRow(task: task, onToggle: () => onToggleTask(task));
      },
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.task, required this.onToggle});

  final StageTask task;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final isDone = task.status == TaskStatus.done;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Transform.scale(
            scale: 1.75,
            child: Checkbox(
              value: isDone,
              activeColor: AppColors.success,
              onChanged: isDone ? null : (_) => onToggle(),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDone ? AppColors.textMuted : AppColors.textPrimary,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (isDone && task.completedAt != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Completada el '
                      '${DateFormat("d 'de' MMMM", 'es').format(task.completedAt!)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResourcesTab extends StatelessWidget {
  const _ResourcesTab({required this.resources});

  final List<StageResource> resources;

  @override
  Widget build(BuildContext context) {
    if (resources.isEmpty) {
      return const Center(
        child: Text(
          'Sin recursos todavía',
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: resources.length,
      itemBuilder: (context, index) =>
          _ResourceCard(resource: resources[index]),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  const _ResourceCard({required this.resource});

  final StageResource resource;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(_iconFor(resource.type), color: AppColors.primary, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resource.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _TypeBadge(type: resource.type),
                ],
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () => _open(context),
              child: const Text('Abrir'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri.tryParse(resource.url);
    if (uri == null || !await canLaunchUrl(uri)) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace')),
      );
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  IconData _iconFor(ResourceType type) => switch (type) {
    ResourceType.video => Icons.play_circle_outline,
    ResourceType.pdf => Icons.picture_as_pdf_outlined,
    ResourceType.exercise => Icons.edit_note_outlined,
    ResourceType.link => Icons.link,
    ResourceType.book => Icons.menu_book_outlined,
  };
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});

  final ResourceType type;

  @override
  Widget build(BuildContext context) {
    final label = switch (type) {
      ResourceType.video => 'VIDEO',
      ResourceType.pdf => 'PDF',
      ResourceType.exercise => 'EJERCICIO',
      ResourceType.link => 'LINK',
      ResourceType.book => 'LIBRO',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab({required this.stage});

  final GoalStage stage;

  @override
  Widget build(BuildContext context) {
    final completed =
        stage.tasks
            .where((t) => t.status == TaskStatus.done && t.completedAt != null)
            .toList()
          ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));

    if (completed.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Todavía no hay tareas completadas en esta etapa.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: completed.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final task = completed[index];
        return Text(
          '✅ ${task.title} completada · ${_relativeLabel(task.completedAt!)}',
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        );
      },
    );
  }

  String _relativeLabel(DateTime date) {
    final days = DateTime.now().difference(date).inDays;
    if (days <= 0) return 'hoy';
    if (days == 1) return 'hace 1 día';
    return 'hace $days días';
  }
}
