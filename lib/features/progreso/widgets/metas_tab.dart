import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/colors.dart';
import '../../../core/models/goal.dart';
import '../../../providers/goals_provider.dart';

/// Tab "Metas" de Progreso: una card por [LifeGoal] con su progreso general,
/// días invertidos, desglose de etapas y velocidad de avance.
class MetasTab extends ConsumerWidget {
  const MetasTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(allGoalsProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(allGoalsProvider),
      child: goalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Error al cargar tus metas: $err',
                style: const TextStyle(color: AppColors.danger),
              ),
            ),
          ],
        ),
        data: (goals) {
          if (goals.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 140),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Todavía no tienes ninguna meta registrada.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              ],
            );
          }

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [for (final goal in goals) _GoalProgressCard(goal: goal)],
          );
        },
      ),
    );
  }
}

class _GoalProgressCard extends StatelessWidget {
  const _GoalProgressCard({required this.goal});

  final LifeGoal goal;

  @override
  Widget build(BuildContext context) {
    final stages = goal.stages;
    final overallProgress = stages.isEmpty
        ? 0.0
        : stages.map((s) => s.progress).reduce((a, b) => a + b) / stages.length;

    final completedStages = stages
        .where((s) => s.status == StageStatus.completed)
        .length;
    final pendingStages = stages.length - completedStages;

    final now = DateTime.now();
    final daysInvested = math.max(0, now.difference(goal.createdAt).inDays);
    final weeksElapsed = math.max(
      1.0,
      now.difference(goal.createdAt).inDays / 7,
    );
    final completedTasks = stages
        .expand((s) => s.tasks)
        .where((t) => t.status == TaskStatus.done)
        .length;
    final velocity = completedTasks / weeksElapsed;

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
          Row(
            children: [
              Text(goal.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  goal.title,
                  maxLines: 2,
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
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: overallProgress,
                    minHeight: 8,
                    backgroundColor: AppColors.background,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(overallProgress * 100).round()}%',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'Días invertidos',
                  value: '$daysInvested',
                ),
              ),
              Expanded(
                child: _MiniStat(
                  label: 'Etapas completas',
                  value: '$completedStages/${stages.length}',
                  subtitle: '$pendingStages pendientes',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.speed_outlined,
                color: AppColors.textMuted,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                '${velocity.toStringAsFixed(1)} tareas/semana promedio',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value, this.subtitle});

  final String label;
  final String value;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
      ],
    );
  }
}
