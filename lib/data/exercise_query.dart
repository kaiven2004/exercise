import 'package:lpinyin/lpinyin.dart';

import 'exercises/exercise_meta.dart';
import 'models/models.dart';
import 'models/workout_models.dart';

/// 动作库排序方式。
enum ExerciseSort {
  recommended('推荐'),
  frequent('常用'),
  name('名称');

  final String label;
  const ExerciseSort(this.label);
}

/// 动作库筛选条件。UI 与测试共用同一套规则。
class ExerciseQuery {
  final String query;
  final String? muscle;
  final Equipment? equipment;
  final String? difficulty;
  final bool favoritesOnly;
  final ExerciseSort sort;

  const ExerciseQuery({
    this.query = '',
    this.muscle,
    this.equipment,
    this.difficulty,
    this.favoritesOnly = false,
    this.sort = ExerciseSort.recommended,
  });

  bool get isFiltering =>
      query.trim().isNotEmpty ||
      muscle != null ||
      equipment != null ||
      difficulty != null ||
      favoritesOnly;

  ExerciseQuery copyWith({
    String? query,
    String? muscle,
    bool clearMuscle = false,
    Equipment? equipment,
    bool clearEquipment = false,
    String? difficulty,
    bool clearDifficulty = false,
    bool? favoritesOnly,
    ExerciseSort? sort,
  }) {
    return ExerciseQuery(
      query: query ?? this.query,
      muscle: clearMuscle ? null : (muscle ?? this.muscle),
      equipment: clearEquipment ? null : (equipment ?? this.equipment),
      difficulty: clearDifficulty ? null : (difficulty ?? this.difficulty),
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
      sort: sort ?? this.sort,
    );
  }
}

/// 动作名称的拼音缓存。搜索 "wt" 也应命中「卧推」。
final Map<String, String> _pinyinIndex = <String, String>{};

String _pinyinFor(Exercise exercise) {
  return _pinyinIndex.putIfAbsent(exercise.id, () {
    final name = exercise.name;
    final initials = PinyinHelper.getShortPinyin(name).toLowerCase();
    final full = PinyinHelper.getPinyinE(name, separator: '').toLowerCase();
    return '$initials $full';
  });
}

bool _matchesQuery(Exercise exercise, String rawQuery) {
  final q = rawQuery.trim().toLowerCase();
  if (q.isEmpty) return true;
  if (exercise.name.toLowerCase().contains(q)) return true;
  if (exercise.categoryPath.toLowerCase().contains(q)) return true;
  if (exercise.description.toLowerCase().contains(q)) return true;
  if (exercise.tips.any((tip) => tip.toLowerCase().contains(q))) return true;
  // 拼音只对纯字母查询生效，避免中文被转写后误命中。
  if (RegExp(r'^[a-z]+$').hasMatch(q)) {
    return _pinyinFor(exercise).contains(q);
  }
  return false;
}

/// 某个分类（含所有子分类）下的动作。
///
/// 分类树只存名称，动作只存 categoryPath，所以按路径分段匹配。
List<Exercise> exercisesUnderCategory(List<Exercise> all, TrainingCategory category) {
  final names = <String>{};
  void collect(TrainingCategory node) {
    names.add(node.name);
    for (final child in node.subCategories) {
      collect(child);
    }
  }

  collect(category);
  return all.where((exercise) {
    final parts = exercise.categoryPath.split(' / ').map((p) => p.trim());
    return parts.any(names.contains);
  }).toList();
}

/// 按条件筛选并排序动作。
List<Exercise> queryExercises({
  required List<Exercise> all,
  ExerciseQuery query = const ExerciseQuery(),
  Set<String> favoriteIds = const {},
  Map<String, LastPerformance> lastPerformances = const {},
  Map<String, int> usageCounts = const {},
}) {
  final filtered = all.where((exercise) {
    if (!_matchesQuery(exercise, query.query)) return false;
    if (query.favoritesOnly && !favoriteIds.contains(exercise.id)) return false;
    final meta = metaFor(exercise);
    if (query.muscle != null && meta.primaryMuscle != query.muscle) {
      return false;
    }
    if (query.equipment != null && meta.equipment != query.equipment) {
      return false;
    }
    if (query.difficulty != null && exercise.difficulty != query.difficulty) {
      return false;
    }
    return true;
  }).toList();

  switch (query.sort) {
    case ExerciseSort.recommended:
      filtered.sort((a, b) {
        final ca = metaFor(a).compound ? 0 : 1;
        final cb = metaFor(b).compound ? 0 : 1;
        if (ca != cb) return ca.compareTo(cb);
        final dateA = lastPerformances[a.id]?.date;
        final dateB = lastPerformances[b.id]?.date;
        if (dateA != dateB) {
          if (dateA == null) return 1;
          if (dateB == null) return -1;
          return dateB.compareTo(dateA);
        }
        return a.id.compareTo(b.id);
      });
    case ExerciseSort.frequent:
      filtered.sort((a, b) {
        final byCount = (usageCounts[b.id] ?? 0).compareTo(usageCounts[a.id] ?? 0);
        return byCount != 0 ? byCount : a.name.compareTo(b.name);
      });
    case ExerciseSort.name:
      filtered.sort((a, b) => a.name.compareTo(b.name));
  }
  return filtered;
}

/// 从训练历史统计每个动作练过几次。
Map<String, int> exerciseUsageCounts(List<WorkoutSession> sessions) {
  final counts = <String, int>{};
  for (final session in sessions) {
    for (final exercise in session.exercises) {
      if (exercise.completedSets == 0) continue;
      counts[exercise.exercise.id] = (counts[exercise.exercise.id] ?? 0) + 1;
    }
  }
  return counts;
}

/// 可选目标肌群，固定顺序便于筛选栏稳定。
const List<String> kSearchMuscles = ['胸', '背', '腿', '臀', '肩', '手臂', '核心', '全身'];

/// 难度筛选顺序。
const List<String> kSearchDifficulties = ['初级', '中级', '高级'];
