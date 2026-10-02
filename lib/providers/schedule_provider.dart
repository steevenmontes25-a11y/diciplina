import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/constants/schedule_data.dart';
import '../core/models/activity.dart';

part 'schedule_provider.g.dart';

/// Horario maestro completo (sin filtrar por día).
@riverpod
List<Activity> masterActivities(Ref ref) {
  return masterSchedule;
}

/// Actividades del horario para un día de la semana concreto.
@riverpod
List<Activity> scheduleForDay(Ref ref, DayOfWeek day) {
  return getActivitiesForDay(day);
}

/// Actividades del horario para el día de hoy.
@riverpod
List<Activity> todaySchedule(Ref ref) {
  return getActivitiesForDay(todayAsEnum);
}
