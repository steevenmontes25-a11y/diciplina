import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';

/// Arco circular de progreso, animado de 0 al [percentage] indicado.
class AnimatedProgressArc extends StatefulWidget {
  const AnimatedProgressArc({
    super.key,
    required this.percentage,
    this.size = 120,
  });

  /// 0.0 - 1.0
  final double percentage;
  final double size;

  @override
  State<AnimatedProgressArc> createState() => _AnimatedProgressArcState();
}

class _AnimatedProgressArcState extends State<AnimatedProgressArc>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );
  late Animation<double> _animation = _buildAnimation();

  Animation<double> _buildAnimation() {
    return Tween<double>(
      begin: 0,
      end: widget.percentage.clamp(0, 1),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedProgressArc oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percentage != widget.percentage) {
      setState(() => _animation = _buildAnimation());
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => CustomPaint(
        size: Size.square(widget.size),
        painter: _ProgressArcPainter(progress: _animation.value),
      ),
    );
  }
}

class _ProgressArcPainter extends CustomPainter {
  _ProgressArcPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    final backgroundPaint = Paint()
      ..color = const Color(0xFF2A2D3E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    canvas.drawCircle(center, radius, backgroundPaint);

    final foregroundPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressArcPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
