/// 训练板块枚举
enum WorkoutSection {
  strength, // 力量训练
  functional, // 功能训练
  yoga, // 瑜伽训练
}

/// 训练分类（部位/肌肉分组）
class TrainingCategory {
  final String id;
  final String name;
  final WorkoutSection section;
  final String svgIcon;
  final List<TrainingCategory> subCategories;

  const TrainingCategory({
    required this.id,
    required this.name,
    required this.section,
    required this.svgIcon,
    this.subCategories = const [],
  });
}

/// 训练动作
class Exercise {
  final String id;
  final String name;
  final String categoryPath;
  final String description;
  final List<String> tips;
  final int sets;
  final int reps;
  final String restSeconds;
  final String imageSvg;
  final String difficulty;
  final String videoPath;

  const Exercise({
    required this.id,
    required this.name,
    required this.categoryPath,
    required this.description,
    this.tips = const [],
    this.sets = 3,
    this.reps = 12,
    this.restSeconds = '60',
    this.imageSvg = 'exercise_default',
    this.difficulty = '初级',
    this.videoPath = '',
  });
}

/// 自定义计划中的动作条目（可覆盖默认组数/次数/休息）
class CustomExerciseItem {
  final Exercise exercise;
  int sets;
  int reps;
  String restSeconds;
  String weight;
  final int order;

  CustomExerciseItem({
    required this.exercise,
    this.sets = 3,
    this.reps = 12,
    this.restSeconds = '60',
    this.weight = '',
    this.order = 0,
  });

  CustomExerciseItem copyWith({int? sets, int? reps, String? restSeconds, String? weight, int? order}) {
    return CustomExerciseItem(
      exercise: exercise,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      restSeconds: restSeconds ?? this.restSeconds,
      weight: weight ?? this.weight,
      order: order ?? this.order,
    );
  }
}

/// 自定义训练计划
class CustomPlan {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<CustomExerciseItem> exercises;

  const CustomPlan({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.exercises,
  });

  CustomPlan copyWith({String? name, List<CustomExerciseItem>? exercises}) {
    return CustomPlan(
      id: id,
      name: name ?? this.name,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      exercises: exercises ?? this.exercises,
    );
  }
}

/// 训练记录（历史）
class TrainingSession {
  final String id;
  final DateTime date;
  final String sectionName;
  final String categoryPath;
  final List<ExerciseLog> exercises;

  const TrainingSession({
    required this.id,
    required this.date,
    required this.sectionName,
    required this.categoryPath,
    required this.exercises,
  });
}

/// 单次动作记录
class ExerciseLog {
  final Exercise exercise;
  final int completedSets;
  final int totalReps;

  const ExerciseLog({
    required this.exercise,
    required this.completedSets,
    required this.totalReps,
  });
}