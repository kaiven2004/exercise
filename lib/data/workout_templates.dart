import 'package:excise/data/exercises/exercise_meta.dart';
import 'package:excise/data/models/models.dart';
import 'package:excise/data/models/workout_models.dart';
import 'package:excise/data/repositories/sample_repository.dart';

/// 首页模板。动作 ID 直接引用现有动作库。
class WorkoutTemplate {
  final String id;
  final String name;
  final String tagline;
  final List<String> exerciseIds;

  const WorkoutTemplate({
    required this.id,
    required this.name,
    required this.tagline,
    required this.exerciseIds,
  });

  int get exerciseCount => exerciseIds.length;

  List<Exercise> resolveExercises([SampleExerciseRepository? repository]) {
    final repo = repository ?? SampleExerciseRepository();
    return exerciseIds
        .map((id) => repo.getExerciseById(id))
        .whereType<Exercise>()
        .toList();
  }
}

const List<WorkoutTemplate> kWorkoutTemplates = [
  WorkoutTemplate(
    id: 'template_full_body_a',
    name: '新手全身 A',
    tagline: '一周练 2–3 次的起点',
    exerciseIds: ['10117', '10022', '10081', '10053', '10151'],
  ),
  WorkoutTemplate(
    id: 'template_upper',
    name: '上肢推拉',
    tagline: '胸背肩手臂一次练全',
    exerciseIds: ['10022', '10053', '10077', '10081', '10059', '10096', '10106'],
  ),
  WorkoutTemplate(
    id: 'template_lower',
    name: '下肢',
    tagline: '股四、腘绳、臀、小腿',
    exerciseIds: ['10115', '10124', '10121', '10126', '10139', '10151'],
  ),
  WorkoutTemplate(
    id: 'template_core',
    name: '核心',
    tagline: '20 分钟收尾或独立训练',
    exerciseIds: ['10144', '10143', '10148', '10151', '10153'],
  ),
];

WorkoutTemplate? templateById(String id) {
  for (final template in kWorkoutTemplates) {
    if (template.id == id) return template;
  }
  return null;
}

/// 默认组次：复合 4×8 休息 90s；孤立 3×12 休息 60s；核心 3 组。
List<WorkoutExercise> buildWorkoutExercises(
  List<Exercise> exercises, {
  Map<String, LastPerformance> lastPerformances = const {},
}) {
  return exercises.map((exercise) {
    final meta = metaFor(exercise);
    final isCore = meta.primaryMuscle == '核心';
    final isHold = isCore &&
        (exercise.name.contains('支撑') ||
            exercise.name.contains('平板') ||
            exercise.name.contains('L支撑'));
    final isMobility = exercise.categoryPath.startsWith('瑜伽训练');

    int sets;
    int reps;
    if (isMobility) {
      sets = exercise.sets;
      reps = exercise.reps;
    } else if (isHold) {
      sets = 3;
      reps = 30;
    } else if (isCore) {
      sets = 3;
      reps = 15;
    } else if (meta.compound) {
      sets = 4;
      reps = 8;
    } else {
      sets = 3;
      reps = 12;
    }

    final last = lastPerformances[exercise.id];
    if (last != null && !isHold) {
      reps = last.reps > 0 ? last.reps : reps;
    }
    final weight = last?.weight ?? 0;
    return WorkoutExercise(
      exercise: exercise,
      sets: List.generate(
        sets,
        (_) => WorkoutSet(weight: weight, reps: reps),
      ),
    );
  }).toList();
}

int estimateMinutes(List<WorkoutExercise> exercises) {
  var seconds = 5 * 60; // 热身与换器械
  for (final exercise in exercises) {
    final rest = int.tryParse(exercise.exercise.restSeconds) ?? 60;
    seconds += exercise.sets.length * (40 + rest);
  }
  return (seconds / 60).round();
}

/// 快速开始的部位选项。
enum QuickBodyPart {
  full('全身', '全身'),
  chest('胸', '胸'),
  back('背', '背'),
  legs('腿', '腿'),
  shoulders('肩', '肩'),
  arms('手臂', '手臂'),
  core('核心', '核心');

  final String label;
  final String muscle;
  const QuickBodyPart(this.label, this.muscle);

  bool matches(Exercise exercise) {
    if (this == QuickBodyPart.full) return true;
    final m = metaFor(exercise).primaryMuscle;
    if (this == QuickBodyPart.legs) return m == '腿' || m == '臀';
    return m == muscle;
  }
}

List<Exercise> quickStartCandidates({
  required QuickBodyPart part,
  Equipment? equipment,
  SampleExerciseRepository? repository,
}) {
  final all = (repository ?? SampleExerciseRepository()).getExercises('all');
  final list = all.where((exercise) {
    if (exercise.categoryPath.startsWith('瑜伽训练')) return false;
    if (!part.matches(exercise)) return false;
    if (equipment != null && metaFor(exercise).equipment != equipment) return false;
    return true;
  }).toList();

  list.sort((a, b) {
    final ca = metaFor(a).compound ? 0 : 1;
    final cb = metaFor(b).compound ? 0 : 1;
    if (ca != cb) return ca.compareTo(cb);
    return a.id.compareTo(b.id);
  });
  return list;
}

/// 规则推荐：复合优先，全身保证至少一推一拉一腿。
List<Exercise> buildQuickStart({
  required QuickBodyPart part,
  Equipment? equipment,
  required int count,
  SampleExerciseRepository? repository,
}) {
  final candidates = quickStartCandidates(
    part: part,
    equipment: equipment,
    repository: repository,
  );
  if (candidates.isEmpty) return const [];

  final picked = <Exercise>[];
  void take(Exercise exercise) {
    if (picked.length < count && !picked.any((e) => e.id == exercise.id)) {
      picked.add(exercise);
    }
  }

  if (part == QuickBodyPart.full) {
    for (final muscle in const ['胸', '背', '腿', '臀', '肩', '核心', '手臂']) {
      if (picked.length >= count) break;
      final match = candidates.where((e) => metaFor(e).primaryMuscle == muscle);
      if (match.isNotEmpty) take(match.first);
    }
  }

  // 复合与孤立交替补齐，避免全是深蹲硬拉。
  final compounds = candidates.where((e) => metaFor(e).compound).toList();
  final isolations = candidates.where((e) => !metaFor(e).compound).toList();
  var ci = 0;
  var ii = 0;
  while (picked.length < count && (ci < compounds.length || ii < isolations.length)) {
    if (ci < compounds.length) take(compounds[ci++]);
    if (picked.length >= count) break;
    if (ii < isolations.length) take(isolations[ii++]);
  }

  return picked;
}
