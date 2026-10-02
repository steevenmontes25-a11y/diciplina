import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/motivational_phrases.dart';
import '../../core/database/db_helper.dart';
import '../../core/models/activity.dart';
import '../../core/models/day_progress.dart';
import '../../core/models/discipline_index.dart';
import '../../core/models/goal.dart';
import '../../core/models/mood.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/goals_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/schedule_provider.dart';

String _capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

String _greetingFor(int hour) {
  if (hour < 12) return 'Buenos días';
  if (hour < 19) return 'Buenas tardes';
  return 'Buenas noches';
}

/// Dashboard principal: la primera pantalla que ve el usuario al abrir la
/// app. Todo en una sola pantalla scrollable, con actualización en vivo
/// cada segundo (hora, actividad en curso y su progreso temporal).
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      ref.invalidate(currentActivityProvider);
      ref.invalidate(nextActivityProvider);
      ref.invalidate(currentActivityProgressProvider);
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateKey = DateFormat('yyyy-MM-dd').format(now);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(activeGoalProvider);
            ref.invalidate(dayStatsProvider(dateKey));
            ref.invalidate(currentStreakProvider);
            ref.invalidate(disciplineIndexProvider);
            ref.invalidate(todayMoodProvider);
          },
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              // El reloj se actualiza cada segundo: aislado en su propia
              // capa de repintado para no forzar el repintado del resto.
              RepaintBoundary(child: _HeroHeader(now: now)),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // La barra de progreso de la actividad en curso también
                    // se actualiza cada segundo.
                    RepaintBoundary(
                      child: _CurrentActivityCard(dateKey: dateKey),
                    ),
                    const SizedBox(height: 16),
                    _DailyProgressRow(dateKey: dateKey),
                    const SizedBox(height: 16),
                    const _MainGoalCard(),
                    const SizedBox(height: 16),
                    _MoodCard(dateKey: dateKey),
                    const SizedBox(height: 16),
                    const _MotivationalQuoteCard(),
                    const SizedBox(height: 20),
                    const _UpcomingActivitiesSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Sección 1: Hero header
// ---------------------------------------------------------------------

class _HeroHeader extends ConsumerWidget {
  const _HeroHeader({required this.now});

  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(userNameProvider).valueOrNull ?? '';
    final greeting = _greetingFor(now.hour);
    final score = ref.watch(disciplineIndexProvider).valueOrNull ?? 0;
    final level = disciplineIndexLevelFor(score);

    final content = Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                name.isEmpty ? '$greeting 👋' : '$greeting, $name 👋',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 18,
                ),
              ),
              const Spacer(),
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary,
                child: Text(
                  (name.isEmpty ? '?' : name[0]).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('h:mm a', 'en_US').format(now),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 52,
              fontWeight: FontWeight.bold,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          Text(
            _capitalize(DateFormat("EEEE, d 'de' MMMM", 'es').format(now)),
            style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ÍNDICE DE DISCIPLINA',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$score',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        ' / 1000',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: level.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: level.color, width: 1),
                ),
                child: Text(
                  level.label,
                  style: TextStyle(
                    color: level.color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 220),
          child: SizedBox(width: double.infinity, child: content),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .custom(
          duration: 6.seconds,
          builder: (context, value, child) => DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1.0 + value * 0.4, -1.0),
                end: Alignment(1.0 - value * 0.4, 1.0),
                colors: const [Color(0xFF0F1117), Color(0xFF0D0B1E)],
              ),
            ),
            child: child,
          ),
        );
  }
}

// ---------------------------------------------------------------------
// Sección 2: Actividad actual
// ---------------------------------------------------------------------

class _CurrentActivityCard extends ConsumerWidget {
  const _CurrentActivityCard({required this.dateKey});

  final String dateKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activity = ref.watch(currentActivityProvider);

    if (activity == null) {
      final next = ref.watch(nextActivityProvider);
      return _FreeTimeCard(next: next);
    }

    final progress = ref.watch(currentActivityProgressProvider);
    final color = activity.category.color;
    final remainingMinutes = max(
      (activity.duration.inMinutes * (1 - progress)).round(),
      0,
    );
    final progressMap =
        ref.watch(progressNotifierProvider(dateKey)).valueOrNull ?? const {};
    final status = progressMap[activity.id]?.status ?? ActivityStatus.pending;

    void mark(ActivityStatus newStatus) {
      ref
          .read(progressNotifierProvider(dateKey).notifier)
          .mark(activity.id, newStatus);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                    'AHORA',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat())
                  .shimmer(
                    duration: 1500.ms,
                    color: AppColors.success.withValues(alpha: 0.6),
                  ),
              const Spacer(),
              Text(
                'Termina en $remainingMinutes min',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(activity.category.icon, size: 32, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${activity.timeStart} – ${activity.timeEnd}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              color: color,
              backgroundColor: color.withValues(alpha: 0.2),
            ),
          ),
          const SizedBox(height: 12),
          if (status == ActivityStatus.pending)
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: '✅ Completado',
                    color: AppColors.success,
                    onTap: () => mark(ActivityStatus.done),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionButton(
                    label: '❌ Omitir',
                    color: AppColors.danger,
                    onTap: () => mark(ActivityStatus.skipped),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionButton(
                    label: '⏸ Posponer',
                    color: AppColors.textMuted,
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Recordatorio pospuesto 15 min.'),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Text(
              status == ActivityStatus.done
                  ? '✅ Ya marcaste esta actividad como completada'
                  : '❌ Marcaste esta actividad como omitida',
              style: TextStyle(
                color: status == ActivityStatus.done
                    ? AppColors.success
                    : AppColors.danger,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _FreeTimeCard extends StatelessWidget {
  const _FreeTimeCard({required this.next});

  final Activity? next;

  @override
  Widget build(BuildContext context) {
    String subtitle;
    if (next == null) {
      subtitle = 'No hay más actividades programadas por hoy.';
    } else {
      final now = DateTime.now();
      final nowMinutes = now.hour * 60 + now.minute;
      final startMinutes = next!.startTime.hour * 60 + next!.startTime.minute;
      final inMinutes = max(startMinutes - nowMinutes, 0);
      subtitle = 'Próxima actividad en $inMinutes min';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text('☕', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tiempo libre',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                if (next != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        next!.category.icon,
                        size: 16,
                        color: next!.category.color,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          next!.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Sección 3: Progreso del día
// ---------------------------------------------------------------------

class _DailyProgressRow extends ConsumerWidget {
  const _DailyProgressRow({required this.dateKey});

  final String dateKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats =
        ref.watch(dayStatsProvider(dateKey)).valueOrNull ??
        const DayStats(total: 0, done: 0, skipped: 0);
    final streak = ref.watch(currentStreakProvider).valueOrNull ?? 0;

    return Row(
      children: [
        Expanded(
          child: _MiniStat(value: '${stats.done}', label: 'hechas'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStat(
            value: '${(stats.percentage * 100).round()}%',
            label: 'del día',
            accentColor: stats.level.color,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStat(value: '🔥 $streak', label: 'días'),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.value, required this.label, this.accentColor});

  final String value;
  final String label;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: accentColor != null
            ? accentColor!.withValues(alpha: 0.12)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: accentColor ?? Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Sección 4: Meta principal
// ---------------------------------------------------------------------

class _MainGoalCard extends ConsumerWidget {
  const _MainGoalCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = ref.watch(activeGoalProvider).valueOrNull;
    if (goal == null) return const SizedBox.shrink();

    final stages =
        ref.watch(goalStagesProvider(goal.id)).valueOrNull ?? goal.stages;
    final overallProgress = stages.isEmpty
        ? 0.0
        : stages.map((s) => s.progress).reduce((a, b) => a + b) / stages.length;
    final daysRemaining = max(
      goal.targetDate.difference(DateTime.now()).inDays,
      0,
    );

    GoalStage? currentStage;
    for (final stage in stages) {
      if (stage.status == StageStatus.inProgress) {
        currentStage = stage;
        break;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🎯', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.university,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${goal.career} · ${goal.country}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$daysRemaining',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'días',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'Progreso general',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              const Spacer(),
              Text(
                '${(overallProgress * 100).round()}%',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: overallProgress,
              minHeight: 6,
              color: AppColors.primary,
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (currentStage != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${currentStage.emoji} ${currentStage.title} · '
                    '${(currentStage.progress * 100).round()}%',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const Spacer(),
              TextButton(
                onPressed: () => context.go('/metas'),
                child: const Text('Ver roadmap →'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Sección 5: Estado de ánimo
// ---------------------------------------------------------------------

class _MoodCard extends ConsumerWidget {
  const _MoodCard({required this.dateKey});

  final String dateKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mood = ref.watch(todayMoodProvider).valueOrNull;

    if (mood != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Text(mood, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Text(
              'Estado de hoy: ${moodLabelForEmoji(mood)}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¿Cómo te sientes hoy?',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final option in moodOptions)
                InkWell(
                  onTap: () async {
                    await DbHelper.instance.setMoodForDate(
                      dateKey,
                      option.emoji,
                    );
                    ref.invalidate(todayMoodProvider);
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      option.emoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Sección 6: Frase motivacional
// ---------------------------------------------------------------------

class _MotivationalQuoteCard extends StatelessWidget {
  const _MotivationalQuoteCard();

  @override
  Widget build(BuildContext context) {
    final phrase = motivationalPhraseForDate();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.all(Radius.circular(12)),
        border: Border(left: BorderSide(color: AppColors.primary, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '"$phrase"',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '— Disciplina AI',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Sección 7: Próximas actividades
// ---------------------------------------------------------------------

class _UpcomingActivitiesSection extends ConsumerWidget {
  const _UpcomingActivitiesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(todayScheduleProvider);
    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;

    final upcoming =
        activities.where((a) {
          final start = a.startTime.hour * 60 + a.startTime.minute;
          return start > nowMinutes;
        }).toList()..sort((a, b) {
          final sa = a.startTime.hour * 60 + a.startTime.minute;
          final sb = b.startTime.hour * 60 + b.startTime.minute;
          return sa.compareTo(sb);
        });
    final next3 = upcoming.take(3).toList();

    if (next3.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'A CONTINUACIÓN',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < next3.length; i++) ...[
          if (i > 0) const Divider(color: AppColors.surface, height: 1),
          _UpcomingRow(activity: next3[i]),
        ],
      ],
    );
  }
}

class _UpcomingRow extends StatelessWidget {
  const _UpcomingRow({required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Text(
              activity.timeStart,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ),
          Icon(
            activity.category.icon,
            size: 16,
            color: activity.category.color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              activity.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            activity.durationLabel,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
