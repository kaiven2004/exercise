import 'models.dart';

/// 一组训练记录。重量单位 kg，0 表示自重。
class WorkoutSet {
  double weight;
  int reps;
  bool completed;
  DateTime? completedAt;

  WorkoutSet({
    this.weight = 0,
    this.reps = 0,
    this.completed = false,
    this.completedAt,
  });

  WorkoutSet copyWith({
    double? weight,
    int? reps,
    bool? completed,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return WorkoutSet(
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      completed: completed ?? this.completed,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
    );
  }

  Map<String, dynamic> toJson() => {
        'weight': weight,
        'reps': reps,
        'completed': completed,
        'completedAt': completedAt?.toIso8601String(),
      };

  factory WorkoutSet.fromJson(Map<String, dynamic> json) => WorkoutSet(
        weight: (json['weight'] as num?)?.toDouble() ?? 0,
        reps: json['reps'] as int? ?? 0,
        completed: json['completed'] as bool? ?? false,
        completedAt: json['completedAt'] == null
            ? null
            : DateTime.tryParse(json['completedAt'] as String),
      );
}

/// 训练中的一个动作，带逐组记录与备注。
class WorkoutExercise {
  final Exercise exercise;
  final List<WorkoutSet> sets;
  String note;

  WorkoutExercise({
    required this.exercise,
    required this.sets,
    this.note = '',
  });

  int get completedSets => sets.where((s) => s.completed).length;
  bool get isFinished => completedSets == sets.length && sets.isNotEmpty;

  double get volume {
    var total = 0.0;
    for (final set in sets) {
      if (!set.completed) continue;
      total += set.weight * set.reps;
    }
    return total;
  }

  int get totalReps {
    var total = 0;
    for (final set in sets) {
      if (set.completed) total += set.reps;
    }
    return total;
  }

  /// 完成组里没有记重量的次数（自重动作）。重量为 0 时容量恒为 0，
  /// 用这个指标替代展示，避免「练了 19 组、容量 0kg」。
  int get bodyweightReps {
    var total = 0;
    for (final set in sets) {
      if (set.completed && set.weight <= 0) total += set.reps;
    }
    return total;
  }

  /// 把重量写到所有未完成的组；已完成的组保持原样。
  void applyWeightToUncompleted(double weight) {
    for (final set in sets) {
      if (!set.completed) set.weight = weight;
    }
  }

  /// 给还没有填重量的未完成组补默认值（不覆盖用户已改过的组）。
  void seedWeight(double weight) {
    if (weight <= 0) return;
    for (final set in sets) {
      if (!set.completed && set.weight <= 0) set.weight = weight;
    }
  }

  WorkoutSet? get bestSet {
    WorkoutSet? best;
    for (final set in sets) {
      if (!set.completed) continue;
      if (best == null ||
          set.weight > best.weight ||
          (set.weight == best.weight && set.reps > best.reps)) {
        best = set;
      }
    }
    return best;
  }

  WorkoutExercise copyWith({List<WorkoutSet>? sets, String? note}) => WorkoutExercise(
        exercise: exercise,
        sets: sets ?? this.sets,
        note: note ?? this.note,
      );

  Map<String, dynamic> toJson() => {
        'exercise': exercise.toJson(),
        'sets': sets.map((s) => s.toJson()).toList(),
        'note': note,
      };

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) => WorkoutExercise(
        exercise: Exercise.fromJson(json['exercise'] as Map<String, dynamic>),
        sets: (json['sets'] as List<dynamic>? ?? const [])
            .map((s) => WorkoutSet.fromJson(s as Map<String, dynamic>))
            .toList(),
        note: json['note'] as String? ?? '',
      );
}

/// 已完成的训练。
class WorkoutSession {
  final String id;
  final String? planId;
  final String name;
  final DateTime startedAt;
  final DateTime endedAt;
  final List<WorkoutExercise> exercises;
  final int rpe;
  final String note;

  const WorkoutSession({
    required this.id,
    this.planId,
    required this.name,
    required this.startedAt,
    required this.endedAt,
    required this.exercises,
    this.rpe = 0,
    this.note = '',
  });

  Duration get duration => endedAt.difference(startedAt);

  int get totalSets => exercises.fold(0, (sum, e) => sum + e.completedSets);

  double get totalVolume => exercises.fold(0.0, (sum, e) => sum + e.volume);

  int get totalReps => exercises.fold(0, (sum, e) => sum + e.totalReps);

  /// 全场自重次数。用于重量为 0 时替代「容量」展示。
  int get totalBodyweightReps => exercises.fold(0, (sum, e) => sum + e.bodyweightReps);

  int get bodyweightSets => exercises.fold(
        0,
        (sum, e) => sum + e.sets.where((s) => s.completed && s.weight == 0).length,
      );

  List<WorkoutExercise> get finishedExercises =>
      exercises.where((e) => e.completedSets > 0).toList();

  Map<String, dynamic> toJson() => {
        'id': id,
        'planId': planId,
        'name': name,
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt.toIso8601String(),
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'rpe': rpe,
        'note': note,
      };

  factory WorkoutSession.fromJson(Map<String, dynamic> json) => WorkoutSession(
        id: json['id'] as String,
        planId: json['planId'] as String?,
        name: json['name'] as String,
        startedAt: DateTime.parse(json['startedAt'] as String),
        endedAt: DateTime.parse(json['endedAt'] as String),
        exercises: (json['exercises'] as List<dynamic>? ?? const [])
            .map((e) => WorkoutExercise.fromJson(e as Map<String, dynamic>))
            .toList(),
        rpe: json['rpe'] as int? ?? 0,
        note: json['note'] as String? ?? '',
      );
}

/// 未完成的训练草稿。进程被杀后从这里恢复。
class WorkoutDraft {
  final String name;
  final String? planId;
  final DateTime startedAt;
  final List<WorkoutExercise> exercises;
  final int exerciseIndex;
  final int setIndex;

  const WorkoutDraft({
    required this.name,
    this.planId,
    required this.startedAt,
    required this.exercises,
    this.exerciseIndex = 0,
    this.setIndex = 0,
  });

  int get completedSets => exercises.fold(0, (sum, e) => sum + e.completedSets);

  int get totalSets => exercises.fold(0, (sum, e) => sum + e.sets.length);

  bool get hasProgress => completedSets > 0;

  bool get isStale => DateTime.now().difference(startedAt).inHours >= 24;

  WorkoutDraft copyWith({
    String? name,
    List<WorkoutExercise>? exercises,
    int? exerciseIndex,
    int? setIndex,
  }) {
    return WorkoutDraft(
      name: name ?? this.name,
      planId: planId,
      startedAt: startedAt,
      exercises: exercises ?? this.exercises,
      exerciseIndex: exerciseIndex ?? this.exerciseIndex,
      setIndex: setIndex ?? this.setIndex,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'planId': planId,
        'startedAt': startedAt.toIso8601String(),
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'exerciseIndex': exerciseIndex,
        'setIndex': setIndex,
      };

  factory WorkoutDraft.fromJson(Map<String, dynamic> json) => WorkoutDraft(
        name: json['name'] as String? ?? '训练',
        planId: json['planId'] as String?,
        startedAt: DateTime.parse(json['startedAt'] as String),
        exercises: (json['exercises'] as List<dynamic>? ?? const [])
            .map((e) => WorkoutExercise.fromJson(e as Map<String, dynamic>))
            .toList(),
        exerciseIndex: json['exerciseIndex'] as int? ?? 0,
        setIndex: json['setIndex'] as int? ?? 0,
      );
}

/// 某个动作上次的表现，用于训练页预填。
class LastPerformance {
  final double weight;
  final int reps;
  final DateTime date;

  const LastPerformance({required this.weight, required this.reps, required this.date});

  String get label {
    if (weight <= 0) return '自重 × $reps';
    final w = weight == weight.roundToDouble() ? weight.toInt().toString() : weight.toStringAsFixed(1);
    return '$w kg × $reps';
  }
}
