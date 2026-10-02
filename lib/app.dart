import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/constants/colors.dart';
import 'core/models/goal.dart';
import 'features/diario/diario_screen.dart';
import 'features/horario/horario_screen.dart';
import 'features/hoy/dashboard_screen.dart';
import 'features/mentor/mentor_screen.dart';
import 'features/mentor/settings_screen.dart';
import 'features/metas/dream_board_screen.dart';
import 'features/metas/metas_screen.dart';
import 'features/metas/stage_detail_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/progreso/progreso_screen.dart';
import 'features/progreso/stats_screen.dart';
import 'shared/widgets/bottom_nav.dart';

/// Rutas de los 5 tabs del bottom nav, en el mismo orden en que aparecen.
const List<String> _tabPaths = [
  '/hoy',
  '/horario',
  '/metas',
  '/mentor',
  '/progreso',
];

/// Navigator raíz de la app: permite abrir el resumen nocturno (modal
/// bottom sheet) al tocar su notificación, desde fuera del árbol de
/// widgets (ver `main.dart`, `NotificationsService.onNotificationTap`).
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter({required String initialLocation}) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    routes: [
      ShellRoute(
        builder: (context, state, child) =>
            MainShell(location: state.uri.toString(), child: child),
        routes: [
          GoRoute(
            path: '/hoy',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/horario',
            builder: (context, state) =>
                HorarioScreen(initialDayName: state.uri.queryParameters['day']),
          ),
          GoRoute(
            path: '/metas',
            builder: (context, state) => const MetasScreen(),
          ),
          GoRoute(
            path: '/mentor',
            builder: (context, state) =>
                MentorScreen(goalId: state.uri.queryParameters['goalId'] ?? ''),
          ),
          GoRoute(
            path: '/progreso',
            builder: (context, state) => const ProgresoScreen(),
          ),
        ],
      ),
      // Pantallas fuera del shell (sin bottom nav).
      GoRoute(
        path: '/metas/stage/:id',
        builder: (context, state) =>
            StageDetailScreen(stage: state.extra as GoalStage),
      ),
      GoRoute(
        path: '/metas/dream',
        builder: (context, state) =>
            DreamBoardScreen(goal: state.extra as LifeGoal),
      ),
      GoRoute(
        path: '/mentor/settings',
        builder: (context, state) => const MentorSettingsScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/diario',
        builder: (context, state) => const DiarioScreen(),
      ),
      GoRoute(
        path: '/progreso/stats',
        builder: (context, state) => const StatsScreen(),
      ),
    ],
  );
}

/// Shell con el [BottomNav] compartido por los 5 tabs principales.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    var currentIndex = _tabPaths.indexWhere(
      (path) => location.startsWith(path),
    );
    if (currentIndex == -1) currentIndex = 0;

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNav(
        currentIndex: currentIndex,
        onTap: (index) => context.go(_tabPaths[index]),
      ),
    );
  }
}

/// Widget raíz de la aplicación.
class DisciplinaDiariaApp extends StatelessWidget {
  DisciplinaDiariaApp({super.key, required String initialLocation})
    : router = createAppRouter(initialLocation: initialLocation);

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Disciplina Diaria',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: AppColors.background,
        cardColor: AppColors.surface,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
          surface: AppColors.surface,
          error: AppColors.danger,
        ).copyWith(primary: AppColors.primary),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: AppColors.background,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        ),
      ),
      locale: const Locale('es'),
      supportedLocales: const [Locale('es'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
