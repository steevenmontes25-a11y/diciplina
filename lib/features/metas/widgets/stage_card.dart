import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/models/goal.dart';
import 'italian_level_meter.dart';

/// Id de la etapa de italiano en la meta precargada de Bologna. La etapa con
/// este id se dibuja con el medidor de niveles A1-B2 en vez de la lista de
/// tareas genérica.
const String italianStageId = 'bologna_stage_2';

/// Máximo de tareas que se muestran en la vista previa de la tarjeta antes
/// de tener que tocar "Ver +".
const int _maxPreviewTasks = 5;

/// Tarjeta de una etapa del roadmap: orden, emoji, título, badge de estado,
/// barra de progreso y una vista previa de sus tareas (o el medidor de
/// niveles, si es la etapa de italiano).
class StageCard extends StatelessWidget {
  const StageCard({super.key, required this.stage, required this.onViewMore});

  final GoalStage stage;
  final VoidCallback onViewMore;

  @override
  Widget build(BuildContext context) {
    final isLocked = stage.status == StageStatus.locked;
    final isItalian = stage.id == italianStageId;

    return Opacity(
      opacity: isLocked ? 0.4 : 1,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${stage.order}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(stage.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    stage.title.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                _StageBadge(status: stage.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: stage.progress,
                    minHeight: 8,
                    backgroundColor: const Color(0xFF2A2D3E),
                    valueColor: AlwaysStoppedAnimation(
                      _progressColor(stage.status),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(stage.progress * 100).round()}%',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isItalian)
              ItalianLevelMeter(stage: stage)
            else
              ..._previewTasks(
                stage,
              ).map((task) => _TaskRow(stage: stage, task: task)),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: isLocked ? null : onViewMore,
                child: const Text('Ver +'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<StageTask> _previewTasks(GoalStage stage) {
    if (stage.tasks.length <= _maxPreviewTasks) return stage.tasks;
    return stage.tasks.sublist(0, _maxPreviewTasks);
  }

  Color _progressColor(StageStatus status) => switch (status) {
    StageStatus.completed => AppColors.warning,
    StageStatus.inProgress => AppColors.success,
    StageStatus.locked => AppColors.textMuted,
  };
}

class _StageBadge extends StatelessWidget {
  const _StageBadge({required this.status});

  final StageStatus status;

  @override
  Widget build(BuildContext context) {
    final (text, color) = switch (status) {
      StageStatus.inProgress => ('EN CURSO', AppColors.success),
      StageStatus.locked => ('🔒 BLOQUEADA', AppColors.textMuted),
      StageStatus.completed => ('✅ COMPLETADA', AppColors.warning),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.stage, required this.task});

  final GoalStage stage;
  final StageTask task;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(_iconFor(stage, task), style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              task.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: task.status == TaskStatus.done
                    ? AppColors.textMuted
                    : AppColors.textPrimary,
                fontSize: 13,
                decoration: task.status == TaskStatus.done
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ hecha, ⏳ la próxima pendiente (la "actual"), ❌ el resto de
  /// pendientes, ➖ omitida.
  String _iconFor(GoalStage stage, StageTask task) {
    if (task.status == TaskStatus.done) return '✅';
    if (task.status == TaskStatus.skipped) return '➖';

    final firstPending = stage.tasks.firstWhere(
      (t) => t.status == TaskStatus.pending,
      orElse: () => task,
    );
    return task.id == firstPending.id ? '⏳' : '❌';
  }
}
