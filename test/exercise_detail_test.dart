import 'package:excise/app/app_scope.dart';
import 'package:excise/data/models/workout_models.dart';
import 'package:excise/data/repositories/sample_repository.dart';
import 'package:excise/ui/screens/exercise_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('详情页展示上次表现、替代动作与两个 CTA', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await initializeDateFormatting('zh_CN', null);
    final services = await AppServices.create();
    final bench = SampleExerciseRepository().getExerciseById('10022')!;
    final date = DateTime(2026, 2, 1, 10);
    await services.workouts.saveSession(WorkoutSession(
      id: 'detail-test',
      name: '上肢推拉',
      startedAt: date,
      endedAt: date.add(const Duration(minutes: 40)),
      exercises: [
        WorkoutExercise(
          exercise: bench,
          sets: [WorkoutSet(weight: 65, reps: 8, completed: true, completedAt: date)],
        ),
      ],
    ));

    await tester.pumpWidget(
      AppScope(
        services: services,
        child: MaterialApp(home: ExerciseDetailScreen(exercise: bench)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('目标肌群'), findsOneWidget);
    expect(find.text('胸'), findsWidgets);
    expect(find.text('上次表现'), findsOneWidget);
    expect(find.text('65 kg × 8'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(find.text('替代动作'), findsOneWidget);
    expect(find.text('加入计划'), findsOneWidget);
    expect(find.text('用这个动作开始练'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
