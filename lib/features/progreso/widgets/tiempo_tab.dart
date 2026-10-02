import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/colors.dart';
import '../../../core/models/activity.dart';
import '../../../providers/progreso_provider.dart';

String _formatDuration(Duration d) {
  final hours = d.inHours;
  final minutes = d.inMinutes % 60;
  if (hours == 0) return '${minutes}min';
  if (minutes == 0) return '${hours}h';
  return '${hours}h ${minutes}min';
}

/// Tab "Tiempo" de Progreso: tiempo total invertido por categoría de
/// actividad, calculado desde las actividades marcadas como hechas.
class TiempoTab extends ConsumerWidget {
  const TiempoTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalsAsync = ref.watch(categoryTimeInvestedProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(categoryTimeInvestedProvider),
      child: totalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Error al calcular el tiempo invertido: $err',
                style: const TextStyle(color: AppColors.danger),
              ),
            ),
          ],
        ),
        data: (totals) {
          if (totals.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 140),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Aún no hay tiempo registrado. ¡Marca tus primeras '
                    'actividades como hechas en "Hoy"!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              ],
            );
          }

          final entries = totals.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          final maxMinutes = entries
              .map((e) => e.value.inMinutes)
              .reduce((a, b) => a > b ? a : b);
          final totalMinutes = entries.fold<int>(
            0,
            (sum, e) => sum + e.value.inMinutes,
          );
          final totalHours = totalMinutes / 60;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final entry in entries)
                _CategoryTimeRow(
                  category: entry.key,
                  duration: entry.value,
                  maxMinutes: maxMinutes,
                ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '🎯 Total invertido en tu sueño: '
                  '${totalHours.toStringAsFixed(0)} horas',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryTimeRow extends StatelessWidget {
  const _CategoryTimeRow({
    required this.category,
    required this.duration,
    required this.maxMinutes,
  });

  final ActivityCategory category;
  final Duration duration;
  final int maxMinutes;

  @override
  Widget build(BuildContext context) {
    final ratio = maxMinutes == 0 ? 0.0 : duration.inMinutes / maxMinutes;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(category.icon, color: category.color, size: 18),
          const SizedBox(width: 8),
          SizedBox(
            width: 74,
            child: Text(
              category.label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 10,
                backgroundColor: AppColors.surface,
                color: category.color,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 70,
            child: Text(
              _formatDuration(duration),
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
