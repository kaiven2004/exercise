import '../models/models.dart';
import 'exercise_meta_table.dart';
import 'exercise_meta_types.dart';

export 'exercise_meta_table.dart';
export 'exercise_meta_types.dart';

/// 动作元数据入口。
///
/// 215 条动作的取值已经写在 [kExerciseMetaTable] 里，不再靠名称猜。
/// 表里没有的新动作才走下面的规则推断，方便以后扩展。
ExerciseMeta metaFor(Exercise exercise) {
  final fixed = kExerciseMetaTable[exercise.id];
  if (fixed != null) return fixed;
  return ExerciseMeta(
    equipment: _inferEquipment(exercise),
    compound: _inferCompound(exercise.name),
    primaryMuscle: primaryMuscleFor(exercise.categoryPath),
  );
}

/// 叶子分类 → 主要肌群。
String primaryMuscleFor(String categoryPath) {
  final parts = categoryPath.split(' / ').map((e) => e.trim()).toList();
  if (parts.isEmpty) return '全身';
  final leaf = parts.last;
  const byLeaf = {
    '胸部训练': '胸',
    '上胸': '胸',
    '中胸': '胸',
    '下胸': '胸',
    '肩部训练': '肩',
    '前束': '肩',
    '中束': '肩',
    '后束': '肩',
    '肩袖肌群': '肩',
    '背部训练': '背',
    '背阔肌': '背',
    '上背厚度': '背',
    '斜方下束': '背',
    '下背/竖脊肌': '背',
    '手臂训练': '手臂',
    '肱二头肌': '手臂',
    '肱三头肌': '手臂',
    '前臂': '手臂',
    '下肢训练': '腿',
    '股四头肌': '腿',
    '腘绳肌': '腿',
    '内收肌群': '腿',
    '小腿训练': '腿',
    '臀部训练': '臀',
    '核心训练': '核心',
    '腹直肌': '核心',
    '腹斜肌': '核心',
    '深层核心': '核心',
    '抗伸展': '核心',
  };
  final muscle = byLeaf[leaf];
  if (muscle != null) return muscle;
  if (parts.first == '功能训练') return '全身';
  if (parts.first == '瑜伽训练') return '全身';
  return '其他';
}

/// 进度页展示顺序，也是容量统计的分组顺序。
const List<String> kMuscleGroupOrder = ['胸', '背', '腿', '臀', '肩', '手臂', '核心', '全身', '其他'];

Equipment _inferEquipment(Exercise exercise) {
  final name = exercise.name;
  bool has(List<String> words) => words.any(name.contains);

  if (name.contains('史密斯')) return Equipment.machine;
  if (name.contains('杠铃')) return Equipment.barbell;
  if (name.contains('哑铃')) return Equipment.dumbbell;
  if (name.contains('壶铃')) return Equipment.kettlebell;
  if (has(['绳索', '龙门架', '滑轮', '缆绳'])) return Equipment.cable;
  if (has(['器械', '机', '器', '哈克', '腿举'])) return Equipment.machine;
  if (name.contains('弹力带')) return Equipment.band;
  if (has(['悬吊', '毛巾', 'TRX'])) return Equipment.bodyweight;
  if (has(['药球', '沙袋', '雪橇', '战绳', '跳箱'])) return Equipment.other;
  if (has(['俯卧撑', '引体', '双杠', '悬垂', '平板', '卷腹', '死虫', '鸟狗', '臀桥', '熊爬', '鳄鱼爬', '猫驼', '呼吸', '行走', '爬'])) {
    return Equipment.bodyweight;
  }
  if (exercise.categoryPath.startsWith('瑜伽训练') || exercise.categoryPath.startsWith('功能训练')) {
    return Equipment.bodyweight;
  }
  return Equipment.other;
}

const List<String> _compoundKeywords = [
  '深蹲',
  '硬拉',
  '卧推',
  '划船',
  '推举',
  '引体',
  '下拉',
  '箭步蹲',
  '分腿蹲',
  '腿举',
  '臂屈伸',
  '臀推',
  '早安式',
  '俯卧撑',
  '农夫行走',
  '推胸',
];

bool _inferCompound(String name) => _compoundKeywords.any(name.contains);
