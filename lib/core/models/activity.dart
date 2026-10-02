import 'package:flutter/material.dart';

/// Categorías de actividad del horario maestro.
enum ActivityCategory {
  salud,
  ejercicio,
  trabajo,
  musica,
  hogar,
  estudio,
  reunion,
  descanso,
  traslado,
}

extension ActivityCategoryX on ActivityCategory {
  Color get color => switch (this) {
    ActivityCategory.salud => const Color(0xFF06B6D4),
    ActivityCategory.ejercicio => const Color(0xFFF97316),
    ActivityCategory.trabajo => const Color(0xFF4F46E5),
    ActivityCategory.musica => const Color(0xFFA855F7),
    ActivityCategory.hogar => const Color(0xFFEAB308),
    ActivityCategory.estudio => const Color(0xFF22C55E),
    ActivityCategory.reunion => const Color(0xFF3B82F6),
    ActivityCategory.descanso => const Color(0xFF6B7280),
    ActivityCategory.traslado => const Color(0xFFEC4899),
  };

  String get label => switch (this) {
    ActivityCategory.salud => 'Salud',
    ActivityCategory.ejercicio => 'Ejercicio',
    ActivityCategory.trabajo => 'Trabajo',
    ActivityCategory.musica => 'Música',
    ActivityCategory.hogar => 'Hogar',
    ActivityCategory.estudio => 'Estudio',
    ActivityCategory.reunion => 'Reunión',
    ActivityCategory.descanso => 'Descanso',
    ActivityCategory.traslado => 'Traslado',
  };

  IconData get icon => switch (this) {
    ActivityCategory.salud => Icons.favorite_rounded,
    ActivityCategory.ejercicio => Icons.fitness_center_rounded,
    ActivityCategory.trabajo => Icons.computer_rounded,
    ActivityCategory.musica => Icons.music_note_rounded,
    ActivityCategory.hogar => Icons.home_rounded,
    ActivityCategory.estudio => Icons.school_rounded,
    ActivityCategory.reunion => Icons.people_rounded,
    ActivityCategory.descanso => Icons.bedtime_rounded,
    ActivityCategory.traslado => Icons.directions_car_rounded,
  };
}

/// Días de la semana usados por el horario maestro.
enum DayOfWeek { lunes, martes, miercoles, jueves, viernes, sabado, domingo }

extension DayOfWeekX on DayOfWeek {
  /// Equivalente a [DateTime.weekday] (1 = lunes ... 7 = domingo).
  int get isoWeekday => index + 1;

  String get label => switch (this) {
    DayOfWeek.lunes => 'Lunes',
    DayOfWeek.martes => 'Martes',
    DayOfWeek.miercoles => 'Miércoles',
    DayOfWeek.jueves => 'Jueves',
    DayOfWeek.viernes => 'Viernes',
    DayOfWeek.sabado => 'Sábado',
    DayOfWeek.domingo => 'Domingo',
  };
}

/// Representa una actividad del horario maestro (plantilla), asociada a
/// uno o más días de la semana.
class Activity {
  final String id;
  final String timeStart; // formato "HH:mm"
  final String timeEnd; // formato "HH:mm"
  final String title;
  final String description;
  final ActivityCategory category;
  final bool isAlarmEnabled;
  final List<DayOfWeek> days;

  /// Peso de esta actividad en el cálculo de disciplina del día: cuánto
  /// aporta completarla al porcentaje de puntos del día.
  final int points;

  const Activity({
    required this.id,
    required this.timeStart,
    required this.timeEnd,
    required this.title,
    required this.description,
    required this.category,
    required this.points,
    this.isAlarmEnabled = false,
    required this.days,
  });

  TimeOfDay get startTime => _parseTime(timeStart);

  TimeOfDay get endTime => _parseTime(timeEnd);

  /// Duración de la actividad. Si [timeEnd] es menor o igual a [timeStart]
  /// se asume que cruza la medianoche.
  Duration get duration {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    var endMinutes = endTime.hour * 60 + endTime.minute;
    if (endMinutes <= startMinutes) endMinutes += 24 * 60;
    return Duration(minutes: endMinutes - startMinutes);
  }

  /// Etiqueta corta de la duración, p. ej. "3h", "45min" o "1h 30min".
  String get durationLabel {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours == 0) return '${minutes}min';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}min';
  }

  /// Si [time] cae dentro del rango `[timeStart, timeEnd)` de esta actividad.
  /// Asume que cruza la medianoche si [timeEnd] es menor o igual a
  /// [timeStart].
  bool isHappeningAt(TimeOfDay time) {
    final minutes = time.hour * 60 + time.minute;
    final startMinutes = startTime.hour * 60 + startTime.minute;
    var endMinutes = endTime.hour * 60 + endTime.minute;
    if (endMinutes <= startMinutes) endMinutes += 24 * 60;
    return minutes >= startMinutes && minutes < endMinutes;
  }

  TimeOfDay _parseTime(String value) {
    final parts = value.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}
