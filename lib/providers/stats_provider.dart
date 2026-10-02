import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/constants/schedule_data.dart';
import '../core/database/db_helper.dart';
import '../core/models/achievement.dart';
import '../core/models/activity.dart';
import '../core/models/daily_record.dart';
import '../core/models/day_progress.dart';
import '../core/services/discipline_service.dart';

part 'stats_provider.g.dart';

const DisciplineService _service = DisciplineService();
final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

/// Un día del calendario visual: `level` es `null` cuando no hay ningún
/// dato registrado ese día (antes de que el usuario empezara a usar la app).
class CalendarDay {
  const CalendarDay({
    required this.date,
    this.level,
    this.percentage = 0,
    this.earnedPoints = 0,
    this.totalPoints = 0,
  });

  final DateTime date;
  final DisciplineLevel? level;
  final double percentage;
  final int earnedPoints;
  final int totalPoints;

  bool get hasData => level != null;
}

/// Calcula en vivo (sin depender de que el día ya esté cerrado) el
/// [CalendarDay] de una fecha concreta, a partir de `activity_progress`.
Future<CalendarDay> _liveCalendarDay(DateTime date) async {
  final dateKey = _dateFormat.format(date);
  final activities = getActivitiesForDay(DayOfWeek.values[date.weekday - 1]);
  final progresses = await DbHelper.instance.getProgressForDate(dateKey);
  final totalPoints = activities.fold(0, (sum, a) => sum + a.points);

  if (progresses.isEmpty) {
    return CalendarDay(date: date, totalPoints: totalPoints);
  }

  final percentage = _service.calculateDayPercentage(progresses, activities);
  return CalendarDay(
    date: date,
    level: _service.levelForPercentage(percentage),
    percentage: percentage,
    earnedPoints: (percentage * totalPoints).round(),
    totalPoints: totalPoints,
  );
}

/// Los últimos 365 días (incluyendo hoy), ascendente por fecha, para el
/// calendario visual tipo GitHub.
@riverpod
Future<List<CalendarDay>> calendarDays(Ref ref) async {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final start = today.subtract(const Duration(days: 364));

  final records = await DbHelper.instance.getDailyRecordsBetween(
    _dateFormat.format(start),
    _dateFormat.format(today.subtract(const Duration(days: 1))),
  );
  final byDate = {for (final r in records) r.date: r};

  final days = <CalendarDay>[];
  for (var i = 0; i <= 364; i++) {
    final date = start.add(Duration(days: i));
    if (i == 364) {
      // Hoy: el día no está "cerrado" todavía, se computa en vivo.
      days.add(await _liveCalendarDay(date));
      continue;
    }
    final record = byDate[_dateFormat.format(date)];
    days.add(
      record == null
          ? CalendarDay(date: date)
          : CalendarDay(
              date: date,
              level: record.disciplineLevel,
              percentage: record.percentage,
              earnedPoints: record.earnedPoints,
              totalPoints: record.totalPoints,
            ),
    );
  }
  return days;
}

/// Resumen del año calendario actual: conteo de días por nivel y la mejor
/// racha de días verdes consecutivos de este año.
class YearStats {
  const YearStats({
    required this.green,
    required this.yellow,
    required this.red,
    required this.bestStreak,
  });

  final int green;
  final int yellow;
  final int red;
  final int bestStreak;

  int get totalDays => green + yellow + red;
}

/// Todos los [DailyRecord] del año calendario actual: los ya cerrados más
/// el de hoy, calculado en vivo (hoy nunca está "cerrado" todavía).
Future<List<DailyRecord>> _currentYearRecords() async {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yearStart = DateTime(now.year, 1, 1);
  final lastClosedDay = today.subtract(const Duration(days: 1));

  final records = <DailyRecord>[];
  if (!lastClosedDay.isBefore(yearStart)) {
    records.addAll(
      await DbHelper.instance.getDailyRecordsBetween(
        _dateFormat.format(yearStart),
        _dateFormat.format(lastClosedDay),
      ),
    );
  }

  final liveToday = await _liveCalendarDay(today);
  if (liveToday.hasData) {
    records.add(
      DailyRecord(
        id: 0,
        date: _dateFormat.format(today),
        totalPoints: liveToday.totalPoints,
        earnedPoints: liveToday.earnedPoints,
        percentage: liveToday.percentage,
        disciplineLevel: liveToday.level!,
        disciplineIndex: 0,
        createdAt: today,
      ),
    );
  }
  return records;
}

@riverpod
Future<YearStats> currentYearStats(Ref ref) async {
  final records = await _currentYearRecords();

  var green = 0, yellow = 0, red = 0, current = 0, best = 0;
  for (final r in records) {
    switch (r.disciplineLevel) {
      case DisciplineLevel.green:
        green++;
        current++;
        best = max(best, current);
      case DisciplineLevel.yellow:
        yellow++;
        current = 0;
      case DisciplineLevel.red:
        red++;
        current = 0;
    }
  }
  return YearStats(green: green, yellow: yellow, red: red, bestStreak: best);
}

/// Tiempo invertido por categoría entre [start] y [end] (ambas inclusive),
/// calculado desde las actividades marcadas como hechas en ese rango.
Future<Map<ActivityCategory, Duration>> _categoryTimeBetween(
  String start,
  String end,
) async {
  final doneCounts = await DbHelper.instance.getActivityCountsByStatusBetween(
    ActivityStatus.done,
    start,
    end,
  );
  final totals = <ActivityCategory, Duration>{};
  for (final activity in masterSchedule) {
    final count = doneCounts[activity.id] ?? 0;
    if (count == 0) continue;
    final invested = activity.duration * count;
    totals.update(
      activity.category,
      (existing) => existing + invested,
      ifAbsent: () => invested,
    );
  }
  return totals;
}

/// Tiempo por categoría de los últimos 30 días.
@riverpod
Future<Map<ActivityCategory, Duration>> categoryTimeLast30Days(
  Ref ref,
) async {
  final now = DateTime.now();
  final start = now.subtract(const Duration(days: 29));
  return _categoryTimeBetween(_dateFormat.format(start), _dateFormat.format(now));
}

/// Tiempo por categoría del año calendario actual (para el Wrapped).
@riverpod
Future<Map<ActivityCategory, Duration>> categoryTimeThisYear(Ref ref) async {
  final now = DateTime.now();
  return _categoryTimeBetween('${now.year}-01-01', _dateFormat.format(now));
}

/// Un punto de la evolución del Índice de Disciplina, con si ese día se
/// desbloqueó algún logro (para marcarlo en el gráfico).
class IndexPoint {
  const IndexPoint({
    required this.date,
    required this.indexValue,
    this.unlockedAchievement,
  });

  final DateTime date;
  final double indexValue;
  final Achievement? unlockedAchievement;
}

/// Evolución del ID en los últimos 90 días, con los logros desbloqueados en
/// ese rango marcados en su fecha correspondiente.
@riverpod
Future<List<IndexPoint>> disciplineIndexLast90Days(Ref ref) async {
  final history = await DbHelper.instance.getDisciplineIndexHistory();
  final achievements = await DbHelper.instance.getAllAchievements();

  final cutoff = DateTime.now().subtract(const Duration(days: 90));
  final unlockedByDate = <String, Achievement>{
    for (final a in achievements)
      if (a.unlockedAt != null) _dateFormat.format(a.unlockedAt!): a,
  };

  return history
      .where((h) => DateTime.parse(h.date).isAfter(cutoff))
      .map(
        (h) => IndexPoint(
          date: DateTime.parse(h.date),
          indexValue: h.indexValue,
          unlockedAchievement: unlockedByDate[h.date],
        ),
      )
      .toList();
}

/// Porcentaje promedio de disciplina por día de la semana, considerando
/// todo el historial de días cerrados.
@riverpod
Future<Map<DayOfWeek, double>> weekdayAverages(Ref ref) async {
  final latest = await DbHelper.instance.getLatestDailyRecordDate();
  if (latest == null) return {};

  final earliest = await DbHelper.instance.getEarliestProgressDate();
  final records = await DbHelper.instance.getDailyRecordsBetween(
    earliest ?? latest,
    latest,
  );

  final totals = <DayOfWeek, double>{};
  final counts = <DayOfWeek, int>{};
  for (final record in records) {
    final day = DayOfWeek.values[DateTime.parse(record.date).weekday - 1];
    totals.update(day, (v) => v + record.percentage, ifAbsent: () => record.percentage);
    counts.update(day, (v) => v + 1, ifAbsent: () => 1);
  }

  return {
    for (final day in DayOfWeek.values)
      if (counts[day] != null) day: totals[day]! / counts[day]!,
  };
}

/// Título y conteo de las actividades más cumplidas / más omitidas
/// (top 3 de cada una, considerando todo el historial).
class TopActivities {
  const TopActivities({required this.mostDone, required this.mostSkipped});

  final List<(String title, int count)> mostDone;
  final List<(String title, int count)> mostSkipped;
}

String _titleForActivityId(String id) {
  for (final activity in masterSchedule) {
    if (activity.id == id) return activity.title;
  }
  return id;
}

List<(String, int)> _top3(Map<String, int> counts) {
  final entries = counts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return entries
      .take(3)
      .map((e) => (_titleForActivityId(e.key), e.value))
      .toList();
}

@riverpod
Future<TopActivities> topActivities(Ref ref) async {
  final done = await DbHelper.instance.getActivityCountsByStatus(
    ActivityStatus.done,
  );
  final skipped = await DbHelper.instance.getActivityCountsByStatus(
    ActivityStatus.skipped,
  );
  return TopActivities(mostDone: _top3(done), mostSkipped: _top3(skipped));
}

/// El logro bloqueado más cerca de desbloquearse, con su progreso actual
/// (0.0 a 1.0) y el valor legible ("12/30 días").
class NextAchievementProgress {
  const NextAchievementProgress({
    required this.achievement,
    required this.currentValue,
    required this.progress,
  });

  final Achievement achievement;
  final int currentValue;
  final double progress;
}

@riverpod
Future<List<Achievement>> allAchievements(Ref ref) async {
  return DbHelper.instance.getAllAchievements();
}

@riverpod
Future<NextAchievementProgress?> nextAchievementProgress(Ref ref) async {
  final achievements = await ref.watch(allAchievementsProvider.future);
  final locked = achievements.where((a) => !a.isUnlocked).toList();
  if (locked.isEmpty) return null;

  final currentStreak = await _currentGreenStreak();
  final currentIndex = await DbHelper.instance.getLatestDisciplineIndex();
  final doneCount = (await DbHelper.instance.getActivityCountsByStatus(
    ActivityStatus.done,
  )).values.fold(0, (sum, c) => sum + c);
  final greenDays = (await ref.watch(currentYearStatsProvider.future)).green;

  int valueFor(Achievement a) => switch (a.type) {
    AchievementType.streak => currentStreak,
    AchievementType.disciplineIndex => currentIndex.round(),
    AchievementType.activitiesDoneCount => doneCount,
    AchievementType.greenDaysCount => greenDays,
    AchievementType.italianB1 => 0,
    AchievementType.examScore => 0,
    AchievementType.goalCreated => 0,
    AchievementType.stageCompleted => 0,
  };

  NextAchievementProgress? best;
  for (final a in locked) {
    final value = valueFor(a);
    if (a.targetValue <= 0) continue;
    final progress = (value / a.targetValue).clamp(0.0, 1.0).toDouble();
    if (best == null || progress > best.progress) {
      best = NextAchievementProgress(
        achievement: a,
        currentValue: value,
        progress: progress,
      );
    }
  }
  return best;
}

Future<int> _currentGreenStreak() async {
  final latest = await DbHelper.instance.getLatestDailyRecordDate();
  if (latest == null) return 0;
  final earliest = await DbHelper.instance.getEarliestProgressDate() ?? latest;
  final records = await DbHelper.instance.getDailyRecordsBetween(earliest, latest);
  var streak = 0;
  for (var i = records.length - 1; i >= 0; i--) {
    if (records[i].disciplineLevel != DisciplineLevel.green) break;
    streak++;
  }
  return streak;
}

/// Racha verde más larga del año, con sus fechas de inicio y fin (para el
/// Wrapped: "Del 3 al 21 de marzo").
class BestStreakRange {
  const BestStreakRange({
    required this.length,
    required this.start,
    required this.end,
  });

  final int length;
  final DateTime? start;
  final DateTime? end;
}

@riverpod
Future<BestStreakRange> bestStreakRangeThisYear(Ref ref) async {
  final records = await _currentYearRecords();

  var bestLen = 0;
  DateTime? bestStart, bestEnd;
  DateTime? runStart;
  var runLen = 0;
  for (final r in records) {
    if (r.disciplineLevel == DisciplineLevel.green) {
      final date = DateTime.parse(r.date);
      runStart ??= date;
      runLen++;
      if (runLen > bestLen) {
        bestLen = runLen;
        bestStart = runStart;
        bestEnd = date;
      }
    } else {
      runStart = null;
      runLen = 0;
    }
  }
  return BestStreakRange(length: bestLen, start: bestStart, end: bestEnd);
}

/// Todo lo que necesita el Wrapped anual. `null` si todavía no hay al menos
/// 30 días de datos este año.
class WrappedData {
  const WrappedData({
    required this.year,
    required this.averagePercentage,
    required this.yearStats,
    required this.categoryTime,
    required this.bestStreak,
    required this.achievementsUnlockedCount,
    required this.achievementEmojis,
  });

  final int year;
  final double averagePercentage;
  final YearStats yearStats;
  final Map<ActivityCategory, Duration> categoryTime;
  final BestStreakRange bestStreak;
  final int achievementsUnlockedCount;
  final List<String> achievementEmojis;

  double get totalHours =>
      categoryTime.values.fold(Duration.zero, (a, b) => a + b).inMinutes / 60;
}

@riverpod
Future<WrappedData?> wrappedData(Ref ref) async {
  final yearStats = await ref.watch(currentYearStatsProvider.future);
  if (yearStats.totalDays < 30) return null;

  final records = await _currentYearRecords();
  final averagePercentage = records.isEmpty
      ? 0.0
      : records.map((r) => r.percentage).reduce((a, b) => a + b) /
            records.length;

  final categoryTime = await ref.watch(categoryTimeThisYearProvider.future);
  final bestStreak = await ref.watch(bestStreakRangeThisYearProvider.future);
  final achievements = await ref.watch(allAchievementsProvider.future);
  final unlocked = achievements.where((a) => a.isUnlocked).toList();

  return WrappedData(
    year: DateTime.now().year,
    averagePercentage: averagePercentage,
    yearStats: yearStats,
    categoryTime: categoryTime,
    bestStreak: bestStreak,
    achievementsUnlockedCount: unlocked.length,
    achievementEmojis: unlocked.map((a) => a.emoji).toList(),
  );
}
