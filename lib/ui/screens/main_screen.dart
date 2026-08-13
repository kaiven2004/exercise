import 'package:excise/data/models/models.dart';
import 'package:excise/data/repositories/sample_repository.dart';
import 'package:excise/ui/widgets/svg_icons.dart';
import 'package:excise/ui/screens/category_screen.dart';
import 'package:excise/ui/screens/search_screen.dart';
import 'package:excise/ui/screens/favorites_screen.dart';
import 'package:excise/ui/screens/history_screen.dart';
import 'package:excise/ui/screens/custom_plan_list_screen.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    final theme = Theme.of(context);
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 170,
            floating: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            foregroundColor: theme.colorScheme.onSurface,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'EXCISE',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
              titlePadding: const EdgeInsets.only(left: 16, bottom: 50),
            ),
            actions: [
              IconButton(
                icon: const SvgIcon(assetName: 'search', size: 22),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
              ),
              IconButton(
                icon: const SvgIcon(assetName: 'history', size: 22),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: theme.colorScheme.primary,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
              isScrollable: true,
              tabs: const [
                Tab(text: '力量训练', icon: SvgIcon(assetName: 'strength', size: 20)),
                Tab(text: '功能训练', icon: SvgIcon(assetName: 'functional', size: 20)),
                Tab(text: '瑜伽训练', icon: SvgIcon(assetName: 'yoga', size: 20)),
                Tab(text: '自定义', icon: SvgIcon(assetName: 'favorite', size: 20)),
              ],
            ),
          ),
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
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: SvgIcon(assetName: 'strength', size: 22), label: '训练'),
          BottomNavigationBarItem(icon: SvgIcon(assetName: 'favorite', size: 22), label: '收藏'),
          BottomNavigationBarItem(icon: SvgIcon(assetName: 'history', size: 22), label: '历史'),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
          }
        },
      ),
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
      WorkoutSection.strength: theme.colorScheme.primary,
      WorkoutSection.functional: const Color(0xFF0277BD),
      WorkoutSection.yoga: const Color(0xFF6A1B9A),
    };
    final color = sectionColors[section] ?? theme.colorScheme.primary;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Container(width: 4, height: 24, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 10),
              Text(_sectionName(section), style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        ...categories.map((cat) {
          final count = _countExercises(repo, cat);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: CategoryCard(
              icon: cat.svgIcon,
              name: cat.name,
              exerciseCount: count,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryScreen(category: cat, section: section))),
            ),
          );
        }),
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
    for (final sub in cat.subCategories) {
      count += repo.getExercises(sub.id).length;
    }
    return count;
  }
}
