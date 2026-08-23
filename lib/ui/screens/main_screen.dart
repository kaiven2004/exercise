import 'package:excise/data/models/models.dart';
import 'package:excise/data/repositories/sample_repository.dart';
import 'package:excise/ui/widgets/svg_icons.dart';
import 'package:excise/ui/screens/category_screen.dart';
import 'package:excise/ui/screens/exercise_list_screen.dart';
import 'package:excise/ui/screens/search_screen.dart';
import 'package:excise/ui/screens/favorites_screen.dart';
import 'package:excise/ui/screens/history_screen.dart';
import 'package:excise/ui/screens/custom_plan_list_screen.dart';
import 'package:excise/ui/screens/body_stats_screen.dart';
import 'package:excise/app/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _bottomIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _bottomIndex == 0
          ? _buildWorkoutTab()
          : _bottomIndex == 1
          ? const FavoritesScreen()
          : const HistoryScreen(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildWorkoutTab() {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        _buildSliverHeader(),
      ],
      body: TabBarView(
        controller: _tabController,
        children: const [
          _SectionTabView(section: WorkoutSection.strength),
          _SectionTabView(section: WorkoutSection.functional),
          _SectionTabView(section: WorkoutSection.yoga),
          CustomPlanListScreen(),
        ],
      ),
    );
  }

  Widget _buildSliverHeader() {
    final now = DateTime.now();
    final greeting = now.hour < 12 ? '早上好' : now.hour < 18 ? '下午好' : '晚上好';
    final dateStr = DateFormat('M月d日 E', 'zh_CN').format(now);
    return SliverAppBar(
      expandedHeight: 130,
      floating: true,
      pinned: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 50, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'EXCISE',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(greeting, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                      child: Text(dateStr, style: const TextStyle(fontSize: 12, color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.monitor_heart, size: 22, color: Color(0xFF3C3C43)), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BodyStatsScreen()))),
        IconButton(icon: const SvgIcon(assetName: 'search', size: 22), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()))),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(46),
        child: Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppTheme.primary,
            indicatorWeight: 2,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textTertiary,
            isScrollable: true,
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontSize: 13),
            tabs: const [
              Tab(text: '力量', icon: SvgIcon(assetName: 'strength', size: 16)),
              Tab(text: '功能', icon: SvgIcon(assetName: 'functional', size: 16)),
              Tab(text: '瑜伽', icon: SvgIcon(assetName: 'yoga', size: 16)),
              Tab(text: '计划', icon: SvgIcon(assetName: 'favorite', size: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _bottomIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: AppTheme.primary,
      unselectedItemColor: AppTheme.textTertiary,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(icon: SvgIcon(assetName: 'strength', size: 24), label: '训练'),
        BottomNavigationBarItem(icon: SvgIcon(assetName: 'favorite', size: 24), label: '收藏'),
        BottomNavigationBarItem(icon: SvgIcon(assetName: 'history', size: 24), label: '历史'),
      ],
      onTap: (index) => setState(() => _bottomIndex = index),
    );
  }
}

class _SectionTabView extends StatelessWidget {
  final WorkoutSection section;
  const _SectionTabView({required this.section});

  @override
  Widget build(BuildContext context) {
    final repo = SampleExerciseRepository();
    final categories = repo.getCategories(section);
    final theme = Theme.of(context);
    final sectionColors = {
      WorkoutSection.strength: AppTheme.primary,
      WorkoutSection.functional: const Color(0xFF34C759),
      WorkoutSection.yoga: const Color(0xFFAF52DE),
    };
    final color = sectionColors[section] ?? AppTheme.primary;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(width: 4, height: 20, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 10),
                Text(_sectionName(section), style: theme.textTheme.headlineSmall),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
                  child: Text('搜索', style: theme.textTheme.labelSmall?.copyWith(color: color)),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final cat = categories[index];
              final count = _countExercises(repo, cat);
              if (count == 0) return null;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ModernCategoryCard(
                  icon: cat.svgIcon,
                  name: cat.name,
                  exerciseCount: count,
                  color: color,
                  onTap: () {
                    if (cat.subCategories.isEmpty) {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => ExerciseListScreen(category: cat, parentCategory: cat, section: section),
                      ));
                    } else {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => CategoryScreen(category: cat, section: section),
                      ));
                    }
                  },
                ),
              );
            }, childCount: categories.length),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  String _sectionName(WorkoutSection s) {
    switch (s) {
      case WorkoutSection.strength: return '力量训练';
      case WorkoutSection.functional: return '功能训练';
      case WorkoutSection.yoga: return '瑜伽训练';
    }
  }

  int _countExercises(SampleExerciseRepository repo, TrainingCategory cat) {
    int count = 0;
    if (cat.subCategories.isNotEmpty) {
      for (final sub in cat.subCategories) {
        count += repo.getExercises(sub.id).length;
      }
    } else {
      count = repo.getExercises(cat.id).length;
    }
    return count;
  }
}

class _ModernCategoryCard extends StatelessWidget {
  final String icon;
  final String name;
  final int exerciseCount;
  final Color color;
  final VoidCallback onTap;

  const _ModernCategoryCard({
    required this.icon, required this.name, required this.exerciseCount,
    required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SvgIcon(assetName: icon, size: 26, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 3),
                    Text('$exerciseCount 个动作', style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Text('$exerciseCount', style: theme.textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, size: 18, color: AppTheme.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

