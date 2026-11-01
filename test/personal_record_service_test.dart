import 'package:excise/data/models/models.dart';
import 'package:excise/data/models/workout_models.dart';
import 'package:excise/data/services/personal_record_service.dart';
import 'package:flutter_test/flutter_test.dart';

Exercise _exercise(String id, String name, {String path = '力量训练 / 胸部训练 / 中胸'}) {
  return Exercise(id: id, name: name, categoryPath: path, description: '测试');
}

WorkoutExercise _exerciseWith(
  Exercise exercise,
  List<(double, int)> sets,
) {
  return WorkoutExercise(
    exercise: exercise,
    sets: sets
        .map((s) => WorkoutSet(weight: s.$1, reps: s.$2, completed: true))
        .toList(),
  );
}

WorkoutSession _session(
  String id,
  DateTime date,
  List<WorkoutExercise> exercises,
) {
  return WorkoutSession(
    id: id,
    name: '测试训练',
    startedAt: date,
    endedAt: date.add(const Duration(minutes: 40)),
    exercises: exercises,
  );
}

void main() {
  group('估算 1RM', () {
    test('Epley 公式', () {
      expect(PersonalRecordService.estimatedOneRepMax(100, 1), 100);
      expect(PersonalRecordService.estimatedOneRepMax(100, 5), closeTo(116.67, 0.01));
      expect(PersonalRecordService.estimatedOneRepMax(0, 10), 0);
      expect(PersonalRecordService.estimatedOneRepMax(60, 0), 0);
    });
  });

  group('PR 判定', () {
    final bench = _exercise('10022', '平板杠铃卧推');

    test('首次训练不算 PR', () {
      final current = _exerciseWith(bench, [(60, 8)]);
      expect(PersonalRecordService.detectForExercise(current, const []), isNull);
    });

    test('重量与次数都提升时判定 1RM 新纪录', () {
      final history = [
        _session('old', DateTime(2026, 1, 1), [_exerciseWith(bench, [(60, 8)])]),
      ];
      final current = _exerciseWith(bench, [(62.5, 8), (60, 10)]);
      final pr = PersonalRecordService.detectForExercise(current, history);
      expect(pr, isNotNull);
      expect(pr!.kind, PrKind.estimatedOneRepMax);
      // 60×10 的估算 1RM（80）高于 62.5×8（79.2），取最佳组。
      expect(pr.weight, 60);
      expect(pr.reps, 10);
      expect(pr.improvement, greaterThan(0));
    });

    test('重量降低但次数更高仍按 1RM 比较', () {
      final history = [
        _session('old', DateTime(2026, 1, 1), [_exerciseWith(bench, [(80, 3)])]),
      ];
      // 70×6 ≈ 84 > 80×3=88? 实际 70*1.2=84 < 88，不破纪录。
      final lower = _exerciseWith(bench, [(70, 6)]);
      expect(PersonalRecordService.detectForExercise(lower, history), isNull);

      // 75×5 = 87.5 仍低于 88，不破纪录。
      final close = _exerciseWith(bench, [(75, 5)]);
      expect(PersonalRecordService.detectForExercise(close, history), isNull);

      // 75×6 = 90 破纪录。
      final better = _exerciseWith(bench, [(75, 6)]);
      expect(PersonalRecordService.detectForExercise(better, history), isNotNull);
    });

    test('自重动作按次数判定', () {
      final pushUp = _exercise('10037', '标准俯卧撑', path: '力量训练 / 胸部训练 / 中胸');
      final history = [
        _session('old', DateTime(2026, 1, 1), [_exerciseWith(pushUp, [(0, 20)])]),
      ];
      expect(
        PersonalRecordService.detectForExercise(_exerciseWith(pushUp, [(0, 20)]), history),
        isNull,
      );
      final pr = PersonalRecordService.detectForExercise(_exerciseWith(pushUp, [(0, 25)]), history);
      expect(pr, isNotNull);
      expect(pr!.kind, PrKind.reps);
      expect(pr.reps, 25);
    });

    test('热身组不参与 PR 判定，历史里的热身成绩也不算', () {
      final history = [
        _session('old', DateTime(2026, 1, 1), [
          WorkoutExercise(
            exercise: bench,
            sets: [
              WorkoutSet(weight: 100, reps: 10, completed: true, isWarmup: true),
              WorkoutSet(weight: 60, reps: 8, completed: true),
            ],
          ),
        ]),
      ];
      // 当前组看起来破了 100×10 的纪录，但那是热身组。
      final current = WorkoutExercise(
        exercise: bench,
        sets: [
          WorkoutSet(weight: 70, reps: 8, completed: true, isWarmup: true),
          WorkoutSet(weight: 62.5, reps: 8, completed: true),
        ],
      );
      final pr = PersonalRecordService.detectForExercise(current, history);
      expect(pr, isNotNull);
      expect(pr!.weight, 62.5);

      // 只有热身组时不会产生 PR。
      final warmupOnly = WorkoutExercise(
        exercise: bench,
        sets: [WorkoutSet(weight: 120, reps: 5, completed: true, isWarmup: true)],
      );
      expect(PersonalRecordService.detectForExercise(warmupOnly, history), isNull);
    });

    test('整场训练会跳过当前会话自身', () {
      final current = _session(
        'current',
        DateTime(2026, 1, 2),
        [_exerciseWith(bench, [(80, 5)])],
      );
      final history = [
        _session('old', DateTime(2026, 1, 1), [_exerciseWith(bench, [(60, 8)])]),
        current,
      ];
      final prs = PersonalRecordService.detect(current, history);
      expect(prs.length, 1);
      expect(prs.first.exerciseId, bench.id);
    });
  });
}
