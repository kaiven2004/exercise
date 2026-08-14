import '../models/models.dart';
import 'exercise_repository.dart';

class SampleExerciseRepository implements ExerciseRepository {
  static const List<TrainingCategory> _strengthCategories = [
    TrainingCategory(
      id: 'strength_upper',
      name: '上肢训练',
      section: WorkoutSection.strength,
      svgIcon: 'arm',
      subCategories: [
        TrainingCategory(
          id: 'strength_chest',
          name: '胸部训练',
          section: WorkoutSection.strength,
          svgIcon: 'chest',
          subCategories: [
            TrainingCategory(id: 'chest_upper', name: '上胸', section: WorkoutSection.strength, svgIcon: 'chest_upper'),
            TrainingCategory(id: 'chest_middle', name: '中胸', section: WorkoutSection.strength, svgIcon: 'chest'),
            TrainingCategory(id: 'chest_lower', name: '下胸', section: WorkoutSection.strength, svgIcon: 'chest_lower'),
          ],
        ),
        TrainingCategory(
          id: 'strength_shoulders',
          name: '肩部训练',
          section: WorkoutSection.strength,
          svgIcon: 'shoulder',
          subCategories: [
            TrainingCategory(id: 'shoulder_front', name: '前束', section: WorkoutSection.strength, svgIcon: 'shoulder_front'),
            TrainingCategory(id: 'shoulder_mid', name: '中束', section: WorkoutSection.strength, svgIcon: 'shoulder_mid'),
            TrainingCategory(id: 'shoulder_rear', name: '后束', section: WorkoutSection.strength, svgIcon: 'shoulder_rear'),
          ],
        ),
        TrainingCategory(
          id: 'strength_back',
          name: '背部训练',
          section: WorkoutSection.strength,
          svgIcon: 'back',
          subCategories: [
            TrainingCategory(id: 'back_lats', name: '背阔肌', section: WorkoutSection.strength, svgIcon: 'back_lats'),
            TrainingCategory(id: 'back_traps', name: '斜方肌', section: WorkoutSection.strength, svgIcon: 'back_traps'),
          ],
        ),
        TrainingCategory(
          id: 'strength_arms',
          name: '手臂训练',
          section: WorkoutSection.strength,
          svgIcon: 'arm',
          subCategories: [
            TrainingCategory(id: 'arms_biceps', name: '肱二头肌', section: WorkoutSection.strength, svgIcon: 'biceps'),
            TrainingCategory(id: 'arms_triceps', name: '肱三头肌', section: WorkoutSection.strength, svgIcon: 'triceps'),
          ],
        ),
      ],
    ),
    TrainingCategory(
      id: 'strength_lower',
      name: '下肢训练',
      section: WorkoutSection.strength,
      svgIcon: 'leg',
      subCategories: [
        TrainingCategory(id: 'leg_quads', name: '股四头肌', section: WorkoutSection.strength, svgIcon: 'leg_quads'),
        TrainingCategory(id: 'leg_hamstrings', name: '腘绳肌', section: WorkoutSection.strength, svgIcon: 'leg_hamstrings'),
        TrainingCategory(id: 'leg_glutes', name: '臀部训练', section: WorkoutSection.strength, svgIcon: 'leg_glutes'),
        TrainingCategory(id: 'leg_calves', name: '小腿训练', section: WorkoutSection.strength, svgIcon: 'leg'),
      ],
    ),
    TrainingCategory(
      id: 'strength_core',
      name: '核心训练',
      section: WorkoutSection.strength,
      svgIcon: 'core',
      subCategories: [
        TrainingCategory(id: 'core_abs', name: '腹直肌', section: WorkoutSection.strength, svgIcon: 'core_abs'),
        TrainingCategory(id: 'core_obliques', name: '腹斜肌', section: WorkoutSection.strength, svgIcon: 'core_obliques'),
      ],
    ),
  ];























  static const List<TrainingCategory> _functionalCategories = [
    TrainingCategory(id: 'func_core', name: '核心稳定', section: WorkoutSection.functional, svgIcon: 'core', subCategories: []),
    TrainingCategory(id: 'func_balance', name: '平衡训练', section: WorkoutSection.functional, svgIcon: 'functional', subCategories: []),
    TrainingCategory(id: 'func_agility', name: '灵敏训练', section: WorkoutSection.functional, svgIcon: 'functional', subCategories: []),
  ];

  static const List<TrainingCategory> _yogaCategories = [
    TrainingCategory(id: 'yoga_hatha', name: '哈他瑜伽', section: WorkoutSection.yoga, svgIcon: 'yoga_hatha', subCategories: []),
    TrainingCategory(id: 'yoga_vinyasa', name: '流瑜伽', section: WorkoutSection.yoga, svgIcon: 'yoga_vinyasa', subCategories: []),
    TrainingCategory(id: 'yoga_ashtanga', name: '阿斯汤加', section: WorkoutSection.yoga, svgIcon: 'yoga_ashtanga', subCategories: []),
    TrainingCategory(id: 'yoga_restorative', name: '恢复瑜伽', section: WorkoutSection.yoga, svgIcon: 'yoga_restorative', subCategories: []),
  ];


  static const List<Exercise> _exercises = [
    Exercise(id: '10001', name: '上斜杠铃卧推（30-35度）', categoryPath: '力量训练 / 胸部训练 / 上胸', description: '角度：凳30-35度，不要调太陡。要点：杠铃落在锁骨/上胸位置，而不是中下胸乳头；手肘45度外展，不要贴身体也不要大开90度；起杠垂直推向上胸正上方。特点：大重量复合，整体上胸厚度，力量基础，上胸第一代表性动作。', tips: ['凳调至30-35度','杠铃落在锁骨/上胸位置','手肘45度外展','垂直推向上胸正上方'], sets: 4, reps: 8, restSeconds: '60', difficulty: '中级', imageSvg: '上胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10002', name: '窄距上斜杠铃卧推', categoryPath: '力量训练 / 胸部训练 / 上胸', description: '握距略窄于常规卧推，依然30-35度凳。特点：缩短力臂，减少肩膀压力，增加上胸内侧刺激，适合大重量肩膀不舒服时备选。', tips: ['握距略窄于常规卧推','凳保持30-35度','减少肩膀压力','增加上胸内侧刺激'], sets: 3, reps: 10, restSeconds: '60', difficulty: '中级', imageSvg: '上胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10003', name: '上斜哑铃卧推（30-35度）', categoryPath: '力量训练 / 胸部训练 / 上胸', description: '要点：哑铃下放要低于肩，充分拉开上胸，底部感受上胸拉伸；顶峰不要完全锁死肘关节，保持肌肉张力。对比杠铃：左右独立，纠正力量不对称，上胸拉伸感强，是仅次于杠铃上斜的主力动作。', tips: ['凳调至30-35度','哑铃下放低于肩','底部充分拉伸上胸','顶峰不完全锁死肘关节'], sets: 4, reps: 10, restSeconds: '60', difficulty: '中级', imageSvg: '上胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10004', name: '高角度上斜哑铃卧推（45度）', categoryPath: '力量训练 / 胸部训练 / 上胸', description: '凳子调到45度，重量要降一档，前束参与会变多。用途：专门针对锁骨最上端的上胸，不适合大重量，适合中等重量增肌。', tips: ['凳调至45度','重量降一档','针对锁骨最上端上胸','中等重量增肌'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: '上胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10005', name: '上斜哑铃飞鸟（30度）', categoryPath: '力量训练 / 胸部训练 / 上胸', description: '手肘微弯固定角度，不要屈伸手臂；轨迹圆弧向斜上方合拢，不是正上方。重点：底部充分拉开上胸，顶峰轻碰哑铃即可，不要大力相撞。专门打磨上胸轮廓、外沿。', tips: ['凳调至30度','手肘微弯固定角度','轨迹圆弧向斜上方合拢','底部充分拉伸顶峰轻碰'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: '上胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10006', name: '地板上斜哑铃卧推', categoryPath: '力量训练 / 胸部训练 / 上胸', description: '没有上斜凳时，把上背部垫哑铃垫，制造轻微上斜角度。特点：限制下放幅度，保护肩，适合肩有旧伤。', tips: ['上背部垫哑铃垫制造上斜','限制下放幅度','保护肩膀','适合肩有旧伤人群'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: '上胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10007', name: '上斜哑铃旋转飞鸟', categoryPath: '力量训练 / 胸部训练 / 上胸', description: '下放掌心朝下，合拢时掌心相对，旋转可以强化上胸肌纤维收缩，高阶孤立变式。', tips: ['凳调至30度','下放时掌心朝下','合拢时掌心相对旋转','高阶孤立变式'], sets: 3, reps: 12, restSeconds: '45', difficulty: '高级', imageSvg: '上胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10008', name: '上斜角度俯卧撑', categoryPath: '力量训练 / 胸部训练 / 上胸', description: '垫高臀部/降低脚位，身体形成头高脚低，相当于上斜推。要点：手放在胸上部两侧，身体一条直线。适合热身、高次数充血，也可以负重背上杠铃片。', tips: ['垫高臀部降低脚位','手放胸上部两侧','身体保持一条直线','适合热身高次数充血'], sets: 3, reps: 15, restSeconds: '30', difficulty: '初级', imageSvg: '上胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10009', name: '壶铃上斜卧推', categoryPath: '力量训练 / 胸部训练 / 上胸', description: '上斜凳，双手壶铃，轨迹和哑铃一致；壶铃重心偏下，对肩关节更友好，适合肩膀容易弹响人群。', tips: ['凳调至30-35度','双手持壶铃','轨迹和哑铃卧推一致','壶铃对肩关节更友好'], sets: 3, reps: 12, restSeconds: '45', difficulty: '中级', imageSvg: '上胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10010', name: '上斜器械推胸', categoryPath: '力量训练 / 胸部训练 / 上胸', description: '机器本身轨道是向上斜，座椅高度调至把手对齐上胸锁骨位置。优点：不用平衡，可冲大重量，力竭时更安全，适合主力复合。', tips: ['座椅调至把手对齐上胸锁骨','机器轨道向上斜','可冲大重量','力竭时更安全'], sets: 4, reps: 10, restSeconds: '60', difficulty: '中级', imageSvg: '上胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10011', name: '坐姿下握式胸推器械', categoryPath: '力量训练 / 胸部训练 / 上胸', description: '把手位置调到偏下，推起轨迹向上，被动强化上胸；很多综合器械没有专门上斜凳，用这个替代。', tips: ['把手调至偏低位置','推起轨迹斜向上','替代上斜凳','被动强化上胸'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: '上胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10012', name: '哈克推胸', categoryPath: '力量训练 / 胸部训练 / 上胸', description: '身体背靠斜板，座椅调低，让把手落点对准上胸；推的轨迹斜向上。特点：超级稳定，可以上很大重量，几乎不用考虑平衡，适合上胸堆厚度。', tips: ['身体背靠斜板','座椅调低让把手对准上胸','推的轨迹斜向上','超级稳定可上很大重量'], sets: 4, reps: 10, restSeconds: '60', difficulty: '中级', imageSvg: '上胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10013', name: '蝴蝶机夹胸（高位把手）', categoryPath: '力量训练 / 胸部训练 / 上胸', description: '把手调到高位，略高于肩膀，坐姿身体微微后仰；夹的时候向斜下方合拢，目标上胸。注意：不要耸肩，肩膀沉住，顶峰收缩停留1-2秒，雕刻上胸中缝轮廓。', tips: ['把手调至高位略高于肩','坐姿身体微微后仰','夹时向斜下方合拢','顶峰收缩停留1-2秒'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: '上胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10014', name: '高位绳索夹胸', categoryPath: '力量训练 / 胸部训练 / 上胸', description: '两个滑轮调至最高位，站姿身体微微前倾，双手握D把手，从高处向斜下方做夹胸，终点双手在腹部前侧交汇。关键点：手肘保持微弯不变，全程不变角度；不是推，是夹。从上胸拉伸到收缩，全程持续张力，很多人上胸缺轮廓必做。', tips: ['滑轮调至最高位','站姿身体微微前倾','手肘微弯不变角度','不是推是夹全程持续张力'], sets: 3, reps: 15, restSeconds: '30', difficulty: '中级', imageSvg: '上胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10015', name: '低位绳索上斜推', categoryPath: '力量训练 / 胸部训练 / 上胸', description: '滑轮放最低，躺30度上斜凳，双手握住低位绳索把手，向上斜上方推，模拟哑铃上斜卧推。特点：下放时持续张力，底部不会卸力，和哑铃杠铃互补。', tips: ['滑轮放最低位','躺30度上斜凳','双手握低位绳索把手','向上斜上方推模拟哑铃上斜'], sets: 3, reps: 12, restSeconds: '45', difficulty: '中级', imageSvg: '上胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10016', name: '单臂高位绳索夹胸', categoryPath: '力量训练 / 胸部训练 / 上胸', description: '单侧训练，纠正左右上胸不对称，孤立感受单侧收缩，适合弱侧补强。', tips: ['单侧训练纠正左右不对称','滑轮调至最高位','身体微微前倾','适合弱侧补强'], sets: 3, reps: 12, restSeconds: '45', difficulty: '中级', imageSvg: '上胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10017', name: '上斜哑铃地板飞鸟', categoryPath: '力量训练 / 胸部训练 / 上胸', description: '躺在地板，背部垫薄垫制造微小上斜，做飞鸟；限制过度下放，保护肩，侧重顶峰收缩。', tips: ['背部垫薄垫制造微小上斜','限制过度下放保护肩','侧重顶峰收缩','飞鸟轨迹向斜上方'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: '上胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10018', name: '上斜卧推停顿版', categoryPath: '力量训练 / 胸部训练 / 上胸', description: '杠铃或哑铃上斜，下放到上胸位置停1-2秒再推起，消除惯性，强化离心，突破平台期。', tips: ['杠铃或哑铃上斜','下放到上胸位置停顿1-2秒','再推起消除惯性','强化离心阶段突破平台期'], sets: 4, reps: 8, restSeconds: '60', difficulty: '高级', imageSvg: '上胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10019', name: '上斜卧推离心慢放', categoryPath: '力量训练 / 胸部训练 / 上胸', description: '不增加重量，刻意拉长离心阶段，4秒下放，上胸肌纤维破坏更强，适合增肌周期。', tips: ['不增加重量','刻意拉长离心阶段','4秒缓慢下放','适合增肌周期'], sets: 3, reps: 10, restSeconds: '60', difficulty: '高级', imageSvg: '上胸', imageUrl: '', videoPath: '', weight: '0'),
    Exercise(id: '10020', name: '反向上斜俯卧撑', categoryPath: '力量训练 / 胸部训练 / 上胸', description: '脚放低臀部垫高头高于脚形成上斜推角度练上胸注意与脚抬高的下胸动作区分。', tips: ['脚放低臀部垫高','头高于脚形成上斜','练上胸不是下胸','注意与脚抬高的下胸动作区分'], sets: 3, reps: 12, restSeconds: '30', difficulty: '初级', imageSvg: '上胸', imageUrl: '', videoPath: '', weight: '0'),
  ];

  @override
  List<WorkoutSection> getSections() => WorkoutSection.values;

  @override
  List<TrainingCategory> getCategories(WorkoutSection section) {
    switch (section) {
      case WorkoutSection.strength:
        return _strengthCategories;
      case WorkoutSection.functional:
        return _functionalCategories;
      case WorkoutSection.yoga:
        return _yogaCategories;
    }
  }

  @override
  List<Exercise> getExercises(String categoryId) {
    if (categoryId == 'all') return List.from(_exercises);
    return _exercises
        .where((e) => e.categoryPath.contains(_getCategoryName(categoryId)))
        .toList();
  }

  @override
  List<Exercise> searchExercises(String query) {
    if (query.isEmpty) return _exercises;
    final q = query.toLowerCase();
    return _exercises
        .where((e) =>
            e.name.toLowerCase().contains(q) ||
            e.categoryPath.toLowerCase().contains(q) ||
            e.description.toLowerCase().contains(q))
        .toList();
  }

  @override
  Exercise? getExerciseById(String id) {
    try {
      return _exercises.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  String _getCategoryName(String categoryId) {
    final map = <String, String>{
      'strength_upper': '上肢训练', 'strength_lower': '下肢训练', 'strength_core': '核心训练',
      'strength_chest': '胸部训练', 'strength_shoulders': '肩部训练', 'strength_back': '背部训练', 'strength_arms': '手臂训练',
      'chest_upper': '上胸', 'chest_middle': '中胸', 'chest_lower': '下胸',
      'shoulder_front': '前束', 'shoulder_mid': '中束', 'shoulder_rear': '后束',
      'back_lats': '背阔肌', 'back_traps': '斜方肌',
      'arms_biceps': '肱二头肌', 'arms_triceps': '肱三头肌',
      'leg_quads': '股四头肌', 'leg_hamstrings': '腘绳肌', 'leg_glutes': '臀部', 'leg_calves': '小腿',
      'core_abs': '腹直肌', 'core_obliques': '腹斜肌',
      'func_core': '核心稳定', 'func_balance': '平衡训练', 'func_agility': '灵敏训练',
      'yoga_hatha': '哈他瑜伽', 'yoga_vinyasa': '流瑜伽', 'yoga_ashtanga': '阿斯汤加', 'yoga_restorative': '恢复瑜伽',
    };
    return map[categoryId] ?? categoryId;
  }
}
