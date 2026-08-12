import 'package:excise/app/theme.dart';
import 'package:excise/ui/screens/main_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExciseApp());
}

class ExciseApp extends StatelessWidget {
  const ExciseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Excise',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainScreen(),
    );
  }
}