import 'package:excise/app/app_scope.dart';
import 'package:excise/app/theme.dart';
import 'package:excise/data/exercises/exercise_meta.dart';
import 'package:excise/data/models/models.dart';
import 'package:excise/data/models/workout_models.dart';
import 'package:excise/data/workout_templates.dart';
import 'package:excise/ui/screens/workout_runner_screen.dart';
import 'package:excise/ui/widgets/exercise_image.dart';
import 'package:flutter/material.dart';

class QuickStartScreen extends StatefulWidget {
  const QuickStartScreen({super.key});

  @override
  State<QuickStartScreen> createState() => _QuickStartScreenState();
}

class _QuickStartScreenState extends State<QuickStartScreen> {
  QuickBodyPart _part = QuickBodyPart.full;
  int _minutes = 40;
  Equipment? _equipment;
  List<Exercise> _selected = const [];

  int get _count => _minutes <= 20 ? 3 : (_minutes <= 40 ? 5 : 7);

  @override
  void initState() {
    super.initState();
    _regenerate();
  }

  void _regenerate() {
    _selected = buildQuickStart(part: _part, equipment: _equipment, count: _count);
  }

  void _update(VoidCallback change) {
    setState(() {
      change();
      _regenerate();
    });
  }

  @override
  Widget build(BuildContext context) {
    final workout = buildWorkoutExercises(
      _selected,
      lastPerformances: AppScope.of(context).workouts.getLastPerformances(),
    );
    final minutes = estimateMinutes(workout);
    return Scaffold(
      backgroundColor: AppTheme.bgMain,
      appBar: AppBar(title: const Text('快速开始')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          _label('练哪里'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              for (final part in QuickBodyPart.values)
                ChoiceChip(
                  label: Text(part.label),
                  selected: _part == part,
                  onSelected: (_) => _update(() => _part = part),
                ),
            ],
          ),
          const SizedBox(height: 20),
          _label('练多久'),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final option in const [20, 40, 60]) ...[
                Expanded(
                  child: _durationButton(option),
                ),
                if (option != 60) const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 20),
          _label('器械'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _equipmentChip(null, '不限'),
              for (final equipment in const [
                Equipment.barbell,
                Equipment.dumbbell,
                Equipment.machine,
                Equipment.cable,
                Equipment.bodyweight,
                Equipment.kettlebell,
                Equipment.band,
              ])
                _equipmentChip(equipment, equipment.label),
            ],
          ),
          const SizedBox(height: 26),
          Row(
            children: [
              _label('动作预览'),
              const Spacer(),
              Text('${_selected.length} 个动作 · 约 $minutes 分钟', style: const TextStyle(fontSize: 12, color: AppTheme.textTertiary)),
            ],
          ),
          const SizedBox(height: 10),
          if (_selected.isEmpty)
            _emptyState()
          else
            for (var i = 0; i < _selected.length; i++) ...[
              _exerciseRow(i),
              if (i != _selected.length - 1) const SizedBox(height: 8),
            ],
        ],
      ),
      bottomSheet: _bottomBar(workout),
    );
  }

  Widget _label(String text) => Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary));

  Widget _durationButton(int minutes) {
    final selected = _minutes == minutes;
    return Material(
      color: selected ? AppTheme.primary : Colors.white,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: () => _update(() => _minutes = minutes),
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: selected ? AppTheme.primary : AppTheme.divider.withValues(alpha: 0.6)),
          ),
          child: Text(
            '$minutes 分钟',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: selected ? Colors.white : AppTheme.textSecondary),
          ),
        ),
      ),
    );
  }

  Widget _equipmentChip(Equipment? equipment, String label) {
    final selected = _equipment == equipment;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => _update(() => _equipment = equipment),
    );
  }

  Widget _exerciseRow(int index) {
    final exercise = _selected[index];
    final meta = metaFor(exercise);
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 4, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 46,
              height: 46,
              child: ExerciseImage(exercise: exercise, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exercise.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                const SizedBox(height: 2),
                Text(
                  '${meta.primaryMuscle} · ${meta.equipment.label}${meta.compound ? ' · 复合' : ''}',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _swap(index),
            style: TextButton.styleFrom(foregroundColor: AppTheme.primary, padding: const EdgeInsets.symmetric(horizontal: 8)),
            child: const Text('换', style: TextStyle(fontSize: 12)),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 18),
            color: AppTheme.textTertiary,
            onPressed: () => setState(() => _selected = [..._selected]..removeAt(index)),
          ),
        ],
      ),
    );
  }

  Future<void> _swap(int index) async {
    final alternatives = quickStartCandidates(part: _part, equipment: _equipment)
        .where((e) => !_selected.any((s) => s.id == e.id))
        .take(30)
        .toList();
    if (alternatives.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('没有更多符合条件的动作')));
      return;
    }
    final picked = await showModalBottomSheet<Exercise>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('换成', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: alternatives.length,
                itemBuilder: (context, i) {
                  final exercise = alternatives[i];
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: SizedBox(
                        width: 42,
                        height: 42,
                        child: ExerciseImage(exercise: exercise, fit: BoxFit.cover),
                      ),
                    ),
                    title: Text(exercise.name),
                    subtitle: Text(
                      '${metaFor(exercise).primaryMuscle} · ${metaFor(exercise).equipment.label}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    onTap: () => Navigator.pop(context, exercise),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
    if (picked != null && mounted) {
      setState(() => _selected = [..._selected]..[index] = picked);
    }
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider.withValues(alpha: 0.45)),
      ),
      child: const Text(
        '没有符合条件的动作，试试放宽器械或换一个部位',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13, color: AppTheme.textTertiary),
      ),
    );
  }

  Widget _bottomBar(List<WorkoutExercise> workout) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.divider, width: 0.5)),
      ),
      child: SizedBox(
        height: 48,
        child: FilledButton(
          onPressed: _selected.isEmpty ? null : () => _start(workout),
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
          ),
          child: Text('开始训练 · ${workout.length} 个动作', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }

  Future<void> _start(List<WorkoutExercise> workout) async {
    final services = AppScope.of(context);
    final existing = services.workouts.getDraft();
    if (existing != null && existing.hasProgress) {
      final replace = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('还有未完成的训练'),
          content: const Text('开始新的训练会覆盖当前草稿。'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('覆盖')),
          ],
        ),
      );
      if (replace != true) return;
    }
    final draft = WorkoutDraft(
      name: '快速开始 · ${_part.label}',
      startedAt: DateTime.now(),
      exercises: workout,
    );
    await services.workouts.saveDraft(draft);
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WorkoutRunnerScreen(initialDraft: draft)),
    );
    if (mounted) Navigator.pop(context);
  }
}
