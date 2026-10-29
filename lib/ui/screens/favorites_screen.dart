import 'package:excise/data/models/models.dart';
import 'package:excise/data/repositories/custom_plan_repository.dart';
import 'package:excise/data/repositories/local_repositories.dart';
import 'package:excise/data/repositories/sample_repository.dart';
import 'package:excise/ui/screens/exercise_detail_screen.dart';
import 'package:excise/ui/widgets/exercise_image.dart';
import 'package:excise/app/theme.dart';
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

  void _startMultiSelect() => setState(() => _multiSelectMode = true);
  void _finishMultiSelect() => setState(() { _multiSelectMode = false; _selectedIds.clear(); });
  void _toggleSelect(Exercise ex) => setState(() { if (_selectedIds.contains(ex.id)) _selectedIds.remove(ex.id); else _selectedIds.add(ex.id); });

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
      backgroundColor: Colors.white,
      builder: (ctx) => _PlanSelector(planList: _plans, exercises: selectedExs),
    );
    if (plan != null && mounted) {
      await _planRepo.init();
      await _planRepo.savePlan(plan);
      await _loadPlans();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已添加 ${plan.exercises.length} 个动作到计划「${plan.name}」')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppTheme.bgMain,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        title: Text(_multiSelectMode ? '已选择 ${_selectedIds.length}' : '我的收藏', style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        leading: _multiSelectMode
            ? IconButton(icon: const Icon(Icons.close), onPressed: _finishMultiSelect)
            : IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => Navigator.pop(context)),
        actions: _favorites.isNotEmpty
            ? [
                _multiSelectMode
                    ? IconButton(icon: const Icon(Icons.check), onPressed: _addSelectedToPlan, color: AppTheme.primary)
                    : IconButton(icon: const Icon(Icons.checklist), onPressed: _startMultiSelect, color: AppTheme.textSecondary),
                const SizedBox(width: 8),
              ]
            : null,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
          ? _EmptyView()
          : RefreshIndicator(
              onRefresh: _loadFavorites,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _favorites.length,
                itemBuilder: (context, index) => _FavoriteCard(
                  exercise: _favorites[index],
                  isMultiSelect: _multiSelectMode,
                  isSelected: _selectedIds.contains(_favorites[index].id),
                  onToggleSelect: () => _toggleSelect(_favorites[index]),
                  onRemove: () => _toggleFavorite(_favorites[index]),
                  onAddToPlan: () => _addToPlan(_favorites[index]),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ExerciseDetailScreen(exercise: _favorites[index]))),
                ),
              ),
            ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 72, height: 72, decoration: BoxDecoration(color: AppTheme.bgGrouped, shape: BoxShape.circle),
            child: const Icon(Icons.favorite_border, size: 32, color: AppTheme.textTertiary),
          ),
          const SizedBox(height: 16),
          const Text('还没有收藏的动作', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          Text('在动作详情页点击爱心图标即可收藏', style: const TextStyle(color: AppTheme.textTertiary)),
        ],
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final Exercise exercise;
  final bool isMultiSelect;
  final bool isSelected;
  final VoidCallback onToggleSelect;
  final VoidCallback onRemove;
  final VoidCallback onAddToPlan;
  final VoidCallback onTap;
  const _FavoriteCard({required this.exercise, required this.isMultiSelect, required this.isSelected, required this.onToggleSelect, required this.onRemove, required this.onAddToPlan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: isSelected ? AppTheme.primary : const Color(0xFFE5E5EA), width: isSelected ? 1.5 : 0.5), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Row(
        children: [
          if (isMultiSelect)
            Padding(padding: const EdgeInsets.only(right: 10), child: Checkbox(value: isSelected, onChanged: (_) => onToggleSelect(), activeColor: AppTheme.primary))
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 48,
                height: 48,
                child: ExerciseImage(exercise: exercise, fit: BoxFit.cover),
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(onTap: onTap, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(exercise.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 3),
              Text('${exercise.sets}组 × ${exercise.reps}次${exercise.weight != '0' ? ' · ${exercise.weight}kg' : ''}', style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textTertiary)),
            ])),
          ),
          if (!isMultiSelect) IconButton(icon: const Icon(Icons.play_circle_outline, size: 22), onPressed: onAddToPlan, color: AppTheme.accent),
          IconButton(icon: const Icon(Icons.favorite, size: 18, color: Color(0xFFE53935)), onPressed: onRemove),
        ],
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
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('选择或新建计划', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (widget.planList.isNotEmpty) ...[
            Text('已有计划', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            ...widget.planList.map((p) => RadioListTile<String>(title: Text(p.name), subtitle: Text('${p.exercises.length} 个动作'), value: p.id, groupValue: _selectedPlanId, onChanged: (v) => setState(() => _selectedPlanId = v!))),
            const Divider(),
          ],
          Text('或新建计划', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(controller: _newNameCtrl, decoration: const InputDecoration(hintText: '输入计划名称', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () async {
            final newName = _newNameCtrl.text.trim();
            final planId = _selectedPlanId.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : _selectedPlanId;
            final isExisting = _selectedPlanId.isNotEmpty;
            CustomPlan plan;
            if (isExisting) {
              plan = widget.planList.firstWhere((p) => p.id == _selectedPlanId);
              final existingIds = plan.exercises.map((e) => e.exercise.id).toSet();
              final newItems = widget.exercises.where((e) => !existingIds.contains(e.id)).map((e) => CustomExerciseItem(exercise: e, order: plan.exercises.length)).toList();
              plan = plan.copyWith(exercises: [...plan.exercises, ...newItems]);
            } else {
              plan = CustomPlan(id: planId, name: newName.isEmpty ? '新计划' : newName, createdAt: DateTime.now(), updatedAt: DateTime.now(), exercises: widget.exercises.map((e) => CustomExerciseItem(exercise: e, order: 0)).toList());
            }
            Navigator.pop(context, plan);
          }, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, padding: const EdgeInsets.symmetric(vertical: 14)), child: const Text('添加到计划', style: TextStyle(fontSize: 16)))),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }
}
