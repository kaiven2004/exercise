import 'package:excise/app/app_scope.dart';
import 'package:excise/ui/screens/custom_plan_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('模板库一键生成我的计划', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await initializeDateFormatting('zh_CN', null);
    final services = await AppServices.create();

    await tester.pumpWidget(
      AppScope(
        services: services,
        child: const MaterialApp(home: CustomPlanListScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('模板库'), findsOneWidget);
    expect(find.text('我的计划'), findsOneWidget);
    expect(find.text('新手全身 A'), findsOneWidget);
    expect(find.text('还没有自己的计划'), findsOneWidget);

    await tester.tap(find.text('使用模板').first);
    await tester.pumpAndSettle();

    final plans = services.plans.getPlans();
    expect(plans.length, 1);
    expect(plans.first.name, '新手全身 A');
    expect(plans.first.exercises, isNotEmpty);
    expect(find.text('我的计划'), findsOneWidget);

    // 生成的计划可以直接开始。
    await tester.tap(find.text('开始'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('完成第 1 组'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
