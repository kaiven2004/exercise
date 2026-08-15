import '../models/models.dart';
import '../exercises/categories.dart';
import '../exercises/functional.dart';
import '../exercises/strength_arms.dart';
import '../exercises/strength_back.dart';
import '../exercises/strength_chest.dart';
import '../exercises/strength_core.dart';
import '../exercises/strength_lower.dart';
import '../exercises/strength_shoulders.dart';
import '../exercises/yoga.dart';
import 'exercise_repository.dart';

/// 全部动作数据（200+ 个，按部位分类聚合自 exercises/ 各文件）
final List<Exercise> _exercises = <Exercise>[
  ...kStrengthChestExercises,
  ...kStrengthShouldersExercises,
  ...kStrengthBackExercises,
  ...kStrengthArmsExercises,
  ...kStrengthLowerExercises,
  ...kStrengthCoreExercises,
  ...kFunctionalExercises,
  ...kYogaExercises,
];

class SampleExerciseRepository implements ExerciseRepository {
  @override
  List<WorkoutSection> getSections() => WorkoutSection.values;

  @override
  List<TrainingCategory> getCategories(WorkoutSection section) {
    switch (section) {
      case WorkoutSection.strength:
        return kStrengthCategories;
      case WorkoutSection.functional:
        return kFunctionalCategories;
      case WorkoutSection.yoga:
        return kYogaCategories;
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
      'shoulder_front': '前束', 'shoulder_mid': '中束', 'shoulder_rear': '后束', 'shoulder_rotator': '肩袖肌群',
      'back_lats': '背阔肌', 'back_upper': '上背厚度', 'back_traps_lower': '斜方下束', 'back_lower': '下背/竖脊肌',
      'arms_biceps': '肱二头肌', 'arms_triceps': '肱三头肌', 'arms_forearm': '前臂',
      'leg_quads': '股四头肌', 'leg_hamstrings': '腘绳肌', 'leg_glutes': '臀部', 'leg_calves': '小腿', 'leg_adductors': '内收肌群',
      'core_abs': '腹直肌', 'core_obliques': '腹斜肌', 'core_deep': '深层核心', 'core_antiflex': '抗伸展',
      'func_core': '核心稳定', 'func_balance': '平衡训练', 'func_agility': '灵敏训练', 'func_unilateral': '单侧力量', 'func_hip': '髋功能', 'func_thoracic': '胸椎肩胛', 'func_grip': '悬吊抓握', 'func_flow': '动物流', 'func_metabolic': '代谢力量', 'func_breath': '呼吸训练',
      'yoga_power': '力量瑜伽', 'yoga_vinyasa': '流瑜伽', 'yoga_hatha': '哈他瑜伽', 'yoga_yin': '阴瑜伽',
    };
    return map[categoryId] ?? categoryId;
  }
}
