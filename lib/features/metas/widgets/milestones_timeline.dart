import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/models/goal.dart';

/// Timeline horizontal scrollable de hitos logrados. No se muestra nada si
/// [milestones] está vacío.
class MilestonesTimeline extends StatelessWidget {
  const MilestonesTimeline({super.key, required this.milestones});

  final List<Milestone> milestones;

  @override
  Widget build(BuildContext context) {
    if (milestones.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: milestones.length,
        separatorBuilder: (context, index) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            Icons.arrow_forward,
            color: AppColors.textMuted,
            size: 16,
          ),
        ),
        itemBuilder: (context, index) {
          final milestone = milestones[index];
          return GestureDetector(
            onTap: () => _showDetails(context, milestone),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🏆', style: TextStyle(fontSize: 32)),
                const SizedBox(height: 4),
                SizedBox(
                  width: 96,
                  child: Text(
                    milestone.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${milestone.daysToComplete} días',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDetails(BuildContext context, Milestone milestone) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          '🏆 ${milestone.title}',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          '${milestone.description}\n\nLo lograste en ${milestone.daysToComplete} '
          'días.',
          style: const TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
