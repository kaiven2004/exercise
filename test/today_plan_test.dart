import 'package:excise/app/app_scope.dart';
import 'package:excise/data/models/models.dart';
import 'package:excise/data/workout_templates.dart';
import 'package:excise/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('首页优先展示今天排期的计划并可直接开始', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await initializeDateFormatting('zh_CN', null);
    final services = await AppServices.create();

    final now = DateTime.now();
    final base = buildPlanFromTemplate(kWorkoutTemplates.first, id: 'plan_today');
    final plan = CustomPlan(
      id: base.id,
      name: '今日排期',
      createdAt: base.createdAt,
      updatedAt: base.updatedAt,
      exercises: base.exercises,
      scheduledWeekdays: [now.weekday],
    );
    await services.plans.savePlan(plan);

    await tester.pumpWidget(ExciseApp(services: services));
    await tester.pumpAndSettle();

    expect(find.text('今天的计划'), findsOneWidget);
    expect(find.text('今日排期'), findsOneWidget);
    expect(find.text('开始训练'), findsOneWidget);

    await tester.tap(find.text('开始训练'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('完成第 1 组'), findsOneWidget);
    expect(services.workouts.getDraft()?.planId, 'plan_today');

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('没有排期时首页仍显示今天练什么', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await initializeDateFormatting('zh_CN', null);
    final services = await AppServices.create();

    final now = DateTime.now();
    final tomorrow = now.weekday == 7 ? 1 : now.weekday + 1;
    final base = buildPlanFromTemplate(kWorkoutTemplates.first, id: 'plan_tomorrow');
    await services.plans.savePlan(CustomPlan(
      id: base.id,
      name: '明日排期',
      createdAt: base.createdAt,
      updatedAt: base.updatedAt,
      exercises: base.exercises,
      scheduledWeekdays: [tomorrow],
    ));

    await tester.pumpWidget(ExciseApp(services: services));
    await tester.pumpAndSettle();

    expect(find.text('今天练什么'), findsOneWidget);
    expect(find.text('今日排期'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
