import 'package:flutter/material.dart';

import '../constants/colors.dart';

/// Nivel del Índice de Disciplina (ID): un puntaje acumulado 0-1000 que
/// resume la constancia global del usuario, a diferencia de
/// [DisciplineLevel] que solo mide un día o una semana puntual.
enum DisciplineIndexLevel {
  principiante,
  constante,
  disciplinado,
  elite,
  leyenda,
  maestro,
}

extension DisciplineIndexLevelX on DisciplineIndexLevel {
  String get label => switch (this) {
    DisciplineIndexLevel.principiante => '🌱 PRINCIPIANTE',
    DisciplineIndexLevel.constante => '⚡ CONSTANTE',
    DisciplineIndexLevel.disciplinado => '🔥 DISCIPLINADO',
    DisciplineIndexLevel.elite => '💎 ELITE',
    DisciplineIndexLevel.leyenda => '👑 LEYENDA',
    DisciplineIndexLevel.maestro => '🏛️ MAESTRO',
  };

  Color get color => switch (this) {
    DisciplineIndexLevel.principiante => AppColors.textMuted,
    DisciplineIndexLevel.constante => AppColors.primary,
    DisciplineIndexLevel.disciplinado => AppColors.warning,
    DisciplineIndexLevel.elite => const Color(0xFF06B6D4),
    DisciplineIndexLevel.leyenda => const Color(0xFFF59E0B),
    DisciplineIndexLevel.maestro => const Color(0xFFEC4899),
  };
}

/// Deriva el [DisciplineIndexLevel] correspondiente a un puntaje (0-1000).
DisciplineIndexLevel disciplineIndexLevelFor(int score) => switch (score) {
  >= 900 => DisciplineIndexLevel.maestro,
  >= 720 => DisciplineIndexLevel.leyenda,
  >= 520 => DisciplineIndexLevel.elite,
  >= 320 => DisciplineIndexLevel.disciplinado,
  >= 150 => DisciplineIndexLevel.constante,
  _ => DisciplineIndexLevel.principiante,
};
