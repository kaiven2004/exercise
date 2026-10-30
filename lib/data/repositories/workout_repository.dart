import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';
import '../models/workout_models.dart';

/// 训练记录与草稿的本地仓库。
///
/// v2 数据结构：每组单独记录重量/次数。启动时把旧 `training_history`
/// 一次性导入，旧数据按“完成组数 + 总次数”合成等分记录。
class WorkoutRepository extends ChangeNotifier {
  static const _sessionsKey = 'workout_sessions_v2';
  static const _draftKey = 'workout_draft_v2';
  static const _legacyImportKey = 'workout_v2_legacy_imported';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _importLegacyHistory();
  }

  bool get isReady => _prefs != null;

  List<WorkoutSession> getSessions() {
    final jsons = _prefs?.getStringList(_sessionsKey) ?? const [];
    final sessions = <WorkoutSession>[];
    for (final raw in jsons) {
      try {
        sessions.add(WorkoutSession.fromJson(jsonDecode(raw) as Map<String, dynamic>));
      } catch (_) {
        // 单条损坏不影响其他记录。
      }
    }
    sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return sessions;
  }

  WorkoutSession? getLastSession() {
    final sessions = getSessions();
    return sessions.isEmpty ? null : sessions.first;
  }

  List<WorkoutSession> getSessionsForExercise(String exerciseId) {
    return getSessions()
        .where((s) => s.exercises.any((e) => e.exercise.id == exerciseId && e.completedSets > 0))
        .toList();
  }

  /// 每个动作上次最好的一组。
  Map<String, LastPerformance> getLastPerformances() {
    final map = <String, LastPerformance>{};
    for (final session in getSessions()) {
      for (final exercise in session.exercises) {
        final best = exercise.bestSet;
        if (best == null) continue;
        final existing = map[exercise.exercise.id];
        if (existing == null || session.startedAt.isAfter(existing.date)) {
          map[exercise.exercise.id] = LastPerformance(
            weight: best.weight,
            reps: best.reps,
            date: session.startedAt,
          );
        }
      }
    }
    return map;
  }

  LastPerformance? getLastPerformance(String exerciseId) => getLastPerformances()[exerciseId];

  Future<void> saveSession(WorkoutSession session) async {
    final prefs = _prefs;
    if (prefs == null) return;
    final list = getSessions();
    final existing = list.indexWhere((s) => s.id == session.id);
    if (existing >= 0) {
      list[existing] = session;
    } else {
      list.add(session);
    }
    list.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    await prefs.setStringList(_sessionsKey, list.map((s) => jsonEncode(s.toJson())).toList());
    notifyListeners();
  }

  Future<void> deleteSession(String id) async {
    final prefs = _prefs;
    if (prefs == null) return;
    final list = getSessions().where((s) => s.id != id).toList();
    await prefs.setStringList(_sessionsKey, list.map((s) => jsonEncode(s.toJson())).toList());
    notifyListeners();
  }

  Future<void> clearAllSessions() async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.remove(_sessionsKey);
    notifyListeners();
  }

  WorkoutDraft? getDraft() {
    final raw = _prefs?.getString(_draftKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return WorkoutDraft.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveDraft(WorkoutDraft draft) async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setString(_draftKey, jsonEncode(draft.toJson()));
    notifyListeners();
  }

  Future<void> clearDraft() async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.remove(_draftKey);
    notifyListeners();
  }

  Future<void> _importLegacyHistory() async {
    final prefs = _prefs;
    if (prefs == null || prefs.getBool(_legacyImportKey) == true) return;

    final legacyRaw = prefs.getStringList('training_history') ?? const [];
    final existingIds = getSessions().map((s) => s.id).toSet();
    final imported = <WorkoutSession>[];

    for (final raw in legacyRaw) {
      try {
        final old = TrainingSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
        final id = 'legacy_${old.id}';
        if (existingIds.contains(id)) continue;
        final session = _convertLegacySession(old, id);
        if (session.totalSets > 0) imported.add(session);
      } catch (_) {
        // 旧记录损坏时跳过。
      }
    }

    if (imported.isNotEmpty) {
      final all = [...getSessions(), ...imported]
        ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
      await prefs.setStringList(_sessionsKey, all.map((s) => jsonEncode(s.toJson())).toList());
    }
    await prefs.setBool(_legacyImportKey, true);
  }

  WorkoutSession _convertLegacySession(TrainingSession old, String newId) {
    var restTotal = 0;
    var setCount = 0;
    final exercises = <WorkoutExercise>[];

    for (final log in old.exercises) {
      final count = log.completedSets;
      if (count <= 0) continue;
      final reps = (log.totalReps / count).round().clamp(1, 1000);
      final weight = double.tryParse(log.exercise.weight) ?? 0;
      final sets = List.generate(
        count,
        (_) => WorkoutSet(weight: weight, reps: reps, completed: true, completedAt: old.date),
      );
      exercises.add(WorkoutExercise(exercise: log.exercise, sets: sets));
      setCount += count;
      restTotal += (int.tryParse(log.exercise.restSeconds) ?? 60) * count;
    }

    // 旧数据没有起止时间，按组数与休息粗略倒推。
    final seconds = setCount * 40 + restTotal;
    final endedAt = old.date.add(Duration(seconds: seconds == 0 ? 1 : seconds));
    final parts = old.categoryPath.split(' / ');
    final name = parts.length >= 3 ? parts[1] : (parts.isEmpty ? old.sectionName : parts.last);

    return WorkoutSession(
      id: newId,
      name: name,
      startedAt: old.date,
      endedAt: endedAt,
      exercises: exercises,
    );
  }
}
