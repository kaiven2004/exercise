import 'package:excise/app/app_scope.dart';
import 'package:excise/app/theme.dart';
import 'package:excise/data/exercises/exercise_meta.dart';
import 'package:excise/data/models/models.dart';
import 'package:excise/data/models/workout_models.dart';
import 'package:excise/data/repositories/exercise_override_repository.dart';
import 'package:excise/data/repositories/local_repositories.dart';
import 'package:excise/data/repositories/sample_repository.dart';
import 'package:excise/ui/screens/workout_runner_screen.dart';
import 'package:excise/ui/widgets/exercise_image.dart';
import 'package:excise/ui/widgets/svg_icons.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:intl/intl.dart' show DateFormat;
class ExerciseDetailScreen extends StatefulWidget {
  final Exercise exercise;
  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _isFavorite = false;
  bool _loading = true;
  late final LocalFavoriteRepository _favRepo;
  late final ExerciseOverrideRepository _overrideRepo;
  late final SampleExerciseRepository _exerciseRepo;
  AppServices? _services;
  LastPerformance? _lastPerformance;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _hasVideo = false;
  bool _editing = false;

  late int _sets = 3;
  late int _reps = 12;
  late String _restSeconds = '60';
  late String _weight = '0';

  TextEditingController _setsController = TextEditingController();
  TextEditingController _repsController = TextEditingController();
  TextEditingController _restController = TextEditingController();
  TextEditingController _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _favRepo = LocalFavoriteRepository();
    _overrideRepo = ExerciseOverrideRepository();
    _exerciseRepo = SampleExerciseRepository();
    _initRepositories();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final services = AppScope.maybeOf(context);
    if (services == _services) return;
    _services = services;
    _lastPerformance = services?.workouts.getLastPerformance(widget.exercise.id);
  }

  Future<void> _initRepositories() async {
    await _overrideRepo.init();
    await _favRepo.init();
    _sets = _overrideRepo.getOverrideSets(widget.exercise.id) ?? widget.exercise.sets;
    _reps = _overrideRepo.getOverrideReps(widget.exercise.id) ?? widget.exercise.reps;
    _restSeconds = _overrideRepo.getOverrideRest(widget.exercise.id) ?? widget.exercise.restSeconds;
    _setsController.text = _sets.toString();
    _repsController.text = _reps.toString();
    _restController.text = _restSeconds;
    _weightController.text = _overrideRepo.getOverrideWeight(widget.exercise.id) ?? widget.exercise.weight;
    setState(() {
      _isFavorite = _favRepo.isFavorite(widget.exercise);
      _loading = false;
    });
    _loadVideo();
  }

  Future<void> _loadVideo() async {
    final path = widget.exercise.videoPath;
    if (path.isEmpty) {
      setState(() => _hasVideo = false);
      return;
    }
    final placeholderColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    try {
      _videoController = VideoPlayerController.asset('assets/videos/$path');
      await _videoController!.initialize();
      if (!mounted) return;
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: false,
        looping: true,
        showControls: true,
        placeholder: Container(
          color: placeholderColor,
          child: const Center(
            child: SvgIcon(assetName: 'play_circle', size: 48),
          ),
        ),
      );
      setState(() => _hasVideo = true);
    } catch (e) {
      setState(() => _hasVideo = false);
    }
  }

  @override
  void dispose() {
    _setsController.dispose();
    _repsController.dispose();
    _restController.dispose();
    _weightController.dispose();
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _saveEdit() async {
    final setsVal = int.tryParse(_setsController.text);
    final repsVal = int.tryParse(_repsController.text);
    final restVal = int.tryParse(_restController.text);
    if (setsVal != null) _sets = setsVal;
    if (repsVal != null) _reps = repsVal;
    if (restVal != null) _restSeconds = restVal.toString();
    _weight = _weightController.text;
    await _overrideRepo.saveOverride(
      widget.exercise.id,
      sets: _sets,
      reps: _reps,
      restSeconds: _restSeconds,
    );
    await _overrideRepo.saveWeight(widget.exercise.id, _weight);
    setState(() => _editing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已保存修改')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;
    final theme = Theme.of(context);

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(ex.name)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(ex.name),
        actions: [
          IconButton(
            icon: SvgIcon(
              assetName: _isFavorite ? 'favorite_filled' : 'favorite',
              size: 22,
              color: _isFavorite ? const Color(0xFFE53935) : null,
            ),
            onPressed: () {
              setState(() => _isFavorite = !_isFavorite);
              _favRepo.toggleFavorite(ex);
            },
          ),
          TextButton(
            onPressed: () {
              if (_editing) {
                _saveEdit();
              } else {
                setState(() => _editing = true);
              }
            },
            child: Text(_editing ? '保存' : '修改', style: const TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.w500)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_hasVideo) ...[
            _VideoPlayerWidget(chewieController: _chewieController!),
            const SizedBox(height: 16),
          ] else if (ex.videoPath.isNotEmpty) ...[
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgIcon(assetName: 'play_circle', size: 48),
                    SizedBox(height: 8),
                    Text('视频加载中...', style: TextStyle(color: Colors.white54)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ] else ...[
            Container(
              width: double.infinity,
              height: 240,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ExerciseImage(
                  exercise: ex,
                  animated: true,
                  fit: BoxFit.contain,
                  iconScale: 0.4,
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
          _metaSummary(ex),
          if (_lastPerformance != null) ...[
            const SizedBox(height: 12),
            _lastPerformanceCard(),
          ],
          const SizedBox(height: 16),
          _InfoSection(
            title: '基本信息',
            items: [
              _InfoRow(label: '锻炼部位', value: ex.categoryPath),
              _InfoRow(label: '难度', value: ex.difficulty),
              if (_editing)
                _EditableInfoRow(label: '组数', controller: _setsController)
              else
                _InfoRow(label: '组数', value: '${_sets} 组'),
              if (_editing)
                _EditableInfoRow(label: '次数', controller: _repsController)
              else
                _InfoRow(
                  label: '次数',
                  value: ex.reps <= 60 ? '${_reps} 次' : '${_reps} 秒',
                ),
              if (_editing)
                _EditableInfoRow(label: '组间休息（秒）', controller: _restController)
              else
                _InfoRow(label: '组间休息', value: '${_restSeconds} 秒'),
              if (_editing)
                _EditableInfoRow(label: '重量（kg）', controller: _weightController)
              else
                _InfoRow(label: '重量', value: _weight != '0' ? _weight + ' kg' : '—'),
            ],
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: '动作要领',
            items: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(ex.description, style: theme.textTheme.bodyMedium),
              ),
            ],
          ),
          if (ex.tips.isNotEmpty) ...[
            const SizedBox(height: 16),
            _InfoSection(
              title: '注意事项',
              items: ex.tips
                  .map(
                    (tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 3, right: 8),
                            child: SvgIcon(
                              assetName: 'favorite',
                              size: 14,
                              color: Color(0xFFFFB300),
                            ),
                          ),
                          Expanded(
                            child: Text(tip, style: theme.textTheme.bodyMedium),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],
          _alternativesSection(ex),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _addToPlan(ex),
                  icon: const Icon(Icons.playlist_add_rounded, size: 19),
                  label: const Text('加入计划'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _startWithExercise(ex),
                  icon: const Icon(Icons.play_arrow_rounded, size: 21),
                  label: const Text(
                    '用这个动作开始练',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _metaSummary(Exercise ex) {
    final meta = metaFor(ex);
    return Row(
      children: [
        _metaItem('目标肌群', meta.primaryMuscle, AppTheme.primary),
        const SizedBox(width: 8),
        _metaItem('器械', meta.equipment.label, AppTheme.accent),
        const SizedBox(width: 8),
        _metaItem('难度', ex.difficulty, AppTheme.accentWarm),
      ],
    );
  }

  Widget _metaItem(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: AppTheme.divider.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textTertiary)),
            const SizedBox(height: 2),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _lastPerformanceCard() {
    final last = _lastPerformance!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFF101828),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.history_rounded, size: 17, color: Color(0xFF8FA3BF)),
          const SizedBox(width: 8),
          Text('上次表现', style: const TextStyle(fontSize: 12, color: Color(0xFFB6C2D4))),
          const Spacer(),
          Text(
            last.label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Text(
            DateFormat('M月d日').format(last.date),
            style: const TextStyle(fontSize: 11, color: Color(0xFF8FA3BF)),
          ),
        ],
      ),
    );
  }

  Widget _alternativesSection(Exercise ex) {
    final alternatives = _alternatives(ex);
    if (alternatives.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        const Text('替代动作', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: alternatives.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final item = alternatives[index];
              return Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(11),
                child: InkWell(
                  borderRadius: BorderRadius.circular(11),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ExerciseDetailScreen(exercise: item)),
                  ),
                  child: Container(
                    width: 142,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: AppTheme.divider.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 38,
                            height: 38,
                            child: ExerciseImage(exercise: item, fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<Exercise> _alternatives(Exercise ex) {
    final parts = ex.categoryPath.split(' / ');
    final leaf = parts.isEmpty ? '' : parts.last;
    final all = _exerciseRepo.getExercises('all');
    final sameLeaf = all
        .where((e) => e.id != ex.id && e.categoryPath.split(' / ').last == leaf)
        .toList();
    final pool = sameLeaf.length >= 3
        ? sameLeaf
        : all.where((e) => e.id != ex.id && metaFor(e).primaryMuscle == metaFor(ex).primaryMuscle).toList();
    return pool.take(6).toList();
  }

  Future<void> _startWithExercise(Exercise ex) async {
    final services = AppScope.maybeOf(context);
    if (services == null) return;
    final existing = services.workouts.getDraft();
    if (existing != null && existing.hasProgress) {
      final replace = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('还有未完成的训练'),
          content: const Text('用这个动作开始会覆盖当前草稿。'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('覆盖')),
          ],
        ),
      );
      if (replace != true || !mounted) return;
    }

    final meta = metaFor(ex);
    final last = services.workouts.getLastPerformance(ex.id);
    final setCount = meta.primaryMuscle == '核心' ? 3 : (meta.compound ? 4 : 3);
    final reps = last?.reps ?? (meta.primaryMuscle == '核心' ? 15 : (meta.compound ? 8 : 12));
    final draft = WorkoutDraft(
      name: ex.name,
      startedAt: DateTime.now(),
      exercises: [
        WorkoutExercise(
          exercise: ex,
          sets: List.generate(
            setCount,
            (_) => WorkoutSet(weight: last?.weight ?? 0, reps: reps),
          ),
        ),
      ],
    );
    await services.workouts.saveDraft(draft);
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WorkoutRunnerScreen(initialDraft: draft)),
    );
    if (mounted) {
      setState(() {
        _lastPerformance = services.workouts.getLastPerformance(ex.id);
      });
    }
  }

  Future<void> _addToPlan(Exercise ex) async {
    final services = AppScope.maybeOf(context);
    if (services == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('计划功能暂不可用')),
      );
      return;
    }
    final plans = services.plans.getPlans();
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Text('加入计划', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            ),
            for (final plan in plans)
              ListTile(
                leading: const Icon(Icons.fitness_center_rounded, size: 20, color: AppTheme.primary),
                title: Text(plan.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                subtitle: Text('${plan.exercises.length} 个动作', style: const TextStyle(fontSize: 11)),
                onTap: () => Navigator.pop(ctx, plan.id),
              ),
            ListTile(
              leading: const Icon(Icons.add_circle_outline_rounded, size: 20, color: AppTheme.primary),
              title: const Text('新建计划', style: TextStyle(fontSize: 14, color: AppTheme.primary)),
              onTap: () => Navigator.pop(ctx, '__new__'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (choice == null) return;

    CustomPlan? target;
    if (choice == '__new__') {
      final name = await _askPlanName(ex);
      if (name == null) return;
      final now = DateTime.now();
      target = CustomPlan(
        id: now.millisecondsSinceEpoch.toString(),
        name: name,
        createdAt: now,
        updatedAt: now,
        exercises: const [],
      );
    } else {
      for (final plan in plans) {
        if (plan.id == choice) target = plan;
      }
    }
    if (target == null) return;

    final item = CustomExerciseItem(
      exercise: ex,
      sets: _sets,
      reps: _reps,
      restSeconds: _restSeconds,
      weight: _weight,
      order: target.exercises.length,
    );
    final updated = CustomPlan(
      id: target.id,
      name: target.name,
      createdAt: target.createdAt,
      updatedAt: DateTime.now(),
      exercises: [...target.exercises, item],
    );
    await services.plans.savePlan(updated);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已加入「${updated.name}」')),
    );
  }

  Future<String?> _askPlanName(Exercise ex) async {
    final controller = TextEditingController(text: '${ex.name} 计划');
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('新建计划'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '计划名称'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim().isEmpty ? '${ex.name} 计划' : controller.text.trim()),
            child: const Text('创建'),
          ),
        ],
      ),
    );
    controller.dispose();
    return name;
  }
}

class _VideoPlayerWidget extends StatelessWidget {
  final ChewieController chewieController;
  const _VideoPlayerWidget({required this.chewieController});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Chewie(controller: chewieController),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> items;
  const _InfoSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...items,
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            '${label}  ',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditableInfoRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  const _EditableInfoRow({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            '${label}  ',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFF1565C0),
                    width: 2,
                  ),
                ),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
