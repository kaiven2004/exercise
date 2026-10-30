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
}
