import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/colors.dart';
import '../../../core/models/goal.dart';

/// Dialog de celebración que se muestra al completar todas las tareas de
/// una etapa.
Future<void> showStageCompletedDialog(
  BuildContext context, {
  required GoalStage stage,
  required int daysToComplete,
  VoidCallback? onViewNextStage,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 64)).animate().scale(
              begin: Offset.zero,
              end: const Offset(1, 1),
              duration: 700.ms,
              curve: Curves.elasticOut,
            ),
            const SizedBox(height: 16),
            const Text(
              '¡Etapa completada!',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${stage.emoji} ${stage.title}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 15),
            ),
            const SizedBox(height: 8),
            Text(
              'Duración: $daysToComplete días',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onViewNextStage?.call();
                },
                child: Text(
                  onViewNextStage != null ? 'Ver siguiente etapa' : 'Cerrar',
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
