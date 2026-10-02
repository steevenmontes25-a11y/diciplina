import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/models/goal.dart';

const List<String> _levels = ['A1', 'A2', 'B1', 'B2'];
const Color _currentLevelColor = Color(0xFF3B82F6);

/// Vista expandida (una tarjeta grande por nivel) del progreso de italiano,
/// usada en el tab "Tareas" del detalle de la etapa de italiano.
class ItalianLevelsExpanded extends StatelessWidget {
  const ItalianLevelsExpanded({
    super.key,
    required this.stage,
    required this.referenceDate,
  });

  final GoalStage stage;

  /// Fecha usada como punto de partida para calcular "Completado · X días"
  /// (no hay un campo de "inicio de etapa" propio, así que se usa la fecha
  /// de creación de la meta).
  final DateTime referenceDate;

  @override
  Widget build(BuildContext context) {
    final taskByLevel = <String, StageTask>{};
    for (final level in _levels) {
      final match = stage.tasks.where((t) => t.title.contains('Nivel $level'));
      if (match.isNotEmpty) taskByLevel[level] = match.first;
    }

    final currentLevel = _levels.firstWhere(
      (level) => taskByLevel[level]?.status != TaskStatus.done,
      orElse: () => _levels.last,
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final level in _levels)
          _LevelCard(
            level: level,
            task: taskByLevel[level],
            isCurrent: level == currentLevel,
            isFinalTarget: level == _levels.last,
            referenceDate: referenceDate,
          ),
      ],
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.level,
    required this.task,
    required this.isCurrent,
    required this.isFinalTarget,
    required this.referenceDate,
  });

  final String level;
  final StageTask? task;
  final bool isCurrent;
  final bool isFinalTarget;
  final DateTime referenceDate;

  @override
  Widget build(BuildContext context) {
    final isDone = task?.status == TaskStatus.done;
    final isLocked = !isDone && !isCurrent;

    // No hay progreso granular real por nivel (cada nivel es una única
    // tarea): 100% si está hecho, 0% si está bloqueado, y 50% como
    // aproximación honesta de "en progreso" para el nivel actual.
    final percentage = isDone ? 1.0 : (isCurrent ? 0.5 : 0.0);

    final Color background;
    final Color accent;
    if (isDone) {
      background = AppColors.success.withValues(alpha: 0.12);
      accent = AppColors.success;
    } else if (isCurrent) {
      background = _currentLevelColor.withValues(alpha: 0.12);
      accent = _currentLevelColor;
    } else {
      background = AppColors.surface;
      accent = AppColors.textMuted;
    }

    return Opacity(
      opacity: isLocked ? 0.4 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14),
          border: isCurrent ? Border.all(color: accent, width: 1.5) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 32,
                  child: Text(
                    level,
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: percentage,
                    minHeight: 8,
                    backgroundColor: const Color(0xFF2A2D3E),
                    valueColor: AlwaysStoppedAnimation(accent),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(percentage * 100).round()}%',
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _statusText(),
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ),
                if (isFinalTarget && !isDone)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'OBJETIVO FINAL',
                      style: TextStyle(
                        color: AppColors.warning,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _statusText() {
    if (task?.status == TaskStatus.done) {
      final completedAt = task?.completedAt;
      if (completedAt == null) return 'Completado';
      final days = completedAt.difference(referenceDate).inDays;
      return 'Completado · ${days < 0 ? 0 : days} días';
    }
    if (isCurrent) return 'En progreso';
    return '🔒 Bloqueado';
  }
}
