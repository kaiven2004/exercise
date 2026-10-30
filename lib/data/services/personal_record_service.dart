import 'dart:math' as math;

import '../models/workout_models.dart';

/// PR 类型。
enum PrKind {
  /// 有重量动作：估算 1RM 创新高。
  estimatedOneRepMax,

  /// 自重动作：单组次数创新高。
  reps,
}

/// 一次动作的 PR 结果。
///
/// [value] 是可比较的数值：有重量时为估算 1RM（kg），自重时为次数。
/// [weight]/[reps] 是达成 PR 的那一组原始数据，用于展示。
class PrResult {
  final String exerciseId;
  final String exerciseName;
  final PrKind kind;
  final double weight;
  final int reps;
  final double value;
  final double previousValue;

  const PrResult({
    required this.exerciseId,
    required this.exerciseName,
    required this.kind,
    required this.weight,
    required this.reps,
    required this.value,
    required this.previousValue,
  });

  double get improvement => value - previousValue;

  String get setLabel {
    final w = weight == weight.roundToDouble()
        ? weight.toInt().toString()
        : weight.toStringAsFixed(1);
    if (kind == PrKind.reps || weight <= 0) return '$reps 次';
    return '$w kg × $reps';
  }

  String get recordLabel {
    if (kind == PrKind.reps || weight <= 0) return '$reps 次';
    return '估算 1RM ${value.toStringAsFixed(1)} kg';
  }
}

/// PR 计算。纯函数，便于单元测试，也避免 UI 里散落规则。
class PersonalRecordService {
  /// Epley 公式。次数为 1 时直接返回重量。
  static double estimatedOneRepMax(double weight, int reps) {
    if (weight <= 0 || reps <= 0) return 0;
    if (reps == 1) return weight;
    return weight * (1 + reps / 30.0);
  }

  /// 当前动作相对历史是否刷新 PR。
  ///
  /// 只有在历史里出现过同一动作时才判定为 PR，首次训练不会满屏“新纪录”。
  static PrResult? detectForExercise(
    WorkoutExercise current,
    Iterable<WorkoutSession> history, {
    String? excludeSessionId,
  }) {
    final completed = current.sets.where((s) => s.completed).toList();
    if (completed.isEmpty) return null;

    final weighted = completed.where((s) => s.weight > 0).toList();
    if (weighted.isNotEmpty) {
      final best = _bestByEstimatedOneRepMax(weighted);
      final newValue = estimatedOneRepMax(best.weight, best.reps);
      if (newValue <= 0) return null;

      double? previous;
      for (final session in history) {
        if (excludeSessionId != null && session.id == excludeSessionId) continue;
        for (final exercise in session.exercises) {
          if (exercise.exercise.id != current.exercise.id) continue;
          for (final set in exercise.sets) {
            if (!set.completed || set.weight <= 0) continue;
            final value = estimatedOneRepMax(set.weight, set.reps);
            if (previous == null || value > previous) previous = value;
          }
        }
      }
      if (previous == null || newValue <= previous + 0.05) return null;
      return PrResult(
        exerciseId: current.exercise.id,
        exerciseName: current.exercise.name,
        kind: PrKind.estimatedOneRepMax,
        weight: best.weight,
        reps: best.reps,
        value: newValue,
        previousValue: previous,
      );
    }

    // 自重动作按次数比较。
    final newReps = completed.map((s) => s.reps).reduce(math.max);
    int? previous;
    for (final session in history) {
      if (excludeSessionId != null && session.id == excludeSessionId) continue;
      for (final exercise in session.exercises) {
        if (exercise.exercise.id != current.exercise.id) continue;
        for (final set in exercise.sets) {
          if (!set.completed || set.weight > 0) continue;
          if (previous == null || set.reps > previous) previous = set.reps;
        }
      }
    }
    if (previous == null || newReps <= previous) return null;
    return PrResult(
      exerciseId: current.exercise.id,
      exerciseName: current.exercise.name,
      kind: PrKind.reps,
      weight: 0,
      reps: newReps,
      value: newReps.toDouble(),
      previousValue: previous.toDouble(),
    );
  }

  /// 整场训练的 PR 列表，按刷新幅度从大到小。
  static List<PrResult> detect(
    WorkoutSession session,
    Iterable<WorkoutSession> history,
  ) {
    final results = <PrResult>[];
    for (final exercise in session.exercises) {
      final result = detectForExercise(
        exercise,
        history,
        excludeSessionId: session.id,
      );
      if (result != null) results.add(result);
    }
    results.sort((a, b) => b.improvement.compareTo(a.improvement));
    return results;
  }

  static WorkoutSet _bestByEstimatedOneRepMax(List<WorkoutSet> sets) {
    var best = sets.first;
    var bestValue = estimatedOneRepMax(best.weight, best.reps);
    for (final set in sets.skip(1)) {
      final value = estimatedOneRepMax(set.weight, set.reps);
      if (value > bestValue || (value == bestValue && set.reps > best.reps)) {
        best = set;
        bestValue = value;
      }
    }
    return best;
  }
}
