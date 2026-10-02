import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/models/activity.dart';
import '../../../../providers/stats_provider.dart';

String _formatDuration(Duration d) {
  final hours = d.inHours;
  final minutes = d.inMinutes % 60;
  if (hours == 0) return '${minutes}min';
  if (minutes == 0) return '${hours}h';
  return '${hours}h ${minutes}min';
}

String _pluralWeekday(String label) => switch (label) {
  'Sábado' => 'sábados',
  'Domingo' => 'domingos',
  _ => label.toLowerCase(),
};

/// Tab "Estadísticas": tiempo por categoría, evolución del ID, patrones
/// semanales y actividades más cumplidas/omitidas.
class EstadisticasTab extends ConsumerWidget {
  const EstadisticasTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(categoryTimeLast30DaysProvider);
        ref.invalidate(disciplineIndexLast90DaysProvider);
        ref.invalidate(weekdayAveragesProvider);
        ref.invalidate(topActivitiesProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _SectionTitle('Tiempo por categoría (últimos 30 días)'),
          SizedBox(height: 12),
          _CategoryTimeSection(),
          SizedBox(height: 28),
          _SectionTitle('Evolución del Índice de Disciplina (90 días)'),
          SizedBox(height: 12),
          _IndexEvolutionSection(),
          SizedBox(height: 28),
          _SectionTitle('Patrones semanales'),
          SizedBox(height: 12),
          _WeekdayPatternSection(),
          SizedBox(height: 28),
          _SectionTitle('Actividades más cumplidas / más omitidas'),
          SizedBox(height: 12),
          _TopActivitiesSection(),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: AppColors.textMuted,
        fontWeight: FontWeight.bold,
        fontSize: 12,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _CategoryTimeSection extends ConsumerWidget {
  const _CategoryTimeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalsAsync = ref.watch(categoryTimeLast30DaysProvider);

    return totalsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Text(
        'Error: $err',
        style: const TextStyle(color: AppColors.danger),
      ),
      data: (totals) {
        if (totals.isEmpty) {
          return const Text(
            'Aún no hay actividades marcadas en los últimos 30 días.',
            style: TextStyle(color: AppColors.textMuted),
          );
        }
        final entries = totals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final maxMinutes = entries
            .map((e) => e.value.inMinutes)
            .reduce((a, b) => a > b ? a : b);

        return Column(
          children: [
            for (final entry in entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(entry.key.icon, color: entry.key.color, size: 16),
                    const SizedBox(width: 6),
                    SizedBox(
                      width: 66,
                      child: Text(
                        entry.key.label,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 44,
                      child: Text(
                        _formatDuration(entry.value),
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 18,
                        child: CustomPaint(
                          painter: _HorizontalBarPainter(
                            ratio: entry.value.inMinutes / maxMinutes,
                            color: entry.key.color,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _HorizontalBarPainter extends CustomPainter {
  _HorizontalBarPainter({required this.ratio, required this.color});

  final double ratio;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final trackPaint = Paint()..color = AppColors.surface;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(4),
      ),
      trackPaint,
    );

    final barWidth = size.width * ratio.clamp(0.0, 1.0).toDouble();
    if (barWidth <= 0) return;
    final barPaint = Paint()..color = color;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, barWidth, size.height),
        const Radius.circular(4),
      ),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _HorizontalBarPainter oldDelegate) =>
      oldDelegate.ratio != ratio || oldDelegate.color != color;
}

class _IndexEvolutionSection extends ConsumerWidget {
  const _IndexEvolutionSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pointsAsync = ref.watch(disciplineIndexLast90DaysProvider);

    return pointsAsync.when(
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Text(
        'Error: $err',
        style: const TextStyle(color: AppColors.danger),
      ),
      data: (points) {
        if (points.length < 2) {
          return const Text(
            'Todavía no hay suficiente historial cerrado para graficar la '
            'evolución del ID.',
            style: TextStyle(color: AppColors.textMuted),
          );
        }

        final spots = [
          for (var i = 0; i < points.length; i++)
            FlSpot(i.toDouble(), points[i].indexValue),
        ];

        return SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: 1000,
              minX: 0,
              maxX: (points.length - 1).toDouble(),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: const FlTitlesData(
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              rangeAnnotations: RangeAnnotations(
                horizontalRangeAnnotations: [
                  HorizontalRangeAnnotation(
                    y1: 0,
                    y2: 400,
                    color: AppColors.danger.withValues(alpha: 0.06),
                  ),
                  HorizontalRangeAnnotation(
                    y1: 400,
                    y2: 700,
                    color: AppColors.warning.withValues(alpha: 0.06),
                  ),
                  HorizontalRangeAnnotation(
                    y1: 700,
                    y2: 1000,
                    color: AppColors.success.withValues(alpha: 0.06),
                  ),
                ],
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => AppColors.background,
                  getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
                    final point = points[spot.spotIndex];
                    return LineTooltipItem(
                      '${DateFormat('d MMM', 'es').format(point.date)}\n'
                      '${point.indexValue.round()}',
                      const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 11,
                      ),
                    );
                  }).toList(),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.2,
                  color: AppColors.primary,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    checkToShowDot: (spot, _) =>
                        points[spot.x.toInt()].unlockedAchievement != null,
                    getDotPainter: (spot, percent, bar, index) =>
                        FlDotCirclePainter(
                          radius: 5,
                          color: AppColors.warning,
                          strokeWidth: 2,
                          strokeColor: AppColors.background,
                        ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primary.withValues(alpha: 0.3),
                        AppColors.primary.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WeekdayPatternSection extends ConsumerWidget {
  const _WeekdayPatternSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final averagesAsync = ref.watch(weekdayAveragesProvider);

    return averagesAsync.when(
      loading: () => const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Text(
        'Error: $err',
        style: const TextStyle(color: AppColors.danger),
      ),
      data: (averages) {
        if (averages.isEmpty) {
          return const Text(
            'Aún no hay suficiente historial para ver patrones semanales.',
            style: TextStyle(color: AppColors.textMuted),
          );
        }

        MapEntry<DayOfWeek, double>? weakestOrNull;
        for (final entry in averages.entries) {
          if (weakestOrNull == null || entry.value < weakestOrNull.value) {
            weakestOrNull = entry;
          }
        }
        final weakest = weakestOrNull!;
        final othersAvg =
            averages.entries
                .where((e) => e.key != weakest.key)
                .map((e) => e.value)
                .fold(0.0, (a, b) => a + b) /
            (averages.length - 1).clamp(1, 999);
        final dropPoints = ((othersAvg - weakest.value) * 100).round();

        return Column(
          children: [
            SizedBox(
              height: 160,
              child: BarChart(
                BarChartData(
                  minY: 0,
                  maxY: 100,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => AppColors.background,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                          BarTooltipItem(
                            '${rod.toY.round()}%',
                            const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 11,
                            ),
                          ),
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final day = DayOfWeek.values[value.toInt()];
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              day.label.substring(0, 1),
                              style: TextStyle(
                                color: day == weakest.key
                                    ? AppColors.danger
                                    : AppColors.textMuted,
                                fontSize: 11,
                                fontWeight: day == weakest.key
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    for (final day in DayOfWeek.values)
                      BarChartGroupData(
                        x: day.index,
                        barRods: [
                          BarChartRodData(
                            toY: (averages[day] ?? 0) * 100,
                            color: day == weakest.key
                                ? AppColors.danger
                                : AppColors.primary,
                            width: 18,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            if (dropPoints > 0) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '⚠️ Los ${_pluralWeekday(weakest.key.label)} tu disciplina '
                  'baja un $dropPoints%',
                  style: const TextStyle(
                    color: AppColors.danger,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _TopActivitiesSection extends ConsumerWidget {
  const _TopActivitiesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topAsync = ref.watch(topActivitiesProvider);

    return topAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Text(
        'Error: $err',
        style: const TextStyle(color: AppColors.danger),
      ),
      data: (top) {
        if (top.mostDone.isEmpty && top.mostSkipped.isEmpty) {
          return const Text(
            'Aún no hay suficiente historial.',
            style: TextStyle(color: AppColors.textMuted),
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _TopList(
                title: 'Más cumplidas',
                icon: '✅',
                color: AppColors.success,
                items: top.mostDone,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TopList(
                title: 'Más omitidas',
                icon: '❌',
                color: AppColors.danger,
                items: top.mostSkipped,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TopList extends StatelessWidget {
  const _TopList({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });

  final String title;
  final String icon;
  final Color color;
  final List<(String, int)> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            const Text('—', style: TextStyle(color: AppColors.textMuted))
          else
            for (final (title, count) in items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Text(icon, style: TextStyle(fontSize: 12, color: color)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      '$count',
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
