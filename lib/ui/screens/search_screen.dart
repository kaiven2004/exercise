import 'package:excise/app/app_scope.dart';
import 'package:excise/app/theme.dart';
import 'package:excise/data/exercises/exercise_meta.dart';
import 'package:excise/data/exercise_query.dart';
import 'package:excise/data/models/models.dart';
import 'package:excise/data/models/workout_models.dart';
import 'package:excise/data/repositories/sample_repository.dart';
import 'package:excise/ui/screens/exercise_detail_screen.dart';
import 'package:excise/ui/widgets/exercise_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

/// 动作库搜索：关键词 + 部位 / 器械 / 难度 / 收藏筛选，支持拼音首字母。
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  late final SampleExerciseRepository _repo;
  late final List<Exercise> _all;

  ExerciseQuery _query = const ExerciseQuery();
  Set<String> _favoriteIds = <String>{};
  Map<String, LastPerformance> _lastPerformances = const {};
  Map<String, int> _usageCounts = const {};
  bool _loadedHistory = false;

  static const _hotSearches = ['卧推', '深蹲', '硬拉', '引体向上', '侧平举', '卷腹'];

  @override
  void initState() {
    super.initState();
    _repo = SampleExerciseRepository();
    _all = _repo.getExercises('all');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadedHistory) return;
    _loadedHistory = true;
    final services = AppScope.maybeOf(context);
    if (services == null) return;
    _favoriteIds = services.favorites
        .getFavorites(_all)
        .map((e) => e.id)
        .toSet();
    _lastPerformances = services.workouts.getLastPerformances();
    _usageCounts = exerciseUsageCounts(services.workouts.getSessions());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Exercise> get _results => queryExercises(
        all: _all,
        query: _query,
        favoriteIds: _favoriteIds,
        lastPerformances: _lastPerformances,
        usageCounts: _usageCounts,
      );

  void _update(ExerciseQuery next) {
    setState(() => _query = next);
  }

  void _setHotSearch(String text) {
    _controller.text = text;
    _controller.selection = TextSelection.collapsed(offset: text.length);
    _update(_query.copyWith(query: text));
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    return Scaffold(
      backgroundColor: AppTheme.bgMain,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        title: const Text('搜索动作', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _controller,
              autofocus: false,
              textInputAction: TextInputAction.search,
              onChanged: (value) => _update(_query.copyWith(query: value)),
              decoration: InputDecoration(
                hintText: '搜索名称、部位、要领，或拼音首字母',
                prefixIcon: const Icon(Icons.search, size: 19, color: AppTheme.textTertiary),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close, size: 17, color: AppTheme.textTertiary),
                        onPressed: () {
                          _controller.clear();
                          _update(_query.copyWith(query: ''));
                        },
                      ),
              ),
            ),
          ),
          _muscleBar(),
          _controlBar(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
            child: Row(
              children: [
                Text(
                  '${results.length} 个动作',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                ),
                if (_query.isFiltering) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      _controller.clear();
                      _update(const ExerciseQuery());
                    },
                    child: const Text('清除筛选', style: TextStyle(fontSize: 12, color: AppTheme.primary)),
                  ),
                ],
                const Spacer(),
                if (!_query.isFiltering && results.isNotEmpty)
                  const Text('点击查看动作详情', style: TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
              ],
            ),
          ),
          if (!_query.isFiltering)
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _hotSearches.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final text = _hotSearches[index];
                  return ActionChip(
                    label: Text(text, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: AppTheme.divider.withValues(alpha: 0.6)),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _setHotSearch(text),
                  );
                },
              ),
            ),
          const SizedBox(height: 6),
          Expanded(
            child: results.isEmpty
                ? _emptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: results.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final exercise = results[index];
                      return _SearchResultCard(
                        exercise: exercise,
                        isFavorite: _favoriteIds.contains(exercise.id),
                        last: _lastPerformances[exercise.id],
                        usageCount: _usageCounts[exercise.id] ?? 0,
                        onTap: () async {
                          final services = AppScope.maybeOf(context);
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ExerciseDetailScreen(exercise: exercise),
                            ),
                          );
                          if (!mounted || services == null) return;
                          setState(() {
                            _favoriteIds = services.favorites
                                .getFavorites(_all)
                                .map((e) => e.id)
                                .toSet();
                          });
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _muscleBar() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: kSearchMuscles.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final muscle = index == 0 ? null : kSearchMuscles[index - 1];
          final active = _query.muscle == muscle;
          return ChoiceChip(
            label: Text(muscle ?? '全部'),
            selected: active,
            onSelected: (_) => _update(
              muscle == null
                  ? _query.copyWith(clearMuscle: true)
                  : _query.copyWith(muscle: muscle),
            ),
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              color: active ? Colors.white : AppTheme.textSecondary,
            ),
            selectedColor: AppTheme.primary,
            backgroundColor: Colors.white,
            side: BorderSide(color: active ? AppTheme.primary : AppTheme.divider.withValues(alpha: 0.5)),
            visualDensity: VisualDensity.compact,
            showCheckmark: false,
          );
        },
      ),
    );
  }

  Widget _controlBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: _menuButton<String>(
              value: _query.equipment?.name ?? 'all',
              label: _query.equipment?.label ?? '器械',
              active: _query.equipment != null,
              items: [
                const PopupMenuItem<String>(value: 'all', child: Text('全部器械')),
                for (final equipment in Equipment.values)
                  PopupMenuItem<String>(value: equipment.name, child: Text(equipment.label)),
              ],
              onSelected: (value) => _update(
                value == 'all'
                    ? _query.copyWith(clearEquipment: true)
                    : _query.copyWith(
                        equipment: Equipment.values.firstWhere((e) => e.name == value),
                      ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _menuButton<String>(
              value: _query.difficulty ?? 'all',
              label: _query.difficulty ?? '难度',
              active: _query.difficulty != null,
              items: [
                const PopupMenuItem<String>(value: 'all', child: Text('全部难度')),
                for (final difficulty in kSearchDifficulties)
                  PopupMenuItem<String>(value: difficulty, child: Text(difficulty)),
              ],
              onSelected: (value) => _update(
                value == 'all'
                    ? _query.copyWith(clearDifficulty: true)
                    : _query.copyWith(difficulty: value),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _menuButton<ExerciseSort>(
              value: _query.sort,
              label: _query.sort.label,
              active: _query.sort != ExerciseSort.recommended,
              items: [
                for (final sort in ExerciseSort.values)
                  PopupMenuItem<ExerciseSort>(value: sort, child: Text(sort.label)),
              ],
              onSelected: (value) => _update(_query.copyWith(sort: value)),
            ),
          ),
          const SizedBox(width: 6),
          _favoriteButton(),
        ],
      ),
    );
  }

  Widget _menuButton<T>({
    required T value,
    required String label,
    required bool active,
    required List<PopupMenuEntry<T>> items,
    required ValueChanged<T> onSelected,
  }) {
    return PopupMenuButton<T>(
      itemBuilder: (context) => items,
      onSelected: onSelected,
      tooltip: label,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 9),
        decoration: BoxDecoration(
          color: active ? AppTheme.primary.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: active ? AppTheme.primary.withValues(alpha: 0.45) : AppTheme.divider.withValues(alpha: 0.55),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  color: active ? AppTheme.primary : AppTheme.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.expand_more_rounded,
              size: 15,
              color: active ? AppTheme.primary : AppTheme.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _favoriteButton() {
    final active = _query.favoritesOnly;
    return Tooltip(
      message: '只看收藏',
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: () => _update(_query.copyWith(favoritesOnly: !active)),
        child: Container(
          width: 36,
          height: 34,
          decoration: BoxDecoration(
            color: active ? AppTheme.accentRed.withValues(alpha: 0.1) : Colors.white,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: active ? AppTheme.accentRed.withValues(alpha: 0.5) : AppTheme.divider.withValues(alpha: 0.55),
            ),
          ),
          child: Icon(
            active ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: 18,
            color: active ? AppTheme.accentRed : AppTheme.textTertiary,
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off_rounded, size: 44, color: AppTheme.textTertiary),
          const SizedBox(height: 10),
          Text(
            _query.favoritesOnly ? '还没有符合条件的收藏动作' : '未找到相关动作',
            style: const TextStyle(fontSize: 13, color: AppTheme.textTertiary),
          ),
          if (_query.isFiltering) ...[
            const SizedBox(height: 6),
            TextButton(
              onPressed: () {
                _controller.clear();
                _update(const ExerciseQuery());
              },
              child: const Text('清除筛选条件'),
            ),
          ],
        ],
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final Exercise exercise;
  final bool isFavorite;
  final LastPerformance? last;
  final int usageCount;
  final VoidCallback onTap;

  const _SearchResultCard({
    required this.exercise,
    required this.isFavorite,
    required this.last,
    required this.usageCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final meta = metaFor(exercise);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: AppTheme.divider.withValues(alpha: 0.45)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 54,
                  height: 54,
                  child: ExerciseImage(exercise: exercise, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            exercise.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                          ),
                        ),
                        if (isFavorite)
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(Icons.favorite_rounded, size: 13, color: AppTheme.accentRed),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _tag(meta.primaryMuscle, AppTheme.primary),
                        _tag(meta.equipment.label, AppTheme.textSecondary),
                        if (meta.compound) _tag('复合', AppTheme.accent),
                        if (exercise.difficulty.isNotEmpty) _tag(exercise.difficulty, AppTheme.textTertiary),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _subtitle(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, size: 18, color: AppTheme.textTertiary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500)),
    );
  }

  String _subtitle() {
    if (last != null) {
      return '上次 ${DateFormat('M月d日').format(last!.date)} · ${last!.label}';
    }
    if (usageCount > 0) return '练过 $usageCount 次';
    return exercise.categoryPath;
  }
}
