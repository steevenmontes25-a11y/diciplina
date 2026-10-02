import 'package:flutter/material.dart';

/// Estado de una actividad en una fecha concreta.
enum ActivityStatus { pending, done, skipped }

/// Registro del estado de una actividad en una fecha ("yyyy-MM-dd").
class ActivityProgress {
  final String activityId;
  final String date;
  final ActivityStatus status;
  final DateTime? markedAt;

  const ActivityProgress({
    required this.activityId,
    required this.date,
    required this.status,
    this.markedAt,
  });

  ActivityProgress copyWith({
    String? activityId,
    String? date,
    ActivityStatus? status,
    DateTime? markedAt,
  }) {
    return ActivityProgress(
      activityId: activityId ?? this.activityId,
      date: date ?? this.date,
      status: status ?? this.status,
      markedAt: markedAt ?? this.markedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'activity_id': activityId,
      'date': date,
      'status': status.name,
      'marked_at': markedAt?.toIso8601String(),
    };
  }

  factory ActivityProgress.fromMap(Map<String, dynamic> map) {
    return ActivityProgress(
      activityId: map['activity_id'] as String,
      date: map['date'] as String,
      status: ActivityStatus.values.byName(map['status'] as String),
      markedAt: map['marked_at'] != null
          ? DateTime.parse(map['marked_at'] as String)
          : null,
    );
  }
}

/// Estadísticas agregadas de un día completo del horario.
class DayStats {
  final int total;
  final int done;
  final int skipped;

  const DayStats({
    required this.total,
    required this.done,
    required this.skipped,
  });

  double get percentage => total == 0 ? 0 : done / total;

  DisciplineLevel get level => disciplineLevelForPercentage(percentage);
}

/// Nivel de disciplina alcanzado según el porcentaje de actividades hechas.
enum DisciplineLevel { green, yellow, red }

/// Deriva el [DisciplineLevel] correspondiente a un porcentaje (0.0 - 1.0).
DisciplineLevel disciplineLevelForPercentage(double percentage) =>
    switch (percentage) {
      >= 0.8 => DisciplineLevel.green,
      >= 0.4 => DisciplineLevel.yellow,
      _ => DisciplineLevel.red,
    };

extension DisciplineLevelX on DisciplineLevel {
  Color get color => switch (this) {
    DisciplineLevel.green => const Color(0xFF22C55E),
    DisciplineLevel.yellow => const Color(0xFFEAB308),
    DisciplineLevel.red => const Color(0xFFEF4444),
  };

  String get label => switch (this) {
    DisciplineLevel.green => '⭐ SEMANA MAESTRA',
    DisciplineLevel.yellow => '🌱 EN CONSTRUCCIÓN',
    DisciplineLevel.red => '🔥 MODO RECUPERACIÓN',
  };
}
