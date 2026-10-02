import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/models/goal.dart';
import '../core/services/claude_service.dart';
import '../features/metas/widgets/stage_card.dart' show italianStageId;
import 'goals_provider.dart';
import 'historial_provider.dart';
import 'progress_provider.dart';

part 'mentor_provider.g.dart';

const List<String> _italianLevels = ['A1', 'A2', 'B1', 'B2'];

/// Nombre que el usuario configuró para sí mismo en Ajustes del Mentor.
const String mentorUserNamePrefKey = 'mentor_user_name';

/// Nivel de italiano actual (el primero cuya tarea aún no está hecha, o el
/// último si ya se completaron todos), calculado igual que en
/// [ItalianLevelsExpanded].
String _italianLevelFor(List<GoalStage> stages) {
  GoalStage? italianStage;
  for (final s in stages) {
    if (s.id == italianStageId) {
      italianStage = s;
      break;
    }
  }
  if (italianStage == null) return 'No iniciado';

  final taskByLevel = <String, StageTask>{};
  for (final level in _italianLevels) {
    final match = italianStage.tasks.where(
      (t) => t.title.contains('Nivel $level'),
    );
    if (match.isNotEmpty) taskByLevel[level] = match.first;
  }

  final current = _italianLevels.firstWhere(
    (level) => taskByLevel[level]?.status != TaskStatus.done,
    orElse: () => _italianLevels.last,
  );
  return current;
}

/// Arma el [MentorContext] con datos reales de la meta activa para el
/// Mentor IA (usado tanto en el análisis proactivo como en el chat).
@riverpod
Future<MentorContext> mentorContext(Ref ref, String goalId) async {
  final goal = await ref.watch(activeGoalProvider.future);
  final stages = await ref.watch(goalStagesProvider(goalId).future);
  final simulations = await ref.watch(examSimulationsProvider(goalId).future);
  final historial = await ref.watch(historialDataProvider.future);

  final now = DateTime.now();
  final targetDate = goal?.targetDate ?? now;
  final daysRemaining = targetDate.difference(now).inDays;

  final monday = DateTime(
    now.year,
    now.month,
    now.day,
  ).subtract(Duration(days: now.weekday - 1));
  final weekStats = await ref.watch(
    weekStatsProvider(DateFormat('yyyy-MM-dd').format(monday)).future,
  );
  final currentStreak = await ref.watch(currentStreakProvider.future);

  final sortedSims = [...simulations]..sort((a, b) => a.date.compareTo(b.date));
  final tolcAverage = sortedSims.isEmpty
      ? 0.0
      : sortedSims.map((s) => s.score).reduce((a, b) => a + b) /
            sortedSims.length;
  final weakTopics = sortedSims.isNotEmpty
      ? sortedSims.last.weakTopics
      : const <String>[];

  final stagesJson = jsonEncode(
    stages
        .map(
          (s) => {
            'title': s.title,
            'status': s.status.name,
            'progress': (s.progress * 100).round(),
          },
        )
        .toList(),
  );

  final prefs = await SharedPreferences.getInstance();
  final userName = prefs.getString(mentorUserNamePrefKey) ?? 'tú';

  return MentorContext(
    userName: userName,
    career: goal?.career ?? '',
    university: goal?.university ?? '',
    country: goal?.country ?? '',
    targetDate: targetDate,
    daysRemaining: daysRemaining,
    stagesJson: stagesJson,
    weekDisciplinePercent: (weekStats.percentage * 100).round(),
    currentStreak: currentStreak,
    mostSkippedActivities: historial.mostSkippedTitle != null
        ? [historial.mostSkippedTitle!]
        : const [],
    tolcSimulationsDone: sortedSims.length,
    tolcAverage: tolcAverage,
    weakTopics: weakTopics,
    italianLevel: _italianLevelFor(stages),
  );
}
