import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/colors.dart';
import '../../../core/models/day_progress.dart';
import '../../../providers/historial_provider.dart';
import '../../../providers/progress_provider.dart';

String _capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// Número de semana ISO-8601 del año para [date].
int _isoWeekNumber(DateTime date) {
  final thursday = date.add(Duration(days: 3 - ((date.weekday + 6) % 7)));
  final firstDayOfYear = DateTime(thursday.year, 1, 1);
  final diff = thursday.difference(firstDayOfYear).inDays;
  return 1 + (diff / 7).floor();
}

String _weekLabel(DateTime monday) {
  final weekNum = _isoWeekNumber(monday);
  final monthLabel = _capitalize(
    DateFormat('MMM', 'es').format(monday).replaceAll('.', ''),
  );
  return 'Semana $weekNum · $monthLabel ${monday.year}';
}

/// Tab "Disciplina" de Progreso: estadísticas globales, rachas y desglose
/// semanal del cumplimiento del horario (el antiguo Historial).
class DisciplinaTab extends ConsumerWidget {
  const DisciplinaTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(historialDataProvider);
    final currentStreak = ref.watch(currentStreakProvider).valueOrNull ?? 0;
    final longestStreak = ref.watch(longestStreakProvider).valueOrNull ?? 0;
    final weekStreak = ref.watch(weekStreakProvider).valueOrNull ?? 0;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(historialDataProvider);
        ref.invalidate(currentStreakProvider);
        ref.invalidate(longestStreakProvider);
        ref.invalidate(weekStreakProvider);
      },
      child: dataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Error al cargar el historial: $err',
                style: const TextStyle(color: AppColors.danger),
              ),
            ),
          ],
        ),
        data: (data) {
          if (data.weeks.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 140),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Aún no hay historial. ¡Marca tu primera actividad en "Hoy"!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              ],
            );
          }

          final best = data.bestWeek!;

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              _GlobalStatsHeader(
                totalWeeks: data.totalWeeks,
                bestWeekPercentage: best.stats.percentage,
                bestWeekLabel: _weekLabel(best.monday),
                mostCompletedTitle: data.mostCompletedTitle,
                mostCompletedCount: data.mostCompletedCount,
                mostSkippedTitle: data.mostSkippedTitle,
                mostSkippedCount: data.mostSkippedCount,
                currentStreak: currentStreak,
                longestStreak: longestStreak,
                weekStreak: weekStreak,
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Semanas',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...data.weeks.map((week) => _WeekTile(week: week)),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}

class _GlobalStatsHeader extends StatelessWidget {
  const _GlobalStatsHeader({
    required this.totalWeeks,
    required this.bestWeekPercentage,
    required this.bestWeekLabel,
    required this.mostCompletedTitle,
    required this.mostCompletedCount,
    required this.mostSkippedTitle,
    required this.mostSkippedCount,
    required this.currentStreak,
    required this.longestStreak,
    required this.weekStreak,
  });

  final int totalWeeks;
  final double bestWeekPercentage;
  final String bestWeekLabel;
  final String? mostCompletedTitle;
  final int mostCompletedCount;
  final String? mostSkippedTitle;
  final int mostSkippedCount;
  final int currentStreak;
  final int longestStreak;
  final int weekStreak;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.calendar_month_outlined,
                  label: 'Semanas registradas',
                  value: '$totalWeeks',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  icon: Icons.emoji_events_outlined,
                  label: 'Mejor semana',
                  value: '${(bestWeekPercentage * 100).round()}%',
                  subtitle: bestWeekLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.local_fire_department_outlined,
                  label: 'Racha actual',
                  value: '$currentStreak días',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  icon: Icons.military_tech_outlined,
                  label: 'Récord histórico',
                  value: '$longestStreak días',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _StatTile(
            icon: Icons.auto_awesome_outlined,
            label: 'Semanas verdes seguidas',
            value: '$weekStreak',
          ),
          if (mostCompletedTitle != null) ...[
            const SizedBox(height: 10),
            _StatTile(
              icon: Icons.check_circle_outline,
              label: 'Actividad más cumplida',
              value: mostCompletedTitle!,
              subtitle: '$mostCompletedCount veces',
            ),
          ],
          if (mostSkippedTitle != null) ...[
            const SizedBox(height: 10),
            _StatTile(
              icon: Icons.cancel_outlined,
              label: 'Actividad más fallida',
              value: mostSkippedTitle!,
              subtitle: '$mostSkippedCount veces',
            ),
          ],
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
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

class _WeekTile extends StatelessWidget {
  const _WeekTile({required this.week});

  final WeekSummary week;

  @override
  Widget build(BuildContext context) {
    final level = week.stats.level;
    final emoji = switch (level) {
      DisciplineLevel.green => '🟢',
      DisciplineLevel.yellow => '🟡',
      DisciplineLevel.red => '🔴',
    };

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedIconColor: AppColors.textMuted,
          iconColor: AppColors.textMuted,
          title: Text(
            _weekLabel(week.monday),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: week.stats.percentage,
                      minHeight: 6,
                      backgroundColor: AppColors.background,
                      color: level.color,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${(week.stats.percentage * 100).round()}%',
                  style: TextStyle(
                    color: level.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: level.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 14)),
          ),
          children: [
            for (var i = 0; i < 7; i++)
              _DayBreakdownRow(date: week.monday.add(Duration(days: i))),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _DayBreakdownRow extends ConsumerWidget {
  const _DayBreakdownRow({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    final statsAsync = ref.watch(dayStatsProvider(dateKey));
    final label = _capitalize(DateFormat('EEEE', 'es').format(date));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: statsAsync.when(
              loading: () => const LinearProgressIndicator(minHeight: 4),
              error: (_, _) => const SizedBox.shrink(),
              data: (stats) {
                final level = stats.level;
                return Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: stats.percentage,
                          minHeight: 4,
                          backgroundColor: AppColors.background,
                          color: level.color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${stats.done}/${stats.total}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
