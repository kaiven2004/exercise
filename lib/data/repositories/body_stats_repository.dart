import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class BodyStatsRepository {
  static const _key = 'body_measurements';
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  List<BodyMeasurement> getMeasurements() {
    final jsons = _prefs?.getStringList(_key) ?? [];
    return jsons
        .map((s) => BodyMeasurement.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addMeasurement(BodyMeasurement m) async {
    if (_prefs == null) return;
    final list = getMeasurements();
    list.add(m);
    await _prefs!.setStringList(_key, list.map((s) => jsonEncode(s.toJson())).toList());
  }

  Future<void> deleteMeasurement(String id) async {
    if (_prefs == null) return;
    final list = getMeasurements()..removeWhere((m) => m.id == id);
    await _prefs!.setStringList(_key, list.map((s) => jsonEncode(s.toJson())).toList());
  }

  Future<void> clearAll() async {
    if (_prefs == null) return;
    await _prefs!.remove(_key);
  }

  BodyMeasurement? getLatest() {
    final list = getMeasurements();
    return list.isNotEmpty ? list.first : null;
  }
}