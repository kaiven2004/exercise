import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// 组间休息结束提醒。
///
/// 只在后台时发通知，前台用震动和提示音。模拟器、未授权或插件不可用时
/// 全部静默降级，不影响训练主流程。
class RestReminder {
  RestReminder([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const _notificationId = 7001;
  static const _channelId = 'rest_timer';

  final FlutterLocalNotificationsPlugin _plugin;

  bool _initialized = false;
  bool _available = true;
  bool _permissionAsked = false;

  Future<void> _ensureInit() async {
    if (_initialized || !_available) return;
    try {
      await _plugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
      );
      _initialized = true;
    } catch (_) {
      _available = false;
    }
  }

  /// Android 13+ 需要运行时授权，只问一次。
  Future<void> ensurePermission() async {
    if (_permissionAsked || !_available) return;
    _permissionAsked = true;
    await _ensureInit();
    if (!_available) return;
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await android?.requestNotificationsPermission();
    } catch (_) {
      // 桌面/测试环境没有该实现。
    }
  }

  Future<void> showRestFinished() async {
    await _ensureInit();
    if (!_available) return;
    try {
      await _plugin.show(
        _notificationId,
        '休息结束',
        '开始下一组',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            '组间休息',
            channelDescription: '组间休息结束时提醒',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            category: AndroidNotificationCategory.reminder,
          ),
        ),
      );
    } catch (_) {
      // 通知不可用时只保留震动。
    }
  }

  Future<void> cancel() async {
    if (!_available) return;
    try {
      await _plugin.cancel(_notificationId);
    } catch (_) {}
  }
}
