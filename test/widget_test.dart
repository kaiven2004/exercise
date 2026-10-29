// This is a basic Flutter widget test.
import 'package:excise/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  testWidgets('App launches correctly', (WidgetTester tester) async {
    await initializeDateFormatting('zh_CN', null);
    await tester.pumpWidget(const ExciseApp());
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
