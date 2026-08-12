import 'package:shared_preferences/shared_preferences.dart';

class ExerciseOverrideRepository {
  static const _prefix = 'exercise_override_';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String _key(String exerciseId, String field) => '${_prefix}${exerciseId}_${field}';

  Future<void> saveOverride(String exerciseId, {int? sets, int? reps, String? restSeconds}) async {
    if (_prefs == null) return;
    if (sets != null) await _prefs!.setInt(_key(exerciseId, 'sets'), sets);
    if (reps != null) await _prefs!.setInt(_key(exerciseId, 'reps'), reps);
    if (restSeconds != null) await _prefs!.setString(_key(exerciseId, 'rest'), restSeconds);
  }

  int? getOverrideSets(String exerciseId) => _prefs?.getInt(_key(exerciseId, 'sets'));
  int? getOverrideReps(String exerciseId) => _prefs?.getInt(_key(exerciseId, 'reps'));
  String? getOverrideRest(String exerciseId) => _prefs?.getString(_key(exerciseId, 'rest'));
  int getEffectiveSets(String exerciseId, int defaultSets) => getOverrideSets(exerciseId) ?? defaultSets;
  int getEffectiveReps(String exerciseId, int defaultReps) => getOverrideReps(exerciseId) ?? defaultReps;
  String getEffectiveRest(String exerciseId, String defaultRest) => getOverrideRest(exerciseId) ?? defaultRest;
  String? getOverrideWeight(String exerciseId) => _prefs?.getString(_key(exerciseId, 'weight'));
  Future<void> saveWeight(String exerciseId, String weight) async {
    if (_prefs == null) return;
    await _prefs!.setString(_key(exerciseId, 'weight'), weight);
  }

}