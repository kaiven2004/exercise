import 'package:excise/app/app_scope.dart';
import 'package:excise/data/exercises/exercise_meta.dart';
import 'package:excise/data/exercise_query.dart';
import 'package:excise/data/repositories/sample_repository.dart';
import 'package:excise/ui/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('搜索页支持拼音首字母与收藏筛选', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await initializeDateFormatting('zh_CN', null);
    final services = await AppServices.create();

    await tester.pumpWidget(
      AppScope(
        services: services,
        child: const MaterialApp(home: SearchScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // 默认展示全部动作和筛选控件。
    expect(find.text('器械'), findsWidgets);
    expect(find.text('难度'), findsWidgets);
    expect(find.text('推荐'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'wt');
    await tester.pumpAndSettle();

    expect(find.text('上斜杠铃卧推'), findsOneWidget);
    expect(find.textContaining('卧推'), findsWidgets);

    // 清除搜索后再试器械筛选。
    await tester.tap(find.text('清除筛选'));
    await tester.pumpAndSettle();

    final all = SampleExerciseRepository().getExercises('all');
    final dumbbellCount = queryExercises(
      all: all,
      query: const ExerciseQuery(equipment: Equipment.dumbbell),
    ).length;
    await tester.tap(find.text('器械').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(PopupMenuItem<String>, '哑铃'));
    await tester.pumpAndSettle();
    expect(find.text('$dumbbellCount 个动作'), findsOneWidget);

    // 只看收藏：没有收藏时给出空状态。
    await tester.tap(find.byTooltip('只看收藏'));
    await tester.pumpAndSettle();
    expect(find.textContaining('收藏'), findsWidgets);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
