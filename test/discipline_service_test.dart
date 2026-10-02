import 'package:disciplina_diaria/core/models/activity.dart';
import 'package:disciplina_diaria/core/models/daily_record.dart';
import 'package:disciplina_diaria/core/models/day_progress.dart';
import 'package:disciplina_diaria/core/services/discipline_service.dart';
import 'package:flutter_test/flutter_test.dart';

Activity _activity(String id, int points) => Activity(
  id: id,
  timeStart: '06:00',
  timeEnd: '07:00',
  title: id,
  description: '',
  category: ActivityCategory.salud,
  points: points,
  days: const [DayOfWeek.lunes],
);

ActivityProgress _done(String activityId) => ActivityProgress(
  activityId: activityId,
  date: '2026-01-01',
  status: ActivityStatus.done,
);

DailyRecord _record(String date, double percentage, DisciplineLevel level) =>
    DailyRecord(
      id: 0,
      date: date,
      totalPoints: 100,
      earnedPoints: (percentage * 100).round(),
      percentage: percentage,
      disciplineLevel: level,
      disciplineIndex: 0,
      createdAt: DateTime.parse(date),
    );

void main() {
  const service = DisciplineService();

  group('calculateDayPercentage', () {
    test('está ponderado por puntos, no por conteo de actividades', () {
      final activities = [_activity('a', 90), _activity('b', 10)];
      // Solo la de mayor peso está hecha: 90/100, no 1/2 (50%).
      final progresses = [_done('a')];

      final pct = service.calculateDayPercentage(progresses, activities);

      expect(pct, 0.9);
    });

    test('es 0 cuando no hay actividades', () {
      expect(service.calculateDayPercentage(const [], const []), 0);
    });
  });

  group('levelForPercentage', () {
    test('umbrales 0.80 / 0.40', () {
      expect(service.levelForPercentage(0.85), DisciplineLevel.green);
      expect(service.levelForPercentage(0.80), DisciplineLevel.green);
      expect(service.levelForPercentage(0.79), DisciplineLevel.yellow);
      expect(service.levelForPercentage(0.40), DisciplineLevel.yellow);
      expect(service.levelForPercentage(0.39), DisciplineLevel.red);
    });
  });

  group('calculateDisciplineIndex', () {
    test('es 0 con historial vacío', () {
      expect(service.calculateDisciplineIndex(const [], currentStreak: 0), 0);
    });

    test('un día reciente perfecto pesa más que uno antiguo perfecto', () {
      // Mismo historial, pero el día perfecto está más reciente en [a] que
      // en [b]: [a] debe dar un índice mayor por la ponderación exponencial.
      final recentGoodHistory = [
        _record('2026-01-01', 0.2, DisciplineLevel.red),
        _record('2026-01-02', 1.0, DisciplineLevel.green),
      ];
      final oldGoodHistory = [
        _record('2026-01-01', 1.0, DisciplineLevel.green),
        _record('2026-01-02', 0.2, DisciplineLevel.red),
      ];

      final recentGoodIndex = service.calculateDisciplineIndex(
        recentGoodHistory,
        currentStreak: 0,
      );
      final oldGoodIndex = service.calculateDisciplineIndex(
        oldGoodHistory,
        currentStreak: 0,
      );

      expect(recentGoodIndex, greaterThan(oldGoodIndex));
    });

    test('el bonus de racha está acotado a 50', () {
      final history = [_record('2026-01-01', 1.0, DisciplineLevel.green)];

      final withHugeStreak = service.calculateDisciplineIndex(
        history,
        currentStreak: 1000,
      );

      // 1 día perfecto -> baseIndex = 1000; el tope general de 1000 ya
      // esconde el bonus, así que se verifica contra un porcentaje menor.
      final partialHistory = [
        _record('2026-01-01', 0.5, DisciplineLevel.yellow),
      ];
      final baseWithoutStreak = service.calculateDisciplineIndex(
        partialHistory,
        currentStreak: 0,
      );
      final baseWithHugeStreak = service.calculateDisciplineIndex(
        partialHistory,
        currentStreak: 1000,
      );

      expect(withHugeStreak, 1000);
      expect(baseWithHugeStreak - baseWithoutStreak, 50);
    });
  });

  group('idDelta', () {
    test('verde: +8 si el ID es bajo, +4 si ya es alto', () {
      expect(service.idDelta(DisciplineLevel.green, 100), 8.0);
      expect(service.idDelta(DisciplineLevel.green, 600), 4.0);
    });

    test('amarillo: siempre +1', () {
      expect(service.idDelta(DisciplineLevel.yellow, 50), 1.0);
      expect(service.idDelta(DisciplineLevel.yellow, 900), 1.0);
    });

    test('rojo: -2 si el ID es bajo, -6 si es alto', () {
      expect(service.idDelta(DisciplineLevel.red, 100), -2.0);
      expect(service.idDelta(DisciplineLevel.red, 300), -6.0);
    });
  });
}
