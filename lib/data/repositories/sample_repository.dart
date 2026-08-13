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
          subCategories: [],
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
    // 上胸
    Exercise(id: '1', name: '上斜杠铃卧推', categoryPath: '力量训练 / 上肢 / 胸部训练 / 上胸', description: '仰卧于上斜凳（30-45度），双手握杠略宽于肩，下放至胸上部，推起时呼气。', tips: ['杠铃下放至乳头连线上方', '肘部与身体呈45度角', '核心收紧避免弓腰'], sets: 4, reps: 8, restSeconds: '90', difficulty: '中级', imageSvg: 'chest_upper', videoPath: ''),
    Exercise(id: '2', name: '上斜哑铃卧推', categoryPath: '力量训练 / 上肢 / 胸部训练 / 上胸', description: '仰卧于上斜凳，双手持哑铃，从胸部两侧推至头顶，缓慢下放。', tips: ['哑铃不要碰撞', '下放时感受胸部拉伸', '核心收紧'], sets: 3, reps: 10, restSeconds: '60', difficulty: '初级', imageSvg: 'chest_upper', videoPath: ''),
    // 中胸
    Exercise(id: '3', name: '平板杠铃卧推', categoryPath: '力量训练 / 上肢 / 胸部训练 / 中胸', description: '仰卧平凳，双手握杠略宽于肩，下放至胸中部，推起时呼气。', tips: ['杠铃下放至胸中部', '肩胛骨收紧下沉', '脚踩实地面'], sets: 4, reps: 8, restSeconds: '90', difficulty: '中级', imageSvg: 'chest', videoPath: ''),
    Exercise(id: '4', name: '平板哑铃卧推', categoryPath: '力量训练 / 上肢 / 胸部训练 / 中胸', description: '仰卧平凳，双手持哑铃，从胸部两侧推至头顶，缓慢下放。', tips: ['哑铃不要碰撞', '下放时感受胸部拉伸', '核心收紧'], sets: 3, reps: 10, restSeconds: '60', difficulty: '初级', imageSvg: 'chest', videoPath: ''),
    Exercise(id: '5', name: '哑铃飞鸟', categoryPath: '力量训练 / 上肢 / 胸部训练 / 中胸', description: '仰卧平凳，双手持哑铃向上伸直，向两侧打开至胸部有拉伸感，然后还原。', tips: ['肘部微屈', '感受胸部拉伸', '不要下放太低'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: 'chest', videoPath: ''),
    // 下胸
    Exercise(id: '6', name: '双杠臂屈伸', categoryPath: '力量训练 / 上肢 / 胸部训练 / 下胸', description: '双手撑双杠，身体前倾，屈肘下放至肩部与手平齐，推起。', tips: ['身体前倾更刺激胸部', '下放深度适中', '核心收紧'], sets: 3, reps: 10, restSeconds: '60', difficulty: '中级', imageSvg: 'chest_lower', videoPath: ''),
    Exercise(id: '7', name: '俯卧撑', categoryPath: '力量训练 / 上肢 / 胸部训练 / 下胸', description: '双手撑地与肩同宽，身体保持直线，屈肘下放至胸部接近地面，推起。', tips: ['身体保持直线', '下放时吸气', '推起时呼气'], sets: 3, reps: 15, restSeconds: '45', difficulty: '初级', imageSvg: 'chest_lower', videoPath: ''),
    // 前束
    Exercise(id: '8', name: '哑铃前平举', categoryPath: '力量训练 / 上肢 / 肩部训练 / 前束', description: '站立，双手持哑铃于大腿前，向前举起至与肩同高，缓慢下放。', tips: ['不要耸肩', '举起时呼气', '控制下放速度'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: 'shoulder_front', videoPath: ''),
    // 中束
    Exercise(id: '9', name: '哑铃侧平举', categoryPath: '力量训练 / 上肢 / 肩部训练 / 中束', description: '站立，双手持哑铃于身体两侧，向两侧举起至与肩同高，缓慢下放。', tips: ['肘部微屈', '不要举过高', '感受肩部外侧发力'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: 'shoulder_mid', videoPath: ''),
    Exercise(id: '10', name: '绳索侧平举', categoryPath: '力量训练 / 上肢 / 肩部训练 / 中束', description: '站立于绳索机旁，单手握住低处把手，向侧方举起至与肩同高。', tips: ['身体微侧', '控制速度', '顶峰收缩'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: 'shoulder_mid', videoPath: ''),
    // 后束
    Exercise(id: '11', name: '俯身哑铃反向飞鸟', categoryPath: '力量训练 / 上肢 / 肩部训练 / 后束', description: '俯身，双手持哑铃，向两侧举起至与背部平行，缓慢下放。', tips: ['俯身角度约45度', '不要耸肩', '感受肩部后侧发力'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: 'shoulder_rear', videoPath: ''),
    Exercise(id: '12', name: '面拉', categoryPath: '力量训练 / 上肢 / 肩部训练 / 后束', description: '站立于绳索机前，双手握住把手，向面部方向拉，肘部高于手腕。', tips: ['绳索调至胸高', '拉至面部', '顶峰收缩1秒'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: 'shoulder_rear', videoPath: ''),
    // 背阔肌
    Exercise(id: '13', name: '引体向上', categoryPath: '力量训练 / 上肢 / 背部训练 / 背阔肌', description: '正手握杠略宽于肩，垂直悬吊，发力将身体向上拉至下巴过杠，缓慢下放。', tips: ['握距略宽于肩', '下放时控制速度', '核心收紧'], sets: 4, reps: 8, restSeconds: '90', difficulty: '中级', imageSvg: 'back_lats', videoPath: ''),
    Exercise(id: '14', name: '杠铃划船', categoryPath: '力量训练 / 上肢 / 背部训练 / 背阔肌', description: '俯身约45度，双手握杠铃，将杠铃拉向腹部，缓慢下放。', tips: ['俯身角度约45度', '杠铃拉向腹部', '肩胛骨收紧'], sets: 4, reps: 8, restSeconds: '90', difficulty: '中级', imageSvg: 'back_lats', videoPath: ''),
    Exercise(id: '15', name: '坐姿绳索划船', categoryPath: '力量训练 / 上肢 / 背部训练 / 背阔肌', description: '坐姿，双手握住绳索把手，向后拉至腹部，感受背部收缩。', tips: ['胸部挺起', '拉至腹部', '肩胛骨收紧'], sets: 3, reps: 12, restSeconds: '60', difficulty: '初级', imageSvg: 'back_lats', videoPath: ''),
    // 斜方肌
    Exercise(id: '16', name: '杠铃耸肩', categoryPath: '力量训练 / 上肢 / 背部训练 / 斜方肌', description: '双手握杠铃于大腿前，向上耸肩至最高点，缓慢下放。', tips: ['垂直上提不要旋转', '顶峰收缩1秒', '不要过于用力'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: 'back_traps', videoPath: ''),
    Exercise(id: '17', name: '哑铃耸肩', categoryPath: '力量训练 / 上肢 / 背部训练 / 斜方肌', description: '双手持哑铃于身体两侧，向上耸肩至最高点，缓慢下放。', tips: ['垂直上提', '顶峰收缩', '不要过度用力'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: 'back_traps', videoPath: ''),
    // 股四头肌
    Exercise(id: '18', name: '深蹲', categoryPath: '力量训练 / 下肢 / 股四头肌', description: '双脚与肩同宽，杠铃置于肩后，下蹲至大腿与地面平行，站起。', tips: ['膝盖与脚尖方向一致', '下蹲至大腿平行地面', '核心收紧'], sets: 4, reps: 8, restSeconds: '90', difficulty: '中级', imageSvg: 'leg_quads', videoPath: ''),
    Exercise(id: '19', name: '腿举', categoryPath: '力量训练 / 下肢 / 股四头肌', description: '坐于腿举机上，双脚与肩同宽踩在踏板上，向下弯曲膝盖至90度，推起。', tips: ['不要完全锁死膝盖', '控制下放速度', '背部贴紧靠背'], sets: 3, reps: 10, restSeconds: '60', difficulty: '初级', imageSvg: 'leg_quads', videoPath: ''),
    // 腘绳肌
    Exercise(id: '20', name: '罗马尼亚硬拉', categoryPath: '力量训练 / 下肢 / 腘绳肌', description: '双手持杠铃，膝关节微屈，将杠铃沿大腿下放至腘绳肌有拉伸感，然后站起。', tips: ['保持背部挺直', '感受腘绳肌拉伸', '不要过度下放'], sets: 4, reps: 8, restSeconds: '90', difficulty: '中级', imageSvg: 'leg_hamstrings', videoPath: ''),
    Exercise(id: '21', name: '腿弯举', categoryPath: '力量训练 / 下肢 / 腘绳肌', description: '俯卧于腿弯举机，将小腿向后弯曲至大腿后方，缓慢下放。', tips: ['动作缓慢控制', '不要完全伸直', '顶峰收缩1秒'], sets: 3, reps: 12, restSeconds: '60', difficulty: '初级', imageSvg: 'leg_hamstrings', videoPath: ''),
    // 臀部
    Exercise(id: '22', name: '臀桥', categoryPath: '力量训练 / 下肢 / 臀部训练', description: '仰卧，双脚踩地，臀部发力将髋部推起至身体成直线，顶峰收缩。', tips: ['顶峰时夹紧臀部', '不要过度拱腰', '感受臀部发力'], sets: 3, reps: 15, restSeconds: '60', difficulty: '初级', imageSvg: 'leg_glutes', videoPath: ''),
    Exercise(id: '23', name: '保加利亚分腿蹲', categoryPath: '力量训练 / 下肢 / 臀部训练', description: '后脚抬高置于凳上，前脚蹲下至大腿与地面平行，站起。', tips: ['重心在前脚', '下蹲时膝盖不要超过脚尖太多', '保持身体直立'], sets: 3, reps: 10, restSeconds: '60', difficulty: '中级', imageSvg: 'leg_glutes', videoPath: ''),
    // 腹直肌
    Exercise(id: '24', name: '卷腹', categoryPath: '力量训练 / 核心训练 / 腹直肌', description: '仰卧，屈膝，肩胛骨离地，卷起上半身，感受腹部收缩。', tips: ['不要抱头用力', '用腹部发力带动', '下背部贴地'], sets: 3, reps: 20, restSeconds: '45', difficulty: '初级', imageSvg: 'core_abs', videoPath: ''),
    Exercise(id: '25', name: '悬垂举腿', categoryPath: '力量训练 / 核心训练 / 腹直肌', description: '悬垂于单杠，双腿并拢举至与身体成90度，缓慢下放。', tips: ['不要借力摆动', '用腹部发力', '下放时控制速度'], sets: 3, reps: 10, restSeconds: '60', difficulty: '高级', imageSvg: 'core_abs', videoPath: ''),
    // 腹斜肌
    Exercise(id: '26', name: '俄罗斯转体', categoryPath: '力量训练 / 核心训练 / 腹斜肌', description: '坐姿屈膝，身体后倾，双手持重物左右转动躯干。', tips: ['重心在坐骨', '转动上半身', '不要只动手臂'], sets: 3, reps: 20, restSeconds: '45', difficulty: '初级', imageSvg: 'core_obliques', videoPath: ''),
    Exercise(id: '27', name: '平板支撑', categoryPath: '力量训练 / 核心训练 / 腹斜肌', description: '俯卧，前臂撑地，身体成直线，保持静止。', tips: ['身体保持直线', '不要塌腰', '均匀呼吸'], sets: 3, reps: 60, restSeconds: '45', difficulty: '初级', imageSvg: 'core_obliques', videoPath: ''),
    // 功能性训练
    Exercise(id: '28', name: '药球摔砸', categoryPath: '功能训练 / 核心稳定', description: '双手持药球举过头顶，用力向下摔砸，利用全身力量爆发。', tips: ['从髋部发力', '全程控制药球', '落地缓冲'], sets: 3, reps: 10, restSeconds: '60', difficulty: '中级', imageSvg: 'functional', videoPath: ''),
    Exercise(id: '29', name: '单腿硬拉', categoryPath: '功能训练 / 平衡训练', description: '单腿站立，身体前倾，另一条腿向后抬起，保持平衡。', tips: ['支撑腿微屈', '髋部向后推', '眼睛看前方'], sets: 3, reps: 10, restSeconds: '45', difficulty: '中级', imageSvg: 'functional', videoPath: ''),
    Exercise(id: '30', name: '波比跳', categoryPath: '功能训练 / 灵敏训练', description: '从站立开始，下蹲双手撑地，跳起成平板支撑，收腿跳起，向上跳。', tips: ['动作连贯流畅', '平板支撑时核心收紧', '跳起时呼气'], sets: 3, reps: 10, restSeconds: '60', difficulty: '高级', imageSvg: 'functional', videoPath: ''),
    // 瑜伽
    Exercise(id: '31', name: '山式站立', categoryPath: '瑜伽训练 / 哈他瑜伽', description: '双脚并拢站立，双手自然下垂，脊柱向上延伸，保持呼吸均匀。', tips: ['双脚均匀受力', '脊柱向上延伸', '深呼吸'], sets: 1, reps: 30, restSeconds: '10', difficulty: '初级', imageSvg: 'yoga_hatha', videoPath: ''),
    Exercise(id: '32', name: '树式', categoryPath: '瑜伽训练 / 哈他瑜伽', description: '单腿站立，另一只脚掌贴于支撑腿大腿内侧，双手合十或向上伸展。', tips: ['眼睛注视固定点', '髋部保持水平', '深呼吸'], sets: 1, reps: 30, restSeconds: '10', difficulty: '初级', imageSvg: 'yoga_hatha', videoPath: ''),
    Exercise(id: '33', name: '下犬式', categoryPath: '瑜伽训练 / 流瑜伽', description: '双手双膝撑地，臀部向上抬起，身体呈倒V形，手脚向后延伸。', tips: ['脊柱延伸', '脚跟尽量向下', '不要憋气'], sets: 1, reps: 45, restSeconds: '10', difficulty: '初级', imageSvg: 'yoga_vinyasa', videoPath: ''),
    Exercise(id: '34', name: '战士二式', categoryPath: '瑜伽训练 / 流瑜伽', description: '双脚分开约一条腿长，前腿弯曲，双臂向两侧伸展，眼睛看前方手指。', tips: ['前腿膝盖不要超过脚尖', '髋部打开', '深呼吸'], sets: 1, reps: 30, restSeconds: '10', difficulty: '初级', imageSvg: 'yoga_vinyasa', videoPath: ''),
    Exercise(id: '35', name: '眼镜蛇式', categoryPath: '瑜伽训练 / 阿斯汤加', description: '俯卧，双手置于胸腔两侧，吸气时用手臂力量抬起上半身，保持臀部贴地。', tips: ['不要过度后弯', '肩膀下沉', '保持呼吸'], sets: 1, reps: 30, restSeconds: '10', difficulty: '初级', imageSvg: 'yoga_ashtanga', videoPath: ''),
    Exercise(id: '36', name: '婴儿式', categoryPath: '瑜伽训练 / 恢复瑜伽', description: '跪姿，臀部坐向脚跟，身体前倾，额头触地，手臂向前或向后延伸。', tips: ['全身放松', '深呼吸', '保持姿势'], sets: 1, reps: 60, restSeconds: '10', difficulty: '初级', imageSvg: 'yoga_restorative', videoPath: ''),
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
        .where(
          (e) =>
              e.name.toLowerCase().contains(q) ||
              e.categoryPath.toLowerCase().contains(q) ||
              e.description.toLowerCase().contains(q),
        )
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
    final map = {
      // 父级部位
      'strength_upper': '上肢训练',
      'strength_lower': '下肢训练',
      'strength_core': '核心训练',
      'strength_chest': '胸部训练',
      'strength_shoulders': '肩部训练',
      'strength_back': '背部训练',
      'strength_arms': '手臂训练',
      // 肌肉细分
      'chest_upper': '上胸',
      'chest_middle': '中胸',
      'chest_lower': '下胸',
      'shoulder_front': '前束',
      'shoulder_mid': '中束',
      'shoulder_rear': '后束',
      'back_lats': '背阔肌',
      'back_traps': '斜方肌',
      'leg_quads': '股四头肌',
      'leg_hamstrings': '腘绳肌',
      'leg_glutes': '臀部',
      'core_abs': '腹直肌',
      'core_obliques': '腹斜肌',
      // 功能训练
      'func_core': '核心稳定',
      'func_balance': '平衡训练',
      'func_agility': '灵敏训练',
      // 瑜伽
      'yoga_hatha': '哈他瑜伽',
      'yoga_vinyasa': '流瑜伽',
      'yoga_ashtanga': '阿斯汤加',
      'yoga_restorative': '恢复瑜伽',
    };
    return map[categoryId] ?? categoryId;
  }
}
