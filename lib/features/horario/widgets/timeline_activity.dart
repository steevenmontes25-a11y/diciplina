import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/colors.dart';
import '../../../core/models/activity.dart';
import '../../../core/models/day_progress.dart';

/// Color de la línea vertical continua del timeline.
const Color _timelineColor = Color(0xFF2A2D3E);

/// Fila del timeline de "Horario": hora, punto, línea y tarjeta de detalle.
class TimelineActivity extends StatelessWidget {
  const TimelineActivity({
    super.key,
    required this.activity,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
    this.isCurrentActivity = false,
    this.progressStatus,
  });

  final Activity activity;
  final bool isFirst;
  final bool isLast;
  final bool isCurrentActivity;
  final ActivityStatus? progressStatus;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = activity.category.color;
    final dotSize = activity.duration.inHours >= 1 ? 16.0 : 10.0;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 64,
            child: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Text(
                activity.timeStart,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ),
          ),
          Column(
            children: [
              Container(
                width: 2,
                height: 14,
                color: isFirst ? Colors.transparent : _timelineColor,
              ),
              Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  border: Border.all(color: AppColors.background, width: 2),
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: isLast ? Colors.transparent : _timelineColor,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isCurrentActivity
                    ? const Color(0xFF1E2235)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border(
                  left: BorderSide(
                    color: color,
                    width: isCurrentActivity ? 3 : 1.5,
                  ),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${activity.timeStart} – ${activity.timeEnd}',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                            if (isCurrentActivity)
                              const _NowBadge()
                            else
                              Text(
                                activity.durationLabel,
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              activity.category.icon,
                              size: 16,
                              color: color,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                activity.title,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          activity.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _CategoryBadge(category: activity.category),
                            if (progressStatus != null)
                              _StatusIcon(status: progressStatus!),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge "AHORA" pulsante para la actividad en curso.
class _NowBadge extends StatelessWidget {
  const _NowBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.success,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'AHORA',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds);
  }
}

/// Pequeña insignia con el ícono y nombre de la categoría de la actividad.
class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category});

  final ActivityCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(category.icon, size: 12, color: category.color),
          const SizedBox(width: 4),
          Text(
            category.label,
            style: TextStyle(
              color: category.color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Ícono que refleja el estado de progreso (hecha / omitida) de la actividad.
class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status});

  final ActivityStatus status;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      ActivityStatus.done => const Icon(
        Icons.check_circle,
        color: AppColors.success,
        size: 18,
      ),
      ActivityStatus.skipped => const Icon(
        Icons.cancel,
        color: AppColors.danger,
        size: 18,
      ),
      ActivityStatus.pending => const SizedBox.shrink(),
    };
  }
}
