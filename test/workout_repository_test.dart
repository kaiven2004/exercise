import 'dart:convert';

import 'package:excise/data/models/models.dart';
import 'package:excise/data/models/workout_models.dart';
import 'package:excise/data/repositories/workout_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _bench = Exercise(
  id: '10022',
  name: '平板杠铃卧推',
  categoryPath: '力量训练 / 胸部训练 / 中胸',
  description: '测试',
);

WorkoutExercise _exercise(List<(double, int)> sets, {bool completed = true}) {
  return WorkoutExercise(
    exercise: _bench,
    sets: sets
        .map((s) => WorkoutSet(weight: s.$1, reps: s.$2, completed: completed))
        .toList(),
  );
}

WorkoutSession _session(String id, DateTime date, List<WorkoutExercise> exercises) {
  return WorkoutSession(
    id: id,
    name: '测试训练',
    startedAt: date,
    endedAt: date.add(const Duration(minutes: 45)),
    exercises: exercises,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('草稿逐组数据可以完整保存和恢复', () async {
    final repo = WorkoutRepository();
    await repo.init();

    final draft = WorkoutDraft(
      name: '上肢推拉',
      planId: 'template_upper',
      startedAt: DateTime(2026, 2, 1, 10),
      exercises: [
        _exercise([(60, 8), (62.5, 8)], completed: false),
      ],
      exerciseIndex: 0,
      setIndex: 1,
    );
    await repo.saveDraft(draft);

    final restored = repo.getDraft();
    expect(restored, isNotNull);
    expect(restored!.name, '上肢推拉');
    expect(restored.planId, 'template_upper');
    expect(restored.totalSets, 2);
    expect(restored.completedSets, 0);
    expect(restored.setIndex, 1);
    expect(restored.exercises.first.sets[1].weight, 62.5);

    await repo.clearDraft();
    expect(repo.getDraft(), isNull);
  });

  test('保存训练后能取回历史与上次表现', () async {
    final repo = WorkoutRepository();
    await repo.init();

    final older = _session(
      'older',
      DateTime(2026, 1, 1),
      [_exercise([(60, 8)])],
    );
    final newer = _session(
      'newer',
      DateTime(2026, 1, 8),
      [_exercise([(70, 5), (65, 9)])],
    );
    await repo.saveSession(older);
    await repo.saveSession(newer);

    final sessions = repo.getSessions();
    expect(sessions.map((s) => s.id), ['newer', 'older']);

    final last = repo.getLastPerformance(_bench.id);
    expect(last, isNotNull);
    // 上次表现取最重的一组，用于训练页预填。
    expect(last!.weight, 70);
    expect(last.reps, 5);
  });

  test('旧 training_history 一次性导入为逐组记录', () async {
    final legacy = TrainingSession(
      id: 'old-1',
      date: DateTime(2026, 1, 3, 9),
      sectionName: '力量训练',
      categoryPath: _bench.categoryPath,
      exercises: [
        ExerciseLog(exercise: _bench, completedSets: 3, totalReps: 30),
      ],
    );
    SharedPreferences.setMockInitialValues({
      'training_history': [jsonEncode(legacy.toJson())],
    });

    final repo = WorkoutRepository();
    await repo.init();

    final imported = repo.getSessions();
    expect(imported.length, 1);
    expect(imported.first.id, 'legacy_old-1');
    expect(imported.first.totalSets, 3);
    expect(imported.first.totalReps, 30);
    expect(imported.first.exercises.first.sets.length, 3);
    expect(imported.first.exercises.first.sets.first.reps, 10);

    // 再次初始化不会重复导入。
    final again = WorkoutRepository();
    await again.init();
    expect(again.getSessions().length, 1);
  });
}
