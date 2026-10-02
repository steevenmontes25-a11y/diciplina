import 'dart:io';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/models/activity.dart';
import '../../../../core/models/day_progress.dart';
import '../../../../core/models/goal.dart';
import '../../../../core/services/discipline_service.dart';
import '../../../../providers/goals_provider.dart';
import '../../../../providers/stats_provider.dart';
import '../../../metas/widgets/animated_progress_arc.dart';

/// Heurística puramente local (no hay backend con datos de otros usuarios)
/// para dar una sensación de comparación en la Slide 2.
int? _topPercentFor(double averagePercentage) {
  if (averagePercentage >= 0.90) return 5;
  if (averagePercentage >= 0.80) return 15;
  if (averagePercentage >= 0.70) return 30;
  if (averagePercentage >= 0.60) return 50;
  return null;
}

/// Tab "Wrapped": resumen anual tipo story, disponible solo con al menos
/// 30 días de datos este año.
class WrappedTab extends ConsumerWidget {
  const WrappedTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(wrappedDataProvider);

    return dataAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Text(
          'Error: $err',
          style: const TextStyle(color: AppColors.danger),
        ),
      ),
      data: (data) =>
          data == null ? const _NotAvailablePlaceholder() : _WrappedStory(data: data),
    );
  }
}

class _NotAvailablePlaceholder extends StatelessWidget {
  const _NotAvailablePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          '🎁\n\nDisponible cuando tengas 30 días de datos.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textMuted, height: 1.5),
        ),
      ),
    );
  }
}

class _WrappedStory extends ConsumerStatefulWidget {
  const _WrappedStory({required this.data});

  final WrappedData data;

  @override
  ConsumerState<_WrappedStory> createState() => _WrappedStoryState();
}

class _WrappedStoryState extends ConsumerState<_WrappedStory> {
  final PageController _pageController = PageController();
  final ScreenshotController _screenshotController = ScreenshotController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _share() async {
    final bytes = await _screenshotController.capture();
    if (bytes == null || !mounted) return;
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/wrapped_${widget.data.year}.png');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Mi Wrapped ${widget.data.year} en Disciplina AI',
    );
  }

  @override
  Widget build(BuildContext context) {
    final goal = ref.watch(activeGoalProvider).valueOrNull;
    final stages = goal == null
        ? const <GoalStage>[]
        : ref.watch(goalStagesProvider(goal.id)).valueOrNull ?? goal.stages;
    final overallProgress = stages.isEmpty
        ? 0.0
        : stages.map((s) => s.progress).reduce((a, b) => a + b) / stages.length;
    final daysRemaining = goal == null
        ? 0
        : max(goal.targetDate.difference(DateTime.now()).inDays, 0);

    final slides = <Widget>[
      _CoverSlide(year: widget.data.year, active: _page == 0),
      _DisciplineSlide(data: widget.data, active: _page == 1),
      _DaysSlide(data: widget.data, active: _page == 2),
      _TimeSlide(data: widget.data, active: _page == 3),
      _StreakSlide(data: widget.data, active: _page == 4),
      _GoalSlide(
        goal: goal,
        overallProgress: overallProgress,
        daysRemaining: daysRemaining,
        active: _page == 5,
      ),
      _AchievementsSlide(data: widget.data, active: _page == 6),
      _ClosingSlide(active: _page == 7, onShare: _share),
    ];

    return Screenshot(
      controller: _screenshotController,
      child: ColoredBox(
        color: Colors.black,
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: slides.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, i) => slides[i],
            ),
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  for (var i = 0; i < slides.length; i++)
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        height: 3,
                        decoration: BoxDecoration(
                          color: i <= _page ? Colors.white : Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
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

class _SlideScaffold extends StatelessWidget {
  const _SlideScaffold({required this.child, this.gradient = false});

  final Widget child;
  final bool gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: gradient ? null : Colors.black,
        gradient: gradient
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F1117), Color(0xFF0D0B1E)],
              )
            : null,
      ),
      child: child,
    );
  }
}

/// Número grande que cuenta de 0 a [value] cada vez que la slide se vuelve
/// activa (el `ValueKey(active)` reinicia el `TweenAnimationBuilder`).
class _AnimatedNumber extends StatelessWidget {
  const _AnimatedNumber({
    required this.value,
    required this.active,
    required this.style,
    this.formatter,
  });

  final double value;
  final bool active;
  final TextStyle style;
  final String Function(double)? formatter;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(active),
      tween: Tween(begin: 0, end: active ? value : 0),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) {
        return Text(
          formatter != null ? formatter!(v) : v.round().toString(),
          style: style,
        );
      },
    );
  }
}

// ---------------------------------------------------------------------
// Slide 1 — Portada
// ---------------------------------------------------------------------

class _CoverSlide extends StatelessWidget {
  const _CoverSlide({required this.year, required this.active});

  final int year;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return _SlideScaffold(
      gradient: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Tu $year',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ).animate(key: ValueKey(active)).fadeIn(duration: 600.ms).slideY(
            begin: 0.2,
            end: 0,
          ),
          const SizedBox(height: 8),
          const Text(
            'en datos',
            style: TextStyle(color: AppColors.textMuted, fontSize: 32),
          ).animate(key: ValueKey(active)).fadeIn(delay: 300.ms, duration: 600.ms).slideY(
            begin: 0.2,
            end: 0,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Slide 2 — Disciplina
// ---------------------------------------------------------------------

class _DisciplineSlide extends StatelessWidget {
  const _DisciplineSlide({required this.data, required this.active});

  final WrappedData data;
  final bool active;

  @override
  Widget build(BuildContext context) {
    const service = DisciplineService();
    final level = service.levelForPercentage(data.averagePercentage);
    final topPercent = _topPercentFor(data.averagePercentage);

    return _SlideScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Este año tu disciplina promedio fue',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 16),
          ).animate(key: ValueKey(active)).fadeIn(),
          const SizedBox(height: 16),
          _AnimatedNumber(
            value: data.averagePercentage * 100,
            active: active,
            formatter: (v) => '${v.round()}%',
            style: TextStyle(
              color: level.color,
              fontSize: 72,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (topPercent != null) ...[
            const SizedBox(height: 16),
            Text(
              'Eso te pone en el top $topPercent% de usuarios disciplinados',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
            ).animate(key: ValueKey(active)).fadeIn(delay: 900.ms),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Slide 3 — Días
// ---------------------------------------------------------------------

class _DaysSlide extends StatelessWidget {
  const _DaysSlide({required this.data, required this.active});

  final WrappedData data;
  final bool active;

  @override
  Widget build(BuildContext context) {
    Widget line(String text, Color color, int delayMs) => Text(
      text,
      style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.bold),
    ).animate(key: ValueKey(active)).fadeIn(delay: delayMs.ms).slideX(begin: 0.15, end: 0);

    return _SlideScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          line('🟢 ${data.yearStats.green} días perfectos', AppColors.success, 0),
          const SizedBox(height: 12),
          line('🟡 ${data.yearStats.yellow} días aceptables', AppColors.warning, 400),
          const SizedBox(height: 12),
          line('🔴 ${data.yearStats.red} días bajos', AppColors.danger, 800),
          const SizedBox(height: 24),
          Text(
            'De ${data.yearStats.totalDays} días registrados',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
          ).animate(key: ValueKey(active)).fadeIn(delay: 1200.ms),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Slide 4 — Tiempo
// ---------------------------------------------------------------------

class _TimeSlide extends StatelessWidget {
  const _TimeSlide({required this.data, required this.active});

  final WrappedData data;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final entries = data.categoryTime.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return _SlideScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Invertiste tu tiempo en:',
            style: TextStyle(color: AppColors.textMuted, fontSize: 16),
          ).animate(key: ValueKey(active)).fadeIn(),
          const SizedBox(height: 16),
          if (entries.isNotEmpty)
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 46,
                  sections: [
                    for (final e in entries)
                      PieChartSectionData(
                        value: e.value.inMinutes.toDouble(),
                        color: e.key.color,
                        title: '',
                        radius: 54,
                      ),
                  ],
                ),
              ),
            ).animate(key: ValueKey(active)).fadeIn(delay: 300.ms).scale(
              begin: const Offset(0.7, 0.7),
              end: const Offset(1, 1),
            ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 6,
            children: [
              for (final e in entries)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: e.key.color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      e.key.label,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Total: ${data.totalHours.round()} horas de tu vida '
            'conscientemente dirigidas',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ).animate(key: ValueKey(active)).fadeIn(delay: 900.ms),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Slide 5 — Racha
// ---------------------------------------------------------------------

class _StreakSlide extends StatelessWidget {
  const _StreakSlide({required this.data, required this.active});

  final WrappedData data;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final range = data.bestStreak;
    final rangeLabel = range.start != null && range.end != null
        ? 'Del ${DateFormat('d', 'es').format(range.start!)} al '
              '${DateFormat("d 'de' MMMM", 'es').format(range.end!)}'
        : null;

    return _SlideScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Tu mejor racha fue',
            style: TextStyle(color: AppColors.textMuted, fontSize: 16),
          ).animate(key: ValueKey(active)).fadeIn(),
          const SizedBox(height: 16),
          _AnimatedNumber(
            value: range.length.toDouble(),
            active: active,
            formatter: (v) => '🔥 ${v.round()}',
            style: const TextStyle(
              color: AppColors.warning,
              fontSize: 72,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'días consecutivos de disciplina',
            style: TextStyle(color: AppColors.textMuted, fontSize: 14),
          ).animate(key: ValueKey(active)).fadeIn(delay: 900.ms),
          if (rangeLabel != null) ...[
            const SizedBox(height: 8),
            Text(
              rangeLabel,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            ).animate(key: ValueKey(active)).fadeIn(delay: 1100.ms),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Slide 6 — Meta
// ---------------------------------------------------------------------

class _GoalSlide extends StatelessWidget {
  const _GoalSlide({
    required this.goal,
    required this.overallProgress,
    required this.daysRemaining,
    required this.active,
  });

  final LifeGoal? goal;
  final double overallProgress;
  final int daysRemaining;
  final bool active;

  @override
  Widget build(BuildContext context) {
    if (goal == null) {
      return const _SlideScaffold(
        child: Text(
          'Todavía no tienes una meta activa.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }

    return _SlideScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Tu gran objetivo:',
            style: TextStyle(color: AppColors.textMuted, fontSize: 16),
          ).animate(key: ValueKey(active)).fadeIn(),
          const SizedBox(height: 8),
          Text(
            goal!.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ).animate(key: ValueKey(active)).fadeIn(delay: 200.ms),
          const SizedBox(height: 24),
          RepaintBoundary(
            child: AnimatedProgressArc(percentage: overallProgress)
                .animate(key: ValueKey(active))
                .fadeIn(delay: 400.ms)
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
          ),
          const SizedBox(height: 12),
          Text(
            '${(overallProgress * 100).round()}% completado',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ).animate(key: ValueKey(active)).fadeIn(delay: 900.ms),
          const SizedBox(height: 4),
          Text(
            '$daysRemaining días para lograrlo',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ).animate(key: ValueKey(active)).fadeIn(delay: 1100.ms),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Slide 7 — Logros
// ---------------------------------------------------------------------

class _AchievementsSlide extends StatelessWidget {
  const _AchievementsSlide({required this.data, required this.active});

  final WrappedData data;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return _SlideScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Desbloqueaste ${data.achievementsUnlockedCount} logros',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ).animate(key: ValueKey(active)).fadeIn(),
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 14,
            runSpacing: 14,
            children: [
              for (var i = 0; i < data.achievementEmojis.length; i++)
                Text(
                  data.achievementEmojis[i],
                  style: const TextStyle(fontSize: 36),
                ).animate(key: ValueKey(active)).fadeIn(delay: (i * 150).ms).scale(
                  begin: const Offset(0.4, 0.4),
                  end: const Offset(1, 1),
                  curve: Curves.easeOutBack,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Slide 8 — Cierre
// ---------------------------------------------------------------------

class _ClosingSlide extends StatelessWidget {
  const _ClosingSlide({required this.active, required this.onShare});

  final bool active;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return _SlideScaffold(
      gradient: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'La disciplina de hoy',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontStyle: FontStyle.italic,
            ),
          ).animate(key: ValueKey(active)).fadeIn(),
          const Text(
            'es la libertad de mañana.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontStyle: FontStyle.italic,
            ),
          ).animate(key: ValueKey(active)).fadeIn(delay: 300.ms),
          const SizedBox(height: 12),
          const Text(
            '— Disciplina AI',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ).animate(key: ValueKey(active)).fadeIn(delay: 600.ms),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: onShare,
            icon: const Icon(Icons.ios_share),
            label: const Text('Compartir mi Wrapped'),
          ).animate(key: ValueKey(active)).fadeIn(delay: 900.ms),
        ],
      ),
    );
  }
}
