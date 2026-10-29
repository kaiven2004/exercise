import '../models/models.dart';

/// 力量板块分类树（上肢→胸/肩/背/臂 + 下肢 + 核心）
const List<TrainingCategory> kStrengthCategories = [
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
          TrainingCategory(id: 'shoulder_rotator', name: '肩袖肌群', section: WorkoutSection.strength, svgIcon: 'shoulder'),
        ],
      ),
      TrainingCategory(
        id: 'strength_back',
        name: '背部训练',
        section: WorkoutSection.strength,
        svgIcon: 'back',
        subCategories: [
          TrainingCategory(id: 'back_lats', name: '背阔肌', section: WorkoutSection.strength, svgIcon: 'back_lats'),
          TrainingCategory(id: 'back_upper', name: '上背厚度', section: WorkoutSection.strength, svgIcon: 'back'),
          TrainingCategory(id: 'back_traps_lower', name: '斜方下束', section: WorkoutSection.strength, svgIcon: 'back_traps'),
          TrainingCategory(id: 'back_lower', name: '下背/竖脊肌', section: WorkoutSection.strength, svgIcon: 'back'),
        ],
      ),
      TrainingCategory(
        id: 'strength_arms',
        name: '手臂训练',
        section: WorkoutSection.strength,
        svgIcon: 'arm',
        subCategories: [
          TrainingCategory(id: 'arms_biceps', name: '肱二头肌', section: WorkoutSection.strength, svgIcon: 'arm'),
          TrainingCategory(id: 'arms_triceps', name: '肱三头肌', section: WorkoutSection.strength, svgIcon: 'arm'),
          TrainingCategory(id: 'arms_forearm', name: '前臂', section: WorkoutSection.strength, svgIcon: 'arm'),
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
      TrainingCategory(id: 'leg_adductors', name: '内收肌群', section: WorkoutSection.strength, svgIcon: 'leg'),
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
      TrainingCategory(id: 'core_deep', name: '深层核心', section: WorkoutSection.strength, svgIcon: 'core'),
      TrainingCategory(id: 'core_antiflex', name: '抗伸展', section: WorkoutSection.strength, svgIcon: 'core'),
    ],
  ),
];

/// 功能训练分类（一级，无二级）
const List<TrainingCategory> kFunctionalCategories = [
  TrainingCategory(id: 'func_core', name: '核心稳定', section: WorkoutSection.functional, svgIcon: 'core', subCategories: []),
  TrainingCategory(id: 'func_balance', name: '平衡训练', section: WorkoutSection.functional, svgIcon: 'functional', subCategories: []),
  TrainingCategory(id: 'func_agility', name: '灵敏训练', section: WorkoutSection.functional, svgIcon: 'functional', subCategories: []),
  TrainingCategory(id: 'func_unilateral', name: '单侧力量', section: WorkoutSection.functional, svgIcon: 'functional', subCategories: []),
  TrainingCategory(id: 'func_hip', name: '髋功能', section: WorkoutSection.functional, svgIcon: 'functional', subCategories: []),
  TrainingCategory(id: 'func_thoracic', name: '胸椎肩胛', section: WorkoutSection.functional, svgIcon: 'functional', subCategories: []),
  TrainingCategory(id: 'func_grip', name: '悬吊抓握', section: WorkoutSection.functional, svgIcon: 'functional', subCategories: []),
  TrainingCategory(id: 'func_flow', name: '动物流', section: WorkoutSection.functional, svgIcon: 'functional', subCategories: []),
  TrainingCategory(id: 'func_metabolic', name: '代谢力量', section: WorkoutSection.functional, svgIcon: 'functional', subCategories: []),
  TrainingCategory(id: 'func_breath', name: '呼吸训练', section: WorkoutSection.functional, svgIcon: 'core', subCategories: []),
];

/// 瑜伽分类（含子分类）
const List<TrainingCategory> kYogaCategories = [
  TrainingCategory(
    id: 'yoga_power',
    name: '力量瑜伽',
    section: WorkoutSection.yoga,
    svgIcon: 'yoga',
    subCategories: [],
  ),
  TrainingCategory(
    id: 'yoga_vinyasa',
    name: '流瑜伽',
    section: WorkoutSection.yoga,
    svgIcon: 'yoga_vinyasa',
    subCategories: [],
  ),
  TrainingCategory(
    id: 'yoga_hatha',
    name: '哈他瑜伽',
    section: WorkoutSection.yoga,
    svgIcon: 'yoga_hatha',
    subCategories: [],
  ),
  TrainingCategory(
    id: 'yoga_yin',
    name: '阴瑜伽',
    section: WorkoutSection.yoga,
    svgIcon: 'yoga_restorative',
    subCategories: [],
  ),
];
