import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';

/// Placeholder del Diario personal: todavía no implementado como feature
/// completo, pero ya tiene una ruta real a la que puede navegar el botón
/// "Escribir en el diario" del resumen nocturno.
class DiarioScreen extends StatelessWidget {
  const DiarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'Diario',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            '📝\n\nEl diario personal está en camino.\nPronto podrás escribir aquí sobre tu día.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, height: 1.5),
          ),
        ),
      ),
    );
  }
}
