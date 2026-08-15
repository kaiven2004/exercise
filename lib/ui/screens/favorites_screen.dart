import 'package:excise/data/models/models.dart';
import 'package:excise/data/repositories/custom_plan_repository.dart';
import 'package:excise/data/repositories/local_repositories.dart';
import 'package:excise/data/repositories/sample_repository.dart';
import 'package:excise/ui/screens/exercise_detail_screen.dart';
import 'package:excise/ui/widgets/svg_icons.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Exercise> _favorites = [];
  bool _loading = true;
  Set<String> _selectedIds = {};
  bool _multiSelectMode = false;
  late final SampleExerciseRepository _repo;
  late final LocalCustomPlanRepository _planRepo;
  List<CustomPlan> _plans = [];
  static const _key = 'favorites';

  @override
  void initState() {
    super.initState();
    _repo = SampleExerciseRepository();
    _planRepo = LocalCustomPlanRepository();
    _loadFavorites();
    _loadPlans();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_key) ?? [];
    final all = _repo.getExercises('all');
    setState(() {
      _favorites = all.where((e) => ids.contains(e.id)).toList();
      _loading = false;
    });
  }

  Future<void> _loadPlans() async {
    await _planRepo.init();
    setState(() => _plans = _planRepo.getPlans());
  }

  Future<void> _toggleFavorite(Exercise ex) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_key) ?? [];
    if (ids.contains(ex.id)) { ids.remove(ex.id); } else { ids.add(ex.id); }
    await prefs.setStringList(_key, ids);
    if (mounted) _loadFavorites();
  }

  void _startMultiSelect() { setState(() => _multiSelectMode = true); }
  void _finishMultiSelect() { setState(() { _multiSelectMode = false; _selectedIds.clear(); }); }
  void _toggleSelect(Exercise ex) {
    setState(() {
      if (_selectedIds.contains(ex.id)) { _selectedIds.remove(ex.id); }
      else { _selectedIds.add(ex.id); }
    });
  }

  void _addSelectedToPlan() {
    if (_selectedIds.isEmpty) return;
    if (mounted) _showAddToPlanDialog(_selectedIds.toSet());
  }

  Future<void> _addToPlan(Exercise ex) async {
    if (mounted) _showAddToPlanDialog({ex.id});
  }

  Future<void> _showAddToPlanDialog(Set<String> ids) async {
    final selectedExs = _favorites.where((e) => ids.contains(e.id)).toList();
    if (!mounted) return;
    final plan = await showModalBottomSheet<CustomPlan>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (ctx) => _PlanSelector(planList: _plans, exercises: selectedExs),
    );
    if (plan != null && mounted) {
      await _planRepo.init();
      await _planRepo.savePlan(plan);
      await _loadPlans();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(
          '\u5DF2\u6DFB\u52A0 ${plan.exercises.length} \u4E2A\u52A8\u4F5C\u5230\u8BA1\u5212\u300C${plan.name}\u300D',
        )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: _multiSelectMode
            ? Text('\u5DF2\u9009\u62E9 ${_selectedIds.length}')
            : const Text('\u6211\u7684\u6536\u85CF'),
        leading: _multiSelectMode
            ? IconButton(icon: const Icon(Icons.close), onPressed: _finishMultiSelect)
            : IconButton(
                icon: const SvgIcon(assetName: 'arrow_right', size: 20),
                onPressed: () => Navigator.pop(context),
              ),
        actions: _favorites.isNotEmpty
            ? [
                _multiSelectMode
                    ? IconButton(icon: const Icon(Icons.check), onPressed: _addSelectedToPlan)
                    : IconButton(icon: const Icon(Icons.checklist), onPressed: _startMultiSelect),
              ]
            : null,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SvgIcon(assetName: 'favorite', size: 64),
                  const SizedBox(height: 16),
                  Text('\u8FD8\u6CA1\u6709\u6536\u85CF\u7684\u52A8\u4F5C', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('\u5728\u52A8\u4F5C\u8BE6\u60C5\u9875\u70B9\u51FB\u7231\u5FC3\u56FE\u6807\u5373\u53EF\u6536\u85CF', style: theme.textTheme.bodySmall),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _favorites.length,
              itemBuilder: (context, index) {
                final ex = _favorites[index];
                final isSelected = _selectedIds.contains(ex.id);
                return _FavoriteCard(
                  exercise: ex,
                  isSelected: _multiSelectMode ? isSelected : null,
                  isMultiSelect: _multiSelectMode,
                  onTap: () {
                    if (_multiSelectMode) { _toggleSelect(ex); }
                    else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ExerciseDetailScreen(exercise: ex)),
                      );
                    }
                  },
                  onRemove: () => _toggleFavorite(ex),
                  onAddToPlan: () => _addToPlan(ex),
                  onSelect: () => _toggleSelect(ex),
                );
              },
            ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final Exercise exercise;
  final bool? isSelected;
  final bool isMultiSelect;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final VoidCallback onAddToPlan;
  final VoidCallback onSelect;
  const _FavoriteCard({
    required this.exercise,
    this.isSelected,
    this.isMultiSelect = false,
    required this.onTap,
    required this.onRemove,
    required this.onAddToPlan,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (isMultiSelect)
                Checkbox(
                  value: isSelected,
                  onChanged: (v) => onSelect(),
                )
              else
                const SizedBox(width: 24),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SvgIcon(
                  assetName: exercise.imageSvg,
                  size: 28,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${exercise.categoryPath}  ${exercise.sets}\u7EC4 x ${exercise.reps}\u6B21',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              if (!isMultiSelect)
                IconButton(
                  icon: const SvgIcon(assetName: 'history', size: 18),
                  onPressed: onAddToPlan,
                ),
              IconButton(
                icon: SvgIcon(assetName: 'favorite_filled', size: 20, color: const Color(0xFFE53935)),
                onPressed: onRemove,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanSelector extends StatefulWidget {
  final List<CustomPlan> planList;
  final List<Exercise> exercises;
  const _PlanSelector({required this.planList, required this.exercises});

  @override
  State<_PlanSelector> createState() => _PlanSelectorState();
}

class _PlanSelectorState extends State<_PlanSelector> {
  String _selectedPlanId = '';
  final TextEditingController _newNameCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('\u9009\u62E9\u6216\u65B0\u5EFA\u8BA1\u5212', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (widget.planList.isNotEmpty) ...[
              Text('\u5DF2\u6709\u8BA1\u5212\uFF1A', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              ...widget.planList.map((p) => RadioListTile<String>(
                title: Text(p.name),
                subtitle: Text('${p.exercises.length} \u4E2A\u52A8\u4F5C'),
                value: p.id,
                groupValue: _selectedPlanId,
                onChanged: (v) => setState(() => _selectedPlanId = v!),
              )),
              const SizedBox(height: 8),
            ],
            const Divider(),
            const SizedBox(height: 8),
            Text('\u6216\u65B0\u5EFA\u8BA1\u5212\uFF1A', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _newNameCtrl,
              decoration: const InputDecoration(
                hintText: '\u8F93\u5165\u8BA1\u5212\u540D\u79F0',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final newName = _newNameCtrl.text.trim();
                  final planId = _selectedPlanId.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : _selectedPlanId;
                  final isExisting = _selectedPlanId.isNotEmpty;
                  CustomPlan plan;
                  if (isExisting) {
                    plan = widget.planList.firstWhere((p) => p.id == _selectedPlanId);
                    final existingIds = plan.exercises.map((e) => e.exercise.id).toSet();
                    final newItems = widget.exercises
                        .where((e) => !existingIds.contains(e.id))
                        .map((e) => CustomExerciseItem(exercise: e, order: plan.exercises.length))
                        .toList();
                    plan = plan.copyWith(exercises: [...plan.exercises, ...newItems]);
                  } else {
                    plan = CustomPlan(
                      id: planId,
                      name: newName.isEmpty ? '\u65B0\u8BA1\u5212' : newName,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                      exercises: widget.exercises.map((e) => CustomExerciseItem(exercise: e, order: 0)).toList(),
                    );
                  }
                  Navigator.pop(context, plan);
                },
                style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('\u6DFB\u52A0\u5230\u8BA1\u5212', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}