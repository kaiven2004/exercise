import 'package:excise/app/theme.dart';
import 'package:excise/ui/screens/custom_plan_list_screen.dart';
import 'package:excise/ui/screens/profile_screen.dart';
import 'package:excise/ui/screens/progress_screen.dart';
import 'package:excise/ui/screens/today_screen.dart';
import 'package:flutter/material.dart';

/// 应用主壳：训练 / 计划 / 进度 / 我的。
///
/// 用 IndexedStack 保留各 Tab 的滚动位置和页面状态；训练页是默认首页。
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  static const _tabs = [
    TodayScreen(),
    CustomPlanListScreen(),
    ProgressScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgMain,
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppTheme.divider, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.textTertiary,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.fitness_center_rounded, size: 22), label: '训练'),
            BottomNavigationBarItem(icon: Icon(Icons.event_note_rounded, size: 22), label: '计划'),
            BottomNavigationBarItem(icon: Icon(Icons.insights_rounded, size: 22), label: '进度'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded, size: 22), label: '我的'),
          ],
          onTap: (index) => setState(() => _index = index),
        ),
      ),
    );
  }
}
