import 'package:excise/data/models/models.dart';
import 'package:excise/data/models/workout_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const bench = Exercise(
    id: '10022',
    name: '平板杠铃卧推',
    categoryPath: '力量训练 / 胸部训练 / 中胸',
    description: '测试',
  );

  WorkoutExercise build(List<WorkoutSet> sets) => WorkoutExercise(exercise: bench, sets: sets);

  group('自重次数', () {
    test('只统计已完成且没有重量的组', () {
      final exercise = build([
        WorkoutSet(weight: 0, reps: 12, completed: true),
        WorkoutSet(weight: 0, reps: 10, completed: true),
        WorkoutSet(weight: 20, reps: 8, completed: true),
        WorkoutSet(weight: 0, reps: 15),
      ]);
      expect(exercise.bodyweightReps, 22);
      expect(exercise.totalReps, 30);
    });

    test('全场汇总自重次数', () {
      final session = WorkoutSession(
        id: 's',
        name: '测试',
        startedAt: DateTime(2026, 1, 1),
        endedAt: DateTime(2026, 1, 1, 1),
        exercises: [
          build([WorkoutSet(reps: 12, completed: true)]),
          WorkoutExercise(
            exercise: const Exercise(
              id: '10085',
              name: '平板支撑',
              categoryPath: '力量训练 / 核心训练 / 核心训练',
              description: '',
            ),
            sets: [WorkoutSet(reps: 30, completed: true)],
          ),
        ],
      );
      expect(session.totalBodyweightReps, 42);
      expect(session.totalVolume, 0);
    });
  });

  group('重量批量应用', () {
    test('应用到全部组只覆盖未完成组', () {
      final exercise = build([
        WorkoutSet(weight: 40, reps: 10, completed: true),
        WorkoutSet(reps: 10),
        WorkoutSet(weight: 0, reps: 8),
      ]);
      exercise.applyWeightToUncompleted(60);
      expect(exercise.sets[0].weight, 40);
      expect(exercise.sets[1].weight, 60);
      expect(exercise.sets[2].weight, 60);
    });

    test('沿用重量不覆盖用户已填写的组', () {
      final exercise = build([
        WorkoutSet(weight: 0, reps: 10),
        WorkoutSet(weight: 35, reps: 10),
        WorkoutSet(weight: 0, reps: 10, completed: true),
      ]);
      exercise.seedWeight(50);
      expect(exercise.sets[0].weight, 50);
      expect(exercise.sets[1].weight, 35);
      expect(exercise.sets[2].weight, 0);
    });

    test('重量为 0 时不做任何事', () {
      final exercise = build([WorkoutSet(reps: 10)]);
      exercise.seedWeight(0);
      expect(exercise.sets.first.weight, 0);
    });
  });
}
