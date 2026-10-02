import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/colors.dart';
import '../../../core/models/activity.dart';
import '../../../core/models/goal.dart';
import '../../../providers/goals_provider.dart';
import '../../../providers/schedule_provider.dart';

/// Card compacta "Tu meta hoy": resumen de días restantes, en qué enfocarse
/// hoy y el progreso de la etapa actualmente en curso. Se oculta si no hay
/// una meta activa.
class GoalTodayCard extends ConsumerWidget {
  const GoalTodayCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = ref.watch(activeGoalProvider).valueOrNull;
    if (goal == null) return const SizedBox.shrink();

    final stages =
        ref.watch(goalStagesProvider(goal.id)).valueOrNull ?? goal.stages;
    final todayActivities = ref.watch(todayScheduleProvider);

    final inProgressStage = _firstInProgressStage(stages);
    final focusText = _focusText(inProgressStage, todayActivities);
    final daysRemaining = goal.targetDate.difference(DateTime.now()).inDays;
    final place = goal.university.split(' ').last;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(goal.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '$place · $daysRemaining días',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          if (focusText != null) ...[
            const SizedBox(height: 8),
            Text(
              'Enfócate en: $focusText',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
          if (inProgressStage != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: inProgressStage.progress,
                      minHeight: 8,
                      backgroundColor: AppColors.background,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(inProgressStage.progress * 100).round()}% '
                  '${inProgressStage.title}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.go('/metas'),
              child: const Text('Ver roadmap →'),
            ),
          ),
        ],
      ),
    );
  }

  GoalStage? _firstInProgressStage(List<GoalStage> stages) {
    for (final stage in stages) {
      if (stage.status == StageStatus.inProgress) return stage;
    }
    return null;
  }

  /// "La tarea pendiente más antigua de la etapa en progreso" + "la
  /// actividad de estudio/italiano del horario de hoy", si existen.
  String? _focusText(GoalStage? inProgressStage, List<Activity> today) {
    String? oldestPendingTask;
    if (inProgressStage != null) {
      for (final task in inProgressStage.tasks) {
        if (task.status == TaskStatus.pending) {
          oldestPendingTask = task.title;
          break;
        }
      }
    }

    Activity? studyActivity;
    for (final activity in today) {
      if (activity.category == ActivityCategory.estudio ||
          activity.title.toLowerCase().contains('italiano')) {
        studyActivity = activity;
        break;
      }
    }

    final parts = [?oldestPendingTask, ?studyActivity?.title];
    return parts.isEmpty ? null : parts.join(' + ');
  }
}
