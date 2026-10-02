import 'dart:async';

import 'package:flutter/material.dart';

/// Contador regresivo que se actualiza cada segundo con una pequeña
/// animación de "flip" (deslizamiento + fundido) al cambiar.
class FlipCountdown extends StatefulWidget {
  const FlipCountdown({super.key, required this.targetDate});

  final DateTime targetDate;

  @override
  State<FlipCountdown> createState() => _FlipCountdownState();
}

class _FlipCountdownState extends State<FlipCountdown> {
  late Timer _timer;
  late Duration _remaining = _computeRemaining();

  Duration _computeRemaining() {
    final diff = widget.targetDate.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _remaining = _computeRemaining());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;
    final label =
        '$days días · $hours horas · $minutes minutos · $seconds segundos';

    return ClipRect(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.6),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: Text(
          label,
          key: ValueKey<int>(_remaining.inSeconds),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
