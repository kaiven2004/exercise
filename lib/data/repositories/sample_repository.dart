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
    Exercise(id: '1', name: '上斜杠铃卧推', categoryPath: '力量训练 / 上肢 / 胸部训练 / 上胸', description: '仰卧于上斜凳（30-45度），双手握杠略宽于肩，下放至胸上沿，推起时呼气。', tips: ['肩胛骨收紧贴凳', '杠铃下放至乳头上缘', '核心收紧，不要拱腰'], sets: 4, reps: 8, restSeconds: '90', difficulty: '中级', imageSvg: 'chest_upper', videoPath: ''),
    Exercise(id: '2', name: '上斜哑铃卧推', categoryPath: '力量训练 / 上肢 / 胸部训练 / 上胸', description: '仰卧上斜凳，双手持哑铃，从肩部两侧推起至头顶上方，缓慢下放。', tips: ['哑铃不要碰撞', '控制下落速度', '顶峰收缩1秒'], sets: 3, reps: 10, restSeconds: '60', difficulty: '初级', imageSvg: 'chest_upper', videoPath: ''),
    // 中胸
    Exercise(id: '3', name: '平板杠铃卧推', categoryPath: '力量训练 / 上肢 / 胸部训练 / 中胸', description: '仰卧于平凳，双脚踩实地面，双手握杠略宽于肩，下放至胸中部，推起。', tips: ['肩胛骨收紧', '杠铃触胸后快速推起', '不要完全锁死肘关节'], sets: 4, reps: 8, restSeconds: '90', difficulty: '中级', imageSvg: 'chest', videoPath: ''),
    Exercise(id: '4', name: '平板哑铃卧推', categoryPath: '力量训练 / 上肢 / 胸部训练 / 中胸', description: '仰卧平凳，双手持哑铃，从胸部两侧推起至头顶，缓慢下放。', tips: ['哑铃不要碰撞', '下放时感受胸部拉伸', '核心收紧'], sets: 3, reps: 10, restSeconds: '60', difficulty: '初级', imageSvg: 'chest', videoPath: ''),
    Exercise(id: '5', name: '哑铃飞鸟', categoryPath: '力量训练 / 上肢 / 胸部训练 / 中胸', description: '仰卧平凳，双手持哑铃向上伸直，向两侧打开至胸部有拉伸感，然后还原。', tips: ['肘部微屈', '感受胸部拉伸', '不要下放太低'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: 'chest', videoPath: ''),
    // 下胸
    Exercise(id: '6', name: '双杠臂屈伸', categoryPath: '力量训练 / 上肢 / 胸部训练 / 下胸', description: '双手撑双杠，身体前倾，屈肘下放至肩部与手平，然后推起。', tips: ['身体前倾主要练胸', '下放至肩部与手平', '不要完全锁死肘'], sets: 3, reps: 10, restSeconds: '60', difficulty: '中级', imageSvg: 'chest_lower', videoPath: ''),
    Exercise(id: '7', name: '下斜卧推', categoryPath: '力量训练 / 上肢 / 胸部训练 / 下胸', description: '仰卧于下斜凳，双手握杠，从胸部下方推起至手臂伸直。', tips: ['下斜角度不要太大', '控制节奏', '感受下胸发力'], sets: 3, reps: 10, restSeconds: '60', difficulty: '中级', imageSvg: 'chest_lower', videoPath: ''),
    Exercise(id: '8', name: '绳索夹胸', categoryPath: '力量训练 / 上肢 / 胸部训练 / 下胸', description: '站立于飞鸟机中间，双手持把手，从高处向中间夹胸。', tips: ['手肘微屈', '顶峰收缩1秒', '不要借力摆动'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: 'chest_lower', videoPath: ''),
    // 前束
    Exercise(id: '9', name: '杠铃直立划船', categoryPath: '力量训练 / 上肢 / 肩部训练 / 前束', description: '双手握杠，从体前向上提拉至胸部高度，肘部高于手腕。', tips: ['肘部始终高于手腕', '不要提拉过高', '核心收紧'], sets: 3, reps: 10, restSeconds: '60', difficulty: '中级', imageSvg: 'shoulder_front', videoPath: ''),
    Exercise(id: '10', name: '杠铃前平举', categoryPath: '力量训练 / 上肢 / 肩部训练 / 前束', description: '双手持杠铃于体前，向前平举至与肩同高，缓慢下放。', tips: ['不要借力摆动', '顶峰收缩', '控制下放速度'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: 'shoulder_front', videoPath: ''),
    // 中束
    Exercise(id: '11', name: '哑铃侧平举', categoryPath: '力量训练 / 上肢 / 肩部训练 / 中束', description: '双手持哑铃于体侧，向两侧举起至与肩同高，缓慢下放。', tips: ['手肘微屈', '不要借力', '顶峰停顿1秒'], sets: 4, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: 'shoulder_mid', videoPath: ''),
    Exercise(id: '12', name: '绳索侧平举', categoryPath: '力量训练 / 上肢 / 肩部训练 / 中束', description: '站立于飞鸟机一侧，手持把手向侧方举起至与肩同高。', tips: ['身体微侧', '控制节奏', '不要借力'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: 'shoulder_mid', videoPath: ''),
    // 后束
    Exercise(id: '13', name: '俯身哑铃飞鸟', categoryPath: '力量训练 / 上肢 / 肩部训练 / 后束', description: '俯身，双手持哑铃，向两侧举起至与肩同高，感受后束收缩。', tips: ['俯身约45度', '手肘微屈', '不要借力'], sets: 3, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: 'shoulder_rear', videoPath: ''),
    // 背阔肌
    Exercise(id: '14', name: '引体向上', categoryPath: '力量训练 / 上肢 / 背部训练 / 背阔肌', description: '正手抓杠，身体悬垂，拉至下巴超过杠，缓慢下放。', tips: ['全程控制', '不要借力摆动', '下放时感受背部拉伸'], sets: 4, reps: 6, restSeconds: '120', difficulty: '高级', imageSvg: 'back_lats', videoPath: ''),
    Exercise(id: '15', name: '杠铃划船', categoryPath: '力量训练 / 上肢 / 背部训练 / 背阔肌', description: '俯身约45度，双手握杠，将杠铃拉向腹部，缓慢下放。', tips: ['保持背部平直', '肘部贴近身体', '拉至腹部位置'], sets: 4, reps: 8, restSeconds: '90', difficulty: '中级', imageSvg: 'back_lats', videoPath: ''),
    Exercise(id: '16', name: '高位下拉', categoryPath: '力量训练 / 上肢 / 背部训练 / 背阔肌', description: '坐姿，双手宽握把手，向下拉至胸前，感受背部收缩。', tips: ['不要借力后仰', '拉至胸前', '顶峰收缩'], sets: 3, reps: 10, restSeconds: '60', difficulty: '初级', imageSvg: 'back_lats', videoPath: ''),
    // 斜方肌
    Exercise(id: '17', name: '杠铃耸肩', categoryPath: '力量训练 / 上肢 / 背部训练 / 斜方肌', description: '双手持杠铃于体前，向上耸肩至最高点，稍停后缓慢下放。', tips: ['只有肩胛骨运动', '不要旋转肩膀', '顶峰收缩2秒'], sets: 4, reps: 12, restSeconds: '45', difficulty: '初级', imageSvg: 'back_traps', videoPath: ''),
    Exercise(id: '18', name: '哑铃单臂划船', categoryPath: '力量训练 / 上肢 / 背部训练 / 斜方肌', description: '单手撑凳，另一手持哑铃划船至腰部，感受背部收缩。', tips: ['背部保持平直', '肘部贴近身体', '不要借力'], sets: 3, reps: 10, restSeconds: '60', difficulty: '初级', imageSvg: 'back_traps', videoPath: ''),
    // 股四头肌
    Exercise(id: '19', name: '杠铃深蹲', categoryPath: '力量训练 / 下肢 / 股四头肌', description: '杠铃置于肩后，双脚与肩同宽，下蹲至大腿与地面平行，站起。', tips: ['膝盖不要内扣', '下蹲至大腿平行', '核心收紧'], sets: 4, reps: 8, restSeconds: '120', difficulty: '高级', imageSvg: 'leg_quads', videoPath: ''),
    Exercise(id: '20', name: '杠铃腿弯举', categoryPath: '力量训练 / 下肢 / 股四头肌', description: '俯卧于腿弯举机，将小腿向后弯举至大腿后方，缓慢下放。', tips: ['动作缓慢控制', '不要完全伸直', '顶峰收缩1秒'], sets: 3, reps: 12, restSeconds: '60', difficulty: '初级', imageSvg: 'leg_quads', videoPath: ''),
    // 腘绳肌
    Exercise(id: '21', name: '罗马尼亚硬拉', categoryPath: '力量训练 / 下肢 / 腘绳肌', description: '双手持杠铃，微屈膝，向前送髋至大腿后侧有拉伸感，然后还原。', tips: ['背部保持平直', '杠铃贴近腿部', '感受大腿后侧拉伸'], sets: 4, reps: 8, restSeconds: '90', difficulty: '中级', imageSvg: 'leg_hamstrings', videoPath: ''),
    Exercise(id: '22', name: '腿弯举', categoryPath: '力量训练 / 下肢 / 腘绳肌', description: '俯卧于腿弯举机，将小腿向后弯举至大腿后方，缓慢下放。', tips: ['动作缓慢控制', '不要完全伸直', '顶峰收缩1秒'], sets: 3, reps: 12, restSeconds: '60', difficulty: '初级', imageSvg: 'leg_hamstrings', videoPath: ''),
    // 臀部
    Exercise(id: '23', name: '臀桥', categoryPath: '力量训练 / 下肢 / 臀部训练', description: '仰卧，双脚踩地，臀部发力将髋部推起至身体成直线，顶峰收缩。', tips: ['顶峰时夹紧臀部', '不要过度拱腰', '感受臀部发力'], sets: 3, reps: 15, restSeconds: '60', difficulty: '初级', imageSvg: 'leg_glutes', videoPath: ''),
    Exercise(id: '24', name: '保加利亚分腿蹲', categoryPath: '力量训练 / 下肢 / 臀部训练', description: '后脚抬高置于凳上，前脚蹲下至大腿与地面平行，站起。', tips: ['重心在前脚', '下蹲时膝盖不要超过脚尖太多', '保持身体直立'], sets: 3, reps: 10, restSeconds: '60', difficulty: '中级', imageSvg: 'leg_glutes', videoPath: ''),
    // 腹直肌
    Exercise(id: '25', name: '卷腹', categoryPath: '力量训练 / 核心训练 / 腹直肌', description: '仰卧，屈膝，肩胛骨离地，卷起上半身，感受腹部收缩。', tips: ['不要抱头用力', '用腹部发力带动', '下背部贴地'], sets: 3, reps: 20, restSeconds: '45', difficulty: '初级', imageSvg: 'core_abs', videoPath: ''),
    Exercise(id: '26', name: '悬垂举腿', categoryPath: '力量训练 / 核心训练 / 腹直肌', description: '悬垂于单杠，双腿并拢举至与身体成90度，缓慢下放。', tips: ['不要借力摆动', '用腹部发力', '下放时控制速度'], sets: 3, reps: 10, restSeconds: '60', difficulty: '高级', imageSvg: 'core_abs', videoPath: ''),
    // 腹斜肌
    Exercise(id: '27', name: '俄罗斯转体', categoryPath: '力量训练 / 核心训练 / 腹斜肌', description: '坐姿屈膝，身体后倾，双手持重物左右转动躯干。', tips: ['重心在坐骨', '转动上半身', '不要只动手臂'], sets: 3, reps: 20, restSeconds: '45', difficulty: '初级', imageSvg: 'core_obliques', videoPath: ''),
    Exercise(id: '28', name: '平板支撑', categoryPath: '力量训练 / 核心训练 / 腹斜肌', description: '俯卧，前臂撑地，身体成直线，保持静止。', tips: ['身体保持直线', '不要塌腰', '均匀呼吸'], sets: 3, reps: 60, restSeconds: '45', difficulty: '初级', imageSvg: 'core_obliques', videoPath: ''),
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
    return _exercises
        .where((e) => e.categoryPath.contains(_getCategoryName(categoryId)))
        .toList();
  }

  @override
  List<Exercise> searchExercises(String query) {
    if (query.isEmpty) return [];
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
    };
    return map[categoryId] ?? categoryId;
  }
}