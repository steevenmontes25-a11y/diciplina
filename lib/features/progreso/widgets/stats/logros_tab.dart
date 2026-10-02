import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/database/db_helper.dart';
import '../../../../core/models/achievement.dart';
import '../../../../providers/stats_provider.dart';

/// Tab "Logros": grid 3 columnas con todos los logros, bloqueados en
/// escala de grises, y el progreso hacia el más próximo a desbloquear.
class LogrosTab extends ConsumerWidget {
  const LogrosTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(allAchievementsProvider);
    final nextAsync = ref.watch(nextAchievementProgressProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(allAchievementsProvider);
        ref.invalidate(nextAchievementProgressProvider);
      },
      child: achievementsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Error al cargar los logros: $err',
                style: const TextStyle(color: AppColors.danger),
              ),
            ),
          ],
        ),
        data: (achievements) {
          final unlockedCount = achievements.where((a) => a.isUnlocked).length;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                '$unlockedCount / ${achievements.length} logros desbloqueados',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 16),
              nextAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
                data: (next) =>
                    next == null ? const SizedBox.shrink() : _NextUpBanner(next: next),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: achievements.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  final achievement = achievements[index];
                  return _AchievementCard(
                    achievement: achievement,
                    onTap: achievement.isUnlocked
                        ? () => _showDetail(context, achievement)
                        : null,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDetail(BuildContext context, Achievement achievement) {
    showDialog<void>(
      context: context,
      builder: (context) => _AchievementDetailDialog(achievement: achievement),
    );
  }
}

class _NextUpBanner extends StatelessWidget {
  const _NextUpBanner({required this.next});

  final NextAchievementProgress next;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${next.achievement.emoji} ${next.currentValue}/'
            '${next.achievement.targetValue} para "${next.achievement.title}"',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: next.progress,
              minHeight: 6,
              backgroundColor: AppColors.background,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.achievement, required this.onTap});

  final Achievement achievement;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.isUnlocked;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: unlocked
              ? Border.all(color: AppColors.warning.withValues(alpha: 0.5))
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: unlocked ? 1 : 0.35,
              child: Text(
                unlocked ? achievement.emoji : '🔒',
                style: const TextStyle(fontSize: 32),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              unlocked ? achievement.title : '???',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: unlocked ? AppColors.textPrimary : AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementDetailDialog extends StatelessWidget {
  const _AchievementDetailDialog({required this.achievement});

  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(achievement.emoji, style: const TextStyle(fontSize: 64))
                .animate()
                .scale(
                  begin: Offset.zero,
                  end: const Offset(1, 1),
                  duration: 700.ms,
                  curve: Curves.elasticOut,
                ),
            const SizedBox(height: 16),
            Text(
              achievement.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              achievement.description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            if (achievement.unlockedAt != null) ...[
              Text(
                'Conseguido el '
                '${DateFormat("d 'de' MMMM 'de' y", 'es').format(achievement.unlockedAt!)}',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              FutureBuilder<String?>(
                future: DbHelper.instance.getEarliestProgressDate(),
                builder: (context, snapshot) {
                  final earliest = snapshot.data;
                  if (earliest == null) return const SizedBox.shrink();
                  final days = achievement.unlockedAt!
                      .difference(DateTime.parse(earliest))
                      .inDays;
                  return Text(
                    'Conseguido en $days días desde que empezaste',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
