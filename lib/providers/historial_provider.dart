import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/constants/schedule_data.dart';
import '../core/database/db_helper.dart';
import '../core/models/day_progress.dart';
import 'progress_provider.dart';

part 'historial_provider.g.dart';

/// Resumen de una semana (lunes) ya calculado.
class WeekSummary {
  const WeekSummary({required this.monday, required this.stats});

  final DateTime monday;
  final DayStats stats;
}

/// Datos agregados para la pantalla de historial.
class HistorialData {
  const HistorialData({
    required this.weeks,
    required this.mostCompletedTitle,
    required this.mostCompletedCount,
    required this.mostSkippedTitle,
    required this.mostSkippedCount,
  });

  /// Semanas ordenadas de la más reciente a la más antigua.
  final List<WeekSummary> weeks;
  final String? mostCompletedTitle;
  final int mostCompletedCount;
  final String? mostSkippedTitle;
  final int mostSkippedCount;

  int get totalWeeks => weeks.length;

  WeekSummary? get bestWeek {
    if (weeks.isEmpty) return null;
    return weeks.reduce(
      (a, b) => a.stats.percentage >= b.stats.percentage ? a : b,
    );
  }
}

String? _titleForActivityId(String? id) {
  if (id == null) return null;
  for (final activity in masterSchedule) {
    if (activity.id == id) return activity.title;
  }
  return id;
}

/// Datos globales de historial: una fila por cada semana desde la primera
/// vez que se marcó una actividad, más las actividades más cumplida/fallida.
@riverpod
Future<HistorialData> historialData(Ref ref) async {
  final db = DbHelper.instance;
  final earliest = await db.getEarliestProgressDate();

  if (earliest == null) {
    return const HistorialData(
      weeks: [],
      mostCompletedTitle: null,
      mostCompletedCount: 0,
      mostSkippedTitle: null,
      mostSkippedCount: 0,
    );
  }

  final earliestDate = DateTime.parse(earliest);
  final firstMonday = DateTime(
    earliestDate.year,
    earliestDate.month,
    earliestDate.day,
  ).subtract(Duration(days: earliestDate.weekday - 1));

  final now = DateTime.now();
  final currentMonday = DateTime(
    now.year,
    now.month,
    now.day,
  ).subtract(Duration(days: now.weekday - 1));

  final dateFormat = DateFormat('yyyy-MM-dd');
  final weeks = <WeekSummary>[];
  for (
    var monday = firstMonday;
    !monday.isAfter(currentMonday);
    monday = monday.add(const Duration(days: 7))
  ) {
    final stats = await ref.watch(
      weekStatsProvider(dateFormat.format(monday)).future,
    );
    weeks.add(WeekSummary(monday: monday, stats: stats));
  }

  final doneCounts = await db.getActivityCountsByStatus(ActivityStatus.done);
  final skippedCounts = await db.getActivityCountsByStatus(
    ActivityStatus.skipped,
  );

  String? mostCompletedId;
  var mostCompletedCount = 0;
  doneCounts.forEach((id, count) {
    if (count > mostCompletedCount) {
      mostCompletedCount = count;
      mostCompletedId = id;
    }
  });

  String? mostSkippedId;
  var mostSkippedCount = 0;
  skippedCounts.forEach((id, count) {
    if (count > mostSkippedCount) {
      mostSkippedCount = count;
      mostSkippedId = id;
    }
  });

  return HistorialData(
    weeks: weeks.reversed.toList(),
    mostCompletedTitle: _titleForActivityId(mostCompletedId),
    mostCompletedCount: mostCompletedCount,
    mostSkippedTitle: _titleForActivityId(mostSkippedId),
    mostSkippedCount: mostSkippedCount,
  );
}
