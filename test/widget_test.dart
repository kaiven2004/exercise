// This is a basic Flutter widget test.
import 'package:excise/app/app_scope.dart';
import 'package:excise/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App launches correctly', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await initializeDateFormatting('zh_CN', null);
    final services = await AppServices.create();
    await tester.pumpWidget(ExciseApp(services: services));
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
