import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:disciplina_diaria/app.dart';

void main() {
  testWidgets('App arranca y muestra el Dashboard', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: DisciplinaDiariaApp(initialLocation: '/hoy')),
    );
    // El Dashboard corre un Timer.periodic de 1s para el reloj en vivo, que
    // nunca deja asentar la UI del todo: no se puede usar pumpAndSettle().
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Hoy'), findsWidgets);
    expect(find.text('ÍNDICE DE DISCIPLINA'), findsOneWidget);

    // Desmonta el árbol para cancelar el Timer.periodic antes de que
    // termine el test (si no, flutter_test falla con "Timer pending").
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Onboarding arranca en la primera página', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: DisciplinaDiariaApp(initialLocation: '/onboarding')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tu horario maestro está listo 📅'), findsOneWidget);
  });

  testWidgets('Horario muestra el selector de días y la línea de tiempo', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(child: DisciplinaDiariaApp(initialLocation: '/horario')),
    );
    // Si la hora real cae dentro de una actividad programada, su tile
    // muestra un shimmer con .repeat() infinito: pumpAndSettle() nunca
    // se asienta con una animación que no termina, así que se usa un
    // número acotado de pumps en su lugar (preexistente, no de este cambio).
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Horario'), findsWidgets);
    expect(find.text('L'), findsOneWidget);
    expect(find.text('D'), findsOneWidget);
  });

  testWidgets('Progreso arranca sin lanzar excepciones', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: DisciplinaDiariaApp(initialLocation: '/progreso')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Progreso'), findsWidgets);
    expect(find.text('📅 Disciplina'), findsOneWidget);
    expect(find.text('🎯 Metas'), findsOneWidget);
    expect(find.text('⏱ Tiempo'), findsOneWidget);
  });

  testWidgets('Mentor arranca sin lanzar excepciones', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: DisciplinaDiariaApp(initialLocation: '/mentor')),
    );
    await tester.pumpAndSettle();

    expect(find.text('🧠 Mentor IA'), findsOneWidget);
  });

  testWidgets('Metas arranca sin lanzar excepciones', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: DisciplinaDiariaApp(initialLocation: '/metas')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Metas'), findsWidgets);
  });
}
