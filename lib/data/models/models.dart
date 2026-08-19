/// 训练板块枚举
enum WorkoutSection {
  strength,
  functional,
  yoga,
}

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
  final String imageUrl;
  final String difficulty;
  final String videoPath;
  final String weight;

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
    this.imageUrl = '',
    this.difficulty = '初级',
    this.videoPath = '',
    this.weight = '0',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'categoryPath': categoryPath,
        'description': description,
        'tips': tips,
        'sets': sets,
        'reps': reps,
        'restSeconds': restSeconds,
        'imageSvg': imageSvg,
        'imageUrl': imageUrl,
        'difficulty': difficulty,
        'videoPath': videoPath,
        'weight': weight,
      };

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        id: json['id'] as String,
        name: json['name'] as String,
        categoryPath: json['categoryPath'] as String,
        description: json['description'] as String,
        tips: (json['tips'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
        sets: json['sets'] as int? ?? 3,
        reps: json['reps'] as int? ?? 12,
        restSeconds: json['restSeconds'] as String? ?? '60',
        imageSvg: json['imageSvg'] as String? ?? 'exercise_default',
        imageUrl: json['imageUrl'] as String? ?? '',
        difficulty: json['difficulty'] as String? ?? '初级',
        videoPath: json['videoPath'] as String? ?? '',
        weight: json['weight'] as String? ?? '0',
      );
}

class SetConfig {
  final double weight;
  final int reps;
  const SetConfig({this.weight = 0, this.reps = 12});
  Map<String, dynamic> toJson() => {'weight': weight, 'reps': reps};
  factory SetConfig.fromJson(Map<String, dynamic> json) =>
      SetConfig(weight: (json['weight'] as num).toDouble(), reps: json['reps'] as int);
}

class CustomExerciseItem {
  final Exercise exercise;
  int sets;
  int reps;
  String restSeconds;
  String weight;
  final int order;
  final List<SetConfig>? setConfigs;

  CustomExerciseItem({
    required this.exercise,
    this.sets = 3,
    this.reps = 12,
    this.restSeconds = '60',
    this.weight = '',
    this.order = 0,
    this.setConfigs,
  });

  CustomExerciseItem copyWith({int? sets, int? reps, String? restSeconds, String? weight, int? order, List<SetConfig>? setConfigs}) {
    return CustomExerciseItem(
      exercise: exercise,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      restSeconds: restSeconds ?? this.restSeconds,
      weight: weight ?? this.weight,
      order: order ?? this.order,
      setConfigs: setConfigs ?? this.setConfigs,
    );
  }
}

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

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'sectionName': sectionName,
        'categoryPath': categoryPath,
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };

  factory TrainingSession.fromJson(Map<String, dynamic> json) => TrainingSession(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        sectionName: json['sectionName'] as String,
        categoryPath: json['categoryPath'] as String,
        exercises: (json['exercises'] as List<dynamic>)
            .map((e) => ExerciseLog.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class ExerciseLog {
  final Exercise exercise;
  final int completedSets;
  final int totalReps;

  const ExerciseLog({
    required this.exercise,
    required this.completedSets,
    required this.totalReps,
  });

  Map<String, dynamic> toJson() => {
        'exercise': exercise.toJson(),
        'completedSets': completedSets,
        'totalReps': totalReps,
      };

  factory ExerciseLog.fromJson(Map<String, dynamic> json) => ExerciseLog(
        exercise: Exercise.fromJson(json['exercise'] as Map<String, dynamic>),
        completedSets: json['completedSets'] as int,
        totalReps: json['totalReps'] as int,
      );
}
