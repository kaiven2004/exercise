import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import 'repositories.dart';

class LocalFavoriteRepository implements FavoriteRepository {
  static const _key = 'favorites';
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  List<String> _getIds() => _prefs?.getStringList(_key) ?? [];

  @override
  List<Exercise> getFavorites(List<Exercise> allExercises) {
    final ids = _getIds();
    return allExercises.where((e) => ids.contains(e.id)).toList();
  }

  @override
  bool isFavorite(Exercise exercise) => _getIds().contains(exercise.id);

  @override
  Future<void> toggleFavorite(Exercise exercise) async {
    if (_prefs == null) return;
    final ids = _getIds();
    if (ids.contains(exercise.id)) {
      ids.remove(exercise.id);
    } else {
      ids.add(exercise.id);
    }
    await _prefs!.setStringList(_key, ids);
  }
}

class LocalTrainingHistoryRepository implements TrainingHistoryRepository {
  static const _key = 'training_history';
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  List<TrainingSession> getHistory() {
    final jsons = _prefs?.getStringList(_key) ?? [];
    return jsons
        .map((s) => TrainingSession.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> addSession(TrainingSession session) async {
    if (_prefs == null) return;
    final list = getHistory();
    list.insert(0, session);
    await _prefs!.setStringList(_key, list.map((s) => jsonEncode(s.toJson())).toList());
  }

  @override
  Future<void> clearHistory() async {
    if (_prefs != null) await _prefs!.remove(_key);
  }
}