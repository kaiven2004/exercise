import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import 'repositories.dart';

class LocalCustomPlanRepository implements CustomPlanRepository {
  static const _key = 'custom_plans';
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  List<CustomPlan> getPlans() {
    final jsons = _prefs?.getStringList(_key) ?? [];
    return jsons.map((s) => _fromJson(jsonDecode(s) as Map<String, dynamic>)).toList();
  }

  @override
  CustomPlan? getPlan(String id) {
    try {
      return getPlans().firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> savePlan(CustomPlan plan) async {
    if (_prefs == null) return;
    final plans = getPlans();
    final idx = plans.indexWhere((p) => p.id == plan.id);
    if (idx >= 0) {
      plans[idx] = plan;
    } else {
      plans.add(plan);
    }
    await _prefs!.setStringList(_key, plans.map((p) => jsonEncode(_toJson(p))).toList());
  }

  @override
  Future<void> deletePlan(String id) async {
    if (_prefs == null) return;
    final plans = getPlans().where((p) => p.id != id).toList();
    await _prefs!.setStringList(_key, plans.map((p) => jsonEncode(_toJson(p))).toList());
  }

  @override
  Future<void> duplicatePlan(CustomPlan plan) async {
    final dup = CustomPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '${plan.name} (副本)',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      exercises: plan.exercises,
    );
    await savePlan(dup);
  }

  Map<String, dynamic> _toJson(CustomPlan plan) {
    return {
      'id': plan.id,
      'name': plan.name,
      'createdAt': plan.createdAt.toIso8601String(),
      'updatedAt': plan.updatedAt.toIso8601String(),
      'exercises': plan.exercises.map((e) => {
        'exerciseId': e.exercise.id,
        'exerciseName': e.exercise.name,
        'exerciseCategoryPath': e.exercise.categoryPath,
        'exerciseImageSvg': e.exercise.imageSvg,
        'imageSvg': e.exercise.imageUrl,
        'sets': e.sets,
        'reps': e.reps,
        'restSeconds': e.restSeconds,
        'weight': e.weight,
        'order': e.order,
      }).toList(),
    };
  }

  CustomPlan _fromJson(Map<String, dynamic> json) {
    final exercises = (json['exercises'] as List<dynamic>).map((e) {
      final exJson = e as Map<String, dynamic>;
      return CustomExerciseItem(
        exercise: Exercise(
          id: exJson['exerciseId'] as String,
          name: exJson['exerciseName'] as String,
          categoryPath: exJson['exerciseCategoryPath'] as String,
          description: '',
          imageSvg: exJson['exerciseImageSvg'] as String,
          imageUrl: exJson['imageSvg'] as String? ?? '',
        ),
        sets: exJson['sets'] as int,
        reps: exJson['reps'] as int,
        restSeconds: exJson['restSeconds'] as String,
        weight: exJson['weight'] as String? ?? '',
        order: exJson['order'] as int,
      );
    }).toList();
    return CustomPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      exercises: exercises,
    );
  }
}