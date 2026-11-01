import 'package:excise/app/app_scope.dart';
import 'package:excise/data/models/models.dart';
import 'package:excise/data/repositories/custom_plan_repository.dart';
import 'package:excise/data/repositories/exercise_override_repository.dart';
import 'package:excise/data/repositories/sample_repository.dart';
import 'package:excise/data/workout_templates.dart';
import 'package:excise/ui/widgets/exercise_image.dart';
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
  LocalCustomPlanRepository? _repo;
  late final ExerciseOverrideRepository _overrideRepo;
  late final TextEditingController _nameController;
  late String _planName;
  late List<CustomExerciseItem> _exercises;
  late List<int> _weekdays;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _overrideRepo = ExerciseOverrideRepository();
    _overrideRepo.init();
    _planName = widget.plan?.name ?? '新计划';
    _nameController = TextEditingController(text: _planName);
    _exercises = widget.plan?.exercises.toList() ?? [];
    _exercises.sort((a, b) => a.order.compareTo(b.order));
    _weekdays = widget.plan?.scheduledWeekdays.toList() ?? [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _repo ??= AppScope.of(context).plans;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请至少添加一个动作')));
      return;
    }
    final repo = _repo;
    if (repo == null) return;
    if (mounted) setState(() => _saving = true);
    final now = DateTime.now();
    // 拖拽后按当前顺序重写 order，重开计划仍保持排序。
    final ordered = [
      for (var i = 0; i < _exercises.length; i++) _exercises[i].copyWith(order: i),
    ];
    final plan = CustomPlan(
      id: widget.plan?.id ?? now.millisecondsSinceEpoch.toString(),
      name: _planName,
      createdAt: widget.plan?.createdAt ?? now,
      updatedAt: now,
      exercises: ordered,
      scheduledWeekdays: _weekdays,
    );
    await repo.init();
    await repo.savePlan(plan);
    if (mounted) {
      setState(() => _saving = false);
      Navigator.pop(context);
      widget.onSave();
    }
  }

  void _toggleWeekday(int weekday) {
    setState(() {
      if (_weekdays.contains(weekday)) {
        _weekdays.remove(weekday);
      } else {
        _weekdays.add(weekday);
      }
      _weekdays.sort();
    });
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
        final item = CustomExerciseItem(exercise: selected, order: _exercises.length);
        _exercises.add(item);
      });
      _syncOverrideToItem(_exercises.last);
    }
  }

  Future<void> _syncOverrideToItem(CustomExerciseItem item) async {
    final effSets = _overrideRepo.getEffectiveSets(item.exercise.id, item.sets);
    final effReps = _overrideRepo.getEffectiveReps(item.exercise.id, item.reps);
    final effRest = item.restSeconds;
    final effWeight = item.weight;
    setState(() {
      item.sets = effSets;
      item.reps = effReps;
      item.restSeconds = effRest;
      item.weight = effWeight;
    });
    await _overrideRepo.saveOverride(item.exercise.id, sets: effSets, reps: effReps, restSeconds: effRest);
    await _overrideRepo.saveWeight(item.exercise.id, effWeight);
  }

  Future<void> _saveOverride(CustomExerciseItem item) async {
    await _overrideRepo.saveOverride(item.exercise.id, sets: item.sets, reps: item.reps, restSeconds: item.restSeconds);
    await _overrideRepo.saveWeight(item.exercise.id, item.weight);
  }

  void _removeExercise(int index) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('删除动作'),
      content: Text('确定要从计划中移除${_exercises[index].exercise.name}吗？'),
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
          const SizedBox(width: 60, child: Text('重量', style: TextStyle(color: Colors.white70))),
          Expanded(child: TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            decoration: const InputDecoration(hintText: 'kg', border: OutlineInputBorder()),
            onChanged: (v) => item.weight = v,
            controller: TextEditingController(text: item.weight),
          )),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          const SizedBox(width: 60, child: Text('休息', style: TextStyle(color: Colors.white70))),
          Expanded(child: TextField(
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(hintText: '秒', border: OutlineInputBorder()),
            onChanged: (v) => item.restSeconds = v,
            controller: TextEditingController(text: item.restSeconds),
          )),
        ]),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          icon: const Icon(Icons.tune, size: 18),
          label: const Text('高级设置（逐组配置）'),
          onPressed: () {
            Navigator.pop(ctx);
            _openSetConfigEditor(index);
          },
        ),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
        TextButton(onPressed: () async { Navigator.pop(ctx); await _saveOverride(item); }, child: const Text('保存', style: TextStyle(color: Color(0xFF1565C0)))),
      ],
    ));
  }

  void _openSetConfigEditor(int itemIndex) {
    final item = _exercises[itemIndex];
    final sets = item.sets;
    final defaultReps = item.reps;
    final defaultWeight = item.weight;

    List<SetConfig> configs = item.setConfigs != null && item.setConfigs!.length == sets
        ? List.from(item.setConfigs!)
        : List.generate(sets, (i) => SetConfig(weight: double.tryParse(defaultWeight) ?? 0, reps: defaultReps));

    while (configs.length < sets) {
      configs.add(SetConfig(weight: double.tryParse(defaultWeight) ?? 0, reps: defaultReps));
    }
    if (configs.length > sets) {
      configs = configs.sublist(0, sets);
    }

    showDialog(
      context: context,
      builder: (ctx) => _SetConfigDialog(
        itemName: item.exercise.name,
        sets: sets,
        configs: configs,
        onSave: (newConfigs) {
          setState(() {
            _exercises[itemIndex] = item.copyWith(setConfigs: newConfigs);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑计划', style: TextStyle(color: Colors.white)),
        backgroundColor: theme.colorScheme.primary,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: '计划名称',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            onChanged: (v) => _planName = v,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('排期', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  Text(
                    _weekdays.isEmpty ? '未排期（首页不会提醒）' : scheduleLabel(_weekdays),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  for (var day = 1; day <= 7; day++)
                    FilterChip(
                      label: Text('周${kWeekdayShortLabels[day - 1]}', style: const TextStyle(fontSize: 11)),
                      selected: _weekdays.contains(day),
                      showCheckmark: false,
                      visualDensity: VisualDensity.compact,
                      onSelected: (_) => _toggleWeekday(day),
                    ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                '${_exercises.length} 个动作 · 长按拖动排序',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              TextButton.icon(
                icon: const SvgIcon(assetName: 'favorite', size: 16),
                label: const Text('添加动作'),
                onPressed: _addExercise,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _exercises.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const SvgIcon(assetName: 'strength', size: 64),
                  const SizedBox(height: 12),
                  const Text('还没有动作，点击"添加动作"开始'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const SvgIcon(assetName: 'favorite', size: 18),
                    label: const Text('添加动作'),
                    onPressed: _addExercise,
                    style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary),
                  ),
                ]))
              : ReorderableListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  buildDefaultDragHandles: false,
                  itemCount: _exercises.length,
                  onReorderItem: (oldIndex, newIndex) {
                    setState(() {
                      final item = _exercises.removeAt(oldIndex);
                      _exercises.insert(newIndex, item);
                    });
                  },
                  itemBuilder: (context, index) {
                    final item = _exercises[index];
                    final hasSetConfigs = item.setConfigs != null && item.setConfigs!.isNotEmpty;
                    return Card(
                      key: ObjectKey(item),
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.fromLTRB(8, 8, 6, 8),
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ReorderableDragStartListener(
                              index: index,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(Icons.drag_indicator_rounded, size: 20, color: Color(0xFFB0B4BA)),
                              ),
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                width: 46,
                                height: 46,
                                child: ExerciseImage(exercise: item.exercise, fit: BoxFit.cover),
                              ),
                            ),
                          ],
                        ),
                        title: Text(item.exercise.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(
                            _formatDisplay(item, hasSetConfigs),
                            style: theme.textTheme.bodySmall,
                          ),
                          if (hasSetConfigs)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                '逐组配置',
                                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary),
                              ),
                            ),
                        ]),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                          if (hasSetConfigs)
                            Container(
                              margin: const EdgeInsets.only(right: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                              child: const Text('各组不同', style: TextStyle(fontSize: 10, color: Color(0xFF1565C0))),
                            ),
                          IconButton(
                            tooltip: '编辑',
                            icon: const Icon(Icons.edit_outlined, size: 19, color: Color(0xFF6B7280)),
                            onPressed: () => _editExercise(index),
                          ),
                          IconButton(
                            tooltip: '删除',
                            icon: const Icon(Icons.delete_outline_rounded, size: 19, color: Color(0xFF9CA3AF)),
                            onPressed: () => _removeExercise(index),
                          ),
                        ]),
                      ),
                    );
                  },
                ),
        ),
        SafeArea(
          child: Padding(
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
          ),
        ),
      ]),
    );
  }

  String _formatDisplay(CustomExerciseItem item, bool hasSetConfigs) {
    if (hasSetConfigs && item.setConfigs != null) {
      final parts = item.setConfigs!.map((s) => '${s.weight.toInt()}kg x ${s.reps}次').join(' · ');
      return parts;
    }
    return '${item.sets}组 x ${item.reps}次' + (item.weight != '0' && item.weight.isNotEmpty ? ' · ' + item.weight + 'kg' : '') + ' · 休息${item.restSeconds}s';
  }
}

class _SetConfigDialog extends StatefulWidget {
  final String itemName;
  final int sets;
  final List<SetConfig> configs;
  final Function(List<SetConfig>) onSave;
  const _SetConfigDialog({required this.itemName, required this.sets, required this.configs, required this.onSave});

  @override
  State<_SetConfigDialog> createState() => _SetConfigDialogState();
}

class _SetConfigDialogState extends State<_SetConfigDialog> {
  late List<TextEditingController> _weightControllers;
  late List<TextEditingController> _repsControllers;

  @override
  void initState() {
    super.initState();
    _weightControllers = widget.configs.map((c) => TextEditingController(text: c.weight.toInt().toString())).toList();
    _repsControllers = widget.configs.map((c) => TextEditingController(text: c.reps.toString())).toList();
  }

  @override
  void dispose() {
    for (final c in _weightControllers) c.dispose();
    for (final c in _repsControllers) c.dispose();
    super.dispose();
  }

  void _onSave() {
    final newConfigs = List.generate(widget.sets, (i) {
      final w = double.tryParse(_weightControllers[i].text) ?? 0;
      final r = int.tryParse(_repsControllers[i].text) ?? widget.configs[i].reps;
      return SetConfig(weight: w, reps: r);
    });
    widget.onSave(newConfigs);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text('逐组设置 -- ${widget.itemName}'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 8),
          Row(children: [
            Expanded(flex: 1, child: Text('组', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
            const SizedBox(width: 8),
            Expanded(flex: 2, child: Text('重量 (kg)', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
            const SizedBox(width: 8),
            Expanded(flex: 2, child: Text('次数', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
          ]),
          const Divider(height: 16),
          ...List.generate(widget.sets, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    '第${i + 1}组',
                    style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _weightControllers[i],
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _repsControllers[i],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                  ),
                ),
              ]),
            );
          }),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
        TextButton(
          onPressed: _onSave,
          style: TextButton.styleFrom(backgroundColor: theme.colorScheme.primary),
          child: const Text('保存', style: TextStyle(color: Colors.white)),
        ),
      ],
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
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 40,
                            height: 40,
                            child: ExerciseImage(exercise: ex, fit: BoxFit.cover),
                          ),
                        ),
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
