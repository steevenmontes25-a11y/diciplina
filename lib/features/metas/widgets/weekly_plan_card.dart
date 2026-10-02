import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/colors.dart';
import '../../../core/database/db_helper.dart';
import '../../../core/models/goal.dart';
import '../../../providers/goals_provider.dart';

/// Tarjeta con el plan de la semana actual: checklist de tareas y una barra
/// de progreso.
class WeeklyPlanCard extends ConsumerWidget {
  const WeeklyPlanCard({super.key, required this.goalId, required this.plan});

  final String goalId;
  final WeeklyPlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = plan.tasks.length;
    final done = plan.tasks.where((t) => t.isDone).length;
    final progress = total == 0 ? 0.0 : done / total;

    final weekStart = plan.weekStart;
    final weekEnd = weekStart.add(const Duration(days: 6));
    final dateFormat = DateFormat('MMM d', 'es');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📅 Plan Semana ${plan.weekNumber}  ·  '
            '${dateFormat.format(weekStart)} – ${dateFormat.format(weekEnd)}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          for (final task in plan.tasks)
            _WeeklyTaskRow(
              task: task,
              onChanged: (value) async {
                await DbHelper.instance.toggleWeeklyTask(task.id, value);
                ref.invalidate(currentWeekPlanProvider(goalId));
              },
            ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: const Color(0xFF2A2D3E),
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}

class _WeeklyTaskRow extends StatelessWidget {
  const _WeeklyTaskRow({required this.task, required this.onChanged});

  final WeeklyTask task;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!task.isDone),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Checkbox(
              value: task.isDone,
              activeColor: AppColors.primary,
              onChanged: (value) => onChanged(value ?? false),
            ),
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  color: task.isDone
                      ? AppColors.textMuted
                      : AppColors.textPrimary,
                  decoration: task.isDone ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
