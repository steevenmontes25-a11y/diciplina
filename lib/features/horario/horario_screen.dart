import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/schedule_data.dart';
import '../../core/models/activity.dart';
import '../../core/models/day_progress.dart';
import '../../providers/progress_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../shared/widgets/activity_modal.dart';
import 'widgets/day_selector.dart';
import 'widgets/timeline_activity.dart';

/// Pantalla con el horario semanal completo, navegable por día, con
/// diseño de línea de tiempo.
class HorarioScreen extends ConsumerStatefulWidget {
  const HorarioScreen({super.key, this.initialDayName});

  /// Nombre (`DayOfWeek.name`) del día a mostrar al abrir la pantalla, p. ej.
  /// desde el grid de "Semana". Si es `null` o inválido, muestra hoy.
  final String? initialDayName;

  @override
  ConsumerState<HorarioScreen> createState() => _HorarioScreenState();
}

class _HorarioScreenState extends ConsumerState<HorarioScreen> {
  late DayOfWeek _selectedDay = _parseInitialDay();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _currentActivityKey = GlobalKey();
  bool _didScrollToCurrent = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  DayOfWeek _parseInitialDay() {
    final name = widget.initialDayName;
    if (name == null) return todayAsEnum;
    for (final day in DayOfWeek.values) {
      if (day.name == name) return day;
    }
    return todayAsEnum;
  }

  void _selectDay(DayOfWeek day) {
    setState(() {
      _selectedDay = day;
      // Solo se re-arma el scroll automático cuando se vuelve a seleccionar
      // el día de hoy; para el resto de los días no aplica.
      _didScrollToCurrent = day != todayAsEnum;
    });
  }

  void _scheduleScrollToCurrent() {
    if (_didScrollToCurrent) return;
    _didScrollToCurrent = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _currentActivityKey.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.3,
      );
    });
  }

  (String, String) _statusLabel(DisciplineLevel level) => switch (level) {
    DisciplineLevel.green => ('🟢', 'Excelente'),
    DisciplineLevel.yellow => ('🟡', 'Parcial'),
    DisciplineLevel.red => ('🔴', 'Bajo'),
  };

  @override
  Widget build(BuildContext context) {
    final isToday = _selectedDay == todayAsEnum;
    final dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final activities = ref.watch(scheduleForDayProvider(_selectedDay));
    final progressMap = isToday
        ? ref.watch(progressNotifierProvider(dateKey)).valueOrNull ?? const {}
        : const <String, ActivityProgress>{};
    final stats = isToday
        ? ref.watch(dayStatsProvider(dateKey)).valueOrNull
        : null;

    final currentIndex = isToday
        ? activities.indexWhere((a) => a.isHappeningAt(TimeOfDay.now()))
        : -1;
    if (currentIndex != -1) {
      _scheduleScrollToCurrent();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'Horario',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            DaySelector(selectedDay: _selectedDay, onChanged: _selectDay),
            if (isToday && stats != null) ...[
              const SizedBox(height: 10),
              _TodayStatusLine(
                day: _selectedDay,
                stats: stats,
                statusLabel: _statusLabel(stats.level),
              ),
            ],
            const SizedBox(height: 12),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(scheduleForDayProvider(_selectedDay));
                  if (isToday) {
                    ref.invalidate(progressNotifierProvider(dateKey));
                    ref.invalidate(dayStatsProvider(dateKey));
                  }
                },
                child: activities.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 120),
                          Center(
                            child: Text(
                              'Sin actividades este día',
                              style: TextStyle(color: AppColors.textMuted),
                            ),
                          ),
                        ],
                      )
                    : CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            sliver: SliverList.builder(
                              itemCount: activities.length,
                              itemBuilder: (context, index) {
                                final activity = activities[index];
                                final isCurrent = index == currentIndex;
                                final progress = progressMap[activity.id];

                                return TimelineActivity(
                                  key: isCurrent ? _currentActivityKey : null,
                                  activity: activity,
                                  isFirst: index == 0,
                                  isLast: index == activities.length - 1,
                                  isCurrentActivity: isCurrent,
                                  progressStatus: isToday
                                      ? progress?.status
                                      : null,
                                  onTap: () => showActivityModal(
                                    context,
                                    activity: activity,
                                    date: isToday ? dateKey : null,
                                    progress: progress,
                                    onStatusChanged: isToday
                                        ? (newStatus) => ref
                                              .read(
                                                progressNotifierProvider(
                                                  dateKey,
                                                ).notifier,
                                              )
                                              .mark(activity.id, newStatus)
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 24)),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Línea de estado del día ("MARTES — 5 cumplidas · 🟡 Parcial"), visible
/// solo cuando el día seleccionado es hoy.
class _TodayStatusLine extends StatelessWidget {
  const _TodayStatusLine({
    required this.day,
    required this.stats,
    required this.statusLabel,
  });

  final DayOfWeek day;
  final DayStats stats;
  final (String, String) statusLabel;

  @override
  Widget build(BuildContext context) {
    final (emoji, label) = statusLabel;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        '${day.label.toUpperCase()} — ${stats.done} cumplidas · $emoji $label',
        style: TextStyle(
          color: stats.level.color,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}
