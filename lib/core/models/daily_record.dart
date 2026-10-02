import 'achievement.dart';
import 'day_progress.dart';

/// Registro cerrado de un día: puntos, porcentaje, nivel e Índice de
/// Disciplina en ese momento. Es la fuente de verdad histórica usada por
/// DisciplineService.calculateDisciplineIndex y para graficar evolución.
class DailyRecord {
  const DailyRecord({
    required this.id,
    required this.date,
    required this.totalPoints,
    required this.earnedPoints,
    required this.percentage,
    required this.disciplineLevel,
    required this.disciplineIndex,
    this.mood,
    required this.createdAt,
  });

  final int id;

  /// Fecha en formato "yyyy-MM-dd".
  final String date;
  final int totalPoints;
  final int earnedPoints;
  final double percentage;
  final DisciplineLevel disciplineLevel;
  final double disciplineIndex;
  final String? mood;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'total_points': totalPoints,
      'earned_points': earnedPoints,
      'percentage': percentage,
      'discipline_level': disciplineLevel.name,
      'discipline_index': disciplineIndex,
      'mood': mood,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory DailyRecord.fromMap(Map<String, dynamic> map) {
    return DailyRecord(
      id: map['id'] as int,
      date: map['date'] as String,
      totalPoints: map['total_points'] as int,
      earnedPoints: map['earned_points'] as int,
      percentage: (map['percentage'] as num).toDouble(),
      disciplineLevel: DisciplineLevel.values.byName(
        map['discipline_level'] as String,
      ),
      disciplineIndex: (map['discipline_index'] as num).toDouble(),
      mood: map['mood'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

/// Resultado de cerrar el día vía `DbHelper.closeDayRecord`: todo lo que
/// necesita la pantalla de resumen nocturno para mostrarse.
class DayCloseResult {
  const DayCloseResult({
    required this.date,
    required this.percentage,
    required this.level,
    required this.totalPoints,
    required this.earnedPoints,
    required this.disciplineIndex,
    required this.disciplineIndexDelta,
    required this.currentStreak,
    required this.newlyUnlockedAchievements,
  });

  final String date;
  final double percentage;
  final DisciplineLevel level;
  final int totalPoints;
  final int earnedPoints;
  final double disciplineIndex;

  /// Cuánto cambió el ID respecto al último valor guardado (0 si este es
  /// el primer día registrado).
  final double disciplineIndexDelta;
  final int currentStreak;
  final List<Achievement> newlyUnlockedAchievements;
}
