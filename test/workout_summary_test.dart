import 'package:excise/app/app_scope.dart';
import 'package:excise/data/models/models.dart';
import 'package:excise/data/models/workout_models.dart';
import 'package:excise/ui/screens/workout_summary_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('总结页保存训练并清除草稿', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await initializeDateFormatting('zh_CN', null);
    final services = await AppServices.create();

    final bench = const Exercise(
      id: '10022',
      name: '平板杠铃卧推',
      categoryPath: '力量训练 / 胸部训练 / 中胸',
      description: '测试',
    );
    final started = DateTime(2026, 2, 1, 10);
    final session = WorkoutSession(
      id: 'summary-test',
      name: '上肢推拉',
      startedAt: started,
      endedAt: started.add(const Duration(minutes: 42)),
      exercises: [
        WorkoutExercise(
          exercise: bench,
          sets: [
            WorkoutSet(weight: 60, reps: 8, completed: true, completedAt: started),
            WorkoutSet(weight: 62.5, reps: 8, completed: true, completedAt: started),
            WorkoutSet(weight: 65, reps: 6),
          ],
        ),
      ],
    );

    await services.workouts.saveDraft(
      WorkoutDraft(name: '上肢推拉', startedAt: started, exercises: session.exercises),
    );
    expect(services.workouts.getDraft(), isNotNull);

    await tester.pumpWidget(
      AppScope(
        services: services,
        child: MaterialApp(home: WorkoutSummaryScreen(session: session)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('训练完成'), findsOneWidget);
    expect(find.text('42:00'), findsOneWidget);
    // 未完成的第三组不计入总结与保存。
    expect(find.text('2'), findsWidgets);
    expect(find.text('保存并完成'), findsOneWidget);

    await tester.tap(find.text('保存并完成'));
    await tester.pumpAndSettle();

    final saved = services.workouts.getSessions();
    expect(saved.length, 1);
    expect(saved.first.totalSets, 2);
    expect(saved.first.exercises.first.sets.length, 2);
    expect(saved.first.totalVolume, 60 * 8 + 62.5 * 8);
    expect(services.workouts.getDraft(), isNull);
  });

  testWidgets('进入总结页即落库，返回时保存 RPE', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await initializeDateFormatting('zh_CN', null);
    final services = await AppServices.create();

    const plank = Exercise(
      id: '10085',
      name: '平板支撑',
      categoryPath: '力量训练 / 核心训练 / 核心训练',
      description: '测试',
    );
    final started = DateTime(2026, 2, 2, 9);
    final session = WorkoutSession(
      id: 'summary-auto',
      name: '核心',
      startedAt: started,
      endedAt: started.add(const Duration(minutes: 15)),
      exercises: [
        WorkoutExercise(
          exercise: plank,
          sets: [
            WorkoutSet(reps: 30, completed: true, completedAt: started),
            WorkoutSet(reps: 30, completed: true, completedAt: started),
          ],
        ),
      ],
    );
    await services.workouts.saveDraft(
      WorkoutDraft(name: '核心', startedAt: started, exercises: session.exercises),
    );

    await tester.pumpWidget(
      AppScope(
        services: services,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => WorkoutSummaryScreen(session: session)),
                ),
                child: const Text('打开总结'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('打开总结'));
    await tester.pumpAndSettle();

    // 没点保存也已经落库，草稿清掉；自重动作显示次数而不是 0kg。
    expect(services.workouts.getSessions().length, 1);
    expect(services.workouts.getDraft(), isNull);
    expect(find.text('自重'), findsOneWidget);
    expect(find.textContaining('60', findRichText: true), findsWidgets);

    // 选 RPE 后直接返回，不应再弹「还没保存」。
    await tester.ensureVisible(find.text('8'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('8'));
    await tester.pump();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('打开总结'), findsOneWidget);
    final saved = services.workouts.getSessions().single;
    expect(saved.rpe, 8);
    expect(saved.totalBodyweightReps, 60);
  });
}
