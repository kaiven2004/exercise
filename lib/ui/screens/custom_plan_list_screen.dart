import 'package:excise/app/app_scope.dart';
import 'package:excise/data/models/models.dart';
import 'package:excise/data/models/workout_models.dart';
import 'package:excise/data/repositories/custom_plan_repository.dart';
import 'package:excise/ui/screens/custom_plan_editor_screen.dart';
import 'package:excise/ui/screens/workout_runner_screen.dart';
import 'package:excise/ui/widgets/svg_icons.dart';
import 'package:flutter/material.dart';

class CustomPlanListScreen extends StatefulWidget {
  const CustomPlanListScreen({super.key});
  @override
  State<CustomPlanListScreen> createState() => _CustomPlanListScreenState();
}

class _CustomPlanListScreenState extends State<CustomPlanListScreen> {
  late final LocalCustomPlanRepository _repo;
  List<CustomPlan> _plans = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _repo = LocalCustomPlanRepository();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    await _repo.init();
    setState(() {
      _plans = _repo.getPlans();
      _loading = false;
    });
  }

  Future<void> _deletePlan(CustomPlan plan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除计划'),
        content: Text('确定要删除计划「${plan.name}」吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('删除', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _repo.deletePlan(plan.id);
      _loadPlans();
    }
  }

  Future<void> _startPlan(CustomPlan plan) async {
    final services = AppScope.of(context);
    final exercises = <WorkoutExercise>[];
    for (final item in plan.exercises) {
      final configs = item.setConfigs;
      final List<WorkoutSet> sets;
      if (configs != null && configs.isNotEmpty) {
        sets = configs
            .map((c) => WorkoutSet(weight: c.weight, reps: c.reps))
            .toList();
      } else {
        final weight = double.tryParse(item.weight) ?? 0;
        sets = List.generate(
          item.sets.clamp(1, 12).toInt(),
          (_) => WorkoutSet(weight: weight, reps: item.reps.clamp(1, 100).toInt()),
        );
      }
      exercises.add(WorkoutExercise(exercise: item.exercise, sets: sets));
    }
    if (exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('计划里还没有动作')),
      );
      return;
    }

    final existing = services.workouts.getDraft();
    if (existing != null && existing.hasProgress) {
      final replace = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('还有未完成的训练'),
          content: const Text('开始这个计划会覆盖当前草稿。'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('覆盖')),
          ],
        ),
      );
      if (replace != true) return;
    }

    final draft = WorkoutDraft(
      name: plan.name,
      planId: plan.id,
      startedAt: DateTime.now(),
      exercises: exercises,
    );
    await services.workouts.saveDraft(draft);
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WorkoutRunnerScreen(initialDraft: draft)),
    );
    if (mounted) _loadPlans();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('自定义计划')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _plans.isEmpty
          ? _EmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _plans.length,
              itemBuilder: (context, index) {
                final plan = _plans[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _PlanCard(
                    plan: plan,
                    onTap: () => _startPlan(plan),
                    onEdit: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CustomPlanEditorScreen(plan: plan, onSave: () => _loadPlans())),
                    ),
                    onDelete: () => _deletePlan(plan),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CustomPlanEditorScreen(plan: null, onSave: () => _loadPlans())),
        ),
        icon: const SvgIcon(assetName: 'favorite', size: 18),
        label: const Text('新建计划'),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final CustomPlan plan;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _PlanCard({required this.plan, required this.onTap, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plan.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(
                          '${plan.exercises.length} 个动作 · ${plan.updatedAt.month}月${plan.updatedAt.day}日',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(icon: const SvgIcon(assetName: 'favorite', size: 18), onPressed: onEdit),
                  IconButton(icon: const SvgIcon(assetName: 'history', size: 18), onPressed: onDelete),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: plan.exercises.take(5).map((item) => Chip(
                  label: Text(item.exercise.name, style: const TextStyle(fontSize: 11)),
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.4))),
                )).toList(),
              ),
              if (plan.exercises.length > 5) Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('+${plan.exercises.length - 5} 更多', style: theme.textTheme.bodySmall),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgIcon(assetName: 'strength', size: 72, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text('还没有自定义计划', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text('点击右下角按钮创建你的第一个训练计划', style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}