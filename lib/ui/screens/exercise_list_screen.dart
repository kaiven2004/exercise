import 'package:excise/data/models/models.dart';
import 'package:excise/data/repositories/exercise_override_repository.dart';
import 'package:excise/data/repositories/sample_repository.dart';
import 'package:excise/ui/screens/exercise_detail_screen.dart';
import 'package:excise/ui/widgets/exercise_image.dart';
import 'package:excise/ui/widgets/svg_icons.dart';
import 'package:excise/app/theme.dart';
import 'package:flutter/material.dart';

class ExerciseListScreen extends StatefulWidget {
  final TrainingCategory category;
  final TrainingCategory parentCategory;
  final WorkoutSection section;

  const ExerciseListScreen({
    super.key,
    required this.category,
    required this.parentCategory,
    required this.section,
  });

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  late final SampleExerciseRepository _repo;
  late final ExerciseOverrideRepository _overrideRepo;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _repo = SampleExerciseRepository();
    _overrideRepo = ExerciseOverrideRepository();
    _overrideRepo.init();
  }

  List<Exercise> get _filteredExercises {
    var exercises = _repo.getExercises(widget.category.id);
    if (_searchQuery.isNotEmpty) {
      exercises = exercises.where((e) =>
        e.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        e.categoryPath.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    return exercises;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subCategories = widget.category.subCategories;
    final path = _buildPath();
    final sectionColors = {
      WorkoutSection.strength: AppTheme.primary,
      WorkoutSection.functional: const Color(0xFF34C759),
      WorkoutSection.yoga: const Color(0xFFAF52DE),
    };
    final color = sectionColors[widget.section] ?? AppTheme.primary;

    return Scaffold(
      backgroundColor: AppTheme.bgMain,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 110,
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: AppTheme.textPrimary,
            flexibleSpace: FlexibleSpaceBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.category.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  Text(path, style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textTertiary)),
                ],
              ),
              titlePadding: const EdgeInsets.only(left: 16, bottom: 8),
            ),
            leading: IconButton(
              icon: const Icon(Icons.chevron_left, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.favorite_border, size: 22), onPressed: () {}),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(52),
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: subCategories.isNotEmpty
                      ? SizedBox(
                          height: 36,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _FilterChip(label: '全部', isSelected: true, color: color, onTap: () {}),
                              ...subCategories.map((sub) => Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: _FilterChip(label: sub.name, isSelected: false, color: color, onTap: () {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (_) => ExerciseListScreen(category: sub, parentCategory: widget.category, section: widget.section),
                                  ));
                                }),
                              )),
                            ],
                          ),
                        )
                      : TextField(
                          decoration: InputDecoration(
                            hintText: '搜索 ${widget.category.name} 动作...',
                            prefixIcon: const Icon(Icons.search, size: 18, color: AppTheme.textTertiary),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () => setState(() => _searchQuery = ''))
                                : null,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                            filled: true,
                            fillColor: AppTheme.bgGrouped,
                            contentPadding: const EdgeInsets.symmetric(vertical: 0),
                            isDense: true,
                          ),
                          onChanged: (v) => setState(() => _searchQuery = v),
                        ),
                ),
              ),
            ),
          ),
          if (subCategories.isEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final ex = _filteredExercises[index];
                  return _ModernExerciseCard(
                    exercise: ex,
                    overrideRepo: _overrideRepo,
                    color: color,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ExerciseDetailScreen(exercise: ex))),
                  );
                }, childCount: _filteredExercises.length),
              ),
            )
          else
            SliverToBoxAdapter(
              child: _filteredExercises.isEmpty
                  ? _EmptyState(category: widget.category)
                  : const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }

  String _buildPath() {
    final parts = <String>[];
    if (widget.parentCategory.id != widget.category.id) parts.add(widget.parentCategory.name);
    parts.add(widget.category.name);
    return parts.join(' / ');
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.isSelected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? color : AppTheme.bgGrouped,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, color: isSelected ? Colors.white : AppTheme.textSecondary)),
      ),
    );
  }
}

class _ModernExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final ExerciseOverrideRepository overrideRepo;
  final Color color;
  final VoidCallback onTap;
  const _ModernExerciseCard({required this.exercise, required this.overrideRepo, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sets = overrideRepo.getEffectiveSets(exercise.id, exercise.sets);
    final reps = overrideRepo.getEffectiveReps(exercise.id, exercise.reps);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: ExerciseImage(exercise: exercise, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(exercise.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _StatBadge(label: '$sets组', color: color),
                          const SizedBox(width: 6),
                          _StatBadge(label: '$reps次', color: color),
                          if (overrideRepo.getOverrideWeight(exercise.id) != null && overrideRepo.getOverrideWeight(exercise.id) != '0') ...[
                            const SizedBox(width: 6),
                            _StatBadge(label: '${overrideRepo.getOverrideWeight(exercise.id)}kg', color: color),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, size: 18, color: AppTheme.textTertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatBadge({required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final TrainingCategory category;
  const _EmptyState({required this.category});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgIcon(assetName: 'exercise_default', size: 64, color: AppTheme.textTertiary),
            const SizedBox(height: 16),
            Text('暂无动作数据', style: theme.textTheme.titleMedium?.copyWith(color: AppTheme.textTertiary)),
            const SizedBox(height: 8),
            Text('${category.name} 的动作数据将在后续更新', style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}


