import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/colors.dart';
import 'widgets/disciplina_tab.dart';
import 'widgets/metas_tab.dart';
import 'widgets/tiempo_tab.dart';

/// Pantalla unificada de Progreso: disciplina del horario, avance de metas y
/// tiempo invertido, cada una en su propio tab.
class ProgresoScreen extends StatelessWidget {
  const ProgresoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: const Text(
            'Progreso',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          actions: [
            IconButton(
              tooltip: 'Ver análisis completo',
              onPressed: () => context.push('/progreso/stats'),
              icon: const Icon(
                Icons.insights_outlined,
                color: AppColors.textMuted,
              ),
            ),
          ],
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textMuted,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: '📅 Disciplina'),
              Tab(text: '🎯 Metas'),
              Tab(text: '⏱ Tiempo'),
            ],
          ),
        ),
        body: const SafeArea(
          child: TabBarView(
            children: [DisciplinaTab(), MetasTab(), TiempoTab()],
          ),
        ),
      ),
    );
  }
}
