import '../models/models.dart';

/// 力量训练 / 核心训练：腹直肌 (10143-10147) + 腹斜肌 (10148-10150) + 深层核心 (10151-10153) + 抗伸展 (10154-10156) + 后链核心 (10157)
const List<Exercise> kStrengthCoreExercises = [
  Exercise(id: '10143', name: '悬垂举腿', categoryPath: '力量训练 / 核心训练 / 腹直肌', description: '单杠悬挂，身体不要大幅度摆动，把双腿抬至与地面平行，重点刺激下腹。可以屈膝降低难度，直腿难度最高。下腹王牌动作。', tips: ['单杠悬挂身体稳定','双腿抬至与地面平行','重点刺激下腹','直腿难度最高'], sets: 3, reps: 12, restSeconds: '45', difficulty: '中级', imageSvg: '腹直肌', imageUrl: '', videoPath: '', weight: '0'),
  Exercise(id: '10144', name: '卷腹', categoryPath: '力量训练 / 核心训练 / 腹直肌', description: '仰卧，下背贴地，只把上背部卷起，不要抱头猛拽脖子；可以胸口压杠铃片负重，强化上腹。', tips: ['仰卧下背贴地','只卷起上背部','不要抱头猛拽脖子','可压杠铃片负重'], sets: 3, reps: 15, restSeconds: '30', difficulty: '初级', imageSvg: '腹直肌', imageUrl: '', videoPath: '', weight: '0'),
  Exercise(id: '10145', name: '仰卧反向卷腹', categoryPath: '力量训练 / 核心训练 / 腹直肌', description: '平躺，骨盆卷起把膝盖拉向胸口，专门针对下腹，腰压力比悬垂举腿更小。', tips: ['平躺骨盆卷起','膝盖拉向胸口','专门针对下腹','腰压力更小'], sets: 3, reps: 15, restSeconds: '30', difficulty: '初级', imageSvg: '腹直肌', imageUrl: '', videoPath: '', weight: '0'),
  Exercise(id: '10146', name: '龙旗', categoryPath: '力量训练 / 核心训练 / 腹直肌', description: '高难度，卧推凳边缘，身体伸直缓慢下放再拉起，上腹下腹整体轰炸，对核心要求极高。', tips: ['卧推凳边缘','身体伸直缓慢下放','上腹下腹整体轰炸','对核心要求极高'], sets: 3, reps: 8, restSeconds: '60', difficulty: '高级', imageSvg: '腹直肌', imageUrl: '', videoPath: '', weight: '0'),
  Exercise(id: '10147', name: '绳索卷腹', categoryPath: '力量训练 / 核心训练 / 腹直肌', description: '高位绳索，跪姿，手握绳索在头两侧，身体做卷腹向下收缩。负重可控，上腹肌肥大首选。', tips: ['高位绳索跪姿','手握绳索头两侧','身体做卷腹向下收缩','上腹肌肥大首选'], sets: 3, reps: 12, restSeconds: '45', difficulty: '中级', imageSvg: '腹直肌', imageUrl: '', videoPath: '', weight: '0'),

  Exercise(id: '10148', name: '俄罗斯转体', categoryPath: '力量训练 / 核心训练 / 腹斜肌', description: '身体后倾，双脚离地，手持哑铃/药球左右转体，刺激两侧腹斜肌。', tips: ['身体后倾双脚离地','手持哑铃药球','左右转体','刺激两侧腹斜肌'], sets: 3, reps: 15, restSeconds: '30', difficulty: '初级', imageSvg: '腹斜肌', imageUrl: '', videoPath: '', weight: '0'),
  Exercise(id: '10149', name: '单臂农夫行走', categoryPath: '力量训练 / 核心训练 / 腹斜肌', description: '单侧握大重量哑铃，身体对抗侧倾，抗侧屈，强化腹斜肌深层，功能性极强。', tips: ['单侧握大重量哑铃','身体对抗侧倾','抗侧屈','强化腹斜肌深层'], sets: 3, reps: 20, restSeconds: '45', difficulty: '中级', imageSvg: '腹斜肌', imageUrl: '', videoPath: '', weight: '0'),
  Exercise(id: '10150', name: '绳索伐木', categoryPath: '力量训练 / 核心训练 / 腹斜肌', description: '高位/低位绳索，双手抓把手，躯干旋转拉动把手，抗旋转训练，腹斜肌主力动作。', tips: ['高位或低位绳索','双手抓把手','躯干旋转拉动','抗旋转训练'], sets: 3, reps: 12, restSeconds: '45', difficulty: '中级', imageSvg: '腹斜肌', imageUrl: '', videoPath: '', weight: '0'),

  Exercise(id: '10151', name: '平板支撑', categoryPath: '力量训练 / 核心训练 / 深层核心', description: '肘撑身体成一条直线，不要塌腰翘臀；背上放杠铃片负重进阶，等长抗伸展。腹横肌天然腰带。', tips: ['肘撑身体成直线','不要塌腰翘臀','可背杠铃片负重','等长抗伸展'], sets: 3, reps: 30, restSeconds: '30', difficulty: '初级', imageSvg: '深层核心', imageUrl: '', videoPath: '', weight: '0'),
  Exercise(id: '10152', name: '侧平板支撑', categoryPath: '力量训练 / 核心训练 / 深层核心', description: '单侧手肘支撑，髋部抬起；髋部可以放置哑铃负重，抗侧屈，强化腹斜肌+腹横肌。', tips: ['单侧手肘支撑','髋部抬起','可放哑铃负重','抗侧屈'], sets: 3, reps: 20, restSeconds: '30', difficulty: '中级', imageSvg: '深层核心', imageUrl: '', videoPath: '', weight: '0'),
  Exercise(id: '10153', name: '死虫式', categoryPath: '力量训练 / 核心训练 / 深层核心', description: '仰卧，下背全程压紧地面，手脚交替伸展，控制腰椎不离开地面，激活腹横肌，适合恢复、改善腰代偿。', tips: ['仰卧下背压紧地面','手脚交替伸展','控制腰椎不离地','激活腹横肌'], sets: 3, reps: 10, restSeconds: '30', difficulty: '初级', imageSvg: '深层核心', imageUrl: '', videoPath: '', weight: '0'),

  Exercise(id: '10154', name: '悬垂平板L支撑', categoryPath: '力量训练 / 核心训练 / 抗伸展', description: '双杠上，身体保持平直，核心收紧，抵抗身体向下弯折。', tips: ['双杠上身体平直','核心收紧','抵抗身体向下弯折','高阶核心动作'], sets: 3, reps: 15, restSeconds: '45', difficulty: '高级', imageSvg: '抗伸展', imageUrl: '', videoPath: '', weight: '0'),
  Exercise(id: '10155', name: '药球抗伸展俯卧撑', categoryPath: '力量训练 / 核心训练 / 抗伸展', description: '双手分撑两个药球，做俯卧撑，保持躯干稳定，不让腰塌下去。', tips: ['双手分撑药球','做俯卧撑','保持躯干稳定','不让腰塌'], sets: 3, reps: 10, restSeconds: '45', difficulty: '高级', imageSvg: '抗伸展', imageUrl: '', videoPath: '', weight: '0'),
  Exercise(id: '10156', name: '北欧降（北欧离心卷腹）', categoryPath: '力量训练 / 核心训练 / 抗伸展', description: '膝盖跪在软垫，脚踝固定，身体缓慢向前向下倾倒，靠核心对抗身体往前折，高阶抗伸展，对核心要求很高。', tips: ['膝盖跪软垫','脚踝固定','缓慢向前倾倒','靠核心对抗前折'], sets: 3, reps: 6, restSeconds: '60', difficulty: '高级', imageSvg: '抗伸展', imageUrl: '', videoPath: '', weight: '0'),

  Exercise(id: '10157', name: '鸟狗式', categoryPath: '力量训练 / 核心训练 / 后链核心', description: '四点支撑，对侧手脚同时伸展，保持躯干不动，强化脊柱周围多裂肌，改善腰背代偿。', tips: ['四点支撑','对侧手脚同时伸展','保持躯干不动','强化多裂肌'], sets: 3, reps: 10, restSeconds: '30', difficulty: '初级', imageSvg: '后链核心', imageUrl: '', videoPath: '', weight: '0'),
];
