import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import 'repositories.dart';

class LocalFavoriteRepository implements FavoriteRepository {
  static const _key = 'favorites';
  static const _cleanupFlagKey = 'favorites_chest_id_cleanup_v1';

  /// 旧版本中 10053–10061 同时被下胸和肩部占用。只存 ID 无法区分，
  /// 按数据修复方案一次性清掉，让用户重新收藏。
  static const _ambiguousLegacyIds = {
    '10053', '10054', '10055', '10056', '10057',
    '10058', '10059', '10060', '10061',
  };

  SharedPreferences? _prefs;
  bool _removedLegacyFavorites = false;

  /// 本次启动是否因 ID 修复清理过收藏，用于提示用户。
  bool get removedLegacyFavorites => _removedLegacyFavorites;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    if (_prefs!.getBool(_cleanupFlagKey) == true) return;
    final ids = _getIds();
    final before = ids.length;
    ids.removeWhere(_ambiguousLegacyIds.contains);
    if (ids.length != before) {
      await _prefs!.setStringList(_key, ids);
      _removedLegacyFavorites = true;
    }
    await _prefs!.setBool(_cleanupFlagKey, true);
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
  static const _remapFlagKey = 'history_id_remap_v1';

  /// 旧历史快照里的 ID 重映射（仅改 ID，保留名称/分类快照）。
  /// 10053–10061 只在下胸记录中改；肩部记录保持原 ID。
  static const Map<String, String> _lowerChestIdRemap = {
    '10053': '10211',
    '10054': '10212',
    '10055': '10213',
    '10056': '10214',
    '10057': '10215',
    '10058': '10216',
    '10059': '10217',
    '10060': '10218',
    '10061': '10219',
  };

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _migrateLegacyIds();
  }

  Future<void> _migrateLegacyIds() async {
    final prefs = _prefs;
    if (prefs == null || prefs.getBool(_remapFlagKey) == true) return;
    final sessions = getHistory();
    var changed = false;
    final migrated = sessions.map((session) {
      var sessionChanged = false;
      final logs = session.exercises.map((log) {
        final remapped = _remapExerciseId(log.exercise);
        if (identical(remapped, log.exercise)) return log;
        sessionChanged = true;
        return ExerciseLog(
          exercise: remapped,
          completedSets: log.completedSets,
          totalReps: log.totalReps,
        );
      }).toList();
      if (!sessionChanged) return session;
      changed = true;
      return TrainingSession(
        id: session.id,
        date: session.date,
        sectionName: session.sectionName,
        categoryPath: session.categoryPath,
        exercises: logs,
      );
    }).toList();
    if (changed) {
      await prefs.setStringList(
        _key,
        migrated.map((s) => jsonEncode(s.toJson())).toList(),
      );
    }
    await prefs.setBool(_remapFlagKey, true);
  }

  Exercise _remapExerciseId(Exercise exercise) {
    String? newId;
    if (exercise.categoryPath.endsWith('下胸')) {
      newId = _lowerChestIdRemap[exercise.id];
    } else if (exercise.id == '10015') {
      // 旧胸部数据里的站姿杠铃推举，合并到肩部 10053。
      newId = '10053';
    } else if (exercise.id == '10142') {
      // 10142 与 10092 语义重复，合并到 10092。
      newId = '10092';
    }
    if (newId == null) return exercise;
    return Exercise(
      id: newId,
      name: exercise.name,
      categoryPath: exercise.categoryPath,
      description: exercise.description,
      tips: exercise.tips,
      sets: exercise.sets,
      reps: exercise.reps,
      restSeconds: exercise.restSeconds,
      imageSvg: exercise.imageSvg,
      imageUrl: exercise.imageUrl,
      difficulty: exercise.difficulty,
      videoPath: exercise.videoPath,
      weight: exercise.weight,
    );
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