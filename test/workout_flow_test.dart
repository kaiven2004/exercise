import 'package:excise/app/app_scope.dart';
import 'package:excise/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('模板 → 跟练 → 组间休息 → 跳过', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await initializeDateFormatting('zh_CN', null);
    final services = await AppServices.create();

    await tester.pumpWidget(ExciseApp(services: services));
    await tester.pumpAndSettle();

    // 今日训练页
    expect(find.text('今天练什么'), findsOneWidget);
    expect(find.text('新手全身 A'), findsOneWidget);

    // 打开模板预览并开始
    await tester.tap(find.text('新手全身 A'));
    await tester.pumpAndSettle();
    expect(find.text('开始训练'), findsOneWidget);

    await tester.tap(find.text('开始训练'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // 训练执行页：第一组可完成
    expect(find.text('完成第 1 组'), findsOneWidget);

    await tester.tap(find.text('完成第 1 组'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 自动进入组间休息
    expect(find.text('组间休息'), findsOneWidget);
    expect(find.text('开始下一组'), findsOneWidget);

    await tester.tap(find.text('跳过'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // 回到训练页，第二组成为当前组
    expect(find.text('完成第 2 组'), findsOneWidget);

    // 卸载页面，取消计时器
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
