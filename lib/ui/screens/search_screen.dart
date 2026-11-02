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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: ExerciseFilterControls(query: _query, onChanged: _update),
          ),
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
                      return ExerciseResultCard(
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
