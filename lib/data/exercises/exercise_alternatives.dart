import '../models/models.dart';
import 'exercise_meta.dart';

/// 动作模式。替代动作优先匹配相同模式，再匹配肌群和分类。
///
/// 名称规则覆盖大多数动作，少数名称容易误判的写在 [_patternOverrides] 里。
enum MovementPattern {
  horizontalPush('水平推'),
  verticalPush('垂直推'),
  chestFly('夹胸'),
  horizontalPull('水平拉'),
  verticalPull('垂直拉'),
  rearDelt('后束/面拉'),
  squat('深蹲'),
  hinge('髋铰链'),
  lunge('单腿蹲'),
  hipExtension('伸髋'),
  hipAbduction('髋外展'),
  hipAdduction('髋内收'),
  kneeExtension('伸膝'),
  kneeFlexion('屈膝'),
  calfRaise('提踵'),
  shoulderRaise('肩抬高'),
  shoulderRotation('肩旋转'),
  biceps('弯举'),
  triceps('臂屈伸'),
  coreFlexion('躯干屈曲'),
  antiExtension('抗伸展'),
  rotation('旋转'),
  carry('负重行走'),
  mobility('灵活性'),
  other('其他');

  final String label;
  const MovementPattern(this.label);
}

/// 名称规则判断不了的动作。新增动作时优先靠名称，命中不了再补这里。
const Map<String, MovementPattern> _patternOverrides = {
  // 地雷管推举轨迹介于平推和上推之间，按上胸推类处理。
  '10020': MovementPattern.horizontalPush,
  '10021': MovementPattern.horizontalPush,
  // 固定器械的水平推。
  '10033': MovementPattern.horizontalPush,
  '10036': MovementPattern.horizontalPush,
  // 肩推统一归垂直推。
  '10053': MovementPattern.verticalPush,
  '10054': MovementPattern.verticalPush,
  '10057': MovementPattern.verticalPush,
  '10061': MovementPattern.verticalPush,
  // 面拉和 Y 字动作练后束/下斜方，不按划船算。
  '10067': MovementPattern.rearDelt,
  '10090': MovementPattern.rearDelt,
  '10091': MovementPattern.rearDelt,
  // 山羊挺身、下背伸展归髋铰链。
  '10093': MovementPattern.hinge,
  // 肩袖旋转。
  '10071': MovementPattern.shoulderRotation,
  '10072': MovementPattern.shoulderRotation,
  '10073': MovementPattern.mobility,
  // 窄距卧推是三头主导，但动作模式仍是水平推。
  '10103': MovementPattern.horizontalPush,
  // 双杠臂屈伸：三头版垂直推，前倾版水平推。
  '10109': MovementPattern.verticalPush,
  '10217': MovementPattern.horizontalPush,
  // 北欧降是屈膝主导的腘绳离心，不归核心抗伸展。
  '10156': MovementPattern.kneeFlexion,
  // 药球抗伸展俯卧撑名字里有「俯卧撑」，但训练目的是核心抗伸展。
  '10155': MovementPattern.antiExtension,
  // 负重行走与抗侧屈。
  '10113': MovementPattern.carry,
  '10149': MovementPattern.carry,
  '10162': MovementPattern.carry,
  '10163': MovementPattern.carry,
  '10169': MovementPattern.carry,
  '10188': MovementPattern.carry,
  // 臀主导动作。
  '10129': MovementPattern.hipExtension,
  '10130': MovementPattern.hipExtension,
  '10134': MovementPattern.hipExtension,
  '10135': MovementPattern.hipExtension,
  '10136': MovementPattern.hipExtension,
  // 功能训练里的灵活性与旋转。
  '10164': MovementPattern.mobility,
  '10165': MovementPattern.rotation,
  '10168': MovementPattern.hinge,
  '10170': MovementPattern.mobility,
  '10175': MovementPattern.mobility,
  '10184': MovementPattern.mobility,
  '10189': MovementPattern.mobility,
  '10190': MovementPattern.mobility,
  // 悬吊抓握。
  '10176': MovementPattern.carry,
  '10178': MovementPattern.carry,
  '10180': MovementPattern.carry,
};

/// 推断动作模式。瑜伽统一归灵活性，避免被「支撑」等词误判。
MovementPattern movementPatternFor(Exercise exercise) {
  final fixed = _patternOverrides[exercise.id];
  if (fixed != null) return fixed;
  if (exercise.categoryPath.startsWith('瑜伽训练')) {
    return MovementPattern.mobility;
  }

  final name = exercise.name;
  bool has(List<String> words) => words.any(name.contains);

  // 先判断腿和手臂，避免「腿屈伸」被三头规则抢走。
  if (has(['腿屈伸'])) return MovementPattern.kneeExtension;
  if (has(['腿弯举'])) return MovementPattern.kneeFlexion;
  if (has(['提踵'])) return MovementPattern.calfRaise;
  if (has(['臀推', '髋桥', '后踢', '臀拉'])) return MovementPattern.hipExtension;
  if (has(['硬拉', '早安', '背伸', '挺身', '髋铰链'])) return MovementPattern.hinge;
  if (has(['深蹲', '腿举', '哈克'])) return MovementPattern.squat;
  if (has(['箭步', '分腿', '台阶', '侧步蹲', '单腿箱式', '跳跃落地'])) {
    return MovementPattern.lunge;
  }
  if (has(['外展', '侧向行走'])) return MovementPattern.hipAbduction;
  if (has(['内收'])) return MovementPattern.hipAdduction;
  if (has(['弯举'])) return MovementPattern.biceps;
  if (has(['臂屈伸', '三头', '下压'])) return MovementPattern.triceps;

  if (has(['反向飞鸟', '面拉', 'Y字', 'Y型'])) return MovementPattern.rearDelt;
  if (has(['划船'])) return MovementPattern.horizontalPull;
  if (has(['引体', '高位下拉', '下拉'])) return MovementPattern.verticalPull;

  if (has(['卧推', '推胸', '俯卧撑'])) return MovementPattern.horizontalPush;
  if (has(['推举', '肩推', '阿诺德'])) return MovementPattern.verticalPush;
  if (has(['夹胸', '飞鸟', '拉举'])) return MovementPattern.chestFly;

  if (has(['侧平举', '前平举', '平举'])) return MovementPattern.shoulderRaise;
  if (has(['外旋', '内旋'])) return MovementPattern.shoulderRotation;

  if (has(['卷腹', '举腿', '龙旗'])) return MovementPattern.coreFlexion;
  if (has(['平板', '支撑', '死虫', '鸟狗', '抗伸展'])) {
    return MovementPattern.antiExtension;
  }
  if (has(['转体', '伐木', '旋转', '抗旋转'])) return MovementPattern.rotation;

  if (has(['行走', '农夫', 'carries', '拖拽', '悬挂'])) return MovementPattern.carry;
  if (has(['拉伸', '呼吸', '流动', '猫驼', '爬'])) return MovementPattern.mobility;

  return MovementPattern.other;
}

/// 为 [exercise] 挑选替代动作。
///
/// 排序优先级：同动作模式 > 同主要肌群 > 同叶子分类 > 同复合/孤立；
/// 器械不同会略微加分，方便在器械被占用时换一个选择。
List<Exercise> alternativesFor({
  required Exercise exercise,
  required List<Exercise> all,
  Set<String> excludeIds = const {},
  int limit = 6,
}) {
  final pattern = movementPatternFor(exercise);
  final meta = metaFor(exercise);
  final leaf = _leafOf(exercise);

  final scored = <_ScoredExercise>[];
  for (final candidate in all) {
    if (candidate.id == exercise.id || excludeIds.contains(candidate.id)) {
      continue;
    }
    final candidateMeta = metaFor(candidate);
    var score = 0;
    if (movementPatternFor(candidate) == pattern) score += 100;
    if (candidateMeta.primaryMuscle == meta.primaryMuscle) score += 40;
    if (_leafOf(candidate) == leaf) score += 25;
    if (candidateMeta.compound == meta.compound) score += 8;
    if (candidateMeta.equipment != meta.equipment) score += 5;
    if (score == 0) continue;
    scored.add(_ScoredExercise(candidate, score));
  }

  scored.sort((a, b) {
    final byScore = b.score.compareTo(a.score);
    if (byScore != 0) return byScore;
    final byName = a.exercise.name.compareTo(b.exercise.name);
    if (byName != 0) return byName;
    return a.exercise.id.compareTo(b.exercise.id);
  });

  if (scored.isNotEmpty) {
    return scored.take(limit).map((e) => e.exercise).toList();
  }

  // 极端情况下（模式与肌群都匹配不到）退回到同肌群，再退回到全部动作。
  final sameMuscle = all
      .where((e) => e.id != exercise.id && !excludeIds.contains(e.id))
      .where((e) => metaFor(e).primaryMuscle == meta.primaryMuscle)
      .take(limit)
      .toList();
  if (sameMuscle.isNotEmpty) return sameMuscle;
  return all
      .where((e) => e.id != exercise.id && !excludeIds.contains(e.id))
      .take(limit)
      .toList();
}

String _leafOf(Exercise exercise) {
  final parts = exercise.categoryPath.split(' / ');
  return parts.isEmpty ? '' : parts.last;
}

class _ScoredExercise {
  final Exercise exercise;
  final int score;
  const _ScoredExercise(this.exercise, this.score);
}
