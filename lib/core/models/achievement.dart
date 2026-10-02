/// Qué tipo de umbral desbloquea un [Achievement]; determina qué dato del
/// historial se compara contra `targetValue` en
/// `DbHelper.checkAndUnlockAchievements`.
enum AchievementType {
  /// Cantidad de días cerrados en verde (histórico total).
  greenDaysCount,

  /// Racha de días verdes consecutivos.
  streak,

  /// Índice de Disciplina alcanzado.
  disciplineIndex,

  /// Cantidad de actividades marcadas como hechas (histórico total).
  activitiesDoneCount,

  /// La tarea "Nivel B1" de la etapa de italiano está hecha.
  italianB1,

  /// Alguna simulación de examen alcanzó `targetValue` puntos o más.
  examScore,

  /// Cantidad de metas de vida creadas.
  goalCreated,

  /// Cantidad de etapas de roadmap completadas.
  stageCompleted,
}

/// Un logro de gamificación. La lista [achievementDefinitions] es el
/// catálogo estático (siempre `isUnlocked: false`); `DbHelper.getAllAchievements`
/// la combina con el estado real guardado en la tabla `achievements`.
class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.type,
    required this.targetValue,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  final String id;
  final String title;
  final String description;
  final String emoji;
  final AchievementType type;
  final int targetValue;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Achievement copyWith({bool? isUnlocked, DateTime? unlockedAt}) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      emoji: emoji,
      type: type,
      targetValue: targetValue,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}

/// Catálogo de todos los logros disponibles en la app.
const List<Achievement> achievementDefinitions = [
  Achievement(
    id: 'primer_dia_perfecto',
    title: 'Primer día perfecto',
    description: 'Alcanza tu primer día en verde.',
    emoji: '🌟',
    type: AchievementType.greenDaysCount,
    targetValue: 1,
  ),
  Achievement(
    id: 'racha_7',
    title: 'Semana de fuego',
    description: '7 días seguidos en verde.',
    emoji: '🔥',
    type: AchievementType.streak,
    targetValue: 7,
  ),
  Achievement(
    id: 'racha_30',
    title: 'Mes de diamante',
    description: '30 días seguidos en verde.',
    emoji: '💎',
    type: AchievementType.streak,
    targetValue: 30,
  ),
  Achievement(
    id: 'id_150',
    title: 'Constante',
    description: 'Tu Índice de Disciplina alcanza 150.',
    emoji: '⚡',
    type: AchievementType.disciplineIndex,
    targetValue: 150,
  ),
  Achievement(
    id: 'id_320',
    title: 'Disciplinado',
    description: 'Tu Índice de Disciplina alcanza 320.',
    emoji: '🔥',
    type: AchievementType.disciplineIndex,
    targetValue: 320,
  ),
  Achievement(
    id: 'id_520',
    title: 'Elite',
    description: 'Tu Índice de Disciplina alcanza 520.',
    emoji: '💎',
    type: AchievementType.disciplineIndex,
    targetValue: 520,
  ),
  Achievement(
    id: '100_actividades',
    title: 'Centenario',
    description: '100 actividades completadas.',
    emoji: '🏆',
    type: AchievementType.activitiesDoneCount,
    targetValue: 100,
  ),
  Achievement(
    id: 'italiano_b1',
    title: 'Italiano B1',
    description: 'Completaste el nivel B1 de italiano.',
    emoji: '🇮🇹',
    type: AchievementType.italianB1,
    targetValue: 1,
  ),
  Achievement(
    id: 'tolc_40',
    title: 'TOLC Superado',
    description: 'Una simulación TOLC-I con 40 puntos o más.',
    emoji: '📝',
    type: AchievementType.examScore,
    targetValue: 40,
  ),
  Achievement(
    id: 'primer_meta',
    title: 'Soñador Real',
    description: 'Creaste tu primera meta de vida.',
    emoji: '🎯',
    type: AchievementType.goalCreated,
    targetValue: 1,
  ),
  Achievement(
    id: 'fase_completada',
    title: 'Fase Maestra',
    description: 'Completaste una etapa de tu roadmap.',
    emoji: '🏅',
    type: AchievementType.stageCompleted,
    targetValue: 1,
  ),
];
