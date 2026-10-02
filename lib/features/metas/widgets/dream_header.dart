import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/colors.dart';
import '../../../core/models/goal.dart';

/// Encabezado "sueño" de la pantalla de Metas: emoji, días restantes,
/// universidad/carrera/país y progreso general del roadmap.
class DreamHeader extends StatelessWidget {
  const DreamHeader({
    super.key,
    required this.goal,
    required this.overallProgress,
  });

  final LifeGoal goal;

  /// Progreso general (0.0 - 1.0), promedio del progreso de todas las etapas.
  final double overallProgress;

  @override
  Widget build(BuildContext context) {
    final daysLeft = goal.targetDate.difference(DateTime.now()).inDays;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.background, Color(0xFF1A0A3E)],
          ),
        ),
        child: Stack(
          children: [
            if (goal.dreamImagePath != null)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.15,
                  child: Image.file(
                    File(goal.dreamImagePath!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(goal.emoji, style: const TextStyle(fontSize: 36)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          daysLeft >= 0 ? '$daysLeft días' : 'Fecha vencida',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Text(
                          'para tu sueño',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  goal.university,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${goal.career} · ${goal.country}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Progreso general',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      '${(overallProgress.clamp(0, 1) * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: overallProgress.clamp(0, 1),
                  backgroundColor: const Color(0xFF2A2D3E),
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Contador regresivo (animado) para un examen con fecha configurada, p. ej.
/// el TOLC-I. Se muestra debajo del [DreamHeader] solo cuando existe una
/// fecha objetivo.
class ExamCountdown extends StatelessWidget {
  const ExamCountdown({
    super.key,
    required this.examName,
    required this.targetDate,
  });

  final String examName;
  final DateTime targetDate;

  @override
  Widget build(BuildContext context) {
    final daysLeft = targetDate.difference(DateTime.now()).inDays;
    final label = daysLeft >= 0
        ? '$examName en $daysLeft días'
        : '$examName venció hace ${-daysLeft} días';

    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.timer_outlined,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .fadeIn(duration: 1200.ms, begin: 0.5);
  }
}
