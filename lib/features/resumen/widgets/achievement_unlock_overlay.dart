import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/colors.dart';
import '../../../core/models/achievement.dart';

/// Muestra el overlay de "logro desbloqueado" (entrada desde abajo con
/// scale + fade) y se cierra solo en 3 segundos. El [Future] devuelto se
/// completa cuando el overlay termina de cerrarse, útil para encolar varios
/// logros desbloqueados a la vez uno tras otro.
Future<void> showAchievementUnlockOverlay(
  BuildContext context,
  Achievement achievement,
) {
  final overlayState = Overlay.of(context, rootOverlay: true);
  final completer = Completer<void>();
  late final OverlayEntry entry;

  entry = OverlayEntry(
    builder: (context) => _AchievementUnlockCard(achievement: achievement),
  );

  overlayState.insert(entry);
  Timer(const Duration(seconds: 3), () {
    entry.remove();
    if (!completer.isCompleted) completer.complete();
  });

  return completer.future;
}

class _AchievementUnlockCard extends StatelessWidget {
  const _AchievementUnlockCard({required this.achievement});

  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    return Positioned(
          left: 24,
          right: 24,
          bottom: 56,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.warning, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(achievement.emoji, style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: 8),
                  const Text(
                    '¡LOGRO DESBLOQUEADO!',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.3, end: 0, curve: Curves.easeOutBack, duration: 500.ms)
        .then(delay: 2200.ms)
        .fadeOut(duration: 400.ms);
  }
}
