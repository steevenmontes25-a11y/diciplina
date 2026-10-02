import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/colors.dart';
import '../../../core/models/goal.dart';

const Color _currentLevelColor = Color(0xFF3B82F6);
const List<String> _levels = ['A1', 'A2', 'B1', 'B2'];

/// Medidor de niveles de italiano (A1 → B2), usado en la etapa "Italiano" en
/// vez de la lista de tareas genérica.
class ItalianLevelMeter extends StatelessWidget {
  const ItalianLevelMeter({super.key, required this.stage});

  final GoalStage stage;

  @override
  Widget build(BuildContext context) {
    final statusByLevel = <String, TaskStatus>{};
    for (final level in _levels) {
      final match = stage.tasks.where((t) => t.title.contains('Nivel $level'));
      if (match.isNotEmpty) statusByLevel[level] = match.first.status;
    }

    final currentLevel = _levels.firstWhere(
      (level) => statusByLevel[level] != TaskStatus.done,
      orElse: () => _levels.last,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var i = 0; i < _levels.length; i++) ...[
                Expanded(
                  child: _LevelDot(
                    label: _levels[i],
                    isDone: statusByLevel[_levels[i]] == TaskStatus.done,
                    isCurrent: _levels[i] == currentLevel,
                  ),
                ),
                if (i != _levels.length - 1)
                  Container(
                    width: 16,
                    height: 2,
                    color: const Color(0xFF2A2D3E),
                  ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Actualmente: $currentLevel  →  Objetivo: B2',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelDot extends StatelessWidget {
  const _LevelDot({
    required this.label,
    required this.isDone,
    required this.isCurrent,
  });

  final String label;
  final bool isDone;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final color = isDone
        ? AppColors.success
        : (isCurrent ? _currentLevelColor : AppColors.textMuted);

    Widget circle = Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDone || isCurrent ? color : color.withValues(alpha: 0.12),
        border: isDone || isCurrent
            ? null
            : Border.all(color: AppColors.textMuted, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Icon(
        isDone ? Icons.check : Icons.circle,
        size: isDone ? 16 : (isCurrent ? 12 : 8),
        color: isDone || isCurrent ? Colors.white : AppColors.textMuted,
      ),
    );

    if (isCurrent) {
      circle = circle
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scaleXY(begin: 1, end: 1.15, duration: 700.ms);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        circle,
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
