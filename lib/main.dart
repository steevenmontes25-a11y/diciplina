import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'app.dart';
import 'core/constants/bologna_goal_seed.dart';
import 'core/constants/colors.dart';
import 'core/database/db_helper.dart';
import 'core/services/claude_service.dart';
import 'features/resumen/daily_summary_screen.dart';
import 'providers/goals_provider.dart';
import 'providers/mentor_provider.dart';
import 'providers/notifications_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Barras de sistema transparentes, coherentes con el fondo oscuro de la
  // app en todas las pantallas.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // La app está diseñada solo para vertical.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Pantalla de error elegante (en vez del "red screen of death") si algún
  // widget falla al construirse en producción.
  ErrorWidget.builder = (FlutterErrorDetails details) => Material(
    color: AppColors.background,
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            const Text(
              'Algo salió mal',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Cierra y vuelve a abrir la app. Tu progreso está a salvo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
        ),
      ),
    ),
  );

  // Fechas en español (intl).
  await initializeDateFormatting('es');

  // Zona horaria (para programar notificaciones a la hora local correcta).
  tz_data.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('America/Guayaquil'));

  // El container se crea aquí (en vez de dejar que ProviderScope cree uno
  // nuevo) para poder inicializar el plugin de notificaciones ANTES de
  // runApp y compartir exactamente la misma instancia con el resto de la
  // app a través de UncontrolledProviderScope.
  final container = ProviderContainer();
  final notifications = container.read(notificationsServiceProvider);
  await notifications.initialize();

  // Al tocar la notificación del resumen nocturno, abre el modal del
  // resumen del día usando el navigator raíz de la app.
  notifications.onNotificationTap = (payload) {
    if (payload != NotificationsService.nightlySummaryPayload) return;
    final context = rootNavigatorKey.currentContext;
    if (context != null) showDailySummarySheet(context);
  };
  unawaited(notifications.scheduleNightlySummary());

  // Base de datos SQLite.
  await DbHelper.instance.database;

  // Meta precargada "Estudiar IA en Università di Bologna" (solo la
  // primera vez; no pisa el progreso si ya existe).
  await seedBolognaGoal(DbHelper.instance);

  // Onboarding: solo se muestra la primera vez que se abre la app.
  final onboardingDone = await DbHelper.instance.getPreference(
    'onboarding_done',
  );
  final initialLocation = onboardingDone == null ? '/onboarding' : '/hoy';

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: DisciplinaDiariaApp(initialLocation: initialLocation),
    ),
  );

  // Análisis proactivo semanal del Mentor IA: se revisa en segundo plano (no
  // bloquea el arranque) si ya se generó el de esta semana; si no, lo pide,
  // lo guarda y avisa con una notificación.
  unawaited(_checkWeeklyMentorAnalysis(container));

  // Completa (sin bloquear el arranque) los días ya terminados que nunca se
  // cerraron con `closeDayRecord` -por ejemplo si el usuario no abrió el
  // resumen nocturno esos días-, para que el calendario, las estadísticas y
  // el Wrapped tengan datos continuos en vez de huecos.
  unawaited(_backfillMissedDailyRecords());
}

/// Cierra (sin mostrar overlays de logros) cualquier día entre el último
/// registrado y ayer que haya quedado sin cerrar.
Future<void> _backfillMissedDailyRecords() async {
  final db = DbHelper.instance;
  final earliestProgress = await db.getEarliestProgressDate();
  if (earliestProgress == null) return;

  final latestRecord = await db.getLatestDailyRecordDate();
  final dateFormat = DateFormat('yyyy-MM-dd');
  var cursor = DateTime.parse(latestRecord ?? earliestProgress);
  if (latestRecord != null) cursor = cursor.add(const Duration(days: 1));

  final yesterday = DateTime.now().subtract(const Duration(days: 1));
  // Límite de seguridad para no recorrer un historial ilimitado.
  for (var i = 0; i < 3650 && !cursor.isAfter(yesterday); i++) {
    await db.closeDayRecord(dateFormat.format(cursor));
    cursor = cursor.add(const Duration(days: 1));
  }
}

Future<void> _checkWeeklyMentorAnalysis(ProviderContainer container) async {
  final claude = ClaudeService();
  final apiKey = await claude.getApiKey();
  if (apiKey == null || apiKey.isEmpty) return;

  final goal = await container.read(activeGoalProvider.future);
  if (goal == null) return;

  final now = DateTime.now();
  final monday = DateTime(
    now.year,
    now.month,
    now.day,
  ).subtract(Duration(days: now.weekday - 1));
  final flagKey =
      'mentor_weekly_analysis_${DateFormat('yyyy-MM-dd').format(monday)}';

  final alreadyGenerated = await DbHelper.instance.getPreference(flagKey);
  if (alreadyGenerated != null) return;

  try {
    final mentorCtx = await container.read(
      mentorContextProvider(goal.id).future,
    );
    final analysis = await claude.generateMentorAnalysis(mentorCtx);
    await DbHelper.instance.saveAiMessage(
      goal.id,
      analysis,
      'mentor',
      const {},
    );
    await DbHelper.instance.setPreference(flagKey, 'done');
    await container
        .read(notificationsServiceProvider)
        .showNow(
          '🧠 Tu mentor tiene un análisis para ti',
          'Toca para ver tus recomendaciones de esta semana.',
        );
  } catch (_) {
    // Si falla (sin red, error del servidor, etc.) se reintenta la próxima
    // vez que se abra la app esta misma semana.
  }
}
