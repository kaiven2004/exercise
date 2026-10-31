import 'package:excise/data/repositories/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('默认开启自动休息', () async {
    SharedPreferences.setMockInitialValues({});
    final settings = AppSettings();
    await settings.init();
    expect(settings.restEnabled, isTrue);
  });

  test('关闭后重新创建仍保持关闭', () async {
    SharedPreferences.setMockInitialValues({});
    final settings = AppSettings();
    await settings.init();
    await settings.setRestEnabled(false);
    expect(settings.restEnabled, isFalse);

    final reopened = AppSettings();
    await reopened.init();
    expect(reopened.restEnabled, isFalse);
  });

  test('读取已保存的开关值', () async {
    SharedPreferences.setMockInitialValues({'settings_rest_enabled': true});
    final settings = AppSettings();
    await settings.init();
    expect(settings.restEnabled, isTrue);
  });
}
