import 'package:excise/app/app_scope.dart';
import 'package:excise/data/exercises/categories.dart';
import 'package:excise/data/exercises/exercise_meta.dart';
import 'package:excise/data/exercise_query.dart';
import 'package:excise/data/models/models.dart';
import 'package:excise/data/repositories/sample_repository.dart';
import 'package:excise/ui/screens/exercise_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final upper = kStrengthCategories.first;
  final chest = upper.subCategories.first;

  Future<void> pumpChestList(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    await initializeDateFormatting('zh_CN', null);
    final services = await AppServices.create();

    await tester.pumpWidget(
      AppScope(
        services: services,
        child: MaterialApp(
          home: ExerciseListScreen(
            category: chest,
            parentCategory: upper,
            section: WorkoutSection.strength,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('父分类默认列出全部动作，子分类 Chip 只做筛选', (tester) async {
    await pumpChestList(tester);

    expect(find.text('59 个动作'), findsOneWidget);
    expect(find.text('上斜杠铃卧推'), findsOneWidget);
    expect(find.text('上肢训练 / 胸部训练'), findsOneWidget);

    // 子分类筛选。
    await tester.tap(find.text('下胸'));
    await tester.pumpAndSettle();
    expect(find.text('18 个动作'), findsOneWidget);
    expect(find.text('上肢训练 / 胸部训练 / 下胸'), findsOneWidget);
    expect(find.text('下斜杠铃卧推（15-25度）'), findsOneWidget);
    expect(find.text('上斜杠铃卧推'), findsNothing);

    // 「全部」Chip 恢复整个胸部。
    await tester.tap(find.text('全部'));
    await tester.pumpAndSettle();
    expect(find.text('59 个动作'), findsOneWidget);

    // 搜索覆盖描述，而不只是名称和分类。
    await tester.enterText(find.byType(TextField), '粘滞点');
    await tester.pumpAndSettle();
    expect(find.text('2 个动作'), findsOneWidget);
    expect(find.text('暂停式平板卧推'), findsOneWidget);
    expect(find.text('暂停式下斜卧推'), findsOneWidget);

    await tester.tap(find.text('清除筛选'));
    await tester.pumpAndSettle();
    expect(find.text('59 个动作'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('器械筛选与只看收藏生效', (tester) async {
    await pumpChestList(tester);

    final allChest = exercisesUnderCategory(
      SampleExerciseRepository().getExercises('all'),
      chest,
    );
    final dumbbellCount = queryExercises(
      all: allChest,
      query: const ExerciseQuery(equipment: Equipment.dumbbell),
    ).length;

    await tester.tap(find.byTooltip('器械'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(PopupMenuItem<String>, '哑铃'));
    await tester.pumpAndSettle();
    expect(find.text('$dumbbellCount 个动作'), findsOneWidget);

    // 没有收藏时给出收藏空状态。
    await tester.tap(find.byTooltip('只看收藏').first);
    await tester.pumpAndSettle();
    expect(find.text('还没有符合条件的收藏动作'), findsOneWidget);

    await tester.tap(find.text('清除筛选条件'));
    await tester.pumpAndSettle();
    expect(find.text('59 个动作'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
