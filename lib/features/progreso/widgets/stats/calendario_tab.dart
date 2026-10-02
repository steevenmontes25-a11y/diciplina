import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/schedule_data.dart';
import '../../../../core/database/db_helper.dart';
import '../../../../core/models/activity.dart';
import '../../../../core/models/day_progress.dart';
import '../../../../providers/stats_provider.dart';

String _capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

const double _cellSize = 12;
const double _gap = 2;
const double _step = _cellSize + _gap;
const double _monthLabelHeight = 18;

Color _colorForLevel(DisciplineLevel? level) => switch (level) {
  DisciplineLevel.green => const Color(0xFF22C55E),
  DisciplineLevel.yellow => const Color(0xFFEAB308),
  DisciplineLevel.red => const Color(0xFFEF4444),
  null => const Color(0xFF2A2D3E),
};

/// Tab "Calendario": grid tipo GitHub contribution graph (semanas en
/// columnas, días L-D en filas) de los últimos 12 meses.
class CalendarioTab extends ConsumerWidget {
  const CalendarioTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daysAsync = ref.watch(calendarDaysProvider);
    final yearStatsAsync = ref.watch(currentYearStatsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(calendarDaysProvider);
        ref.invalidate(currentYearStatsProvider);
      },
      child: daysAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Error al cargar el calendario: $err',
                style: const TextStyle(color: AppColors.danger),
              ),
            ),
          ],
        ),
        data: (days) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              yearStatsAsync.when(
                loading: () => const SizedBox(
                  height: 60,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, _) => const SizedBox.shrink(),
                data: (stats) => _YearStatsHeader(stats: stats),
              ),
              const SizedBox(height: 20),
              _CalendarGrid(
                days: days,
                onTapDay: (day) => _showDayDetail(context, day),
              ),
              const SizedBox(height: 12),
              const _Legend(),
            ],
          );
        },
      ),
    );
  }

  void _showDayDetail(BuildContext context, CalendarDay day) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _DayDetailSheet(day: day),
    );
  }
}

class _YearStatsHeader extends StatelessWidget {
  const _YearStatsHeader({required this.stats});

  final YearStats stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🟢 ${stats.green} días verdes · 🟡 ${stats.yellow} amarillos · '
          '🔴 ${stats.red} rojos',
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          'Mejor racha: 🔥 ${stats.bestStreak} días',
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    Widget swatch(Color color, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
        ),
      ],
    );

    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        swatch(_colorForLevel(DisciplineLevel.green), 'Verde'),
        swatch(_colorForLevel(DisciplineLevel.yellow), 'Amarillo'),
        swatch(_colorForLevel(DisciplineLevel.red), 'Rojo'),
        swatch(_colorForLevel(null), 'Sin dato'),
      ],
    );
  }
}

class _CalendarGrid extends StatefulWidget {
  const _CalendarGrid({required this.days, required this.onTapDay});

  final List<CalendarDay> days;
  final ValueChanged<CalendarDay> onTapDay;

  @override
  State<_CalendarGrid> createState() => _CalendarGridState();
}

class _CalendarGridState extends State<_CalendarGrid> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.days.isEmpty) return const SizedBox.shrink();

    final start = widget.days.first.date;
    final today = widget.days.last.date;
    final firstMonday = start.subtract(Duration(days: start.weekday - 1));
    final totalColumns =
        (today.difference(firstMonday).inDays / 7).ceil() + 1;
    final byOffset = {
      for (final d in widget.days) d.date.difference(firstMonday).inDays: d,
    };

    return SizedBox(
      height: _monthLabelHeight + 7 * _step,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _DayLabelsColumn(),
          const SizedBox(width: 6),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: GestureDetector(
                onTapUp: (details) {
                  final col = (details.localPosition.dx / _step).floor();
                  final row =
                      ((details.localPosition.dy - _monthLabelHeight) / _step)
                          .floor();
                  if (row < 0 || row > 6) return;
                  final day = byOffset[col * 7 + row];
                  if (day != null) widget.onTapDay(day);
                },
                child: CustomPaint(
                  size: Size(totalColumns * _step, _monthLabelHeight + 7 * _step),
                  painter: _CalendarPainter(
                    days: widget.days,
                    firstMonday: firstMonday,
                    totalColumns: totalColumns,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayLabelsColumn extends StatelessWidget {
  const _DayLabelsColumn();

  static const _labels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: _monthLabelHeight),
        for (final label in _labels)
          SizedBox(
            height: _step,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 9),
            ),
          ),
      ],
    );
  }
}

class _CalendarPainter extends CustomPainter {
  _CalendarPainter({
    required this.days,
    required this.firstMonday,
    required this.totalColumns,
  });

  final List<CalendarDay> days;
  final DateTime firstMonday;
  final int totalColumns;

  @override
  void paint(Canvas canvas, Size size) {
    for (final day in days) {
      final offset = day.date.difference(firstMonday).inDays;
      final col = offset ~/ 7;
      final row = offset % 7;
      final rect = Rect.fromLTWH(
        col * _step,
        _monthLabelHeight + row * _step,
        _cellSize,
        _cellSize,
      );
      final paint = Paint()..color = _colorForLevel(day.level);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        paint,
      );
    }

    String? lastMonthLabel;
    for (var col = 0; col < totalColumns; col++) {
      final weekMonday = firstMonday.add(Duration(days: col * 7));
      final label = _capitalize(
        DateFormat('MMM', 'es').format(weekMonday).replaceAll('.', ''),
      );
      if (label == lastMonthLabel) continue;
      lastMonthLabel = label;

      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(col * _step, 0));
    }
  }

  @override
  bool shouldRepaint(covariant _CalendarPainter oldDelegate) =>
      oldDelegate.days != days;
}

class _DayDetailSheet extends StatefulWidget {
  const _DayDetailSheet({required this.day});

  final CalendarDay day;

  @override
  State<_DayDetailSheet> createState() => _DayDetailSheetState();
}

class _DayDetailSheetState extends State<_DayDetailSheet> {
  List<ActivityProgress>? _progresses;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final dateKey = DateFormat('yyyy-MM-dd').format(widget.day.date);
    final progresses = await DbHelper.instance.getProgressForDate(dateKey);
    if (!mounted) return;
    setState(() => _progresses = progresses);
  }

  @override
  Widget build(BuildContext context) {
    final day = widget.day;
    final activities = getActivitiesForDay(
      DayOfWeek.values[day.date.weekday - 1],
    );
    final progresses = _progresses;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _capitalize(
              DateFormat("EEEE, d 'de' MMMM 'de' y", 'es').format(day.date),
            ),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (!day.hasData)
            const Text(
              'Sin datos registrados este día.',
              style: TextStyle(color: AppColors.textMuted),
            )
          else ...[
            Row(
              children: [
                Text(
                  '${(day.percentage * 100).round()}%',
                  style: TextStyle(
                    color: _colorForLevel(day.level),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${day.earnedPoints} / ${day.totalPoints} pts',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (progresses == null)
              const Center(child: CircularProgressIndicator())
            else
              for (final activity in activities)
                _ActivityLine(
                  activity: activity,
                  status: _statusFor(progresses, activity.id),
                ),
          ],
        ],
      ),
    );
  }

  ActivityStatus _statusFor(List<ActivityProgress> progresses, String id) {
    for (final p in progresses) {
      if (p.activityId == id) return p.status;
    }
    return ActivityStatus.pending;
  }
}

class _ActivityLine extends StatelessWidget {
  const _ActivityLine({required this.activity, required this.status});

  final Activity activity;
  final ActivityStatus status;

  @override
  Widget build(BuildContext context) {
    final icon = switch (status) {
      ActivityStatus.done => '✅',
      ActivityStatus.skipped => '❌',
      ActivityStatus.pending => '➖',
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              activity.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
