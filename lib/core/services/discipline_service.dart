import 'dart:math' as math;

import '../models/activity.dart';
import '../models/daily_record.dart';
import '../models/day_progress.dart';

/// El "corazón matemático" de la app: porcentaje del día, nivel de color
/// y el Índice de Disciplina (ID), un puntaje 0-1000 que resume la
/// constancia histórica del usuario.
class DisciplineService {
  const DisciplineService();

  /// Porcentaje del día (0.0 a 1.0), ponderado por [Activity.points]: no
  /// todas las actividades pesan igual, así que no es un simple conteo de
  /// "hechas / total".
  double calculateDayPercentage(
    List<ActivityProgress> progresses,
    List<Activity> activities,
  ) {
    final totalPoints = activities.fold(0, (sum, a) => sum + a.points);
    var earnedPoints = 0;
    for (final p in progresses) {
      if (p.status != ActivityStatus.done) continue;
      for (final activity in activities) {
        if (activity.id == p.activityId) {
          earnedPoints += activity.points;
          break;
        }
      }
    }
    return totalPoints == 0 ? 0 : earnedPoints / totalPoints;
  }

  /// Nivel/color de disciplina correspondiente a un porcentaje del día.
  DisciplineLevel levelForPercentage(double pct) =>
      disciplineLevelForPercentage(pct);

  /// Índice de Disciplina (ID) recalculado "desde cero" a partir de todo
  /// el [history] (ascendente por fecha): un promedio ponderado donde los
  /// días más recientes pesan exponencialmente más que los antiguos, más
  /// un bonus por racha actual (máximo +50).
  ///
  /// Se usa para el arranque en frío (el primer día que se cierra, cuando
  /// todavía no hay un ID previo del cual partir con [idDelta]) o para
  /// recalcular el ID completo si hiciera falta una auditoría.
  double calculateDisciplineIndex(
    List<DailyRecord> history, {
    required int currentStreak,
  }) {
    if (history.isEmpty) return 0;

    var weightedSum = 0.0;
    var weightTotal = 0.0;
    for (var i = 0; i < history.length; i++) {
      // i = 0 es el día más reciente: mayor peso, que decae exponencialmente
      // hacia atrás en el historial (a diferencia de un promedio simple).
      final weight = math.exp(-i * 0.05);
      weightedSum += history[history.length - 1 - i].percentage * weight;
      weightTotal += weight;
    }

    final baseIndex = (weightedSum / weightTotal) * 1000;
    final streakBonus = math.min(currentStreak * 2.0, 50.0);
    return math.min(baseIndex + streakBonus, 1000);
  }

  /// Cuánto cambia el ID hoy según el nivel alcanzado: es el mecanismo
  /// normal de actualización día a día (`nuevoId = idPrevio + idDelta(...)`,
  /// acotado a [0, 1000]) una vez que ya existe un ID previo del cual partir.
  double idDelta(DisciplineLevel level, double currentId) => switch (level) {
    DisciplineLevel.green => currentId < 500 ? 8.0 : 4.0,
    DisciplineLevel.yellow => 1.0,
    DisciplineLevel.red => currentId > 200 ? -6.0 : -2.0,
  };
}
