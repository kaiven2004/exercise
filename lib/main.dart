import 'package:excise/app/theme.dart';
import 'package:excise/ui/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('zh_CN', null);
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
