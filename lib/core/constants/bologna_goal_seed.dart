import '../database/db_helper.dart';
import '../models/goal.dart';

const String bolognaGoalId = 'goal_bologna_ia';

/// Precarga la meta "Estudiar IA en Università di Bologna" con sus 4 etapas
/// y los planes semanales (últimas 4 semanas + próximas 8), pero solo la
/// primera vez: si la meta ya existe no vuelve a insertarse, para no pisar
/// el progreso que el usuario ya haya guardado.
Future<void> seedBolognaGoal(DbHelper db) async {
  final database = await db.database;
  final existing = await database.query(
    DbHelper.tableLifeGoals,
    where: 'id = ?',
    whereArgs: [bolognaGoalId],
    limit: 1,
  );
  if (existing.isNotEmpty) return;

  final goal = LifeGoal(
    id: bolognaGoalId,
    title: 'Estudiar IA en Università di Bologna',
    description:
        'Roadmap completo para ingresar a la carrera de Inteligencia '
        'Artificial en la Università di Bologna, Italia.',
    emoji: '🎯',
    targetDate: DateTime(2026, 9, 1),
    createdAt: DateTime.now(),
    status: GoalStatus.active,
    university: 'Università di Bologna',
    career: 'Inteligencia Artificial',
    country: '🇮🇹 Italia',
    stages: [_mathStage(), _italianStage(), _tolcStage(), _documentsStage()],
  );

  await db.insertGoal(goal);

  for (final plan in _weeklyPlans(goal.id)) {
    await db.insertWeeklyPlan(plan);
  }
}

/// Etapa 1: Matemáticas.
GoalStage _mathStage() {
  const stageId = 'bologna_stage_1';
  const taskDefs = [
    ('Álgebra lineal básica', TaskStatus.done),
    ('Factorización', TaskStatus.done),
    ('Ecuaciones lineales y cuadráticas', TaskStatus.done),
    ('Radicales y potencias', TaskStatus.pending),
    ('Logaritmos y exponenciales', TaskStatus.pending),
    ('Trigonometría', TaskStatus.pending),
    ('Cálculo diferencial básico', TaskStatus.pending),
    ('Geometría analítica', TaskStatus.pending),
  ];

  return GoalStage(
    id: stageId,
    goalId: bolognaGoalId,
    order: 1,
    title: 'Matemáticas',
    emoji: '📐',
    status: StageStatus.inProgress,
    tasks: _tasksFrom(stageId, taskDefs),
    resources: [
      StageResource(
        id: '${stageId}_r1',
        stageId: stageId,
        title: 'Álgebra desde cero',
        type: ResourceType.video,
        url: 'https://example.com/videos/algebra-desde-cero',
      ),
      StageResource(
        id: '${stageId}_r2',
        stageId: stageId,
        title: 'Formulario matemáticas TOLC-I',
        type: ResourceType.pdf,
        url: 'https://example.com/docs/formulario-tolc-i.pdf',
      ),
      StageResource(
        id: '${stageId}_r3',
        stageId: stageId,
        title: 'Ejercicios de logaritmos',
        type: ResourceType.exercise,
        url: 'https://example.com/ejercicios/logaritmos',
      ),
    ],
  );
}

/// Etapa 2: Italiano (A1 → B2).
GoalStage _italianStage() {
  const stageId = 'bologna_stage_2';
  const taskDefs = [
    ('Nivel A1 completado', TaskStatus.done),
    ('Nivel A2 — en curso', TaskStatus.pending),
    ('Nivel B1', TaskStatus.pending),
    ('Nivel B2 — objetivo final', TaskStatus.pending),
    ('Examen certificación B2', TaskStatus.pending),
  ];

  return GoalStage(
    id: stageId,
    goalId: bolognaGoalId,
    order: 2,
    title: 'Italiano',
    emoji: '🇮🇹',
    status: StageStatus.inProgress,
    tasks: _tasksFrom(stageId, taskDefs),
    resources: [
      StageResource(
        id: '${stageId}_r1',
        stageId: stageId,
        title: 'Italiano para hispanohablantes',
        type: ResourceType.video,
        url: 'https://example.com/videos/italiano-para-hispanohablantes',
      ),
      StageResource(
        id: '${stageId}_r2',
        stageId: stageId,
        title: 'Gramática italiana A2-B1',
        type: ResourceType.pdf,
        url: 'https://example.com/docs/gramatica-italiana-a2-b1.pdf',
      ),
      StageResource(
        id: '${stageId}_r3',
        stageId: stageId,
        title: 'Duolingo Italian track',
        type: ResourceType.link,
        url: 'https://example.com/links/duolingo-italian-track',
      ),
    ],
  );
}

/// Etapa 3: simulaciones TOLC-I (bloqueada hasta terminar matemáticas).
GoalStage _tolcStage() {
  const stageId = 'bologna_stage_3';

  final tasks = <StageTask>[
    for (var i = 1; i <= 40; i++)
      StageTask(
        id: '${stageId}_sim$i',
        stageId: stageId,
        title: 'Simulación $i/40',
        status: TaskStatus.pending,
      ),
    const StageTask(
      id: '${stageId}_meta_promedio',
      stageId: stageId,
      title: 'Alcanzar promedio 40+ puntos',
      status: TaskStatus.pending,
    ),
  ];

  return GoalStage(
    id: stageId,
    goalId: bolognaGoalId,
    order: 3,
    title: 'TOLC-I',
    emoji: '📝',
    status: StageStatus.locked,
    tasks: tasks,
    resources: const [],
  );
}

/// Etapa 4: documentación para la inscripción.
GoalStage _documentsStage() {
  const stageId = 'bologna_stage_4';
  const taskDefs = [
    ('Pasaporte vigente', TaskStatus.done),
    ('Apostilla de documentos', TaskStatus.done),
    ('Acta de grado', TaskStatus.done),
    ('Traducciones oficiales', TaskStatus.pending),
    ('Registro DSU (beca)', TaskStatus.pending),
    ('Carta de motivación', TaskStatus.pending),
    ('Inscripción universitaria', TaskStatus.pending),
    ('Visa de estudiante', TaskStatus.pending),
  ];

  return GoalStage(
    id: stageId,
    goalId: bolognaGoalId,
    order: 4,
    title: 'Documentación',
    emoji: '📋',
    status: StageStatus.locked,
    tasks: _tasksFrom(stageId, taskDefs),
    resources: const [],
  );
}

List<StageTask> _tasksFrom(String stageId, List<(String, TaskStatus)> defs) {
  return [
    for (var i = 0; i < defs.length; i++)
      StageTask(
        id: '${stageId}_t${i + 1}',
        stageId: stageId,
        title: defs[i].$1,
        status: defs[i].$2,
        completedAt: defs[i].$2 == TaskStatus.done ? DateTime.now() : null,
      ),
  ];
}

/// Genera las últimas 4 semanas y las próximas 8 (incluyendo la semana
/// actual), con 3-4 tareas cada una tomadas de un pool representativo.
List<WeeklyPlan> _weeklyPlans(String goalId) {
  final now = DateTime.now();
  final currentMonday = DateTime(
    now.year,
    now.month,
    now.day,
  ).subtract(Duration(days: now.weekday - 1));

  const taskPool = [
    'Completar ejercicios de logaritmos',
    '2 horas de italiano A2',
    'Leer capítulo de física básica',
    'Repasar vocabulario de italiano',
    'Resolver una simulación TOLC-I de práctica',
    'Revisar documentación para la visa',
  ];

  // -4..-1: últimas 4 semanas (ya pasaron). 0..7: semana actual + próximas 7.
  const offsets = [-4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7];

  final plans = <WeeklyPlan>[];
  for (var i = 0; i < offsets.length; i++) {
    final offset = offsets[i];
    final weekStart = currentMonday.add(Duration(days: 7 * offset));
    final weekNumber = i + 1;
    final planId = 'bologna_week_$weekNumber';

    final taskTitles = [
      taskPool[i % taskPool.length],
      taskPool[(i + 1) % taskPool.length],
      taskPool[(i + 2) % taskPool.length],
      if (i.isEven) taskPool[(i + 3) % taskPool.length],
    ];

    // Las semanas ya pasadas se generan como cumplidas; la actual y las
    // futuras, pendientes.
    final isPastWeek = offset < 0;

    plans.add(
      WeeklyPlan(
        id: planId,
        goalId: goalId,
        weekStart: weekStart,
        weekNumber: weekNumber,
        tasks: [
          for (var t = 0; t < taskTitles.length; t++)
            WeeklyTask(
              id: '${planId}_t${t + 1}',
              weeklyPlanId: planId,
              title: taskTitles[t],
              isDone: isPastWeek,
            ),
        ],
      ),
    );
  }

  return plans;
}
