import 'package:excise/app/app_scope.dart';
import 'package:excise/app/theme.dart';
import 'package:excise/data/exercise_query.dart';
import 'package:excise/data/models/models.dart';
import 'package:excise/data/models/workout_models.dart';
import 'package:excise/data/repositories/sample_repository.dart';
import 'package:excise/ui/screens/exercise_detail_screen.dart';
import 'package:excise/ui/widgets/exercise_filter_controls.dart';
import 'package:excise/ui/widgets/exercise_result_card.dart';
import 'package:flutter/material.dart';

/// 分类动作列表。
///
/// 父分类（如「胸部训练」）默认列出全部子分类动作，
/// 子分类 Chip 只做筛选，不再跳转。
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
  late final List<Exercise> _allUnderCategory;
  final TextEditingController _searchController = TextEditingController();

  ExerciseQuery _query = const ExerciseQuery();
  String? _subCategoryId;
  Set<String> _favoriteIds = <String>{};
  Map<String, LastPerformance> _lastPerformances = const {};
  Map<String, int> _usageCounts = const {};
  bool _loadedUserData = false;

  @override
  void initState() {
    super.initState();
    _repo = SampleExerciseRepository();
    _allUnderCategory = exercisesUnderCategory(_repo.getExercises('all'), widget.category);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadedUserData) return;
    _loadedUserData = true;
    _loadUserData(notify: false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  TrainingCategory? get _selectedSubCategory {
    final id = _subCategoryId;
    if (id == null) return null;
    for (final sub in widget.category.subCategories) {
      if (sub.id == id) return sub;
    }
    return null;
  }

  List<Exercise> get _visibleExercises {
    final sub = _selectedSubCategory;
    final scoped = sub == null
        ? _allUnderCategory
        : exercisesUnderCategory(_allUnderCategory, sub);
    return queryExercises(
      all: scoped,
      query: _query,
      favoriteIds: _favoriteIds,
      lastPerformances: _lastPerformances,
      usageCounts: _usageCounts,
    );
  }

  void _loadUserData({bool notify = true}) {
    final services = AppScope.maybeOf(context);
    if (services == null) return;
    void apply() {
      _favoriteIds = services.favorites
          .getFavorites(_allUnderCategory)
          .map((e) => e.id)
          .toSet();
      _lastPerformances = services.workouts.getLastPerformances();
      _usageCounts = exerciseUsageCounts(services.workouts.getSessions());
    }

    if (notify) {
      setState(apply);
    } else {
      apply();
    }
  }

  void _update(ExerciseQuery next) {
    setState(() => _query = next);
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _query = const ExerciseQuery();
      _subCategoryId = null;
    });
  }

  Future<void> _openDetail(Exercise exercise) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ExerciseDetailScreen(exercise: exercise)),
    );
    if (!mounted) return;
    // 详情页可能改了收藏，回来刷新一下。
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    final results = _visibleExercises;
    return Scaffold(
      backgroundColor: AppTheme.bgMain,
      body: CustomScrollView(
        slivers: [
          _appBar(),
          SliverToBoxAdapter(child: _filterHeader()),
          SliverToBoxAdapter(child: _countRow(results.length)),
          if (results.isEmpty)
            SliverFillRemaining(hasScrollBody: false, child: _emptyState())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final exercise = results[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ExerciseResultCard(
                        exercise: exercise,
                        isFavorite: _favoriteIds.contains(exercise.id),
                        last: _lastPerformances[exercise.id],
                        usageCount: _usageCounts[exercise.id] ?? 0,
                        onTap: () => _openDetail(exercise),
                      ),
                    );
                  },
                  childCount: results.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _appBar() {
    final favoriteActive = _query.favoritesOnly;
    return SliverAppBar(
      expandedHeight: 108,
      pinned: true,
      backgroundColor: Colors.white,
      foregroundColor: AppTheme.textPrimary,
      leading: IconButton(
        icon: const Icon(Icons.chevron_left, size: 28),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          tooltip: '只看收藏',
          icon: Icon(
            favoriteActive ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: 22,
            color: favoriteActive ? AppTheme.accentRed : AppTheme.textSecondary,
          ),
          onPressed: () => _update(_query.copyWith(favoritesOnly: !favoriteActive)),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.category.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            Text(
              _buildPath(),
              style: const TextStyle(fontSize: 12, color: AppTheme.textTertiary),
            ),
          ],
        ),
        titlePadding: const EdgeInsets.only(left: 16, bottom: 10, right: 16),
      ),
    );
  }

  Widget _filterHeader() {
    final subCategories = widget.category.subCategories;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onChanged: (value) => _update(_query.copyWith(query: value)),
              decoration: InputDecoration(
                hintText: '搜索名称、部位、要领，或拼音首字母',
                prefixIcon: const Icon(Icons.search, size: 19, color: AppTheme.textTertiary),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close, size: 17, color: AppTheme.textTertiary),
                        onPressed: () {
                          _searchController.clear();
                          _update(_query.copyWith(query: ''));
                        },
                      ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                filled: true,
                fillColor: AppTheme.bgGrouped,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                isDense: true,
              ),
            ),
          ),
          if (subCategories.isNotEmpty)
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: subCategories.length + 1,
                separatorBuilder: (_, _) => const SizedBox(width: 6),
                itemBuilder: (context, index) {
                  final sub = index == 0 ? null : subCategories[index - 1];
                  final active = _subCategoryId == sub?.id;
                  return ChoiceChip(
                    label: Text(sub?.name ?? '全部'),
                    selected: active,
                    onSelected: (_) => setState(() => _subCategoryId = sub?.id),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      color: active ? Colors.white : AppTheme.textSecondary,
                    ),
                    selectedColor: AppTheme.primary,
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: active ? AppTheme.primary : AppTheme.divider.withValues(alpha: 0.5),
                    ),
                    visualDensity: VisualDensity.compact,
                    showCheckmark: false,
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: ExerciseFilterControls(query: _query, onChanged: _update),
          ),
        ],
      ),
    );
  }

  Widget _countRow(int count) {
    final filtering = _query.isFiltering || _subCategoryId != null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Text(
            '$count 个动作',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
          ),
          if (filtering) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _clearFilters,
              child: const Text('清除筛选', style: TextStyle(fontSize: 12, color: AppTheme.primary)),
            ),
          ],
          const Spacer(),
          if (count > 0)
            const Text('点击查看详情', style: TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
        ],
      ),
    );
  }

  Widget _emptyState() {
    final filtering = _query.isFiltering || _subCategoryId != null;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 44, color: AppTheme.textTertiary),
            const SizedBox(height: 10),
            Text(
              _query.favoritesOnly ? '还没有符合条件的收藏动作' : '没有符合条件的动作',
              style: const TextStyle(fontSize: 13, color: AppTheme.textTertiary),
            ),
            if (filtering) ...[
              const SizedBox(height: 6),
              TextButton(onPressed: _clearFilters, child: const Text('清除筛选条件')),
            ],
          ],
        ),
      ),
    );
  }

  String _buildPath() {
    final parts = <String>[];
    if (widget.parentCategory.id != widget.category.id) {
      parts.add(widget.parentCategory.name);
    }
    parts.add(widget.category.name);
    final sub = _selectedSubCategory;
    if (sub != null) parts.add(sub.name);
    return parts.join(' / ');
  }
}
