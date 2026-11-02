import 'dart:io';

import 'package:excise/data/exercises/categories.dart';
import 'package:excise/data/exercises/exercise_meta.dart';
import 'package:excise/data/exercises/functional.dart';
import 'package:excise/data/exercises/image_map.dart';
import 'package:excise/data/exercises/strength_arms.dart';
import 'package:excise/data/exercises/strength_back.dart';
import 'package:excise/data/exercises/strength_chest.dart';
import 'package:excise/data/exercises/strength_core.dart';
import 'package:excise/data/exercises/strength_lower.dart';
import 'package:excise/data/exercises/strength_shoulders.dart';
import 'package:excise/data/exercises/yoga.dart';
import 'package:excise/data/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

final List<Exercise> _all = [
  ...kStrengthChestExercises,
  ...kStrengthShouldersExercises,
  ...kStrengthBackExercises,
  ...kStrengthArmsExercises,
  ...kStrengthLowerExercises,
  ...kStrengthCoreExercises,
  ...kFunctionalExercises,
  ...kYogaExercises,
];

Set<String> _categoryNames() {
  final names = <String>{};
  void walk(List<TrainingCategory> cats) {
    for (final cat in cats) {
      names.add(cat.name);
      walk(cat.subCategories);
    }
  }

  walk(kStrengthCategories);
  walk(kFunctionalCategories);
  walk(kYogaCategories);
  return names;
}

void main() {
  group('动作数据完整性', () {
    test('动作总数与 ID 唯一', () {
      // 防止误删：当前基线 215 条。改动数据时若增减，需同步更新这个数字。
      expect(_all.length, 215, reason: '动作总数变化，请确认是有意改动');
      final ids = _all.map((e) => e.id).toList();
      expect(ids.toSet().length, ids.length, reason: '存在重复 ID');
    });

    test('categoryPath 每一段都能在分类树中找到', () {
      final names = _categoryNames();
      const roots = {'力量训练', '功能训练', '瑜伽训练'};
      expect(_all, isNotEmpty);
      for (final exercise in _all) {
        final parts = exercise.categoryPath.split(' / ').map((e) => e.trim()).toList();
        expect(parts, isNotEmpty, reason: '${exercise.id} 分类路径为空');
        expect(roots.contains(parts.first), isTrue,
            reason: '${exercise.id} 根分类不存在: ${parts.first}');
        for (final part in parts.skip(1)) {
          expect(names.contains(part), isTrue,
              reason: '${exercise.id} (${exercise.name}) 分类不存在: $part');
        }
      }
    });

    test('基础字段有效', () {
      for (final exercise in _all) {
        expect(exercise.name.trim(), isNotEmpty, reason: '${exercise.id} 名称为空');
        expect(exercise.description.trim(), isNotEmpty, reason: '${exercise.id} 描述为空');
        expect(exercise.sets, greaterThan(0), reason: '${exercise.id} 组数无效');
        expect(exercise.reps, greaterThan(0), reason: '${exercise.id} 次数无效');
        expect(int.tryParse(exercise.restSeconds), isNotNull,
            reason: '${exercise.id} 休息时间无法解析: ${exercise.restSeconds}');
        expect(int.parse(exercise.restSeconds), greaterThanOrEqualTo(0),
            reason: '${exercise.id} 休息时间为负');
        expect(const {'初级', '中级', '高级'}.contains(exercise.difficulty), isTrue,
            reason: '${exercise.id} 难度值异常: ${exercise.difficulty}');
      }
    });

    test('没有全局重名动作', () {
      final seen = <String, String>{};
      final duplicates = <String>[];
      for (final exercise in _all) {
        final existing = seen[exercise.name];
        if (existing != null) {
          duplicates.add('$existing / ${exercise.id} -> ${exercise.name}');
        } else {
          seen[exercise.name] = exercise.id;
        }
      }
      expect(duplicates, isEmpty, reason: duplicates.join('\n'));
    });

    test('描述和要点达到最低信息量', () {
      for (final exercise in _all) {
        expect(exercise.description.trim().length, greaterThanOrEqualTo(20),
            reason: '${exercise.id} (${exercise.name}) 描述过短');
        expect(exercise.tips.length, greaterThanOrEqualTo(2),
            reason: '${exercise.id} (${exercise.name}) 要点少于 2 条');
      }
    });

    test('元数据表覆盖全部动作', () {
      final ids = _all.map((e) => e.id).toSet();
      expect(kExerciseMetaTable.keys.toSet(), ids,
          reason: '新增或删除动作时，请同步更新 exercise_meta_table.dart');
    });

    test('元数据表的主要肌群与分类一致', () {
      for (final exercise in _all) {
        final meta = kExerciseMetaTable[exercise.id];
        expect(meta, isNotNull, reason: '${exercise.id} 缺少元数据');
        expect(meta!.primaryMuscle, primaryMuscleFor(exercise.categoryPath),
            reason: '${exercise.id} (${exercise.name}) 主要肌群与分类不一致');
      }
    });

    test('力量训练动作都有明确器械', () {
      // 药球不在 Equipment 枚举中，允许归入「其他」。
      const medicineBallIds = {'10018', '10155'};
      for (final exercise in _all.where((e) => e.categoryPath.startsWith('力量训练'))) {
        if (medicineBallIds.contains(exercise.id)) continue;
        expect(metaFor(exercise).equipment, isNot(Equipment.other),
            reason: '${exercise.id} (${exercise.name}) 器械仍为「其他」');
      }
    });

    test('动作图片文件存在', () {
      expect(kExerciseGifs, isNotEmpty);
      expect(kExerciseThumbIds.length, kExerciseGifs.length);
      for (final entry in kExerciseGifs.entries) {
        final gif = File('assets/images/${entry.value}');
        expect(gif.existsSync(), isTrue, reason: '缺少 GIF: ${gif.path}');
        final thumb = File('assets/images/thumbs/${entry.key}.png');
        expect(thumb.existsSync(), isTrue, reason: '缺少缩略图: ${thumb.path}');
      }
    });

    test('抽检标记的动作都是真实存在的 GIF', () {
      final ids = _all.map((e) => e.id).toSet();
      for (final id in kMismatchedGifIds) {
        expect(kExerciseGifs.containsKey(id), isTrue, reason: '$id 不在 GIF 索引中');
        expect(ids.contains(id), isTrue, reason: '$id 不对应任何动作');
        expect(getExerciseGif(id), isNull, reason: '$id 应回退 SVG');
        expect(getExerciseThumb(id), isNull, reason: '$id 应回退 SVG');
      }
    });

    test('每个动作都能得到有效元数据', () {
      for (final exercise in _all) {
        final meta = metaFor(exercise);
        expect(meta.primaryMuscle, isNot('其他'),
            reason: '${exercise.id} (${exercise.categoryPath}) 未匹配主要肌群');
        expect(meta.primaryMuscle.trim(), isNotEmpty);
      }
    });
  });
}
