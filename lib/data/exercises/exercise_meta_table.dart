// 动作元数据表：每条动作的器械、是否复合、主要肌群。
// 由动作数据整理而成；新增动作时在这里补一行，
// data_integrity_test 会检查覆盖率和一致性。

import 'exercise_meta_types.dart';

const Map<String, ExerciseMeta> kExerciseMetaTable = {
  // 力量训练 / 胸部训练 / 上胸
  '10001': ExerciseMeta(equipment: Equipment.barbell, compound: true, primaryMuscle: '胸'),
  '10002': ExerciseMeta(equipment: Equipment.machine, compound: true, primaryMuscle: '胸'),
  '10003': ExerciseMeta(equipment: Equipment.barbell, compound: true, primaryMuscle: '胸'),
  '10004': ExerciseMeta(equipment: Equipment.barbell, compound: true, primaryMuscle: '胸'),
  '10005': ExerciseMeta(equipment: Equipment.barbell, compound: true, primaryMuscle: '胸'),
  '10006': ExerciseMeta(equipment: Equipment.dumbbell, compound: true, primaryMuscle: '胸'),
  '10007': ExerciseMeta(equipment: Equipment.dumbbell, compound: false, primaryMuscle: '胸'),
  '10008': ExerciseMeta(equipment: Equipment.dumbbell, compound: true, primaryMuscle: '胸'),
  '10009': ExerciseMeta(equipment: Equipment.dumbbell, compound: true, primaryMuscle: '胸'),
  '10010': ExerciseMeta(equipment: Equipment.dumbbell, compound: true, primaryMuscle: '胸'),
  '10011': ExerciseMeta(equipment: Equipment.cable, compound: false, primaryMuscle: '胸'),
  '10012': ExerciseMeta(equipment: Equipment.cable, compound: true, primaryMuscle: '胸'),
  '10013': ExerciseMeta(equipment: Equipment.machine, compound: true, primaryMuscle: '胸'),
  '10014': ExerciseMeta(equipment: Equipment.machine, compound: false, primaryMuscle: '胸'),
  '10016': ExerciseMeta(equipment: Equipment.bodyweight, compound: true, primaryMuscle: '胸'),
  '10017': ExerciseMeta(equipment: Equipment.bodyweight, compound: true, primaryMuscle: '胸'),
  '10018': ExerciseMeta(equipment: Equipment.other, compound: true, primaryMuscle: '胸'),
  '10019': ExerciseMeta(equipment: Equipment.bodyweight, compound: true, primaryMuscle: '胸'),
  '10020': ExerciseMeta(equipment: Equipment.barbell, compound: true, primaryMuscle: '胸'),
  '10021': ExerciseMeta(equipment: Equipment.barbell, compound: true, primaryMuscle: '胸'),

  // 力量训练 / 胸部训练 / 中胸
  '10022': ExerciseMeta(equipment: Equipment.barbell, compound: true, primaryMuscle: '胸'),
  '10023': ExerciseMeta(equipment: Equipment.machine, compound: true, primaryMuscle: '胸'),
  '10024': ExerciseMeta(equipment: Equipment.barbell, compound: true, primaryMuscle: '胸'),
  '10025': ExerciseMeta(equipment: Equipment.barbell, compound: true, primaryMuscle: '胸'),
  '10026': ExerciseMeta(equipment: Equipment.barbell, compound: true, primaryMuscle: '胸'),
  '10027': ExerciseMeta(equipment: Equipment.dumbbell, compound: true, primaryMuscle: '胸'),
  '10028': ExerciseMeta(equipment: Equipment.dumbbell, compound: false, primaryMuscle: '胸'),
  '10029': ExerciseMeta(equipment: Equipment.dumbbell, compound: true, primaryMuscle: '胸'),
  '10030': ExerciseMeta(equipment: Equipment.dumbbell, compound: true, primaryMuscle: '胸'),
  '10031': ExerciseMeta(equipment: Equipment.dumbbell, compound: false, primaryMuscle: '胸'),
  '10032': ExerciseMeta(equipment: Equipment.machine, compound: false, primaryMuscle: '胸'),
  '10033': ExerciseMeta(equipment: Equipment.machine, compound: true, primaryMuscle: '胸'),
  '10034': ExerciseMeta(equipment: Equipment.cable, compound: false, primaryMuscle: '胸'),
  '10035': ExerciseMeta(equipment: Equipment.cable, compound: true, primaryMuscle: '胸'),
  '10036': ExerciseMeta(equipment: Equipment.cable, compound: true, primaryMuscle: '胸'),
  '10037': ExerciseMeta(equipment: Equipment.bodyweight, compound: true, primaryMuscle: '胸'),
  '10038': ExerciseMeta(equipment: Equipment.bodyweight, compound: true, primaryMuscle: '胸'),
  '10039': ExerciseMeta(equipment: Equipment.bodyweight, compound: true, primaryMuscle: '胸'),
  '10040': ExerciseMeta(equipment: Equipment.band, compound: false, primaryMuscle: '胸'),
  '10041': ExerciseMeta(equipment: Equipment.dumbbell, compound: false, primaryMuscle: '胸'),
  '10043': ExerciseMeta(equipment: Equipment.dumbbell, compound: true, primaryMuscle: '胸'),

  // 力量训练 / 胸部训练 / 下胸
  '10044': ExerciseMeta(equipment: Equipment.barbell, compound: true, primaryMuscle: '胸'),
  '10045': ExerciseMeta(equipment: Equipment.machine, compound: true, primaryMuscle: '胸'),
  '10046': ExerciseMeta(equipment: Equipment.barbell, compound: true, primaryMuscle: '胸'),
  '10047': ExerciseMeta(equipment: Equipment.barbell, compound: true, primaryMuscle: '胸'),
  '10048': ExerciseMeta(equipment: Equipment.barbell, compound: true, primaryMuscle: '胸'),
  '10049': ExerciseMeta(equipment: Equipment.dumbbell, compound: true, primaryMuscle: '胸'),
  '10050': ExerciseMeta(equipment: Equipment.dumbbell, compound: false, primaryMuscle: '胸'),
  '10051': ExerciseMeta(equipment: Equipment.dumbbell, compound: true, primaryMuscle: '胸'),
  '10052': ExerciseMeta(equipment: Equipment.dumbbell, compound: true, primaryMuscle: '胸'),
  '10211': ExerciseMeta(equipment: Equipment.dumbbell, compound: false, primaryMuscle: '胸'),
  '10212': ExerciseMeta(equipment: Equipment.cable, compound: false, primaryMuscle: '胸'),
  '10213': ExerciseMeta(equipment: Equipment.cable, compound: true, primaryMuscle: '胸'),
  '10214': ExerciseMeta(equipment: Equipment.machine, compound: true, primaryMuscle: '胸'),
  '10215': ExerciseMeta(equipment: Equipment.cable, compound: false, primaryMuscle: '胸'),
  '10216': ExerciseMeta(equipment: Equipment.machine, compound: false, primaryMuscle: '胸'),
  '10217': ExerciseMeta(equipment: Equipment.bodyweight, compound: true, primaryMuscle: '胸'),
  '10218': ExerciseMeta(equipment: Equipment.bodyweight, compound: true, primaryMuscle: '胸'),
  '10219': ExerciseMeta(equipment: Equipment.bodyweight, compound: true, primaryMuscle: '胸'),

  // 力量训练 / 肩部训练 / 前束
  '10053': ExerciseMeta(equipment: Equipment.barbell, compound: true, primaryMuscle: '肩'),
  '10054': ExerciseMeta(equipment: Equipment.dumbbell, compound: true, primaryMuscle: '肩'),
  '10055': ExerciseMeta(equipment: Equipment.barbell, compound: false, primaryMuscle: '肩'),
  '10056': ExerciseMeta(equipment: Equipment.dumbbell, compound: false, primaryMuscle: '肩'),
  '10057': ExerciseMeta(equipment: Equipment.machine, compound: true, primaryMuscle: '肩'),
  '10058': ExerciseMeta(equipment: Equipment.cable, compound: false, primaryMuscle: '肩'),

  // 力量训练 / 肩部训练 / 中束
  '10059': ExerciseMeta(equipment: Equipment.dumbbell, compound: false, primaryMuscle: '肩'),
  '10060': ExerciseMeta(equipment: Equipment.dumbbell, compound: false, primaryMuscle: '肩'),
  '10061': ExerciseMeta(equipment: Equipment.dumbbell, compound: true, primaryMuscle: '肩'),
  '10062': ExerciseMeta(equipment: Equipment.cable, compound: false, primaryMuscle: '肩'),
  '10063': ExerciseMeta(equipment: Equipment.machine, compound: false, primaryMuscle: '肩'),
  '10064': ExerciseMeta(equipment: Equipment.cable, compound: false, primaryMuscle: '肩'),

  // 力量训练 / 肩部训练 / 后束
  '10065': ExerciseMeta(equipment: Equipment.dumbbell, compound: false, primaryMuscle: '肩'),
  '10066': ExerciseMeta(equipment: Equipment.dumbbell, compound: false, primaryMuscle: '肩'),
  '10067': ExerciseMeta(equipment: Equipment.dumbbell, compound: false, primaryMuscle: '肩'),
  '10068': ExerciseMeta(equipment: Equipment.cable, compound: false, primaryMuscle: '肩'),
  '10069': ExerciseMeta(equipment: Equipment.machine, compound: false, primaryMuscle: '肩'),
  '10070': ExerciseMeta(equipment: Equipment.cable, compound: false, primaryMuscle: '肩'),

  // 力量训练 / 肩部训练 / 肩袖肌群
  '10071': ExerciseMeta(equipment: Equipment.cable, compound: false, primaryMuscle: '肩'),
  '10072': ExerciseMeta(equipment: Equipment.cable, compound: false, primaryMuscle: '肩'),
  '10073': ExerciseMeta(equipment: Equipment.dumbbell, compound: false, primaryMuscle: '肩'),

  // 力量训练 / 背部训练 / 背阔肌
  '10074': ExerciseMeta(equipment: Equipment.bodyweight, compound: true, primaryMuscle: '背'),
  '10075': ExerciseMeta(equipment: Equipment.bodyweight, compound: true, primaryMuscle: '背'),
  '10076': ExerciseMeta(equipment: Equipment.bodyweight, compound: true, primaryMuscle: '背'),
  '10077': ExerciseMeta(equipment: Equipment.cable, compound: true, primaryMuscle: '背'),
  '10078': ExerciseMeta(equipment: Equipment.cable, compound: true, primaryMuscle: '背'),
  '10079': ExerciseMeta(equipment: Equipment.cable, compound: false, primaryMuscle: '背'),
  '10080': ExerciseMeta(equipment: Equipment.cable, compound: true, primaryMuscle: '背'),

  // 力量训练 / 背部训练 / 上背厚度
  '10081': ExerciseMeta(equipment: Equipment.barbell, compound: true, primaryMuscle: '背'),
  '10082': ExerciseMeta(equipment: Equipment.dumbbell, compound: true, primaryMuscle: '背'),
  '10083': ExerciseMeta(equipment: Equipment.barbell, compound: true, primaryMuscle: '背'),
  '10084': ExerciseMeta(equipment: Equipment.dumbbell, compound: true, primaryMuscle: '背'),
  '10085': ExerciseMeta(equipment: Equipment.cable, compound: true, primaryMuscle: '背'),
  '10086': ExerciseMeta(equipment: Equipment.machine, compound: true, primaryMuscle: '背'),
  '10087': ExerciseMeta(equipment: Equipment.cable, compound: true, primaryMuscle: '背'),
  '10088': ExerciseMeta(equipment: Equipment.machine, compound: true, primaryMuscle: '背'),
  '10089': ExerciseMeta(equipment: Equipment.machine, compound: true, primaryMuscle: '背'),

  // 力量训练 / 背部训练 / 斜方下束
  '10090': ExerciseMeta(equipment: Equipment.dumbbell, compound: false, primaryMuscle: '背'),
  '10091': ExerciseMeta(equipment: Equipment.cable, compound: true, primaryMuscle: '背'),

  // 力量训练 / 背部训练 / 下背/竖脊肌
  '10092': ExerciseMeta(equipment: Equipment.barbell, compound: true, primaryMuscle: '背'),
  '10093': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '背'),
  '10094': ExerciseMeta(equipment: Equipment.barbell, compound: true, primaryMuscle: '背'),
  '10095': ExerciseMeta(equipment: Equipment.machine, compound: false, primaryMuscle: '背'),

  // 力量训练 / 手臂训练 / 肱二头肌
  '10096': ExerciseMeta(equipment: Equipment.barbell, compound: false, primaryMuscle: '手臂'),
  '10097': ExerciseMeta(equipment: Equipment.dumbbell, compound: false, primaryMuscle: '手臂'),
  '10098': ExerciseMeta(equipment: Equipment.barbell, compound: false, primaryMuscle: '手臂'),
  '10099': ExerciseMeta(equipment: Equipment.dumbbell, compound: false, primaryMuscle: '手臂'),
  '10100': ExerciseMeta(equipment: Equipment.cable, compound: false, primaryMuscle: '手臂'),
  '10101': ExerciseMeta(equipment: Equipment.cable, compound: false, primaryMuscle: '手臂'),
  '10102': ExerciseMeta(equipment: Equipment.machine, compound: false, primaryMuscle: '手臂'),

  // 力量训练 / 手臂训练 / 肱三头肌
  '10103': ExerciseMeta(equipment: Equipment.barbell, compound: true, primaryMuscle: '手臂'),
  '10104': ExerciseMeta(equipment: Equipment.dumbbell, compound: false, primaryMuscle: '手臂'),
  '10105': ExerciseMeta(equipment: Equipment.dumbbell, compound: false, primaryMuscle: '手臂'),
  '10106': ExerciseMeta(equipment: Equipment.cable, compound: false, primaryMuscle: '手臂'),
  '10107': ExerciseMeta(equipment: Equipment.cable, compound: false, primaryMuscle: '手臂'),
  '10108': ExerciseMeta(equipment: Equipment.cable, compound: false, primaryMuscle: '手臂'),
  '10109': ExerciseMeta(equipment: Equipment.bodyweight, compound: true, primaryMuscle: '手臂'),
  '10110': ExerciseMeta(equipment: Equipment.machine, compound: false, primaryMuscle: '手臂'),

  // 力量训练 / 手臂训练 / 前臂
  '10111': ExerciseMeta(equipment: Equipment.barbell, compound: false, primaryMuscle: '手臂'),
  '10112': ExerciseMeta(equipment: Equipment.barbell, compound: false, primaryMuscle: '手臂'),
  '10113': ExerciseMeta(equipment: Equipment.dumbbell, compound: true, primaryMuscle: '手臂'),
  '10114': ExerciseMeta(equipment: Equipment.dumbbell, compound: false, primaryMuscle: '手臂'),

  // 力量训练 / 下肢训练 / 股四头肌
  '10115': ExerciseMeta(equipment: Equipment.barbell, compound: true, primaryMuscle: '腿'),
  '10116': ExerciseMeta(equipment: Equipment.barbell, compound: true, primaryMuscle: '腿'),
  '10117': ExerciseMeta(equipment: Equipment.kettlebell, compound: true, primaryMuscle: '腿'),
  '10118': ExerciseMeta(equipment: Equipment.dumbbell, compound: true, primaryMuscle: '腿'),
  '10119': ExerciseMeta(equipment: Equipment.dumbbell, compound: true, primaryMuscle: '腿'),
  '10120': ExerciseMeta(equipment: Equipment.machine, compound: true, primaryMuscle: '腿'),
  '10121': ExerciseMeta(equipment: Equipment.machine, compound: true, primaryMuscle: '腿'),
  '10122': ExerciseMeta(equipment: Equipment.machine, compound: true, primaryMuscle: '腿'),
  '10123': ExerciseMeta(equipment: Equipment.machine, compound: false, primaryMuscle: '腿'),

  // 力量训练 / 下肢训练 / 腘绳肌
  '10124': ExerciseMeta(equipment: Equipment.barbell, compound: true, primaryMuscle: '腿'),
  '10125': ExerciseMeta(equipment: Equipment.barbell, compound: true, primaryMuscle: '腿'),
  '10126': ExerciseMeta(equipment: Equipment.machine, compound: false, primaryMuscle: '腿'),
  '10127': ExerciseMeta(equipment: Equipment.machine, compound: false, primaryMuscle: '腿'),

  // 力量训练 / 下肢训练 / 臀部训练
  '10129': ExerciseMeta(equipment: Equipment.barbell, compound: true, primaryMuscle: '臀'),
  '10130': ExerciseMeta(equipment: Equipment.dumbbell, compound: false, primaryMuscle: '臀'),
  '10131': ExerciseMeta(equipment: Equipment.dumbbell, compound: true, primaryMuscle: '臀'),
  '10132': ExerciseMeta(equipment: Equipment.machine, compound: true, primaryMuscle: '臀'),
  '10133': ExerciseMeta(equipment: Equipment.machine, compound: true, primaryMuscle: '臀'),
  '10134': ExerciseMeta(equipment: Equipment.machine, compound: true, primaryMuscle: '臀'),
  '10135': ExerciseMeta(equipment: Equipment.machine, compound: true, primaryMuscle: '臀'),
  '10136': ExerciseMeta(equipment: Equipment.cable, compound: false, primaryMuscle: '臀'),

  // 力量训练 / 下肢训练 / 内收肌群
  '10137': ExerciseMeta(equipment: Equipment.machine, compound: false, primaryMuscle: '腿'),

  // 力量训练 / 下肢训练 / 小腿训练
  '10138': ExerciseMeta(equipment: Equipment.dumbbell, compound: false, primaryMuscle: '腿'),
  '10139': ExerciseMeta(equipment: Equipment.machine, compound: false, primaryMuscle: '腿'),
  '10140': ExerciseMeta(equipment: Equipment.machine, compound: false, primaryMuscle: '腿'),
  '10141': ExerciseMeta(equipment: Equipment.machine, compound: false, primaryMuscle: '腿'),

  // 力量训练 / 核心训练 / 腹直肌
  '10143': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '核心'),
  '10144': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '核心'),
  '10145': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '核心'),
  '10146': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '核心'),
  '10147': ExerciseMeta(equipment: Equipment.cable, compound: false, primaryMuscle: '核心'),

  // 力量训练 / 核心训练 / 腹斜肌
  '10148': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '核心'),
  '10149': ExerciseMeta(equipment: Equipment.dumbbell, compound: true, primaryMuscle: '核心'),
  '10150': ExerciseMeta(equipment: Equipment.cable, compound: false, primaryMuscle: '核心'),

  // 力量训练 / 核心训练 / 深层核心
  '10151': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '核心'),
  '10152': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '核心'),
  '10153': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '核心'),

  // 力量训练 / 核心训练 / 抗伸展
  '10154': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '核心'),
  '10155': ExerciseMeta(equipment: Equipment.other, compound: true, primaryMuscle: '核心'),
  '10156': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '核心'),

  // 力量训练 / 核心训练 / 深层核心
  '10157': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '核心'),

  // 功能训练 / 单侧力量
  '10158': ExerciseMeta(equipment: Equipment.bodyweight, compound: true, primaryMuscle: '全身'),
  '10159': ExerciseMeta(equipment: Equipment.bodyweight, compound: true, primaryMuscle: '全身'),
  '10160': ExerciseMeta(equipment: Equipment.kettlebell, compound: true, primaryMuscle: '全身'),
  '10161': ExerciseMeta(equipment: Equipment.bodyweight, compound: true, primaryMuscle: '全身'),
  '10162': ExerciseMeta(equipment: Equipment.dumbbell, compound: true, primaryMuscle: '全身'),
  '10163': ExerciseMeta(equipment: Equipment.dumbbell, compound: true, primaryMuscle: '全身'),

  // 功能训练 / 髋功能
  '10164': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '全身'),
  '10165': ExerciseMeta(equipment: Equipment.band, compound: false, primaryMuscle: '全身'),
  '10166': ExerciseMeta(equipment: Equipment.bodyweight, compound: true, primaryMuscle: '全身'),
  '10167': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '全身'),
  '10168': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '全身'),
  '10169': ExerciseMeta(equipment: Equipment.band, compound: false, primaryMuscle: '全身'),

  // 功能训练 / 胸椎肩胛
  '10170': ExerciseMeta(equipment: Equipment.band, compound: false, primaryMuscle: '全身'),
  '10171': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '全身'),
  '10172': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '全身'),
  '10173': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '全身'),
  '10174': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '全身'),
  '10175': ExerciseMeta(equipment: Equipment.other, compound: false, primaryMuscle: '全身'),

  // 功能训练 / 悬吊抓握
  '10176': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '全身'),
  '10177': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '全身'),
  '10178': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '全身'),
  '10179': ExerciseMeta(equipment: Equipment.machine, compound: false, primaryMuscle: '全身'),
  '10180': ExerciseMeta(equipment: Equipment.other, compound: false, primaryMuscle: '全身'),

  // 功能训练 / 动物流
  '10181': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '全身'),
  '10182': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '全身'),
  '10183': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '全身'),
  '10184': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '全身'),

  // 功能训练 / 代谢力量
  '10185': ExerciseMeta(equipment: Equipment.other, compound: false, primaryMuscle: '全身'),
  '10186': ExerciseMeta(equipment: Equipment.other, compound: false, primaryMuscle: '全身'),
  '10187': ExerciseMeta(equipment: Equipment.other, compound: false, primaryMuscle: '全身'),
  '10188': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '全身'),

  // 功能训练 / 呼吸训练
  '10189': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '全身'),
  '10190': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '全身'),

  // 瑜伽训练 / 力量瑜伽
  '10191': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '全身'),
  '10192': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '全身'),
  '10193': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '全身'),
  '10194': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '全身'),
  '10195': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '全身'),

  // 瑜伽训练 / 流瑜伽
  '10196': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '全身'),
  '10197': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '全身'),
  '10198': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '全身'),
  '10199': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '全身'),
  '10200': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '全身'),
  '10201': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '全身'),

  // 瑜伽训练 / 哈他瑜伽
  '10202': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '全身'),
  '10203': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '全身'),
  '10204': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '全身'),
  '10205': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '全身'),

  // 瑜伽训练 / 阴瑜伽
  '10206': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '全身'),
  '10207': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '全身'),
  '10208': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '全身'),
  '10209': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '全身'),
  '10210': ExerciseMeta(equipment: Equipment.bodyweight, compound: false, primaryMuscle: '全身'),
};
