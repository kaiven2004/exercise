import 'package:excise/data/models/models.dart';
import 'package:excise/data/repositories/custom_plan_repository.dart';
import 'package:excise/data/repositories/sample_repository.dart';
import 'package:excise/ui/screens/exercise_detail_screen.dart';
import 'package:excise/ui/widgets/svg_icons.dart';
import 'package:flutter/material.dart';

class CustomPlanEditorScreen extends StatefulWidget {
  final CustomPlan? plan;
  final VoidCallback onSave;
  const CustomPlanEditorScreen({super.key, this.plan, required this.onSave});

  @override
  State<CustomPlanEditorScreen> createState() => _CustomPlanEditorScreenState();
}

class _CustomPlanEditorScreenState extends State<CustomPlanEditorScreen> {
  late final LocalCustomPlanRepository _repo;
  late final SampleExerciseRepository _exerciseRepo;
  late String _planName;
  late List<CustomExerciseItem> _exercises;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _repo = LocalCustomPlanRepository();
    _exerciseRepo = SampleExerciseRepository();
    _planName = widget.plan?.name ?? '新计划';
    _exercises = widget.plan?.exercises.toList() ?? [];
  }

  Future<void> _save() async {
    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请至少添加一个动作')));
      return;
    }
    if (mounted) setState(() => _saving = true);
    final now = DateTime.now();
    final plan = CustomPlan(
      id: widget.plan?.id ?? now.millisecondsSinceEpoch.toString(),
      name: _planName,
      createdAt: widget.plan?.createdAt ?? now,
      updatedAt: now,
      exercises: _exercises,
    );
    await _repo.init();
    await _repo.savePlan(plan);
    if (mounted) {
      setState(() => _saving = false);
      Navigator.pop(context);
      widget.onSave();
    }
  }

  Future<void> _addExercise() async {
    final selected = await showModalBottomSheet<Exercise>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (ctx) => _ExercisePicker(excludeIds: _exercises.map((e) => e.exercise.id).toSet()),
    );
    if (selected != null && mounted) {
      setState(() {
        _exercises.add(CustomExerciseItem(exercise: selected, order: _exercises.length));
      });
    }
  }

  void _removeExercise(int index) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('删除动作'),
      content: Text('确定要从计划中移除「${_exercises[index].exercise.name}」吗？'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
        TextButton(onPressed: () { Navigator.pop(ctx); setState(() => _exercises.removeAt(index)); }, child: const Text('删除', style: TextStyle(color: Colors.red))),
      ],
    ));
  }

  void _editExercise(int index) {
    final item = _exercises[index];
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(item.exercise.name),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          const SizedBox(width: 60, child: Text('组数', style: TextStyle(color: Colors.white70))),
          Expanded(child: TextField(
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(hintText: '组数', border: OutlineInputBorder()),
            onChanged: (v) => item.sets = int.tryParse(v) ?? item.sets,
            controller: TextEditingController(text: item.sets.toString()),
          )),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          const SizedBox(width: 60, child: Text('次数', style: TextStyle(color: Colors.white70))),
          Expanded(child: TextField(
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(hintText: '次数', border: OutlineInputBorder()),
            onChanged: (v) => item.reps = int.tryParse(v) ?? item.reps,
            controller: TextEditingController(text: item.reps.toString()),
          )),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          const SizedBox(width: 60, child: Text('休息(秒)', style: TextStyle(color: Colors.white70))),
          Expanded(child: TextField(
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(hintText: '休息', border: OutlineInputBorder()),
            onChanged: (v) => item.restSeconds = v,
            controller: TextEditingController(text: item.restSeconds),
          )),
        ]),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('保存')),
      ],
    ));
  }

  void _moveExercise(int from, int to) {
    setState(() {
      final item = _exercises.removeAt(from);
      _exercises.insert(to, item);
      for (int i = 0; i < _exercises.length; i++) _exercises[i] = _exercises[i].copyWith(order: i);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.plan == null ? '新建计划' : '编辑计划')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(labelText: '计划名称', prefixIcon: SvgIcon(assetName: 'favorite', size: 16)),
              controller: TextEditingController(text: _planName),
              onChanged: (v) => _planName = v,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('${_exercises.length} 个动作', style: theme.textTheme.titleSmall),
                const Spacer(),
                TextButton.icon(
                  icon: const SvgIcon(assetName: 'favorite', size: 14),
                  label: const Text('添加动作'),
                  onPressed: _addExercise,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _exercises.isEmpty
                ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    SvgIcon(assetName: 'strength', size: 56, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(height: 12),
                    const Text('还没有动作\n点击「添加动作」开始创建'),
                  ]))
                : ReorderableListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _exercises.length,
                    onReorder: (oldIndex, newIndex) => _moveExercise(oldIndex, newIndex),
                    itemBuilder: (context, index) {
                      final item = _exercises[index];
                      return Card(
                        key: ValueKey(item.exercise.id),
                        margin: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () => Navigator.push(context, MaterialPageRoute(
                            builder: (_) => ExerciseDetailScreen(exercise: item.exercise),
                          )),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(width: 36, height: 36, decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                                  child: Center(child: SvgIcon(assetName: item.exercise.imageSvg, size: 20, color: theme.colorScheme.primary))),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(item.exercise.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 2),
                                    Text('${item.sets}组 × ${item.reps}次 · 休息${item.restSeconds}s', style: theme.textTheme.bodySmall),
                                  ]),
                                ),
                                IconButton(icon: const SvgIcon(assetName: 'favorite', size: 18), onPressed: () => _editExercise(index)),
                                IconButton(icon: const SvgIcon(assetName: 'history', size: 18), onPressed: () => _removeExercise(index)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _saving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('保存计划', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          )),
        ],
      ),
    );
  }
}

class _ExercisePicker extends StatefulWidget {
  final Set<String> excludeIds;
  const _ExercisePicker({required this.excludeIds});

  @override
  State<_ExercisePicker> createState() => _ExercisePickerState();
}

class _ExercisePickerState extends State<_ExercisePicker> {
  final TextEditingController _search = TextEditingController();
  List<Exercise> _all = [];
  List<Exercise> _results = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _search.addListener(_onSearch);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _onSearch() {
    final repo = SampleExerciseRepository();
    if (_search.text.isEmpty) {
      setState(() { _results = _all; });
    } else {
      setState(() { _results = repo.searchExercises(_search.text); });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      final repo = SampleExerciseRepository();
      _all = repo.searchExercises('');
      setState(() { _results = _all; _loaded = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _search,
              autofocus: true,
              decoration: InputDecoration(hintText: '搜索动作...', prefixIcon: const SvgIcon(assetName: 'search', size: 18), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 300,
            child: _results.isEmpty
                ? const Center(child: Text('未找到相关动作'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final ex = _results[index];
                      final excluded = widget.excludeIds.contains(ex.id);
                      return ListTile(
                        leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                          child: Center(child: SvgIcon(assetName: ex.imageSvg, size: 22, color: theme.colorScheme.primary))),
                        title: Text(ex.name),
                        subtitle: Text(ex.categoryPath),
                        trailing: excluded ? const Text('已添加', style: TextStyle(color: Colors.grey)): null,
                        enabled: !excluded,
                        onTap: excluded ? null : () => Navigator.pop(context, ex),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}