import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import 'widgets/stats/calendario_tab.dart';
import 'widgets/stats/estadisticas_tab.dart';
import 'widgets/stats/logros_tab.dart';
import 'widgets/stats/wrapped_tab.dart';

/// Pantallas de análisis y visualización de datos: calendario tipo GitHub,
/// estadísticas con gráficas, logros y el Wrapped anual.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: const Text(
            'Análisis',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          bottom: const TabBar(
            isScrollable: true,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textMuted,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: '📅 Calendario'),
              Tab(text: '📊 Estadísticas'),
              Tab(text: '🏆 Logros'),
              Tab(text: '🎁 Wrapped'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            SafeArea(child: CalendarioTab()),
            SafeArea(child: EstadisticasTab()),
            SafeArea(child: LogrosTab()),
            SafeArea(child: WrappedTab()),
          ],
        ),
      ),
    );
  }
}
