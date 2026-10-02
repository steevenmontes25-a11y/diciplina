import 'dart:convert';
import 'dart:math' as math;

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../constants/schedule_data.dart';
import '../models/achievement.dart';
import '../models/activity.dart';
import '../models/daily_record.dart';
import '../models/day_progress.dart';
import '../models/goal.dart';
import '../services/discipline_service.dart';

/// Acceso centralizado a la base de datos SQLite de la app.
class DbHelper {
  DbHelper._internal();
  static final DbHelper instance = DbHelper._internal();

  static const String _dbName = 'disciplina_diaria.db';
  static const int _dbVersion = 4;

  static const String tableActivityProgress = 'activity_progress';
  static const String tablePreferences = 'preferences';
  static const String tableNotificationIds = 'notification_ids';
  static const String tableMoodEntries = 'mood_entries';

  // Puntuación y disciplina
  static const String tableDailyRecords = 'daily_records';
  static const String tableDisciplineIndexHistory = 'discipline_index_history';
  static const String tableAchievements = 'achievements';

  // Metas (Roadmaps)
  static const String tableLifeGoals = 'life_goals';
  static const String tableGoalStages = 'goal_stages';
  static const String tableStageTasks = 'stage_tasks';
  static const String tableStageResources = 'stage_resources';
  static const String tableWeeklyPlans = 'weekly_plans';
  static const String tableWeeklyTasks = 'weekly_tasks';
  static const String tableMilestones = 'milestones';
  static const String tableExamSimulations = 'exam_simulations';
  static const String tableAiMentorLogs = 'ai_mentor_logs';

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createCoreTables(db);
    await _createGoalTables(db);
    await _createMoodTable(db);
    await _createDisciplineTables(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Solo agrega tablas nuevas; las existentes (y sus datos) no se tocan.
    if (oldVersion < 2) {
      await _createGoalTables(db);
    }
    if (oldVersion < 3) {
      await _createMoodTable(db);
    }
    if (oldVersion < 4) {
      await _createDisciplineTables(db);
    }
  }

  Future<void> _createMoodTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableMoodEntries (
        date TEXT PRIMARY KEY,
        mood TEXT NOT NULL,
        recorded_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createDisciplineTables(Database db) async {
    await db.execute('''
      CREATE TABLE $tableDailyRecords (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        total_points INTEGER NOT NULL,
        earned_points INTEGER NOT NULL,
        percentage REAL NOT NULL,
        discipline_level TEXT NOT NULL,
        discipline_index REAL NOT NULL,
        mood TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableDisciplineIndexHistory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        index_value REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableAchievements (
        id TEXT PRIMARY KEY,
        unlocked_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createCoreTables(Database db) async {
    await db.execute('''
      CREATE TABLE $tableActivityProgress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        activity_id TEXT NOT NULL,
        date TEXT NOT NULL,
        status TEXT NOT NULL,
        marked_at TEXT,
        UNIQUE(activity_id, date)
      )
    ''');

    await db.execute('''
      CREATE TABLE $tablePreferences (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableNotificationIds (
        activity_id TEXT PRIMARY KEY,
        notification_id INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _createGoalTables(Database db) async {
    await db.execute('''
      CREATE TABLE $tableLifeGoals (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        emoji TEXT NOT NULL,
        target_date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        status TEXT NOT NULL,
        dream_image_path TEXT,
        university TEXT NOT NULL,
        career TEXT NOT NULL,
        country TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableGoalStages (
        id TEXT PRIMARY KEY,
        goal_id TEXT NOT NULL,
        order_num INTEGER NOT NULL,
        title TEXT NOT NULL,
        emoji TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableStageTasks (
        id TEXT PRIMARY KEY,
        stage_id TEXT NOT NULL,
        title TEXT NOT NULL,
        status TEXT NOT NULL,
        completed_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableStageResources (
        id TEXT PRIMARY KEY,
        stage_id TEXT NOT NULL,
        title TEXT NOT NULL,
        type TEXT NOT NULL,
        url TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableWeeklyPlans (
        id TEXT PRIMARY KEY,
        goal_id TEXT NOT NULL,
        week_start TEXT NOT NULL,
        week_number INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableWeeklyTasks (
        id TEXT PRIMARY KEY,
        weekly_plan_id TEXT NOT NULL,
        title TEXT NOT NULL,
        is_done INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableMilestones (
        id TEXT PRIMARY KEY,
        goal_id TEXT NOT NULL,
        stage_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        days_to_complete INTEGER NOT NULL,
        achieved_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableExamSimulations (
        id TEXT PRIMARY KEY,
        goal_id TEXT NOT NULL,
        exam_name TEXT NOT NULL,
        date TEXT NOT NULL,
        score INTEGER NOT NULL,
        max_score INTEGER NOT NULL,
        target_score INTEGER NOT NULL,
        weak_topics TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableAiMentorLogs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        goal_id TEXT NOT NULL,
        message TEXT NOT NULL,
        role TEXT NOT NULL,
        created_at TEXT NOT NULL,
        context_snapshot TEXT
      )
    ''');
  }

  // ---------------------------------------------------------------------
  // activity_progress
  // ---------------------------------------------------------------------

  Future<void> markActivity(
    String date,
    String activityId,
    ActivityStatus status,
  ) async {
    final db = await database;
    await db.insert(
      tableActivityProgress,
      ActivityProgress(
        activityId: activityId,
        date: date,
        status: status,
        markedAt: DateTime.now(),
      ).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ActivityProgress>> getProgressForDate(String date) async {
    final db = await database;
    final rows = await db.query(
      tableActivityProgress,
      where: 'date = ?',
      whereArgs: [date],
    );
    return rows.map(ActivityProgress.fromMap).toList();
  }

  Future<List<ActivityProgress>> getProgressForWeek(
    String startDate,
    String endDate,
  ) async {
    final db = await database;
    final rows = await db.query(
      tableActivityProgress,
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
    );
    return rows.map(ActivityProgress.fromMap).toList();
  }

  Future<DayStats> getDayStats(String date) async {
    final weekday = DateTime.parse(date).weekday;
    final day = DayOfWeek.values[weekday - 1];
    final total = getActivitiesForDay(day).length;

    final progress = await getProgressForDate(date);
    final done = progress.where((p) => p.status == ActivityStatus.done).length;
    final skipped = progress
        .where((p) => p.status == ActivityStatus.skipped)
        .length;

    return DayStats(total: total, done: done, skipped: skipped);
  }

  /// Fecha ("yyyy-MM-dd") más antigua con al menos un registro de progreso,
  /// o `null` si todavía no se ha marcado ninguna actividad.
  Future<String?> getEarliestProgressDate() async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT MIN(date) as earliest FROM $tableActivityProgress',
    );
    return rows.first['earliest'] as String?;
  }

  /// Cantidad de veces que se marcó cada actividad con [status], agrupado
  /// por `activityId`, considerando todo el historial.
  Future<Map<String, int>> getActivityCountsByStatus(
    ActivityStatus status,
  ) async {
    final db = await database;
    final rows = await db.rawQuery(
      '''
      SELECT activity_id, COUNT(*) as count FROM $tableActivityProgress
      WHERE status = ?
      GROUP BY activity_id
      ''',
      [status.name],
    );
    return {
      for (final r in rows) r['activity_id'] as String: r['count'] as int,
    };
  }

  /// Igual que [getActivityCountsByStatus] pero acotado a un rango de
  /// fechas (ambas inclusive).
  Future<Map<String, int>> getActivityCountsByStatusBetween(
    ActivityStatus status,
    String start,
    String end,
  ) async {
    final db = await database;
    final rows = await db.rawQuery(
      '''
      SELECT activity_id, COUNT(*) as count FROM $tableActivityProgress
      WHERE status = ? AND date BETWEEN ? AND ?
      GROUP BY activity_id
      ''',
      [status.name, start, end],
    );
    return {
      for (final r in rows) r['activity_id'] as String: r['count'] as int,
    };
  }

  // ---------------------------------------------------------------------
  // preferences
  // ---------------------------------------------------------------------

  Future<String?> getPreference(String key) async {
    final db = await database;
    final rows = await db.query(
      tablePreferences,
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['value'] as String;
  }

  Future<void> setPreference(String key, String value) async {
    final db = await database;
    await db.insert(tablePreferences, {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ---------------------------------------------------------------------
  // notification_ids
  // ---------------------------------------------------------------------

  Future<int?> getNotificationId(String activityId) async {
    final db = await database;
    final rows = await db.query(
      tableNotificationIds,
      where: 'activity_id = ?',
      whereArgs: [activityId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['notification_id'] as int;
  }

  Future<void> setNotificationId(String activityId, int notificationId) async {
    final db = await database;
    await db.insert(tableNotificationIds, {
      'activity_id': activityId,
      'notification_id': notificationId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteNotificationId(String activityId) async {
    final db = await database;
    await db.delete(
      tableNotificationIds,
      where: 'activity_id = ?',
      whereArgs: [activityId],
    );
  }

  // ---------------------------------------------------------------------
  // Metas (Roadmaps): life_goals, goal_stages, stage_tasks, stage_resources
  // ---------------------------------------------------------------------

  /// Inserta una meta junto con todas sus etapas, tareas y recursos.
  Future<void> insertGoal(LifeGoal goal) async {
    final db = await database;
    await db.insert(
      tableLifeGoals,
      goal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    for (final stage in goal.stages) {
      await _insertStage(db, stage);
    }
  }

  Future<void> _insertStage(Database db, GoalStage stage) async {
    await db.insert(
      tableGoalStages,
      stage.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    for (final task in stage.tasks) {
      await db.insert(
        tableStageTasks,
        task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    for (final resource in stage.resources) {
      await db.insert(
        tableStageResources,
        resource.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<List<GoalStage>> _getStagesForGoal(Database db, String goalId) async {
    final stageRows = await db.query(
      tableGoalStages,
      where: 'goal_id = ?',
      whereArgs: [goalId],
      orderBy: 'order_num ASC',
    );

    final stages = <GoalStage>[];
    for (final stageRow in stageRows) {
      final stageId = stageRow['id'] as String;
      final taskRows = await db.query(
        tableStageTasks,
        where: 'stage_id = ?',
        whereArgs: [stageId],
      );
      final resourceRows = await db.query(
        tableStageResources,
        where: 'stage_id = ?',
        whereArgs: [stageId],
      );
      stages.add(
        GoalStage.fromMap(
          stageRow,
          tasks: taskRows.map(StageTask.fromMap).toList(),
          resources: resourceRows.map(StageResource.fromMap).toList(),
        ),
      );
    }
    return stages;
  }

  /// Etapas (con sus tareas y recursos) de una meta concreta.
  Future<List<GoalStage>> getStagesForGoal(String goalId) async {
    final db = await database;
    return _getStagesForGoal(db, goalId);
  }

  Future<List<LifeGoal>> getAllGoals() async {
    final db = await database;
    final rows = await db.query(tableLifeGoals, orderBy: 'created_at ASC');

    final goals = <LifeGoal>[];
    for (final row in rows) {
      final stages = await _getStagesForGoal(db, row['id'] as String);
      goals.add(LifeGoal.fromMap(row, stages: stages));
    }
    return goals;
  }

  /// La meta activa más antigua (normalmente solo hay una a la vez).
  Future<LifeGoal?> getActiveGoal() async {
    final db = await database;
    final rows = await db.query(
      tableLifeGoals,
      where: 'status = ?',
      whereArgs: [GoalStatus.active.name],
      orderBy: 'created_at ASC',
      limit: 1,
    );
    if (rows.isEmpty) return null;

    final stages = await _getStagesForGoal(db, rows.first['id'] as String);
    return LifeGoal.fromMap(rows.first, stages: stages);
  }

  Future<void> updateStageStatus(String stageId, StageStatus status) async {
    final db = await database;
    await db.update(
      tableGoalStages,
      {'status': status.name},
      where: 'id = ?',
      whereArgs: [stageId],
    );
  }

  Future<void> completeTask(String taskId) async {
    final db = await database;
    await db.update(
      tableStageTasks,
      {
        'status': TaskStatus.done.name,
        'completed_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  /// Agrega una tarea nueva a una etapa ya existente.
  Future<void> insertStageTask(StageTask task) async {
    final db = await database;
    await db.insert(
      tableStageTasks,
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Agrega un recurso nuevo a una etapa ya existente.
  Future<void> insertStageResource(StageResource resource) async {
    final db = await database;
    await db.insert(
      tableStageResources,
      resource.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Actualiza solo la foto del sueño de una meta (sin tocar sus etapas).
  Future<void> updateGoalDreamImagePath(String goalId, String path) async {
    final db = await database;
    await db.update(
      tableLifeGoals,
      {'dream_image_path': path},
      where: 'id = ?',
      whereArgs: [goalId],
    );
  }

  // ---------------------------------------------------------------------
  // Planes semanales: weekly_plans, weekly_tasks
  // ---------------------------------------------------------------------

  /// Inserta un plan semanal junto con todas sus tareas.
  Future<void> insertWeeklyPlan(WeeklyPlan plan) async {
    final db = await database;
    await db.insert(
      tableWeeklyPlans,
      plan.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    for (final task in plan.tasks) {
      await db.insert(
        tableWeeklyTasks,
        task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  /// El plan semanal cuyo lunes coincide con el de la semana actual, o
  /// `null` si todavía no se generó ninguno para esta semana.
  Future<WeeklyPlan?> getCurrentWeekPlan(String goalId) async {
    final db = await database;
    final now = DateTime.now();
    final monday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));

    final rows = await db.query(
      tableWeeklyPlans,
      where: 'goal_id = ? AND week_start = ?',
      whereArgs: [goalId, monday.toIso8601String()],
      limit: 1,
    );
    if (rows.isEmpty) return null;

    final planId = rows.first['id'] as String;
    final taskRows = await db.query(
      tableWeeklyTasks,
      where: 'weekly_plan_id = ?',
      whereArgs: [planId],
    );
    return WeeklyPlan.fromMap(
      rows.first,
      tasks: taskRows.map(WeeklyTask.fromMap).toList(),
    );
  }

  Future<void> toggleWeeklyTask(String taskId, bool isDone) async {
    final db = await database;
    await db.update(
      tableWeeklyTasks,
      {'is_done': isDone ? 1 : 0},
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  // ---------------------------------------------------------------------
  // exam_simulations
  // ---------------------------------------------------------------------

  Future<void> insertSimulation(ExamSimulation sim) async {
    final db = await database;
    await db.insert(
      tableExamSimulations,
      sim.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ExamSimulation>> getSimulations(String goalId) async {
    final db = await database;
    final rows = await db.query(
      tableExamSimulations,
      where: 'goal_id = ?',
      whereArgs: [goalId],
      orderBy: 'date ASC',
    );
    return rows.map(ExamSimulation.fromMap).toList();
  }

  // ---------------------------------------------------------------------
  // milestones
  // ---------------------------------------------------------------------

  Future<void> insertMilestone(Milestone milestone) async {
    final db = await database;
    await db.insert(
      tableMilestones,
      milestone.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Milestone>> getMilestones(String goalId) async {
    final db = await database;
    final rows = await db.query(
      tableMilestones,
      where: 'goal_id = ?',
      whereArgs: [goalId],
      orderBy: 'achieved_at ASC',
    );
    return rows.map(Milestone.fromMap).toList();
  }

  // ---------------------------------------------------------------------
  // ai_mentor_logs
  // ---------------------------------------------------------------------

  Future<void> saveAiMessage(
    String goalId,
    String message,
    String role,
    Map<String, dynamic> context,
  ) async {
    final db = await database;
    await db.insert(tableAiMentorLogs, {
      'goal_id': goalId,
      'message': message,
      'role': role,
      'created_at': DateTime.now().toIso8601String(),
      'context_snapshot': jsonEncode(context),
    });
  }

  Future<List<Map<String, dynamic>>> getAiHistory(
    String goalId, {
    int limit = 20,
  }) async {
    final db = await database;
    return db.query(
      tableAiMentorLogs,
      where: 'goal_id = ?',
      whereArgs: [goalId],
      orderBy: 'created_at DESC',
      limit: limit,
    );
  }

  // ---------------------------------------------------------------------
  // mood_entries
  // ---------------------------------------------------------------------

  Future<void> setMoodForDate(String date, String mood) async {
    final db = await database;
    await db.insert(tableMoodEntries, {
      'date': date,
      'mood': mood,
      'recorded_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getMoodForDate(String date) async {
    final db = await database;
    final rows = await db.query(
      tableMoodEntries,
      where: 'date = ?',
      whereArgs: [date],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['mood'] as String;
  }

  // ---------------------------------------------------------------------
  // daily_records / discipline_index_history / achievements
  // ---------------------------------------------------------------------

  static const DisciplineService _disciplineService = DisciplineService();

  /// Cierra el día [date] ("yyyy-MM-dd"): calcula sus puntos/porcentaje/nivel,
  /// actualiza el Índice de Disciplina, guarda ambos registros históricos y
  /// verifica si se desbloqueó algún logro. Se puede llamar más de una vez
  /// para el mismo día (p. ej. si el usuario sigue marcando actividades
  /// después de cerrarlo): vuelve a calcular todo y reemplaza el registro.
  Future<DayCloseResult> closeDayRecord(String date) async {
    final db = await database;

    final weekday = DateTime.parse(date).weekday;
    final day = DayOfWeek.values[weekday - 1];
    final activities = getActivitiesForDay(day);
    final progresses = await getProgressForDate(date);

    final percentage = _disciplineService.calculateDayPercentage(
      progresses,
      activities,
    );
    final level = _disciplineService.levelForPercentage(percentage);
    final totalPoints = activities.fold(0, (sum, a) => sum + a.points);
    final earnedPoints = (percentage * totalPoints).round();
    final mood = await getMoodForDate(date);

    final previousIndex = await _latestDisciplineIndexBefore(date);
    double disciplineIndex;
    if (previousIndex == null) {
      // Arranque en frío: todavía no hay un ID previo del cual partir, así
      // que se recalcula desde el historial completo (incluyendo hoy).
      final priorRecords = await _dailyRecordsBefore(date);
      final streakSoFar = _greenStreakFromRecords(priorRecords, level);
      final bootstrapHistory = [
        ...priorRecords,
        DailyRecord(
          id: 0,
          date: date,
          totalPoints: totalPoints,
          earnedPoints: earnedPoints,
          percentage: percentage,
          disciplineLevel: level,
          disciplineIndex: 0,
          mood: mood,
          createdAt: DateTime.now(),
        ),
      ];
      disciplineIndex = _disciplineService.calculateDisciplineIndex(
        bootstrapHistory,
        currentStreak: streakSoFar,
      );
    } else {
      final delta = _disciplineService.idDelta(level, previousIndex);
      disciplineIndex = math.min(math.max(previousIndex + delta, 0.0), 1000.0);
    }

    await db.insert(tableDailyRecords, {
      'date': date,
      'total_points': totalPoints,
      'earned_points': earnedPoints,
      'percentage': percentage,
      'discipline_level': level.name,
      'discipline_index': disciplineIndex,
      'mood': mood,
      'created_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    await db.insert(tableDisciplineIndexHistory, {
      'date': date,
      'index_value': disciplineIndex,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    // La racha ya incluye el registro de hoy recién guardado.
    final currentStreak = await _greenStreakUpTo(date);
    final unlocked = await checkAndUnlockAchievements(date);

    return DayCloseResult(
      date: date,
      percentage: percentage,
      level: level,
      totalPoints: totalPoints,
      earnedPoints: earnedPoints,
      disciplineIndex: disciplineIndex,
      disciplineIndexDelta: previousIndex == null
          ? disciplineIndex
          : disciplineIndex - previousIndex,
      currentStreak: currentStreak,
      newlyUnlockedAchievements: unlocked,
    );
  }

  /// Compara el estado actual contra [achievementDefinitions] y desbloquea
  /// (persiste) los que se cumplen por primera vez a la fecha [date].
  /// Devuelve solo los que se desbloquearon en esta llamada.
  Future<List<Achievement>> checkAndUnlockAchievements(String date) async {
    final unlockedIds = await getUnlockedAchievementIds();
    final newlyUnlocked = <Achievement>[];

    final greenDays = await _countWhere(
      tableDailyRecords,
      "discipline_level = 'green'",
    );
    final doneActivities = await _countWhere(
      tableActivityProgress,
      "status = 'done'",
    );
    final goalsCount = await _countWhere(tableLifeGoals, null);
    final completedStages = await _countWhere(
      tableGoalStages,
      "status = 'completed'",
    );
    final italianB1Done =
        await _countWhere(
          tableStageTasks,
          "title LIKE '%Nivel B1%' AND status = 'done'",
        ) >
        0;
    final tolc40Reached =
        await _countWhere(tableExamSimulations, 'score >= 40') > 0;
    final streak = await _greenStreakUpTo(date);
    final index = await _latestDisciplineIndexAsOf(date);

    bool isMet(Achievement def) => switch (def.type) {
      AchievementType.greenDaysCount => greenDays >= def.targetValue,
      AchievementType.streak => streak >= def.targetValue,
      AchievementType.disciplineIndex => index >= def.targetValue,
      AchievementType.activitiesDoneCount => doneActivities >= def.targetValue,
      AchievementType.italianB1 => italianB1Done,
      AchievementType.examScore => tolc40Reached,
      AchievementType.goalCreated => goalsCount >= def.targetValue,
      AchievementType.stageCompleted => completedStages >= def.targetValue,
    };

    for (final def in achievementDefinitions) {
      if (unlockedIds.contains(def.id)) continue;
      if (!isMet(def)) continue;
      await unlockAchievement(def.id);
      newlyUnlocked.add(
        def.copyWith(isUnlocked: true, unlockedAt: DateTime.now()),
      );
    }

    return newlyUnlocked;
  }

  /// Todos los logros del catálogo, combinados con su estado real de
  /// desbloqueo guardado en BD.
  Future<List<Achievement>> getAllAchievements() async {
    final db = await database;
    final rows = await db.query(tableAchievements);
    final unlockedAt = {
      for (final r in rows)
        r['id'] as String: DateTime.parse(r['unlocked_at'] as String),
    };
    return achievementDefinitions.map((def) {
      final at = unlockedAt[def.id];
      return at == null ? def : def.copyWith(isUnlocked: true, unlockedAt: at);
    }).toList();
  }

  Future<Set<String>> getUnlockedAchievementIds() async {
    final db = await database;
    final rows = await db.query(tableAchievements);
    return rows.map((r) => r['id'] as String).toSet();
  }

  Future<void> unlockAchievement(String id) async {
    final db = await database;
    await db.insert(tableAchievements, {
      'id': id,
      'unlocked_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  /// El [DailyRecord] guardado para [date], o `null` si ese día no se
  /// cerró todavía.
  Future<DailyRecord?> getDailyRecord(String date) async {
    final db = await database;
    final rows = await db.query(
      tableDailyRecords,
      where: 'date = ?',
      whereArgs: [date],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return DailyRecord.fromMap(rows.first);
  }

  /// Fecha ("yyyy-MM-dd") del último día cerrado con `closeDayRecord`, o
  /// `null` si todavía no se cerró ninguno. Usado para saber desde dónde
  /// completar (backfill) los días que faltan al abrir la app.
  Future<String?> getLatestDailyRecordDate() async {
    final db = await database;
    final rows = await db.query(
      tableDailyRecords,
      orderBy: 'date DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['date'] as String;
  }

  /// Los [DailyRecord] cerrados entre [start] y [end] (ambos inclusive),
  /// ascendente por fecha. Días sin cerrar simplemente no aparecen.
  Future<List<DailyRecord>> getDailyRecordsBetween(
    String start,
    String end,
  ) async {
    final db = await database;
    final rows = await db.query(
      tableDailyRecords,
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start, end],
      orderBy: 'date ASC',
    );
    return rows.map(DailyRecord.fromMap).toList();
  }

  /// Historial de valores del Índice de Disciplina, ascendente por fecha
  /// (para graficar su evolución).
  Future<List<({String date, double indexValue})>>
  getDisciplineIndexHistory() async {
    final db = await database;
    final rows = await db.query(
      tableDisciplineIndexHistory,
      orderBy: 'date ASC',
    );
    return rows
        .map(
          (r) => (
            date: r['date'] as String,
            indexValue: (r['index_value'] as num).toDouble(),
          ),
        )
        .toList();
  }

  Future<List<DailyRecord>> _dailyRecordsBefore(String date) async {
    final db = await database;
    final rows = await db.query(
      tableDailyRecords,
      where: 'date < ?',
      whereArgs: [date],
      orderBy: 'date ASC',
    );
    return rows.map(DailyRecord.fromMap).toList();
  }

  /// Racha de días verdes consecutivos terminando en [date] (inclusive),
  /// leída de `daily_records`.
  Future<int> _greenStreakUpTo(String date) async {
    final db = await database;
    final rows = await db.query(
      tableDailyRecords,
      where: 'date <= ?',
      whereArgs: [date],
      orderBy: 'date DESC',
    );
    var streak = 0;
    for (final row in rows) {
      if (row['discipline_level'] != DisciplineLevel.green.name) break;
      streak++;
    }
    return streak;
  }

  /// Igual que [_greenStreakUpTo] pero para el arranque en frío, cuando el
  /// registro de hoy ([todayLevel]) todavía no está guardado en BD.
  int _greenStreakFromRecords(
    List<DailyRecord> priorRecordsAscending,
    DisciplineLevel todayLevel,
  ) {
    var streak = todayLevel == DisciplineLevel.green ? 1 : 0;
    if (streak == 0) return 0;
    for (var i = priorRecordsAscending.length - 1; i >= 0; i--) {
      if (priorRecordsAscending[i].disciplineLevel != DisciplineLevel.green) {
        break;
      }
      streak++;
    }
    return streak;
  }

  Future<double?> _latestDisciplineIndexBefore(String date) async {
    final db = await database;
    final rows = await db.query(
      tableDisciplineIndexHistory,
      where: 'date < ?',
      whereArgs: [date],
      orderBy: 'date DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return (rows.first['index_value'] as num).toDouble();
  }

  /// El último valor guardado del Índice de Disciplina (el de la última
  /// vez que se cerró un día), o 0 si todavía no se cerró ninguno.
  /// A diferencia de [closeDayRecord], esto es de solo lectura: no
  /// recalcula ni desbloquea logros.
  Future<double> getLatestDisciplineIndex() async {
    final db = await database;
    final rows = await db.query(
      tableDisciplineIndexHistory,
      orderBy: 'date DESC',
      limit: 1,
    );
    if (rows.isEmpty) return 0;
    return (rows.first['index_value'] as num).toDouble();
  }

  Future<double> _latestDisciplineIndexAsOf(String date) async {
    final db = await database;
    final rows = await db.query(
      tableDisciplineIndexHistory,
      where: 'date <= ?',
      whereArgs: [date],
      orderBy: 'date DESC',
      limit: 1,
    );
    if (rows.isEmpty) return 0;
    return (rows.first['index_value'] as num).toDouble();
  }

  Future<int> _countWhere(String table, String? whereClause) async {
    final db = await database;
    final sql = whereClause == null
        ? 'SELECT COUNT(*) as c FROM $table'
        : 'SELECT COUNT(*) as c FROM $table WHERE $whereClause';
    final rows = await db.rawQuery(sql);
    return Sqflite.firstIntValue(rows) ?? 0;
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
