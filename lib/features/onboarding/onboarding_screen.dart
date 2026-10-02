import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/schedule_data.dart';
import '../../core/database/db_helper.dart';
import '../../core/models/activity.dart';
import '../../core/models/day_progress.dart';
import '../../providers/notifications_provider.dart';

/// Flujo de bienvenida que se muestra una única vez, en el primer arranque.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _page = 0;
  bool _isScheduling = false;
  int? _scheduledCount;

  static const _pageCount = 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _activateAlarms() async {
    setState(() => _isScheduling = true);

    final service = ref.read(notificationsServiceProvider);
    await service.requestPermissions();
    final count = await service.scheduleAllAlarms();
    await service.scheduleWakeUpAlarms();

    if (!mounted) return;
    setState(() {
      _isScheduling = false;
      _scheduledCount = count;
    });
  }

  Future<void> _finishOnboarding() async {
    await DbHelper.instance.setPreference('onboarding_done', 'true');
    if (!mounted) return;
    context.go('/hoy');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _page = page),
                children: [
                  const _SchedulePage(),
                  _NotificationsPage(
                    isScheduling: _isScheduling,
                    scheduledCount: _scheduledCount,
                    onActivate: _activateAlarms,
                  ),
                  _DisciplinePage(onStart: _finishOnboarding),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      _pageCount,
                      (i) => _Dot(active: i == _page),
                    ),
                  ),
                  if (_page < _pageCount - 1)
                    TextButton(
                      onPressed: () => _goToPage(_page + 1),
                      child: const Text('Siguiente'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SchedulePage extends StatelessWidget {
  const _SchedulePage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Tu horario maestro está listo 📅',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Esta es la cantidad de actividades que tienes programadas cada día:',
            style: TextStyle(color: AppColors.textMuted, fontSize: 15),
          ),
          const SizedBox(height: 24),
          ...DayOfWeek.values.map((day) {
            final count = getActivitiesForDay(day).length;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    day.label,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '$count actividades',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _NotificationsPage extends StatelessWidget {
  const _NotificationsPage({
    required this.isScheduling,
    required this.scheduledCount,
    required this.onActivate,
  });

  final bool isScheduling;
  final int? scheduledCount;
  final VoidCallback onActivate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Activa las notificaciones 🔔',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Te avisaremos a la hora de cada actividad para que no se te pase ninguna.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 15),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isScheduling ? null : onActivate,
              child: isScheduling
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textPrimary,
                      ),
                    )
                  : const Text('Activar alarmas'),
            ),
          ),
          if (scheduledCount != null) ...[
            const SizedBox(height: 16),
            Text(
              'Se programaron $scheduledCount notificaciones',
              style: const TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DisciplinePage extends StatelessWidget {
  const _DisciplinePage({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Mide tu disciplina ⭐',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Cada día se te asigna un nivel según cuántas actividades cumples:',
            style: TextStyle(color: AppColors.textMuted, fontSize: 15),
          ),
          const SizedBox(height: 20),
          const _LevelRow(
            level: DisciplineLevel.green,
            detail: '80% o más de tus actividades cumplidas',
          ),
          const _LevelRow(
            level: DisciplineLevel.yellow,
            detail: 'Entre 40% y 79% cumplidas',
          ),
          const _LevelRow(
            level: DisciplineLevel.red,
            detail: 'Menos del 40% cumplidas',
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onStart,
              child: const Text('¡Empezar!'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelRow extends StatelessWidget {
  const _LevelRow({required this.level, required this.detail});

  final DisciplineLevel level;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: level.color,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  level.label,
                  style: TextStyle(
                    color: level.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  detail,
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
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 6),
      width: active ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
