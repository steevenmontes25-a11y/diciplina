import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/colors.dart';
import '../../../core/models/goal.dart';
import '../../../providers/goals_provider.dart';
import 'add_simulation_modal.dart';

/// Cuántas simulaciones recientes se muestran en la mini-gráfica de barras.
const int _chartWindow = 8;

/// Card expandible con el historial de simulaciones TOLC-I: resumen,
/// mini-gráfica de barras y botón para registrar una nueva.
class TolcSimulationsCard extends ConsumerWidget {
  const TolcSimulationsCard({
    super.key,
    required this.goalId,
    required this.simulations,
    required this.topicPool,
  });

  final String goalId;
  final List<ExamSimulation> simulations;
  final List<String> topicPool;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sorted = [...simulations]..sort((a, b) => a.date.compareTo(b.date));
    final targetScore = sorted.isNotEmpty ? sorted.last.targetScore : 40;
    final summary = _summaryLine(sorted);
    final lastWeakTopics = sorted.isNotEmpty
        ? sorted.last.weakTopics
        : const <String>[];
    final chartData = sorted.length > _chartWindow
        ? sorted.sublist(sorted.length - _chartWindow)
        : sorted;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          collapsedIconColor: AppColors.textMuted,
          iconColor: AppColors.textMuted,
          title: const Text(
            '📝 Simulaciones TOLC-I',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              summary,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (chartData.isNotEmpty)
                    SizedBox(
                      height: 160,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: _TolcBarChartPainter(
                          simulations: chartData,
                          targetScore: targetScore,
                        ),
                      ),
                    ),
                  if (lastWeakTopics.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      '⚠️ Áreas a reforzar: ${lastWeakTopics.join(' · ')}',
                      style: const TextStyle(
                        color: AppColors.warning,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => showAddSimulationModal(
                        context,
                        goalId: goalId,
                        nextSimNumber: (sorted.length + 1).clamp(1, 40),
                        targetScore: targetScore,
                        topicPool: topicPool,
                        onSaved: () =>
                            ref.invalidate(examSimulationsProvider(goalId)),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Registrar simulación'),
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

  String _summaryLine(List<ExamSimulation> sorted) {
    if (sorted.isEmpty) return 'Aún no hay simulaciones registradas';
    final average =
        sorted.map((s) => s.score).reduce((a, b) => a + b) / sorted.length;
    final target = sorted.last.targetScore;
    return '${sorted.length} realizadas · Promedio: ${average.round()}/50 · '
        'Objetivo: $target+';
  }
}

class _TolcBarChartPainter extends CustomPainter {
  _TolcBarChartPainter({required this.simulations, required this.targetScore});

  final List<ExamSimulation> simulations;
  final int targetScore;

  static const double _maxScore = 50;
  static const double _leftPadding = 22;
  static const double _bottomPadding = 16;

  @override
  void paint(Canvas canvas, Size size) {
    if (simulations.isEmpty) return;

    final chartWidth = size.width - _leftPadding;
    final chartHeight = size.height - _bottomPadding;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    void drawLabel(String text, Offset offset, {double fontSize = 9}) {
      textPainter.text = TextSpan(
        text: text,
        style: TextStyle(color: AppColors.textMuted, fontSize: fontSize),
      );
      textPainter.layout();
      textPainter.paint(canvas, offset);
    }

    drawLabel('50', const Offset(0, 0));
    drawLabel('0', Offset(0, chartHeight - 10));

    // Línea punteada del puntaje objetivo.
    final targetY = chartHeight - (targetScore / _maxScore) * chartHeight;
    final dashPaint = Paint()
      ..color = AppColors.danger
      ..strokeWidth = 1;
    var dashX = _leftPadding;
    const dashWidth = 4.0;
    const dashSpace = 3.0;
    while (dashX < size.width) {
      canvas.drawLine(
        Offset(dashX, targetY),
        Offset(dashX + dashWidth, targetY),
        dashPaint,
      );
      dashX += dashWidth + dashSpace;
    }

    final barCount = simulations.length;
    final barSlot = chartWidth / barCount;
    final barWidth = barSlot * 0.5;

    for (var i = 0; i < barCount; i++) {
      final sim = simulations[i];
      final barHeight = (sim.score / _maxScore) * chartHeight;
      final x = _leftPadding + barSlot * i + (barSlot - barWidth) / 2;
      final rect = Rect.fromLTWH(
        x,
        chartHeight - barHeight,
        barWidth,
        barHeight,
      );

      final paint = Paint()
        ..color = sim.score >= sim.targetScore
            ? AppColors.success
            : AppColors.danger;
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          rect,
          topLeft: const Radius.circular(3),
          topRight: const Radius.circular(3),
        ),
        paint,
      );

      drawLabel(
        '${i + 1}',
        Offset(x + barWidth / 2 - 3, chartHeight + 3),
        fontSize: 8,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TolcBarChartPainter oldDelegate) {
    return oldDelegate.simulations != simulations ||
        oldDelegate.targetScore != targetScore;
  }
}
