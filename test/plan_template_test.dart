import 'package:excise/data/models/models.dart';
import 'package:excise/data/repositories/custom_plan_repository.dart';
import 'package:excise/data/workout_templates.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('四套模板都能生成计划', () {
    for (final template in kWorkoutTemplates) {
      final plan = buildPlanFromTemplate(template, id: 'plan_${template.id}');
      expect(plan.name, template.name);
      expect(plan.exercises.length, template.resolveExercises().length);
      expect(plan.exercises, isNotEmpty);
      for (var i = 0; i < plan.exercises.length; i++) {
        expect(plan.exercises[i].order, i);
        expect(plan.exercises[i].sets, greaterThan(0));
        expect(plan.exercises[i].reps, greaterThan(0));
      }
    }
  });

  test('计划拖拽后的顺序能持久化', () async {
    final repo = LocalCustomPlanRepository();
    await repo.init();

    final template = kWorkoutTemplates.first;
    final base = buildPlanFromTemplate(template, id: 'plan_reorder');
    final reversed = [
      for (var i = 0; i < base.exercises.length; i++)
        base.exercises[base.exercises.length - 1 - i].copyWith(order: i),
    ];
    await repo.savePlan(CustomPlan(
      id: base.id,
      name: base.name,
      createdAt: base.createdAt,
      updatedAt: DateTime.now(),
      exercises: reversed,
    ));

    // 重新读取，顺序与 order 字段都保留。
    final reopened = LocalCustomPlanRepository();
    await reopened.init();
    final loaded = reopened.getPlan('plan_reorder');
    expect(loaded, isNotNull);
    expect(
      loaded!.exercises.map((e) => e.exercise.id),
      reversed.map((e) => e.exercise.id),
    );
    expect(
      loaded.exercises.map((e) => e.order),
      [for (var i = 0; i < base.exercises.length; i++) i],
    );
  });

  test('复制计划保留动作但换新 ID', () async {
    final repo = LocalCustomPlanRepository();
    await repo.init();
    final plan = buildPlanFromTemplate(kWorkoutTemplates.first, id: 'plan_original');
    await repo.savePlan(plan);

    await repo.duplicatePlan(plan);
    final plans = repo.getPlans();
    expect(plans.length, 2);
    final copy = plans.firstWhere((p) => p.id != 'plan_original');
    expect(copy.name, contains('副本'));
    expect(
      copy.exercises.map((e) => e.exercise.id),
      plan.exercises.map((e) => e.exercise.id),
    );
  });

  test('删除计划后不会再出现在列表里', () async {
    final repo = LocalCustomPlanRepository();
    await repo.init();
    await repo.savePlan(buildPlanFromTemplate(kWorkoutTemplates.first, id: 'plan_delete'));
    await repo.deletePlan('plan_delete');
    expect(repo.getPlans(), isEmpty);
  });
}
