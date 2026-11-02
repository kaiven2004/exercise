import 'package:excise/data/exercises/exercise_alternatives.dart';
import 'package:excise/data/repositories/sample_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final repo = SampleExerciseRepository();
  final all = repo.getExercises('all');

  test('上斜卧推优先推荐同模式的推类动作', () {
    final exercise = repo.getExerciseById('10001')!;
    final alternatives = alternativesFor(exercise: exercise, all: all);

    expect(alternatives, isNotEmpty);
    expect(alternatives.any((e) => e.id == '10001'), isFalse);
    expect(
      alternatives.take(3).every((e) => movementPatternFor(e) == MovementPattern.horizontalPush),
      isTrue,
      reason: alternatives.map((e) => '${e.name}/${movementPatternFor(e).label}').join(', '),
    );
    expect(alternatives.any((e) => e.id == '10006'), isTrue);

    // 推类动作排在夹胸之前。
    final pressIndex = alternatives.indexWhere((e) => e.id == '10006');
    final flyIndex = alternatives.indexWhere((e) => movementPatternFor(e) == MovementPattern.chestFly);
    if (flyIndex >= 0) {
      expect(pressIndex, lessThan(flyIndex));
    }
  });

  test('弯举不会混入臂屈伸', () {
    final exercise = repo.getExerciseById('10096')!;
    final alternatives = alternativesFor(exercise: exercise, all: all);

    expect(alternatives, isNotEmpty);
    expect(
      alternatives.every((e) => movementPatternFor(e) == MovementPattern.biceps),
      isTrue,
      reason: alternatives.map((e) => '${e.name}/${movementPatternFor(e).label}').join(', '),
    );
  });

  test('平板支撑推荐抗伸展核心动作', () {
    final exercise = repo.getExerciseById('10151')!;
    final alternatives = alternativesFor(exercise: exercise, all: all);

    expect(alternatives, isNotEmpty);
    expect(
      alternatives.take(5).every((e) => movementPatternFor(e) == MovementPattern.antiExtension),
      isTrue,
      reason: alternatives.map((e) => '${e.name}/${movementPatternFor(e).label}').join(', '),
    );
    expect(alternatives.any((e) => e.id == '10153'), isTrue);
  });

  test('新增腿臀动作能按单腿蹲模式找到替代', () {
    final exercise = repo.getExerciseById('10220')!;
    final alternatives = alternativesFor(exercise: exercise, all: all);

    expect(alternatives, isNotEmpty);
    expect(
      alternatives.take(4).every((e) => movementPatternFor(e) == MovementPattern.lunge),
      isTrue,
      reason: alternatives.map((e) => '${e.name}/${movementPatternFor(e).label}').join(', '),
    );
    expect(alternatives.any((e) => e.id == '10221'), isTrue);
  });

  test('排除已用动作并遵守数量上限', () {
    final exercise = repo.getExerciseById('10022')!;
    final alternatives = alternativesFor(
      exercise: exercise,
      all: all,
      excludeIds: const {'10027'},
      limit: 3,
    );

    expect(alternatives.length, 3);
    expect(alternatives.any((e) => e.id == '10027'), isFalse);
    expect(alternatives.any((e) => e.id == '10022'), isFalse);
  });
}
