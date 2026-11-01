import 'package:excise/app/app_scope.dart';
import 'package:excise/app/theme.dart';
import 'package:excise/data/models/models.dart';
import 'package:excise/data/models/workout_models.dart';
import 'package:excise/data/repositories/custom_plan_repository.dart';
import 'package:excise/data/workout_templates.dart';
import 'package:excise/ui/screens/custom_plan_editor_screen.dart';
import 'package:excise/ui/screens/workout_runner_screen.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:flutter/material.dart';

/// 计划 Tab：模板库 + 我的计划。
class CustomPlanListScreen extends StatefulWidget {
  const CustomPlanListScreen({super.key});

  @override
  State<CustomPlanListScreen> createState() => _CustomPlanListScreenState();
}

class _CustomPlanListScreenState extends State<CustomPlanListScreen> {
  LocalCustomPlanRepository? _repo;
  List<CustomPlan> _plans = [];
  List<WorkoutSession> _sessions = const [];
  bool _loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final repo = AppScope.of(context).plans;
    if (identical(repo, _repo)) return;
    _repo = repo;
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    final services = AppScope.of(context);
    await _repo?.init();
    if (!mounted) return;
    setState(() {
      _plans = _repo?.getPlans() ?? const [];
      _sessions = services.workouts.getSessions();
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
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除', style: TextStyle(color: AppTheme.accentRed)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _repo?.deletePlan(plan.id);
    if (mounted) _loadPlans();
  }

  Future<void> _duplicatePlan(CustomPlan plan) async {
    await _repo?.duplicatePlan(plan);
    if (!mounted) return;
    _loadPlans();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已复制「${plan.name}」')),
    );
  }

  Future<void> _useTemplate(WorkoutTemplate template) async {
    final repo = _repo;
    if (repo == null) return;
    final now = DateTime.now();
    final plan = buildPlanFromTemplate(
      template,
      id: 'plan_${template.id}_${now.millisecondsSinceEpoch}',
      now: now,
    );
    await repo.savePlan(plan);
    if (!mounted) return;
    await _loadPlans();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已生成计划「${plan.name}」，点计划卡片开始')),
    );
  }

  Future<void> _startPlan(CustomPlan plan) async {
    final services = AppScope.of(context);
    final draft = buildDraftFromPlan(plan);
    if (draft.exercises.isEmpty) {
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

    await services.workouts.saveDraft(draft);
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WorkoutRunnerScreen(initialDraft: draft)),
    );
    if (mounted) _loadPlans();
  }

  Future<void> _openEditor({CustomPlan? plan}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomPlanEditorScreen(plan: plan, onSave: () => _loadPlans()),
      ),
    );
    if (mounted) _loadPlans();
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().weekday;
    final orderedPlans = [..._plans]..sort((a, b) {
        final aToday = a.isScheduledOn(today) ? 0 : 1;
        final bToday = b.isScheduledOn(today) ? 0 : 1;
        if (aToday != bToday) return aToday.compareTo(bToday);
        return b.updatedAt.compareTo(a.updatedAt);
      });
    return Scaffold(
      backgroundColor: AppTheme.bgMain,
      appBar: AppBar(
        title: const Text('计划'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
              children: [
                _sectionHeader('模板库', '一键生成我的计划'),
                const SizedBox(height: 10),
                _templateRow(),
                const SizedBox(height: 24),
                _sectionHeader('我的计划', '${_plans.length} 个'),
                const SizedBox(height: 10),
                if (_plans.isEmpty)
                  _emptyPlans()
                else
                  for (final plan in orderedPlans) ...[
                    _planCard(plan),
                    const SizedBox(height: 10),
                  ],
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text('新建计划'),
      ),
    );
  }

  Widget _sectionHeader(String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        const Spacer(),
        Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textTertiary)),
      ],
    );
  }

  Widget _templateRow() {
    return SizedBox(
      height: 136,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: kWorkoutTemplates.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final template = kWorkoutTemplates[index];
          final exercises = template.resolveExercises();
          final minutes = estimateMinutes(buildWorkoutExercises(exercises));
          return _TemplateCard(
            template: template,
            exerciseCount: exercises.length,
            minutes: minutes,
            accent: [AppTheme.primary, AppTheme.accent, AppTheme.accentWarm, AppTheme.accentPurple][index % 4],
            onUse: () => _useTemplate(template),
          );
        },
      ),
    );
  }

  int _estimatedMinutes(CustomPlan plan) {
    return estimateMinutes(buildDraftFromPlan(plan).exercises);
  }

  WorkoutSession? _lastSession(CustomPlan plan) {
    for (final session in _sessions) {
      if (session.planId == plan.id) return session;
    }
    return null;
  }

  Widget _planCard(CustomPlan plan) {
    final last = _lastSession(plan);
    final scheduledToday = plan.isScheduledOn(DateTime.now().weekday);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _startPlan(plan),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: scheduledToday
                  ? AppTheme.primary.withValues(alpha: 0.45)
                  : AppTheme.divider.withValues(alpha: 0.45),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      plan.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                    ),
                  ),
                  if (scheduledToday)
                    Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('今天', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.primary)),
                    ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz_rounded, size: 20, color: AppTheme.textTertiary),
                    tooltip: '更多',
                    onSelected: (value) {
                      if (value == 'edit') _openEditor(plan: plan);
                      if (value == 'duplicate') _duplicatePlan(plan);
                      if (value == 'delete') _deletePlan(plan);
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('编辑')),
                      PopupMenuItem(value: 'duplicate', child: Text('复制')),
                      PopupMenuItem(value: 'delete', child: Text('删除')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${plan.exercises.length} 个动作 · 约 ${_estimatedMinutes(plan)} 分钟 · ${scheduleLabel(plan.scheduledWeekdays)}',
                style: const TextStyle(fontSize: 12, color: AppTheme.textTertiary),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: plan.exercises.take(4).map((item) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.bgMain,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    item.exercise.name,
                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                )).toList(),
              ),
              if (plan.exercises.length > 4)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '+${plan.exercises.length - 4} 个',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary),
                  ),
                ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    last == null ? Icons.schedule_rounded : Icons.check_circle_outline_rounded,
                    size: 14,
                    color: last == null ? AppTheme.textTertiary : AppTheme.accent,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    last == null
                        ? '还没练过'
                        : '上次 ${DateFormat('M月d日').format(last.startedAt)} · ${last.totalSets} 组',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.play_arrow_rounded, size: 15, color: AppTheme.primary),
                        SizedBox(width: 2),
                        Text('开始', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primary)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyPlans() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider.withValues(alpha: 0.45)),
      ),
      child: Column(
        children: [
          const Icon(Icons.event_note_outlined, size: 38, color: AppTheme.textTertiary),
          const SizedBox(height: 10),
          const Text('还没有自己的计划', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          const Text(
            '用上面的模板一键生成，或新建一个计划',
            style: TextStyle(fontSize: 12, color: AppTheme.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final WorkoutTemplate template;
  final int exerciseCount;
  final int minutes;
  final Color accent;
  final VoidCallback onUse;

  const _TemplateCard({
    required this.template,
    required this.exerciseCount,
    required this.minutes,
    required this.accent,
    required this.onUse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 208,
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(color: accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(9)),
                child: Icon(Icons.fitness_center_rounded, size: 16, color: accent),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  template.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            template.tagline,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary),
          ),
          const Spacer(),
          Text(
            '$exerciseCount 个动作 · 约 $minutes 分钟',
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 32,
            child: FilledButton(
              onPressed: onUse,
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
              ),
              child: const Text('使用模板', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
