import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/database/db_helper.dart';
import '../core/models/goal.dart';

part 'goals_provider.g.dart';

/// La meta de vida activa (normalmente solo hay una), con sus etapas ya
/// incluidas.
@riverpod
Future<LifeGoal?> activeGoal(Ref ref) async {
  return DbHelper.instance.getActiveGoal();
}

/// Todas las metas de vida registradas (activas, pausadas, completadas...),
/// con sus etapas ya incluidas. Usada por el tab "Metas" de Progreso.
@riverpod
Future<List<LifeGoal>> allGoals(Ref ref) async {
  return DbHelper.instance.getAllGoals();
}

/// Etapas (con tareas y recursos) de una meta concreta.
@riverpod
Future<List<GoalStage>> goalStages(Ref ref, String goalId) async {
  return DbHelper.instance.getStagesForGoal(goalId);
}

/// El plan semanal cuyo lunes es el de la semana actual, si ya existe.
@riverpod
Future<WeeklyPlan?> currentWeekPlan(Ref ref, String goalId) async {
  return DbHelper.instance.getCurrentWeekPlan(goalId);
}

/// Todas las simulaciones de examen registradas para una meta.
@riverpod
Future<List<ExamSimulation>> examSimulations(Ref ref, String goalId) async {
  return DbHelper.instance.getSimulations(goalId);
}

/// Hitos alcanzados de una meta. No está en la lista de providers pedida
/// explícitamente, pero la sección de "Hitos logrados" de la pantalla de
/// Metas no puede construirse sin él.
@riverpod
Future<List<Milestone>> goalMilestones(Ref ref, String goalId) async {
  return DbHelper.instance.getMilestones(goalId);
}
