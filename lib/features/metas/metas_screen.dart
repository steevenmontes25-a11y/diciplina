import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/colors.dart';
import '../../core/models/goal.dart';
import '../../providers/goals_provider.dart';
import 'widgets/dream_header.dart';
import 'widgets/milestones_timeline.dart';
import 'widgets/stage_card.dart';
import 'widgets/tolc_simulations_card.dart';
import 'widgets/weekly_plan_card.dart';

/// Id de la etapa de matemáticas: sus tareas alimentan el pool de "temas
/// fallados" del formulario de simulaciones TOLC-I.
const String _mathStageId = 'bologna_stage_1';

/// Pantalla de Metas (Roadmaps): el sueño, sus etapas, el plan semanal, las
/// simulaciones TOLC-I y los hitos logrados.
class MetasScreen extends ConsumerWidget {
  const MetasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalAsync = ref.watch(activeGoalProvider);
    final goal = goalAsync.valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'Metas',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          if (goal != null)
            TextButton(
              onPressed: () => context.push('/metas/dream', extra: goal),
              child: const Text('🌟 Mi Sueño'),
            ),
        ],
      ),
      floatingActionButton: goal == null
          ? null
          : FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              onPressed: () => context.push('/mentor?goalId=${goal.id}'),
              icon: const Text('🧠', style: TextStyle(fontSize: 18)),
              label: const Text('Consultar Mentor'),
            ),
      body: SafeArea(
        child: goalAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Text(
              'Error al cargar la meta: $err',
              style: const TextStyle(color: AppColors.danger),
            ),
          ),
          data: (goal) {
            if (goal == null) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Todavía no tienes una meta activa.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              );
            }
            return _MetasContent(goal: goal);
          },
        ),
      ),
    );
  }
}

class _MetasContent extends ConsumerWidget {
  const _MetasContent({required this.goal});

  final LifeGoal goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stagesAsync = ref.watch(goalStagesProvider(goal.id));
    final weekPlanAsync = ref.watch(currentWeekPlanProvider(goal.id));
    final simsAsync = ref.watch(examSimulationsProvider(goal.id));
    final milestonesAsync = ref.watch(goalMilestonesProvider(goal.id));

    // Las etapas ya vienen embebidas en `goal` (getActiveGoal las trae), así
    // que se usan como respaldo mientras goalStagesProvider carga o si falla.
    final stages = stagesAsync.valueOrNull ?? goal.stages;
    final overallProgress = stages.isEmpty
        ? 0.0
        : stages.map((s) => s.progress).reduce((a, b) => a + b) / stages.length;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(activeGoalProvider);
        ref.invalidate(goalStagesProvider(goal.id));
        ref.invalidate(currentWeekPlanProvider(goal.id));
        ref.invalidate(examSimulationsProvider(goal.id));
        ref.invalidate(goalMilestonesProvider(goal.id));
      },
      child: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DreamHeader(goal: goal, overallProgress: overallProgress),
          ),
          const SizedBox(height: 8),
          for (final stage in stages)
            StageCard(
              stage: stage,
              onViewMore: () =>
                  context.push('/metas/stage/${stage.id}', extra: stage),
            ),
          const SizedBox(height: 8),
          weekPlanAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => const SizedBox.shrink(),
            data: (plan) => plan == null
                ? const SizedBox.shrink()
                : WeeklyPlanCard(goalId: goal.id, plan: plan),
          ),
          simsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => const SizedBox.shrink(),
            data: (sims) => TolcSimulationsCard(
              goalId: goal.id,
              simulations: sims,
              topicPool: _mathTopicPool(stages),
            ),
          ),
          milestonesAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (milestones) {
              if (milestones.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Hitos logrados',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    MilestonesTimeline(milestones: milestones),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<String> _mathTopicPool(List<GoalStage> stages) {
    for (final stage in stages) {
      if (stage.id == _mathStageId) {
        return stage.tasks.map((t) => t.title).toList();
      }
    }
    return const [];
  }
}
