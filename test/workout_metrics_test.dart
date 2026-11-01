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

  group('热身组', () {
    test('不计入容量、自重次数和最佳组', () {
      final exercise = build([
        WorkoutSet(weight: 20, reps: 10, completed: true, isWarmup: true),
        WorkoutSet(weight: 20, reps: 10, completed: true, isWarmup: true),
        WorkoutSet(weight: 60, reps: 8, completed: true),
        WorkoutSet(weight: 0, reps: 12, completed: true),
      ]);
      expect(exercise.completedSets, 4);
      expect(exercise.completedWorkingSets, 2);
      expect(exercise.volume, 60 * 8);
      expect(exercise.bodyweightReps, 12);
      expect(exercise.bestSet?.weight, 60);
      expect(exercise.warmupSets, 2);
    });

    test('批量重量与沿用重量都跳过热身组', () {
      final exercise = build([
        WorkoutSet(weight: 20, reps: 10, isWarmup: true),
        WorkoutSet(reps: 8),
        WorkoutSet(reps: 8),
      ]);
      exercise.applyWeightToUncompleted(60);
      expect(exercise.sets[0].weight, 20);
      expect(exercise.sets[1].weight, 60);

      final seeded = build([
        WorkoutSet(reps: 10, isWarmup: true),
        WorkoutSet(reps: 10),
      ]);
      seeded.seedWeight(50);
      expect(seeded.sets[0].weight, 0);
      expect(seeded.sets[1].weight, 50);
    });

    test('旧 JSON 没有热身字段时默认为正式组', () {
      final set = WorkoutSet.fromJson({'weight': 40, 'reps': 10, 'completed': true});
      expect(set.isWarmup, isFalse);
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
