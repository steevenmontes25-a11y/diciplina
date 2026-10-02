import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/database/db_helper.dart';
import '../core/models/day_progress.dart';

part 'progress_provider.g.dart';

const _dateFormatPattern = 'yyyy-MM-dd';

String _formatDate(DateTime date) =>
    DateFormat(_dateFormatPattern).format(date);

/// Progreso (`activityId -> ActivityProgress`) para una fecha ("yyyy-MM-dd").
@riverpod
class ProgressNotifier extends _$ProgressNotifier {
  @override
  Future<Map<String, ActivityProgress>> build(String date) async {
    final progress = await DbHelper.instance.getProgressForDate(date);
    return {for (final p in progress) p.activityId: p};
  }

  Future<void> mark(String activityId, ActivityStatus status) async {
    await DbHelper.instance.markActivity(date, activityId, status);
    final current = await future;
    state = AsyncData({
      ...current,
      activityId: ActivityProgress(
        activityId: activityId,
        date: date,
        status: status,
        markedAt: DateTime.now(),
      ),
    });

    switch (status) {
      case ActivityStatus.done:
        unawaited(HapticFeedback.mediumImpact());
      case ActivityStatus.skipped:
        unawaited(HapticFeedback.lightImpact());
      case ActivityStatus.pending:
        break;
    }

    // Guarda una foto de las rachas en `preferences`. La fuente de verdad
    // sigue siendo `activity_progress`; esto solo deja un registro accesible
    // sin recalcular, como pide el sistema de rachas.
    unawaited(_persistStreakSnapshot(ref));
  }
}

Future<void> _persistStreakSnapshot(Ref ref) async {
  final db = DbHelper.instance;
  final current = await ref.read(currentStreakProvider.future);
  final longest = await ref.read(longestStreakProvider.future);
  final weeks = await ref.read(weekStreakProvider.future);
  await db.setPreference('current_streak', current.toString());
  await db.setPreference('longest_streak', longest.toString());
  await db.setPreference('week_streak', weeks.toString());
}

/// Estadísticas agregadas (hechas / omitidas / totales) para una fecha.
@riverpod
Future<DayStats> dayStats(Ref ref, String date) async {
  // Se recalcula cada vez que cambian las marcas de actividades del día.
  ref.watch(progressNotifierProvider(date));
  return DbHelper.instance.getDayStats(date);
}

/// Estadísticas agregadas de una semana completa (lunes a domingo), a partir
/// de la fecha ("yyyy-MM-dd") de su lunes.
@riverpod
Future<DayStats> weekStats(Ref ref, String mondayDate) async {
  final monday = DateTime.parse(mondayDate);
  var total = 0;
  var done = 0;
  var skipped = 0;

  for (var i = 0; i < 7; i++) {
    final dateKey = _formatDate(monday.add(Duration(days: i)));
    ref.watch(progressNotifierProvider(dateKey));
    final stats = await DbHelper.instance.getDayStats(dateKey);
    total += stats.total;
    done += stats.done;
    skipped += stats.skipped;
  }

  return DayStats(total: total, done: done, skipped: skipped);
}

/// Porcentaje promedio de actividades cumplidas en los últimos 30 días
/// (incluyendo hoy). Se usa para calcular el Índice de Disciplina global.
@riverpod
Future<double> last30DaysCompletionRate(Ref ref) async {
  ref.watch(progressNotifierProvider(_formatDate(DateTime.now())));

  var totalDone = 0;
  var totalActivities = 0;
  var day = DateTime.now();
  for (var i = 0; i < 30; i++) {
    final stats = await DbHelper.instance.getDayStats(_formatDate(day));
    totalDone += stats.done;
    totalActivities += stats.total;
    day = day.subtract(const Duration(days: 1));
  }

  return totalActivities == 0 ? 0 : totalDone / totalActivities;
}

/// Cuenta los días consecutivos (terminando hoy, hacia atrás) que alcanzaron
/// [DisciplineLevel.green].
@riverpod
Future<int> currentStreak(Ref ref) async {
  // Marcar solo es posible para el día de hoy, así que basta con observar
  // el progreso de hoy para saber cuándo recalcular.
  ref.watch(progressNotifierProvider(_formatDate(DateTime.now())));

  var day = DateTime.now();
  var streak = 0;

  // Límite de seguridad para no recorrer un historial ilimitado.
  for (var i = 0; i < 3650; i++) {
    final stats = await DbHelper.instance.getDayStats(_formatDate(day));
    if (stats.level != DisciplineLevel.green) break;
    streak++;
    day = day.subtract(const Duration(days: 1));
  }

  return streak;
}

/// Récord histórico de días consecutivos en [DisciplineLevel.green], desde
/// el primer registro de progreso guardado hasta hoy.
@riverpod
Future<int> longestStreak(Ref ref) async {
  ref.watch(progressNotifierProvider(_formatDate(DateTime.now())));

  final earliest = await DbHelper.instance.getEarliestProgressDate();
  if (earliest == null) return 0;

  final start = DateTime.parse(earliest);
  final today = DateTime.now();

  var running = 0;
  var longest = 0;
  for (var d = start; !d.isAfter(today); d = d.add(const Duration(days: 1))) {
    final stats = await DbHelper.instance.getDayStats(_formatDate(d));
    if (stats.level == DisciplineLevel.green) {
      running++;
      if (running > longest) longest = running;
    } else {
      running = 0;
    }
  }
  return longest;
}

/// Cuenta las semanas consecutivas (terminando en la semana actual, hacia
/// atrás) cuyo promedio alcanzó [DisciplineLevel.green].
@riverpod
Future<int> weekStreak(Ref ref) async {
  final now = DateTime.now();
  var monday = now.subtract(Duration(days: now.weekday - 1));
  monday = DateTime(monday.year, monday.month, monday.day);

  var streak = 0;
  // Límite de seguridad (~10 años de semanas).
  for (var i = 0; i < 520; i++) {
    final stats = await ref.watch(
      weekStatsProvider(_formatDate(monday)).future,
    );
    if (stats.total == 0 || stats.level != DisciplineLevel.green) break;
    streak++;
    monday = monday.subtract(const Duration(days: 7));
  }
  return streak;
}
