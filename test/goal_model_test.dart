import 'package:disciplina_diaria/core/models/goal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GoalStage.progress', () {
    test('es 0 cuando no hay tareas', () {
      const stage = GoalStage(
        id: 's1',
        goalId: 'g1',
        order: 1,
        title: 'Etapa',
        emoji: '📐',
        status: StageStatus.locked,
      );
      expect(stage.progress, 0);
    });

    test('se calcula como hechas / total', () {
      const stage = GoalStage(
        id: 's1',
        goalId: 'g1',
        order: 1,
        title: 'Etapa',
        emoji: '📐',
        status: StageStatus.inProgress,
        tasks: [
          StageTask(
            id: 't1',
            stageId: 's1',
            title: 'A',
            status: TaskStatus.done,
          ),
          StageTask(
            id: 't2',
            stageId: 's1',
            title: 'B',
            status: TaskStatus.done,
          ),
          StageTask(
            id: 't3',
            stageId: 's1',
            title: 'C',
            status: TaskStatus.pending,
          ),
          StageTask(
            id: 't4',
            stageId: 's1',
            title: 'D',
            status: TaskStatus.skipped,
          ),
        ],
      );
      expect(stage.progress, 0.5);
    });
  });

  group('ExamSimulation', () {
    test('serializa y deserializa weakTopics como JSON', () {
      final sim = ExamSimulation(
        id: 'sim1',
        goalId: 'g1',
        examName: 'TOLC-I',
        date: DateTime(2026, 3, 1),
        score: 32,
        maxScore: 50,
        targetScore: 40,
        weakTopics: const ['Logaritmos', 'Trigonometría'],
      );

      final map = sim.toMap();
      expect(map['weak_topics'], isA<String>());

      final restored = ExamSimulation.fromMap(map);
      expect(restored.weakTopics, ['Logaritmos', 'Trigonometría']);
      expect(restored.score, 32);
      expect(restored.date, DateTime(2026, 3, 1));
    });
  });

  group('LifeGoal', () {
    test('toMap/fromMap conservan los campos (sin las etapas)', () {
      final goal = LifeGoal(
        id: 'goal_bologna_ia',
        title: 'Estudiar IA en Università di Bologna',
        description: 'desc',
        emoji: '🎯',
        targetDate: DateTime(2026, 9, 1),
        createdAt: DateTime(2025, 1, 1),
        status: GoalStatus.active,
        university: 'Università di Bologna',
        career: 'Inteligencia Artificial',
        country: '🇮🇹 Italia',
      );

      final restored = LifeGoal.fromMap(goal.toMap());
      expect(restored.id, goal.id);
      expect(restored.status, GoalStatus.active);
      expect(restored.targetDate, DateTime(2026, 9, 1));
      expect(restored.stages, isEmpty);
    });
  });

  group('StageTask', () {
    test('completedAt solo se serializa cuando existe', () {
      const pending = StageTask(
        id: 't1',
        stageId: 's1',
        title: 'Pendiente',
        status: TaskStatus.pending,
      );
      expect(pending.toMap()['completed_at'], isNull);

      final done = pending.copyWith(
        status: TaskStatus.done,
        completedAt: DateTime(2025, 6, 1),
      );
      expect(
        done.toMap()['completed_at'],
        DateTime(2025, 6, 1).toIso8601String(),
      );
    });
  });
}
