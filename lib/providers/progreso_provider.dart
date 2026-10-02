import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/constants/schedule_data.dart';
import '../core/database/db_helper.dart';
import '../core/models/activity.dart';
import '../core/models/day_progress.dart';

part 'progreso_provider.g.dart';

/// Tiempo total invertido por categoría de actividad, calculado a partir de
/// cuántas veces se marcó cada actividad como hecha (en todo el historial)
/// multiplicado por su duración.
@riverpod
Future<Map<ActivityCategory, Duration>> categoryTimeInvested(Ref ref) async {
  final doneCounts = await DbHelper.instance.getActivityCountsByStatus(
    ActivityStatus.done,
  );

  final totals = <ActivityCategory, Duration>{};
  for (final activity in masterSchedule) {
    final count = doneCounts[activity.id] ?? 0;
    if (count == 0) continue;
    final invested = activity.duration * count;
    totals.update(
      activity.category,
      (existing) => existing + invested,
      ifAbsent: () => invested,
    );
  }
  return totals;
}
