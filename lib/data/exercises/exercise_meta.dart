import '../models/models.dart';

/// 器械类型。用于动作库筛选和快速开始生成。
enum Equipment {
  barbell,
  dumbbell,
  kettlebell,
  machine,
  cable,
  band,
  bodyweight,
  other,
}

extension EquipmentLabel on Equipment {
  String get label {
    switch (this) {
      case Equipment.barbell:
        return '杠铃';
      case Equipment.dumbbell:
        return '哑铃';
      case Equipment.kettlebell:
        return '壶铃';
      case Equipment.machine:
        return '器械';
      case Equipment.cable:
        return '绳索';
      case Equipment.band:
        return '弹力带';
      case Equipment.bodyweight:
        return '自重';
      case Equipment.other:
        return '其他';
    }
  }
}

/// 动作的派生属性。不写回 219 条原始数据，按需计算。
class ExerciseMeta {
  final Equipment equipment;
  final bool compound;
  final String primaryMuscle;

  const ExerciseMeta({
    required this.equipment,
    required this.compound,
    required this.primaryMuscle,
  });

  @override
  String toString() =>
      'ExerciseMeta(equipment: ${equipment.name}, compound: $compound, primaryMuscle: $primaryMuscle)';
}

/// 高频动作的人工校正。名称规则推断不出的以这里为准。
const Map<String, ExerciseMeta> _overrides = {
  // 胸
  '10001': ExerciseMeta(equipment: Equipment.barbell, compound: true, primaryMuscle: '胸'),
  '10002': ExerciseMeta(equipment: Equipment.machine, compound: true, primaryMuscle: '胸'),
  '10006': ExerciseMeta(equipment: Equipment.dumbbell, compound: true, primaryMuscle: '胸'),
  '10007': ExerciseMeta(equipment: Equipment.dumbbell, compound: false, primaryMuscle: '胸'),
  '10013': ExerciseMeta(equipment: Equipment.machine, compound: true, primaryMuscle: '胸'),
  '10014': ExerciseMeta(equipment: Equipment.machine, compound: false, primaryMuscle: '胸'),
  '10022': ExerciseMeta(equipment: Equipment.barbell, compound: true, primaryMuscle: '胸'),
  '10023': ExerciseMeta(equipment: Equipment.machine, compound: true, primaryMuscle: '胸'),
  '10026': ExerciseMeta(equipment: Equipment.barbell, compound: true, primaryMuscle: '胸'),
  '10027': ExerciseMeta(equipment: Equipment.dumbbell, compound: true, primaryMuscle: '胸'),
  '10028': ExerciseMeta(equipment: Equipment.dumbbell, compound: false, primaryMuscle: '胸'),
  '10031': ExerciseMeta(equipment: Equipment.dumbbell, compound: false, primaryMuscle: '胸'),
  '10032': ExerciseMeta(equipment: Equipment.machine, compound: false, primaryMuscle: '胸'),
  '10033': ExerciseMeta(equipment: Equipment.machine, compound: true, primaryMuscle: '胸'),
  '10034': ExerciseMeta(equipment: Equipment.cable, compound: false, primaryMuscle: '胸'),
  '10037': ExerciseMeta(equipment: Equipment.bodyweight, compound: true, primaryMuscle: '胸'),
  '10042': ExerciseMeta(equipment: Equipment.barbell, compound: true, primaryMuscle: '胸'),
  '10044': ExerciseMeta(equipment: Equipment.barbell, compound: true, primaryMuscle: '胸'),
  '10049': ExerciseMeta(equipment: Equipment.dumbbell, compound: true, primaryMuscle: '胸'),
  '10217': ExerciseMeta(equipment: Equipment.bodyweight, compound: true, primaryMuscle: '胸'),
  '10218': ExerciseMeta(equipment: Equipment.bodyweight, compound: true, primaryMuscle: '胸'),

  // 肩
  '10053': ExerciseMeta(equipment: Equipment.barbell, compound: true, primaryMuscle: '肩'),
  '10054': ExerciseMeta(equipment: Equipment.dumbbell, compound: true, primaryMuscle: '肩'),
  '10056': ExerciseMeta(equipment: Equipment.dumbbell, compound: false, primaryMuscle: '肩'),
  '10059': ExerciseMeta(equipment: Equipment.dumbbell, compound: false, primaryMuscle: '肩'),
  '10060': ExerciseMeta(equipment: Equipment.dumbbell, compound: false, primaryMuscle: '肩'),
  '10061': ExerciseMeta(equipment: Equipment.dumbbell, compound: true, primaryMuscle: '肩'),
  '10062': ExerciseMeta(equipment: Equipment.cable, compound: false, primaryMuscle: '肩'),
  '10065': ExerciseMeta(equipment: Equipment.dumbbell, compound: false, primaryMuscle: '肩'),
  '10068': ExerciseMeta(equipment: Equipment.cable, compound: false, primaryMuscle: '肩'),

  // 背
  '10074': ExerciseMeta(equipment: Equipment.bodyweight, compound: true, primaryMuscle: '背'),
  '10077': ExerciseMeta(equipment: Equipment.cable, compound: true, primaryMuscle: '背'),
  '10079': ExerciseMeta(equipment: Equipment.cable, compound: false, primaryMuscle: '背'),
  '10081': ExerciseMeta(equipment: Equipment.barbell, compound: true, primaryMuscle: '背'),
  '10082': ExerciseMeta(equipment: Equipment.dumbbell, compound: true, primaryMuscle: '背'),
  '10083': ExerciseMeta(equipment: Equipment.barbell, compound: true, primaryMuscle: '背'),
  '10085': ExerciseMeta(equipment: Equipment.cable, compound: true, primaryMuscle: '背'),
  '10088': ExerciseMeta(equipment: Equipment.machine, compound: true, primaryMuscle: '背'),
  '10089': ExerciseMeta(equipment: Equipment.machine, compound: true, primaryMuscle: '背'),
  '10092': ExerciseMeta(equipment: Equipment.barbell, compound: true, primaryMuscle: '背'),
  '10093': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '背'),

  // 手臂
  '10096': ExerciseMeta(equipment: Equipment.barbell, compound: false, primaryMuscle: '手臂'),
  '10097': ExerciseMeta(equipment: Equipment.dumbbell, compound: false, primaryMuscle: '手臂'),
  '10098': ExerciseMeta(equipment: Equipment.barbell, compound: false, primaryMuscle: '手臂'),
  '10103': ExerciseMeta(equipment: Equipment.barbell, compound: true, primaryMuscle: '手臂'),
  '10106': ExerciseMeta(equipment: Equipment.cable, compound: false, primaryMuscle: '手臂'),
  '10108': ExerciseMeta(equipment: Equipment.cable, compound: false, primaryMuscle: '手臂'),
  '10109': ExerciseMeta(equipment: Equipment.bodyweight, compound: true, primaryMuscle: '手臂'),

  // 腿
  '10115': ExerciseMeta(equipment: Equipment.barbell, compound: true, primaryMuscle: '腿'),
  '10116': ExerciseMeta(equipment: Equipment.barbell, compound: true, primaryMuscle: '腿'),
  '10117': ExerciseMeta(equipment: Equipment.kettlebell, compound: true, primaryMuscle: '腿'),
  '10118': ExerciseMeta(equipment: Equipment.dumbbell, compound: true, primaryMuscle: '腿'),
  '10119': ExerciseMeta(equipment: Equipment.dumbbell, compound: true, primaryMuscle: '腿'),
  '10120': ExerciseMeta(equipment: Equipment.machine, compound: true, primaryMuscle: '腿'),
  '10121': ExerciseMeta(equipment: Equipment.machine, compound: true, primaryMuscle: '腿'),
  '10124': ExerciseMeta(equipment: Equipment.barbell, compound: true, primaryMuscle: '腿'),
  '10126': ExerciseMeta(equipment: Equipment.machine, compound: false, primaryMuscle: '腿'),
  '10129': ExerciseMeta(equipment: Equipment.barbell, compound: true, primaryMuscle: '臀'),
  '10131': ExerciseMeta(equipment: Equipment.dumbbell, compound: true, primaryMuscle: '臀'),
  '10135': ExerciseMeta(equipment: Equipment.machine, compound: true, primaryMuscle: '臀'),
  '10139': ExerciseMeta(equipment: Equipment.machine, compound: false, primaryMuscle: '腿'),

  // 核心
  '10143': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '核心'),
  '10144': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '核心'),
  '10148': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '核心'),
  '10151': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '核心'),
  '10153': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '核心'),
  '10157': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '核心'),
};

/// 动作元数据入口。命中人工校正则直接返回，否则按名称与分类推断。
ExerciseMeta metaFor(Exercise exercise) {
  final override = _overrides[exercise.id];
  if (override != null) return override;
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
