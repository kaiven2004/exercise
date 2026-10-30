import 'package:excise/app/app_scope.dart';
import 'package:excise/data/models/models.dart';
import 'package:excise/data/models/workout_models.dart';
import 'package:excise/data/services/personal_record_service.dart';
import 'package:excise/ui/screens/progress_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _bench = Exercise(
  id: '10022',
  name: '平板杠铃卧推',
  categoryPath: '力量训练 / 胸部训练 / 中胸',
  description: '测试',
);

WorkoutSession _session(String id, DateTime date, double weight, int reps) {
  return WorkoutSession(
    id: id,
    name: '上肢推拉',
    startedAt: date,
    endedAt: date.add(const Duration(minutes: 40)),
    exercises: [
      WorkoutExercise(
        exercise: _bench,
        sets: [WorkoutSet(weight: weight, reps: reps, completed: true, completedAt: date)],
      ),
    ],
  );
}

void main() {
  testWidgets('力量曲线展示同一动作的 1RM 趋势', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await initializeDateFormatting('zh_CN', null);
    final services = await AppServices.create();

    final firstDate = DateTime.now().subtract(const Duration(days: 7));
    await services.workouts.saveSession(_session('s1', firstDate, 60, 8));
    await services.workouts.saveSession(_session('s2', DateTime.now(), 65, 8));

    await tester.pumpWidget(
      AppScope(
        services: services,
        child: const MaterialApp(home: ProgressScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final first = PersonalRecordService.estimatedOneRepMax(60, 8);
    final latest = PersonalRecordService.estimatedOneRepMax(65, 8);

    expect(find.text('力量曲线'), findsOneWidget);
    expect(find.text('平板杠铃卧推'), findsOneWidget);
    expect(find.text('最新 ${latest.toStringAsFixed(1)} kg'), findsOneWidget);
    expect(
      find.text('较首次 +${(latest - first).toStringAsFixed(1)} kg'),
      findsOneWidget,
    );
    expect(find.text('2 次记录'), findsOneWidget);

    // 打开动作选择器
    await tester.tap(find.text('平板杠铃卧推'));
    await tester.pumpAndSettle();
    expect(find.text('选择动作'), findsOneWidget);
    expect(find.text('2 次训练'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('从进度列表进入单次训练复盘', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await initializeDateFormatting('zh_CN', null);
    final services = await AppServices.create();
    await services.workouts.saveSession(
      _session('s3', DateTime.now().subtract(const Duration(days: 1)), 60, 8),
    );

    await tester.pumpWidget(
      AppScope(
        services: services,
        child: const MaterialApp(home: ProgressScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('上肢推拉'));
    await tester.pumpAndSettle();

    expect(find.text('训练记录'), findsOneWidget);
    expect(find.text('动作明细'), findsOneWidget);
    expect(find.text('平板杠铃卧推'), findsOneWidget);
    expect(find.text('60 kg × 8'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
