import 'package:excise/data/exercises/categories.dart';
import 'package:excise/data/exercises/exercise_meta.dart';
import 'package:excise/data/exercise_query.dart';
import 'package:excise/data/repositories/sample_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final all = SampleExerciseRepository().getExercises('all');

  test('父分类包含全部子分类动作', () {
    final upper = kStrengthCategories.first;
    final results = exercisesUnderCategory(all, upper);
    expect(results.length, 121);
    expect(results.any((e) => e.id == '10001'), isTrue);
    expect(results.any((e) => e.id == '10074'), isTrue);
    expect(results.any((e) => e.id == '10096'), isTrue);
    // 下肢不属于上肢。
    expect(results.any((e) => e.id == '10115'), isFalse);
  });

  test('叶子分类只包含该分类动作', () {
    final lowerChest = kStrengthCategories.first.subCategories.first.subCategories.last;
    final results = exercisesUnderCategory(all, lowerChest);
    expect(results.length, 18);
    expect(results.every((e) => e.categoryPath.endsWith('下胸')), isTrue);
  });

  test('中文关键词搜索能命中上斜/平板/下斜卧推', () {
    final results = queryExercises(all: all, query: const ExerciseQuery(query: '卧推'));
    expect(results.length, greaterThanOrEqualTo(3));
    expect(results.any((e) => e.id == '10001'), isTrue);
    expect(results.any((e) => e.id == '10022'), isTrue);
    expect(results.where((e) => e.name.contains('卧推')).length, greaterThanOrEqualTo(3));
  });

  test('拼音首字母 wt 能命中卧推', () {
    final results = queryExercises(all: all, query: const ExerciseQuery(query: 'wt'));
    expect(results, isNotEmpty);
    expect(results.any((e) => e.name.contains('卧推')), isTrue);
  });

  test('器械筛选只保留哑铃动作', () {
    final results = queryExercises(
      all: all,
      query: const ExerciseQuery(equipment: Equipment.dumbbell),
    );
    expect(results, isNotEmpty);
    expect(results.every((e) => metaFor(e).equipment == Equipment.dumbbell), isTrue);
  });

  test('部位筛选与器械筛选可以叠加', () {
    final results = queryExercises(
      all: all,
      query: const ExerciseQuery(muscle: '胸', equipment: Equipment.barbell),
    );
    expect(results, isNotEmpty);
    expect(results.every((e) => metaFor(e).primaryMuscle == '胸'), isTrue);
    expect(results.every((e) => metaFor(e).equipment == Equipment.barbell), isTrue);
  });

  test('只看收藏', () {
    final results = queryExercises(
      all: all,
      query: const ExerciseQuery(favoritesOnly: true),
      favoriteIds: {'10022'},
    );
    expect(results.map((e) => e.id), ['10022']);
  });

  test('常用排序按本地训练次数降序', () {
    final results = queryExercises(
      all: all,
      query: const ExerciseQuery(sort: ExerciseSort.frequent),
      usageCounts: {'10081': 5, '10022': 9},
    );
    expect(results.first.id, '10022');
    expect(results[1].id, '10081');
  });

  test('推荐排序复合动作排在孤立动作前', () {
    final results = queryExercises(
      all: all,
      query: const ExerciseQuery(muscle: '胸'),
    );
    final firstIsolation = results.indexWhere((e) => !metaFor(e).compound);
    if (firstIsolation >= 0) {
      expect(
        results.skip(firstIsolation).every((e) => !metaFor(e).compound),
        isTrue,
      );
    }
  });

  test('难度筛选生效', () {
    final results = queryExercises(
      all: all,
      query: const ExerciseQuery(difficulty: '高级'),
    );
    expect(results, isNotEmpty);
    expect(results.every((e) => e.difficulty == '高级'), isTrue);
  });

  test('搜索不到时返回空列表', () {
    final results = queryExercises(
      all: all,
      query: const ExerciseQuery(query: '不存在的动作xyz'),
    );
    expect(results, isEmpty);
  });
}
