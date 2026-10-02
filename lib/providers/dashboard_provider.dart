import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/database/db_helper.dart';
import '../core/models/activity.dart';
import 'mentor_provider.dart' show mentorUserNamePrefKey;
import 'schedule_provider.dart';

part 'dashboard_provider.g.dart';

String _today() => DateFormat('yyyy-MM-dd').format(DateTime.now());

/// La actividad del horario de hoy que está sucediendo ahora mismo, o
/// `null` si no hay ninguna en curso.
@riverpod
Activity? currentActivity(Ref ref) {
  final activities = ref.watch(todayScheduleProvider);
  final now = TimeOfDay.fromDateTime(DateTime.now());
  for (final activity in activities) {
    if (activity.isHappeningAt(now)) return activity;
  }
  return null;
}

/// La próxima actividad del horario de hoy que todavía no empieza, o
/// `null` si ya pasó la última del día.
@riverpod
Activity? nextActivity(Ref ref) {
  final activities = ref.watch(todayScheduleProvider);
  final now = DateTime.now();
  final nowMinutes = now.hour * 60 + now.minute;

  Activity? next;
  var bestDelta = 24 * 60 + 1;
  for (final activity in activities) {
    final startMinutes =
        activity.startTime.hour * 60 + activity.startTime.minute;
    final delta = startMinutes - nowMinutes;
    if (delta > 0 && delta < bestDelta) {
      bestDelta = delta;
      next = activity;
    }
  }
  return next;
}

/// Porcentaje transcurrido (0.0 a 1.0) de la actividad devuelta por
/// [currentActivityProvider]. Asume que la actividad no cruza la
/// medianoche (ninguna del horario maestro lo hace).
@riverpod
double currentActivityProgress(Ref ref) {
  final activity = ref.watch(currentActivityProvider);
  if (activity == null) return 0;

  final now = DateTime.now();
  final nowMinutes = now.hour * 60 + now.minute;
  final startMinutes = activity.startTime.hour * 60 + activity.startTime.minute;
  final endMinutes = activity.endTime.hour * 60 + activity.endTime.minute;

  final total = endMinutes - startMinutes;
  if (total <= 0) return 0;
  return ((nowMinutes - startMinutes) / total).clamp(0.0, 1.0);
}

/// Nombre configurado por el usuario en Ajustes del Mentor (mismo valor que
/// personaliza el system prompt del Mentor IA), o cadena vacía si aún no
/// se configuró.
@riverpod
Future<String> userName(Ref ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(mentorUserNamePrefKey) ?? '';
}

/// Emoji de ánimo ya registrado hoy, o `null` si todavía no se registró.
@riverpod
Future<String?> todayMood(Ref ref) async {
  return DbHelper.instance.getMoodForDate(_today());
}

/// Índice de Disciplina (ID): el último valor cerrado por
/// `DbHelper.closeDayRecord` (ver `DisciplineService`), 0 si el usuario
/// todavía no cerró ningún día. Es de solo lectura a propósito: no cierra
/// el día ni desbloquea logros desde aquí, para no consumir en silencio un
/// desbloqueo sin mostrar su celebración (eso pasa en DailySummaryScreen).
@riverpod
Future<int> disciplineIndex(Ref ref) async {
  final value = await DbHelper.instance.getLatestDisciplineIndex();
  return value.round();
}
