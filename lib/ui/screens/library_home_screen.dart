import 'package:excise/app/theme.dart';
import 'package:excise/data/models/models.dart';
import 'package:excise/data/repositories/sample_repository.dart';
import 'package:excise/ui/screens/category_screen.dart';
import 'package:excise/ui/screens/exercise_list_screen.dart';
import 'package:excise/ui/screens/favorites_screen.dart';
import 'package:excise/ui/screens/search_screen.dart';
import 'package:excise/ui/widgets/svg_icons.dart';
import 'package:flutter/material.dart';

/// 动作库首页：力量 / 功能 / 瑜伽三个分类入口。
class LibraryHomeScreen extends StatefulWidget {
  const LibraryHomeScreen({super.key});

  @override
  State<LibraryHomeScreen> createState() => _LibraryHomeScreenState();
}

class _LibraryHomeScreenState extends State<LibraryHomeScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 3, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgMain,
      appBar: AppBar(
        title: const Text('动作库'),
        actions: [
          IconButton(
            icon: const SvgIcon(assetName: 'favorite', size: 21),
            tooltip: '收藏',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavoritesScreen()),
            ),
          ),
          IconButton(
            icon: const SvgIcon(assetName: 'search', size: 21),
            tooltip: '搜索',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          indicatorWeight: 2,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textTertiary,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 13),
          tabs: const [
            Tab(text: '力量', icon: SvgIcon(assetName: 'strength', size: 16)),
            Tab(text: '功能', icon: SvgIcon(assetName: 'functional', size: 16)),
            Tab(text: '瑜伽', icon: SvgIcon(assetName: 'yoga', size: 16)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _SectionTabView(section: WorkoutSection.strength),
          _SectionTabView(section: WorkoutSection.functional),
          _SectionTabView(section: WorkoutSection.yoga),
        ],
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
      WorkoutSection.strength: AppTheme.primary,
      WorkoutSection.functional: AppTheme.accent,
      WorkoutSection.yoga: AppTheme.accentPurple,
    };
    final color = sectionColors[section] ?? AppTheme.primary;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Row(
          children: [
            Container(width: 4, height: 20, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 10),
            Text(_sectionName(section), style: theme.textTheme.headlineSmall),
            const Spacer(),
            Text('${_totalCount(repo, categories)} 个动作', style: theme.textTheme.labelSmall),
          ],
        ),
        const SizedBox(height: 14),
        for (final cat in categories) ...[
          _CategoryCard(
            icon: cat.svgIcon,
            name: cat.name,
            exerciseCount: _countExercises(repo, cat),
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
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  String _sectionName(WorkoutSection s) {
    switch (s) {
      case WorkoutSection.strength:
        return '力量训练';
      case WorkoutSection.functional:
        return '功能训练';
      case WorkoutSection.yoga:
        return '瑜伽训练';
    }
  }

  int _totalCount(SampleExerciseRepository repo, List<TrainingCategory> categories) {
    return categories.fold(0, (sum, cat) => sum + _countExercises(repo, cat));
  }

  int _countExercises(SampleExerciseRepository repo, TrainingCategory cat) {
    if (cat.subCategories.isNotEmpty) {
      return cat.subCategories.fold(0, (sum, sub) => sum + repo.getExercises(sub.id).length);
    }
    return repo.getExercises(cat.id).length;
  }
}

class _CategoryCard extends StatelessWidget {
  final String icon;
  final String name;
  final int exerciseCount;
  final Color color;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.icon,
    required this.name,
    required this.exerciseCount,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.divider.withValues(alpha: 0.45)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: SvgIcon(assetName: icon, size: 25, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 3),
                    Text('$exerciseCount 个动作', style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 19, color: AppTheme.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
