import 'dart:convert';

import 'package:excise/data/models/models.dart';
import 'package:excise/data/repositories/local_repositories.dart';
import 'package:excise/data/repositories/sample_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Exercise _legacyChestExercise(String id, String name) => Exercise(
      id: id,
      name: name,
      categoryPath: '力量训练 / 胸部训练 / 下胸',
      description: '测试',
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('旧收藏中的 10053–10061 只清理一次', () async {
    SharedPreferences.setMockInitialValues({
      'favorites': ['10001', '10053', '10061'],
    });
    final repo = LocalFavoriteRepository();
    await repo.init();
    expect(repo.removedLegacyFavorites, isTrue);

    final all = SampleExerciseRepository().getExercises('all');
    final favorites = repo.getFavorites(all).map((e) => e.id).toList();
    expect(favorites, ['10001']);

    // 用户之后重新收藏肩部动作，不应再被迁移清掉。
    final shoulder = all.firstWhere((e) => e.id == '10053');
    await repo.toggleFavorite(shoulder);
    final repo2 = LocalFavoriteRepository();
    await repo2.init();
    expect(repo2.removedLegacyFavorites, isFalse);
    expect(repo2.getFavorites(all).map((e) => e.id), containsAll(['10001', '10053']));
  });

  test('旧历史中的下胸 ID 按名称快照重映射', () async {
    final legacy = _legacyChestExercise('10053', '下斜哑铃拉举');
    final session = TrainingSession(
      id: 's1',
      date: DateTime(2026, 1, 1),
      sectionName: '力量训练',
      categoryPath: legacy.categoryPath,
      exercises: [
        ExerciseLog(exercise: legacy, completedSets: 3, totalReps: 30),
      ],
    );
    SharedPreferences.setMockInitialValues({
      'training_history': [jsonEncode(session.toJson())],
    });
    final repo = LocalTrainingHistoryRepository();
    await repo.init();
    final restored = repo.getHistory();
    expect(restored.length, 1);
    expect(restored.first.exercises.first.exercise.id, '10211');
    expect(restored.first.exercises.first.exercise.name, '下斜哑铃拉举');
    expect(restored.first.exercises.first.completedSets, 3);
  });

  test('旧历史中的重复动作合并到保留 ID', () async {
    final dead = Exercise(
      id: '10142',
      name: '传统硬拉',
      categoryPath: '力量训练 / 下肢训练 / 后侧链综合',
      description: '测试',
    );
    final session = TrainingSession(
      id: 's2',
      date: DateTime(2026, 1, 2),
      sectionName: '力量训练',
      categoryPath: dead.categoryPath,
      exercises: [
        ExerciseLog(exercise: dead, completedSets: 4, totalReps: 20),
      ],
    );
    SharedPreferences.setMockInitialValues({
      'training_history': [jsonEncode(session.toJson())],
    });
    final repo = LocalTrainingHistoryRepository();
    await repo.init();
    expect(repo.getHistory().first.exercises.first.exercise.id, '10092');
  });
}
