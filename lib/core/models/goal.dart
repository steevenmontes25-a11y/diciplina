import 'dart:convert';

/// Estado general de una [LifeGoal].
enum GoalStatus { active, completed, paused, abandoned }

/// Estado de avance de una [GoalStage] dentro de su meta.
enum StageStatus { locked, inProgress, completed }

/// Estado de una tarea puntual ([StageTask] o [WeeklyTask]).
enum TaskStatus { pending, done, skipped }

/// Tipo de material de apoyo de una [StageResource].
enum ResourceType { video, pdf, exercise, link, book }

/// Una meta de vida de largo plazo (roadmap), con sus etapas.
class LifeGoal {
  const LifeGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.targetDate,
    required this.createdAt,
    required this.status,
    this.dreamImagePath,
    required this.university,
    required this.career,
    required this.country,
    this.stages = const [],
  });

  final String id;
  final String title;
  final String description;
  final String emoji;
  final DateTime targetDate;
  final DateTime createdAt;
  final GoalStatus status;
  final String? dreamImagePath;
  final String university;
  final String career;
  final String country;
  final List<GoalStage> stages;

  LifeGoal copyWith({
    String? id,
    String? title,
    String? description,
    String? emoji,
    DateTime? targetDate,
    DateTime? createdAt,
    GoalStatus? status,
    String? dreamImagePath,
    String? university,
    String? career,
    String? country,
    List<GoalStage>? stages,
  }) {
    return LifeGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      dreamImagePath: dreamImagePath ?? this.dreamImagePath,
      university: university ?? this.university,
      career: career ?? this.career,
      country: country ?? this.country,
      stages: stages ?? this.stages,
    );
  }

  /// Columnas propias de `life_goals`. Las etapas viven en sus propias
  /// tablas y se guardan/leen por separado.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'emoji': emoji,
      'target_date': targetDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'status': status.name,
      'dream_image_path': dreamImagePath,
      'university': university,
      'career': career,
      'country': country,
    };
  }

  factory LifeGoal.fromMap(
    Map<String, dynamic> map, {
    List<GoalStage> stages = const [],
  }) {
    return LifeGoal(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      emoji: map['emoji'] as String,
      targetDate: DateTime.parse(map['target_date'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      status: GoalStatus.values.byName(map['status'] as String),
      dreamImagePath: map['dream_image_path'] as String?,
      university: map['university'] as String,
      career: map['career'] as String,
      country: map['country'] as String,
      stages: stages,
    );
  }
}

/// Una etapa dentro del roadmap de una [LifeGoal].
class GoalStage {
  const GoalStage({
    required this.id,
    required this.goalId,
    required this.order,
    required this.title,
    required this.emoji,
    required this.status,
    this.tasks = const [],
    this.resources = const [],
  });

  final String id;
  final String goalId;
  final int order;
  final String title;
  final String emoji;
  final StageStatus status;
  final List<StageTask> tasks;
  final List<StageResource> resources;

  /// Progreso (0.0 - 1.0) según cuántas tareas están hechas.
  double get progress => tasks.isEmpty
      ? 0
      : tasks.where((t) => t.status == TaskStatus.done).length / tasks.length;

  GoalStage copyWith({
    String? id,
    String? goalId,
    int? order,
    String? title,
    String? emoji,
    StageStatus? status,
    List<StageTask>? tasks,
    List<StageResource>? resources,
  }) {
    return GoalStage(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      order: order ?? this.order,
      title: title ?? this.title,
      emoji: emoji ?? this.emoji,
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      resources: resources ?? this.resources,
    );
  }

  /// Columnas propias de `goal_stages` (tareas y recursos van aparte).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goal_id': goalId,
      'order_num': order,
      'title': title,
      'emoji': emoji,
      'status': status.name,
    };
  }

  factory GoalStage.fromMap(
    Map<String, dynamic> map, {
    List<StageTask> tasks = const [],
    List<StageResource> resources = const [],
  }) {
    return GoalStage(
      id: map['id'] as String,
      goalId: map['goal_id'] as String,
      order: map['order_num'] as int,
      title: map['title'] as String,
      emoji: map['emoji'] as String,
      status: StageStatus.values.byName(map['status'] as String),
      tasks: tasks,
      resources: resources,
    );
  }
}

/// Una tarea puntual dentro de una [GoalStage].
class StageTask {
  const StageTask({
    required this.id,
    required this.stageId,
    required this.title,
    required this.status,
    this.completedAt,
  });

  final String id;
  final String stageId;
  final String title;
  final TaskStatus status;
  final DateTime? completedAt;

  StageTask copyWith({
    String? id,
    String? stageId,
    String? title,
    TaskStatus? status,
    DateTime? completedAt,
  }) {
    return StageTask(
      id: id ?? this.id,
      stageId: stageId ?? this.stageId,
      title: title ?? this.title,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'stage_id': stageId,
      'title': title,
      'status': status.name,
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  factory StageTask.fromMap(Map<String, dynamic> map) {
    return StageTask(
      id: map['id'] as String,
      stageId: map['stage_id'] as String,
      title: map['title'] as String,
      status: TaskStatus.values.byName(map['status'] as String),
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
    );
  }
}

/// Material de apoyo (video, pdf, ejercicio, link, libro) de una [GoalStage].
class StageResource {
  const StageResource({
    required this.id,
    required this.stageId,
    required this.title,
    required this.type,
    required this.url,
  });

  final String id;
  final String stageId;
  final String title;
  final ResourceType type;
  final String url;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'stage_id': stageId,
      'title': title,
      'type': type.name,
      'url': url,
    };
  }

  factory StageResource.fromMap(Map<String, dynamic> map) {
    return StageResource(
      id: map['id'] as String,
      stageId: map['stage_id'] as String,
      title: map['title'] as String,
      type: ResourceType.values.byName(map['type'] as String),
      url: map['url'] as String,
    );
  }
}

/// Plan semanal de tareas asociado a una [LifeGoal].
class WeeklyPlan {
  const WeeklyPlan({
    required this.id,
    required this.goalId,
    required this.weekStart,
    required this.weekNumber,
    this.tasks = const [],
  });

  final String id;
  final String goalId;
  final DateTime weekStart;
  final int weekNumber;
  final List<WeeklyTask> tasks;

  /// Columnas propias de `weekly_plans` (las tareas van aparte).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goal_id': goalId,
      'week_start': weekStart.toIso8601String(),
      'week_number': weekNumber,
    };
  }

  factory WeeklyPlan.fromMap(
    Map<String, dynamic> map, {
    List<WeeklyTask> tasks = const [],
  }) {
    return WeeklyPlan(
      id: map['id'] as String,
      goalId: map['goal_id'] as String,
      weekStart: DateTime.parse(map['week_start'] as String),
      weekNumber: map['week_number'] as int,
      tasks: tasks,
    );
  }
}

/// Una tarea dentro de un [WeeklyPlan].
class WeeklyTask {
  const WeeklyTask({
    required this.id,
    required this.weeklyPlanId,
    required this.title,
    required this.isDone,
  });

  final String id;
  final String weeklyPlanId;
  final String title;
  final bool isDone;

  WeeklyTask copyWith({
    String? id,
    String? weeklyPlanId,
    String? title,
    bool? isDone,
  }) {
    return WeeklyTask(
      id: id ?? this.id,
      weeklyPlanId: weeklyPlanId ?? this.weeklyPlanId,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'weekly_plan_id': weeklyPlanId,
      'title': title,
      'is_done': isDone ? 1 : 0,
    };
  }

  factory WeeklyTask.fromMap(Map<String, dynamic> map) {
    return WeeklyTask(
      id: map['id'] as String,
      weeklyPlanId: map['weekly_plan_id'] as String,
      title: map['title'] as String,
      isDone: (map['is_done'] as int) == 1,
    );
  }
}

/// Un logro alcanzado dentro del roadmap de una [LifeGoal].
class Milestone {
  const Milestone({
    required this.id,
    required this.goalId,
    required this.stageId,
    required this.title,
    required this.description,
    required this.daysToComplete,
    required this.achievedAt,
  });

  final String id;
  final String goalId;
  final String stageId;
  final String title;
  final String description;
  final int daysToComplete;
  final DateTime achievedAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goal_id': goalId,
      'stage_id': stageId,
      'title': title,
      'description': description,
      'days_to_complete': daysToComplete,
      'achieved_at': achievedAt.toIso8601String(),
    };
  }

  factory Milestone.fromMap(Map<String, dynamic> map) {
    return Milestone(
      id: map['id'] as String,
      goalId: map['goal_id'] as String,
      stageId: map['stage_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      daysToComplete: map['days_to_complete'] as int,
      achievedAt: DateTime.parse(map['achieved_at'] as String),
    );
  }
}

/// Resultado de una simulación de examen (p. ej. TOLC-I) para una [LifeGoal].
class ExamSimulation {
  const ExamSimulation({
    required this.id,
    required this.goalId,
    required this.examName,
    required this.date,
    required this.score,
    required this.maxScore,
    required this.targetScore,
    this.weakTopics = const [],
  });

  final String id;
  final String goalId;
  final String examName;
  final DateTime date;
  final int score;
  final int maxScore;
  final int targetScore;
  final List<String> weakTopics;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goal_id': goalId,
      'exam_name': examName,
      'date': date.toIso8601String(),
      'score': score,
      'max_score': maxScore,
      'target_score': targetScore,
      'weak_topics': jsonEncode(weakTopics),
    };
  }

  factory ExamSimulation.fromMap(Map<String, dynamic> map) {
    return ExamSimulation(
      id: map['id'] as String,
      goalId: map['goal_id'] as String,
      examName: map['exam_name'] as String,
      date: DateTime.parse(map['date'] as String),
      score: map['score'] as int,
      maxScore: map['max_score'] as int,
      targetScore: map['target_score'] as int,
      weakTopics: (jsonDecode(map['weak_topics'] as String) as List)
          .cast<String>(),
    );
  }
}
