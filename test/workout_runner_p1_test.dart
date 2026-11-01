import 'package:excise/app/app_scope.dart';
import 'package:excise/data/models/models.dart';
import 'package:excise/data/models/workout_models.dart';
import 'package:excise/ui/screens/workout_runner_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Exercise _exercise({
  String id = '10151',
  String name = '平板支撑',
  List<String> tips = const [],
}) {
  return Exercise(
    id: id,
    name: name,
    categoryPath: '力量训练 / 核心训练 / 抗伸展',
    description: '测试',
    tips: tips,
  );
}

WorkoutDraft _draft(Exercise exercise, List<WorkoutSet> sets) {
  return WorkoutDraft(
    name: '测试训练',
    startedAt: DateTime.now(),
    exercises: [WorkoutExercise(exercise: exercise, sets: sets)],
  );
}

void main() {
  testWidgets('跟练页展示动作要点并可展开', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final services = await AppServices.create();
    final draft = _draft(
      _exercise(tips: ['肘在肩正下方', '收紧核心，不塌腰']),
      [WorkoutSet(reps: 30)],
    );

    await tester.pumpWidget(
      AppScope(
        services: services,
        child: MaterialApp(home: WorkoutRunnerScreen(initialDraft: draft)),
      ),
    );
    await tester.pump();

    expect(find.text('动作要点'), findsOneWidget);
    expect(find.text('肘在肩正下方'), findsOneWidget);
    expect(find.text('收紧核心，不塌腰'), findsNothing);

    await tester.tap(find.text('动作要点'));
    await tester.pump();

    expect(find.text('· 肘在肩正下方'), findsNothing);
    expect(find.textContaining('收紧核心，不塌腰'), findsOneWidget);
    expect(find.text('替代动作'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('等长动作倒计时结束后记录秒数', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final services = await AppServices.create();
    final draft = _draft(
      _exercise(name: '平板支撑'),
      [WorkoutSet(reps: 1)],
    );

    await tester.pumpWidget(
      AppScope(
        services: services,
        child: MaterialApp(home: WorkoutRunnerScreen(initialDraft: draft)),
      ),
    );
    await tester.pump();

    expect(find.text('等长保持'), findsOneWidget);
    expect(find.text('目标 1 秒'), findsOneWidget);

    await tester.tap(find.text('开始计时'));
    await tester.pump();
    expect(find.text('暂停'), findsOneWidget);

    // 计时用真实时间判断结束，先真实等待一秒，再让周期回调触发。
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 1100)));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump();

    expect(find.text('计时结束，已记录 1 秒'), findsOneWidget);
    expect(draft.exercises.first.sets.first.reps, 1);
    expect(find.text('开始计时'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('组行可以标记热身并按上次一半给重量建议', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final services = await AppServices.create();

    const bench = Exercise(
      id: '10022',
      name: '平板杠铃卧推',
      categoryPath: '力量训练 / 胸部训练 / 中胸',
      description: '测试',
    );
    final started = DateTime.now().subtract(const Duration(days: 2));
    await services.workouts.saveSession(WorkoutSession(
      id: 'history',
      name: '上肢',
      startedAt: started,
      endedAt: started.add(const Duration(minutes: 30)),
      exercises: [
        WorkoutExercise(
          exercise: bench,
          sets: [WorkoutSet(weight: 60, reps: 8, completed: true, completedAt: started)],
        ),
      ],
    ));

    final draft = _draft(bench, [WorkoutSet(reps: 8), WorkoutSet(reps: 8)]);
    await tester.pumpWidget(
      AppScope(
        services: services,
        child: MaterialApp(home: WorkoutRunnerScreen(initialDraft: draft)),
      ),
    );
    await tester.pump();

    expect(find.text('热身'), findsNWidgets(2));
    await tester.tap(find.text('热身').first);
    await tester.pump();

    final warmup = draft.exercises.first.sets.first;
    expect(warmup.isWarmup, isTrue);
    expect(warmup.weight, 30);
    expect(find.text('热身组建议 30 kg（上次的一半）'), findsOneWidget);
    expect(draft.exercises.first.sets[1].isWarmup, isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
