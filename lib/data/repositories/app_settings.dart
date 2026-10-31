import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 本地偏好设置。目前只有组间休息开关，后续单位切换等也放这里。
class AppSettings extends ChangeNotifier {
  static const _restEnabledKey = 'settings_rest_enabled';

  SharedPreferences? _prefs;
  bool _restEnabled = true;

  bool get restEnabled => _restEnabled;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _restEnabled = _prefs?.getBool(_restEnabledKey) ?? true;
  }

  Future<void> setRestEnabled(bool value) async {
    if (_restEnabled == value) return;
    _restEnabled = value;
    notifyListeners();
    await _prefs?.setBool(_restEnabledKey, value);
  }
}
