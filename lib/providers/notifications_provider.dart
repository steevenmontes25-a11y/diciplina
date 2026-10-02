import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/timezone.dart' as tz;

import '../core/constants/colors.dart';
import '../core/constants/schedule_data.dart';
import '../core/models/activity.dart';

part 'notifications_provider.g.dart';

/// Canal de notificaciones/alarmas usado por toda la app.
final AndroidNotificationChannel _androidChannel = AndroidNotificationChannel(
  'disciplina_diaria_channel',
  'Disciplina Diaria',
  description: 'Notificaciones y alarmas del horario diario',
  importance: Importance.max,
  playSound: true,
  enableVibration: true,
  vibrationPattern: Int64List.fromList([0, 250, 250, 250]),
);

/// Servicio de alto nivel para inicializar, permisos y programación de
/// notificaciones/alarmas del horario maestro.
class NotificationsService {
  NotificationsService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  static const String channelId = 'disciplina_diaria_channel';
  static const String channelName = 'Disciplina Diaria';

  /// Payload del resumen nocturno (ver [scheduleNightlySummary]).
  static const String nightlySummaryPayload = 'nightly_summary';

  /// Se invoca con el `payload` de la notificación tocada (foreground o al
  /// abrir la app desde una notificación). Lo asigna `main.dart` una vez
  /// que el router de la app ya existe, para poder navegar.
  void Function(String payload)? onNotificationTap;

  /// Inicializa el plugin y crea el canal de notificaciones de Android.
  /// Debe llamarse una única vez, antes de programar cualquier notificación.
  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null) onNotificationTap?.call(payload);
      },
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);
  }

  /// Pide los permisos necesarios (notificaciones y alarmas exactas en
  /// Android 13+, alertas/sonido en iOS). Devuelve `true` si todo lo pedido
  /// fue concedido (o no aplica en la plataforma/versión actual).
  Future<bool> requestPermissions() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final notificationsGranted = await androidPlugin
        ?.requestNotificationsPermission();
    final exactAlarmsGranted = await androidPlugin
        ?.requestExactAlarmsPermission();

    final iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final iosGranted = await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    return (notificationsGranted ?? true) &&
        (exactAlarmsGranted ?? true) &&
        (iosGranted ?? true);
  }

  /// Cancela todo lo programado y vuelve a programar una notificación por
  /// cada actividad con alarma activada del horario maestro. Devuelve la
  /// cantidad de notificaciones programadas.
  Future<int> scheduleAllAlarms() async {
    await _plugin.cancelAll();
    var count = 0;

    for (final activity in masterSchedule) {
      if (!activity.isAlarmEnabled) continue;

      for (final day in activity.days) {
        final weekday = day.isoWeekday;
        final time = activity.startTime;
        final scheduledDate = _nextInstanceOf(weekday, time.hour, time.minute);
        final description = activity.description.length > 80
            ? '${activity.description.substring(0, 80)}...'
            : activity.description;

        await _plugin.zonedSchedule(
          _notificationId(activity.id, weekday),
          '⏰ ${activity.title}',
          description,
          scheduledDate,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channelId,
              channelName,
              importance: Importance.max,
              priority: Priority.high,
              color: AppColors.primary,
            ),
            iOS: const DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
        count++;
      }
    }

    return count;
  }

  /// Programa las alarmas especiales de despertar: lunes a sábado a las
  /// 06:00 y domingo a las 07:00. Suenan con el mismo canal pero como
  /// notificación de tipo alarma, con pantalla completa en Android.
  Future<void> scheduleWakeUpAlarms() async {
    const wakeUpTimes = <(int weekday, int hour, int minute)>[
      (DateTime.monday, 6, 0),
      (DateTime.tuesday, 6, 0),
      (DateTime.wednesday, 6, 0),
      (DateTime.thursday, 6, 0),
      (DateTime.friday, 6, 0),
      (DateTime.saturday, 6, 0),
      (DateTime.sunday, 7, 0),
    ];

    for (final (weekday, hour, minute) in wakeUpTimes) {
      final scheduledDate = _nextInstanceOf(weekday, hour, minute);

      await _plugin.zonedSchedule(
        _wakeUpNotificationId(weekday),
        '⏰ ¡Hora de despertar!',
        'Empieza tu día con disciplina.',
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            importance: Importance.max,
            priority: Priority.high,
            category: AndroidNotificationCategory.alarm,
            fullScreenIntent: true,
            playSound: true,
            color: AppColors.primary,
          ),
          iOS: const DarwinNotificationDetails(
            interruptionLevel: InterruptionLevel.active,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  /// Programa el recordatorio de una actividad puntual (usado cuando el
  /// usuario activa la notificación de esa actividad desde su modal).
  Future<void> scheduleForActivity(Activity activity) async {
    final time = activity.startTime;
    for (final day in activity.days) {
      final weekday = day.isoWeekday;
      await _plugin.zonedSchedule(
        _notificationId(activity.id, weekday),
        activity.title,
        activity.description,
        _nextInstanceOf(weekday, time.hour, time.minute),
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            importance: Importance.max,
            priority: Priority.high,
            color: AppColors.primary,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  /// Cancela el recordatorio de una actividad puntual.
  Future<void> cancelForActivity(Activity activity) async {
    for (final day in activity.days) {
      await _plugin.cancel(_notificationId(activity.id, day.isoWeekday));
    }
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  /// Programa el resumen nocturno diario a las 22:00. El texto es fijo
  /// (el plugin no puede recalcular contenido dinámico sin la app
  /// corriendo); el resumen real con las cifras del día se calcula al
  /// tocar la notificación, que abre [DailySummaryScreen].
  Future<void> scheduleNightlySummary() async {
    await _plugin.zonedSchedule(
      _nightlySummaryNotificationId,
      '📊 Resumen del día',
      'Toca para ver cómo te fue hoy.',
      _nextDailyInstanceOf(22, 0),
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          importance: Importance.max,
          priority: Priority.high,
          color: AppColors.primary,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: nightlySummaryPayload,
    );
  }

  /// Muestra una notificación inmediata (no programada), usada por ejemplo
  /// para avisar que el análisis semanal del Mentor IA ya está listo.
  Future<void> showNow(String title, String body) async {
    await _plugin.show(
      900000 + DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          importance: Importance.max,
          priority: Priority.high,
          color: AppColors.primary,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  /// Id determinístico y estable para una actividad en un día de la semana
  /// concreto. Se mantiene por debajo de [_wakeUpNotificationId] para que
  /// nunca colisionen entre sí.
  int _notificationId(String activityId, int weekday) =>
      (activityId.hashCode & 0x7ffff) ^ weekday;

  /// Id reservado para las alarmas especiales de despertar (una por día de
  /// la semana), fuera del rango usado por [_notificationId].
  int _wakeUpNotificationId(int weekday) => 900000 + weekday;

  /// Id fijo del resumen nocturno (fuera de los rangos usados por
  /// [_notificationId] y [_wakeUpNotificationId]).
  static const int _nightlySummaryNotificationId = 970000;

  tz.TZDateTime _nextInstanceOf(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    while (scheduled.weekday != weekday || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// Próxima ocurrencia de la hora [hour]:[minute], todos los días.
  tz.TZDateTime _nextDailyInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}

/// Instancia compartida del plugin de notificaciones locales.
@Riverpod(keepAlive: true)
FlutterLocalNotificationsPlugin flutterLocalNotifications(Ref ref) {
  return FlutterLocalNotificationsPlugin();
}

/// Servicio de alto nivel para notificaciones y alarmas.
@Riverpod(keepAlive: true)
NotificationsService notificationsService(Ref ref) {
  return NotificationsService(ref.watch(flutterLocalNotificationsProvider));
}
