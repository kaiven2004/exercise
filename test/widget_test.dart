// This is a basic Flutter widget test.
import '''package:flutter/material.dart''';
import '''package:flutter_test/flutter_test.dart''';
import '''package:excise/main.dart''';

void main() {
  testWidgets('''App launches correctly''', (WidgetTester tester) async {
    await tester.pumpWidget(const ExciseApp());
    await tester.pump();
    expect(find.text('''EXCISE'''), findsOneWidget);
  });
}
