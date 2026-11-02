import 'dart:async';

import 'package:excise/app/app_scope.dart';
import 'package:excise/app/theme.dart';
import 'package:excise/data/exercises/exercise_alternatives.dart';
import 'package:excise/data/exercises/exercise_meta.dart';
import 'package:excise/data/models/models.dart';
import 'package:excise/data/models/workout_models.dart';
import 'package:excise/data/repositories/sample_repository.dart';
import 'package:excise/data/services/rest_reminder.dart';
import 'package:excise/ui/screens/workout_summary_screen.dart';
import 'package:excise/ui/widgets/exercise_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class WorkoutRunnerScreen extends StatefulWidget {
  final WorkoutDraft initialDraft;

  const WorkoutRunnerScreen({super.key, required this.initialDraft});

  @override
  State<WorkoutRunnerScreen> createState() => _WorkoutRunnerScreenState();
}

class _WorkoutRunnerScreenState extends State<WorkoutRunnerScreen> with WidgetsBindingObserver {
  static const _bg = Color(0xFF0B0F14);
  static const _card = Color(0xFF151D27);
  static const _line = Color(0xFF243040);
  static const _text = Color(0xFFF5F7FA);
  static const _muted = Color(0xFF98A6B8);
  static const _success = Color(0xFF30D158);

  late WorkoutDraft _draft;
  late int _exerciseIndex;
  late int _setIndex;
  bool _allowPop = false;
  bool _resting = false;
  bool _restEnabled = true;
  bool _finishing = false;
  bool _settingsLoaded = false;
  AppLifecycleState? _lifecycle;
  RestReminder? _reminder;

  int _restTotalSeconds = 60;
  DateTime? _restEnd;
  Duration _restRemaining = Duration.zero;
  Timer? _restTimer;
  Timer? _clockTimer;
  Duration _elapsed = Duration.zero;

  Timer? _holdTimer;
  DateTime? _holdEnd;
  int _holdTarget = 0;
  Duration _holdRemaining = Duration.zero;
  bool _holdRunning = false;
  bool _tipsExpanded = false;

  WorkoutExercise get _currentExercise => _draft.exercises[_exerciseIndex];
  WorkoutSet get _currentSet => _currentExercise.sets[_setIndex];
  bool get _isHold => _isHoldExercise(_currentExercise.exercise);

  /// 等长动作的计划秒数，跟 reps 共用同一个字段。
  int get _holdSecondsTarget => _currentSet.reps.clamp(1, 600).toInt();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _draft = widget.initialDraft;
    if (_draft.exercises.isEmpty) {
      _draft = WorkoutDraft(
        name: _draft.name,
        startedAt: _draft.startedAt,
        exercises: [
          WorkoutExercise(
            exercise: const Exercise(
              id: 'empty',
              name: '空训练',
              categoryPath: '力量训练 / 核心训练 / 核心训练',
              description: '',
            ),
            sets: [WorkoutSet(reps: 1)],
          ),
        ],
      );
    }
    _exerciseIndex = widget.initialDraft.exerciseIndex.clamp(0, _draft.exercises.length - 1).toInt();
    _setIndex = _currentExercise.sets.isEmpty
        ? 0
        : widget.initialDraft.setIndex.clamp(0, _currentExercise.sets.length - 1).toInt();
    _elapsed = DateTime.now().difference(_draft.startedAt);
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsed = DateTime.now().difference(_draft.startedAt));
    });
    _enableWakelock();
  }

  Future<void> _enableWakelock() async {
    try {
      await WakelockPlus.enable();
    } catch (_) {
      // 桌面/测试环境没有常亮能力，忽略。
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _restTimer?.cancel();
    _clockTimer?.cancel();
    _holdTimer?.cancel();
    unawaited(_reminder?.cancel() ?? Future<void>.value());
    try {
      WakelockPlus.disable();
    } catch (_) {}
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_settingsLoaded) return;
    _settingsLoaded = true;
    final services = AppScope.of(context);
    _restEnabled = services.settings.restEnabled;
    _reminder = services.restReminder;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycle = state;
    if (state == AppLifecycleState.resumed && _resting) {
      _tickRest();
    }
    if (state == AppLifecycleState.resumed && _holdRunning) {
      _tickHold();
    }
  }

  bool _isHoldExercise(Exercise exercise) {
    final name = exercise.name;
    return metaFor(exercise).primaryMuscle == '核心' &&
        (name.contains('支撑') || name.contains('平板') || name.contains('L支撑'));
  }

  String get _repsUnit => _isHold ? '秒' : '次';

  int get _totalSets => _draft.exercises.fold(0, (sum, e) => sum + e.sets.length);
  int get _completedSets => _draft.exercises.fold(0, (sum, e) => sum + e.completedSets);

  Future<void> _persist() async {
    if (!mounted) return;
    await AppScope.of(context).workouts.saveDraft(
          _draft.copyWith(exerciseIndex: _exerciseIndex, setIndex: _setIndex),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: _bg,
        colorScheme: const ColorScheme.dark(
          primary: AppTheme.primary,
          surface: _card,
          onSurface: _text,
          onSurfaceVariant: _muted,
        ),
        dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF1C2531)),
      ),
      child: PopScope(
        canPop: _allowPop,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) _confirmExit();
        },
        child: Scaffold(
          backgroundColor: _bg,
          body: SafeArea(
            child: _resting ? _buildRest() : _buildWorkout(),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkout() {
    final meta = metaFor(_currentExercise.exercise);
    final last = AppScope.of(context).workouts.getLastPerformance(_currentExercise.exercise.id);
    return Column(
      children: [
        _topBar(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
            children: [
              _exerciseCard(meta, last),
              if (_isHold) ...[
                const SizedBox(height: 12),
                _holdCard(),
              ],
              const SizedBox(height: 12),
              _setsCard(),
              const SizedBox(height: 12),
              _toolbar(),
            ],
          ),
        ),
        _completeBar(),
      ],
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 4, 12, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: _muted),
            onPressed: _confirmExit,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _draft.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _text),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_fmtDuration(_elapsed)} · $_completedSets/$_totalSets 组',
                  style: const TextStyle(fontSize: 11, color: _muted, fontFeatures: [FontFeature.tabularFigures()]),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _finishWorkout,
            style: TextButton.styleFrom(foregroundColor: _muted, padding: const EdgeInsets.symmetric(horizontal: 8)),
            child: const Text('结束', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _exerciseCard(ExerciseMeta meta, LastPerformance? last) {
    final exercise = _currentExercise.exercise;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(18), border: Border.all(color: _line)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 76,
                  height: 76,
                  child: ExerciseImage(exercise: exercise, animated: true, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _text),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${meta.primaryMuscle} · ${meta.equipment.label}${meta.compound ? ' · 复合' : ''}',
                      style: const TextStyle(fontSize: 11, color: _muted),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      last == null ? '上次：还没有记录' : '上次：${last.label}',
                      style: const TextStyle(fontSize: 11, color: _muted),
                    ),
                  ],
                ),
              ),
              Text(
                '${_exerciseIndex + 1}/${_draft.exercises.length}',
                style: const TextStyle(fontSize: 11, color: _muted, fontFeatures: [FontFeature.tabularFigures()]),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _bigValue(
                  label: '重量 (kg)',
                  value: _fmtWeight(_currentSet.weight),
                  onMinus: () => _changeWeight(-2.5),
                  onPlus: () => _changeWeight(2.5),
                  onTap: () => _editValue(weight: true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _bigValue(
                  label: _repsUnit,
                  value: '${_currentSet.reps}',
                  onMinus: () => _changeReps(-1),
                  onPlus: () => _changeReps(1),
                  onTap: () => _editValue(weight: false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _tipsSection(exercise),
        ],
      ),
    );
  }

  Widget _tipsSection(Exercise exercise) {
    // 自定义计划里只存动作 ID/名称，要点仍回到动作库查。
    var tips = exercise.tips;
    if (tips.isEmpty) {
      final matches = _allExercises().where((e) => e.id == exercise.id);
      if (matches.isNotEmpty) tips = matches.first.tips;
    }
    final canExpand = tips.length > 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 18, color: _line),
        Row(
          children: [
            const Icon(Icons.lightbulb_outline_rounded, size: 15, color: _muted),
            const SizedBox(width: 6),
            InkWell(
              onTap: tips.isEmpty ? null : () => setState(() => _tipsExpanded = !_tipsExpanded),
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('动作要点', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _text)),
                    if (canExpand) ...[
                      const SizedBox(width: 2),
                      Icon(
                        _tipsExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                        size: 16,
                        color: _muted,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: _swapExercise,
              borderRadius: BorderRadius.circular(6),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.swap_horiz_rounded, size: 14, color: _muted),
                    SizedBox(width: 2),
                    Text('替代动作', style: TextStyle(fontSize: 11, color: _muted)),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (tips.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text('暂无要点，按自己的节奏完成', style: TextStyle(fontSize: 11, color: _muted)),
          )
        else
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: canExpand ? () => setState(() => _tipsExpanded = !_tipsExpanded) : null,
            child: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                _tipsExpanded ? tips.map((t) => '· $t').join('\n') : tips.first,
                maxLines: _tipsExpanded ? null : 2,
                overflow: _tipsExpanded ? null : TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: _muted, height: 1.55),
              ),
            ),
          ),
      ],
    );
  }

  Widget _holdCard() {
    final target = _holdSecondsTarget;
    final hasSession = _holdRunning || _holdRemaining > Duration.zero;
    final remaining = hasSession ? _holdRemaining.inSeconds.clamp(0, 9999) : target;
    final progress = target <= 0 ? 0.0 : (1 - remaining / target).clamp(0.0, 1.0);
    final label = _holdRunning ? '暂停' : (hasSession && remaining < target ? '继续' : '开始计时');
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(18), border: Border.all(color: _line)),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.timer_outlined, size: 15, color: _muted),
              const SizedBox(width: 6),
              const Text('等长保持', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _text)),
              const Spacer(),
              Text('目标 $target 秒', style: const TextStyle(fontSize: 11, color: _muted)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '$remaining',
                style: const TextStyle(
                  fontSize: 34,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  color: _text,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 4),
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text('秒', style: TextStyle(fontSize: 11, color: _muted)),
              ),
              const Spacer(),
              SizedBox(
                height: 36,
                child: FilledButton(
                  onPressed: _toggleHold,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                  ),
                  child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                tooltip: '重置计时',
                onPressed: _resetHold,
                icon: const Icon(Icons.refresh_rounded, size: 19),
                color: _muted,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: _line,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bigValue({
    required String label,
    required String value,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF0F1620), borderRadius: BorderRadius.circular(14), border: Border.all(color: _line)),
      child: Column(
        children: [
          const SizedBox(height: 7),
          Text(label, style: const TextStyle(fontSize: 10, color: _muted)),
          Row(
            children: [
              _stepButton(Icons.remove_rounded, onMinus),
              Expanded(
                child: GestureDetector(
                  onTap: onTap,
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w700,
                      color: _text,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
              _stepButton(Icons.add_rounded, onPlus),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _stepButton(IconData icon, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, size: 20),
      color: _muted,
      onPressed: onTap,
      splashRadius: 20,
    );
  }

  Widget _setsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(18), border: Border.all(color: _line)),
      child: Column(
        children: [
          for (var i = 0; i < _currentExercise.sets.length; i++) _setRow(i),
        ],
      ),
    );
  }

  Widget _setRow(int index) {
    final set = _currentExercise.sets[index];
    final isCurrent = index == _setIndex;
    return InkWell(
      onTap: () => _selectSet(index),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: isCurrent ? AppTheme.primary.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isCurrent ? Border.all(color: AppTheme.primary.withValues(alpha: 0.35)) : null,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 44,
              child: Text(
                '第 ${index + 1} 组',
                style: TextStyle(
                  fontSize: 12,
                  color: set.isWarmup
                      ? const Color(0xFFFFB020)
                      : (isCurrent ? _text : _muted),
                  fontWeight: isCurrent || set.isWarmup ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            Expanded(
              child: Text(
                '${_fmtWeight(set.weight)} kg × ${set.reps} $_repsUnit',
                style: TextStyle(
                  fontSize: 13,
                  color: set.completed ? _success : (isCurrent ? _text : _muted),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            InkWell(
              onTap: () => _toggleWarmup(index),
              borderRadius: BorderRadius.circular(5),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: set.isWarmup ? const Color(0xFFFFB020).withValues(alpha: 0.2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: set.isWarmup
                        ? const Color(0xFFFFB020).withValues(alpha: 0.6)
                        : _line,
                  ),
                ),
                child: Text(
                  '热身',
                  style: TextStyle(
                    fontSize: 9,
                    color: set.isWarmup ? const Color(0xFFFFB020) : _muted,
                    fontWeight: set.isWarmup ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            if (set.completed)
              const Icon(Icons.check_circle_rounded, size: 20, color: _success)
            else
              Icon(Icons.circle_outlined, size: 18, color: isCurrent ? AppTheme.primary : _line),
          ],
        ),
      ),
    );
  }

  Widget _toolbar() {
    return Row(
      children: [
        _toolButton(Icons.add_rounded, '加组', _addSet),
        _toolButton(Icons.swap_horiz_rounded, '换动作', _swapExercise),
        _toolButton(Icons.notes_rounded, '备注', _editNote),
        _toolButton(Icons.skip_next_rounded, '跳过', _skipExercise),
        _toolButton(Icons.skip_previous_rounded, '上一', () => _goExercise(-1)),
      ],
    );
  }

  Widget _toolButton(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Column(
            children: [
              Icon(icon, size: 20, color: _muted),
              const SizedBox(height: 3),
              Text(label, style: const TextStyle(fontSize: 10, color: _muted)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _completeBar() {
    final finishedExercise = _currentExercise.isFinished;
    final isLastExercise = _exerciseIndex >= _draft.exercises.length - 1;
    final label = finishedExercise
        ? (isLastExercise ? '完成训练' : '下一个动作')
        : '完成第 ${_setIndex + 1} 组';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: SizedBox(
        height: 54,
        width: double.infinity,
        child: FilledButton(
          onPressed: finishedExercise
              ? (isLastExercise ? _finishWorkout : () => _goExercise(1))
              : _completeSet,
          style: FilledButton.styleFrom(
            backgroundColor: finishedExercise ? _success : AppTheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 组间休息
  // ---------------------------------------------------------------------------

  Widget _buildRest() {
    final next = _nextTargetDescription();
    final progress = _restTotalSeconds <= 0 ? 0.0 : _restRemaining.inMilliseconds / (_restTotalSeconds * 1000);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      child: Column(
        children: [
          Row(
            children: [
              const Text('组间休息', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _text)),
              const Spacer(),
              TextButton(
                onPressed: _skipRest,
                style: TextButton.styleFrom(foregroundColor: _muted),
                child: const Text('跳过'),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: 230,
            height: 230,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 220,
                  height: 220,
                  child: CircularProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    strokeWidth: 9,
                    backgroundColor: _line,
                    color: AppTheme.primary,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_restRemaining.inSeconds.clamp(0, 999)}',
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w700,
                        color: _text,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    const Text('秒', style: TextStyle(fontSize: 13, color: _muted)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          Text(next, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: _muted, height: 1.5)),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _addRestTime,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _text,
                    side: const BorderSide(color: _line),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                  ),
                  child: const Text('+15 秒'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _skipRest,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                  ),
                  child: const Text('开始下一组'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: () {
              setState(() => _restEnabled = false);
              unawaited(AppScope.of(context).settings.setRestEnabled(false));
              _skipRest();
            },
            style: TextButton.styleFrom(foregroundColor: _muted),
            child: const Text('关闭自动休息', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  String _nextTargetDescription() {
    final exercise = _currentExercise.exercise;
    return '下一组：第 ${_setIndex + 1} / ${_currentExercise.sets.length} 组 · ${exercise.name}\n'
        '${_fmtWeight(_currentSet.weight)} kg × ${_currentSet.reps} $_repsUnit';
  }

  void _startRest(int seconds) {
    if (!_restEnabled || seconds <= 0) return;
    _restTotalSeconds = seconds;
    _restEnd = DateTime.now().add(Duration(seconds: seconds));
    _restRemaining = Duration(seconds: seconds);
    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(milliseconds: 200), (_) => _tickRest());
    setState(() => _resting = true);
    // 第一次休息时申请通知权限，后台也能收到结束提醒。
    unawaited(_reminder?.ensurePermission() ?? Future<void>.value());
  }

  void _tickRest() {
    final end = _restEnd;
    if (end == null) return;
    final remaining = end.difference(DateTime.now());
    if (remaining <= Duration.zero) {
      _finishRest(vibrate: true);
    } else if (mounted) {
      setState(() => _restRemaining = remaining);
    }
  }

  void _addRestTime() {
    final end = _restEnd;
    if (end == null) return;
    setState(() {
      _restEnd = end.add(const Duration(seconds: 15));
      _restTotalSeconds += 15;
      _restRemaining = _restEnd!.difference(DateTime.now());
    });
  }

  void _skipRest() => _finishRest(vibrate: false);

  Future<void> _finishRest({required bool vibrate}) async {
    _restTimer?.cancel();
    _restEnd = null;
    if (mounted) {
      setState(() {
        _resting = false;
        _restRemaining = Duration.zero;
      });
    }
    final reminder = _reminder;
    if (reminder == null) return;
    if (!vibrate) {
      await reminder.cancel();
      return;
    }
    try {
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(pattern: [0, 250, 90, 250]);
      }
    } catch (_) {}
    try {
      await SystemSound.play(SystemSoundType.alert);
    } catch (_) {}
    // 前台有画面和声音，后台才补一条通知。
    if (_lifecycle != AppLifecycleState.resumed) {
      await reminder.showRestFinished();
    }
  }

  // ---------------------------------------------------------------------------
  // 等长动作计时
  // ---------------------------------------------------------------------------

  void _toggleHold() {
    if (_holdRunning) {
      _pauseHold();
      return;
    }
    final target = _holdSecondsTarget;
    if (_holdRemaining <= Duration.zero || _holdTarget != target) {
      _holdTarget = target;
      _holdRemaining = Duration(seconds: target);
    }
    _holdEnd = DateTime.now().add(_holdRemaining);
    _holdTimer?.cancel();
    _holdTimer = Timer.periodic(const Duration(milliseconds: 200), (_) => _tickHold());
    setState(() => _holdRunning = true);
  }

  void _pauseHold() {
    _holdTimer?.cancel();
    final end = _holdEnd;
    if (end != null) {
      final remaining = end.difference(DateTime.now());
      _holdRemaining = remaining.isNegative ? Duration.zero : remaining;
    }
    setState(() {
      _holdRunning = false;
      _holdEnd = null;
    });
  }

  void _tickHold() {
    if (!mounted) return;
    final end = _holdEnd;
    if (end == null) return;
    final remaining = end.difference(DateTime.now());
    if (remaining <= Duration.zero) {
      _finishHold();
      return;
    }
    setState(() => _holdRemaining = remaining);
  }

  void _finishHold() {
    _holdTimer?.cancel();
    if (!mounted) return;
    final target = _holdTarget;
    setState(() {
      _holdRunning = false;
      _holdEnd = null;
      _holdRemaining = Duration.zero;
      if (target > 0) _currentSet.reps = target;
    });
    _showMessage('计时结束，已记录 $target 秒');
    unawaited(_persist());
    unawaited(_holdFeedback());
  }

  Future<void> _holdFeedback() async {
    try {
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(pattern: [0, 180, 80, 180]);
      }
    } catch (_) {}
    try {
      await SystemSound.play(SystemSoundType.alert);
    } catch (_) {}
  }

  void _resetHold() {
    setState(_cancelHold);
  }

  void _cancelHold() {
    _holdTimer?.cancel();
    _holdRunning = false;
    _holdEnd = null;
    _holdRemaining = Duration.zero;
    _holdTarget = 0;
  }

  // ---------------------------------------------------------------------------
  // 组操作
  // ---------------------------------------------------------------------------

  void _selectSet(int index) {
    final set = _currentExercise.sets[index];
    setState(() {
      _cancelHold();
      _setIndex = index;
      if (set.completed) {
        set.completed = false;
        set.completedAt = null;
      }
    });
    _persist();
  }

  void _toggleWarmup(int index) {
    final set = _currentExercise.sets[index];
    final last = AppScope.of(context).workouts.getLastPerformance(_currentExercise.exercise.id);
    var suggested = 0.0;
    var fromLast = false;
    setState(() {
      set.isWarmup = !set.isWarmup;
      if (set.isWarmup && !set.completed) {
        // 优先按上次正式组的一半给建议；没有历史时退回当前重量的一半。
        final reference = (last != null && last.weight > 0)
            ? last.weight
            : (set.weight > 0 ? set.weight : 0.0);
        if (reference > 0) {
          fromLast = last != null && last.weight > 0;
          suggested = ((reference * 0.5) * 2).round() / 2;
          set.weight = suggested;
        }
      }
    });
    _persist();
    if (suggested > 0) {
      _showMessage(
        '热身组建议 ${_fmtWeight(suggested)} kg（${fromLast ? '上次' : '当前重量'}的一半）',
      );
    }
  }

  void _changeWeight(double delta) {
    final value = (_currentSet.weight + delta).clamp(0.0, 500.0).toDouble();
    setState(() => _currentSet.weight = (value * 2).round() / 2);
    _persist();
  }

  void _changeReps(int delta) {
    final value = (_currentSet.reps + delta).clamp(1, 100).toInt();
    setState(() {
      _cancelHold();
      _currentSet.reps = value;
    });
    _persist();
  }

  Future<void> _editValue({required bool weight}) async {
    final controller = TextEditingController(
      text: weight ? _fmtWeight(_currentSet.weight) : '${_currentSet.reps}',
    );
    final result = await showDialog<(String, bool)>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(weight ? '输入重量 (kg)' : '输入$_repsUnit'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(hintText: weight ? '例如 60' : '例如 8'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          if (weight)
            TextButton(
              onPressed: () => Navigator.pop(context, (controller.text, true)),
              child: const Text('应用到全部组'),
            ),
          FilledButton(
            onPressed: () => Navigator.pop(context, (controller.text, false)),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    if (result == null) return;
    final (text, applyAll) = result;
    if (weight) {
      final parsed = double.tryParse(text.trim());
      if (parsed == null) return;
      final value = parsed.clamp(0.0, 500.0).toDouble();
      setState(() {
        if (applyAll) {
          _currentExercise.applyWeightToUncompleted(value);
        } else {
          _currentSet.weight = value;
        }
      });
      _persist();
    } else {
      final parsed = int.tryParse(text.trim());
      if (parsed != null) {
        setState(() {
          _cancelHold();
          _currentSet.reps = parsed.clamp(1, 100).toInt();
        });
        _persist();
      }
    }
  }

  Future<void> _completeSet() async {
    final set = _currentSet;
    if (set.completed) return;
    final carriedWeight = set.isWarmup ? 0.0 : set.weight;
    set
      ..completed = true
      ..completedAt = DateTime.now();
    final target = _nextUncompleted(afterExercise: _exerciseIndex, afterSet: _setIndex);
    final restSeconds = int.tryParse(_currentExercise.exercise.restSeconds) ?? 60;
    if (target == null) {
      await _persist();
      await _finishWorkout();
      return;
    }
    // 同一动作继续下一组时沿用本组重量；用户单独填过的组不覆盖。
    if (target.$1 == _exerciseIndex) {
      _draft.exercises[target.$1].seedWeight(carriedWeight);
    }
    setState(() {
      _cancelHold();
      _tipsExpanded = false;
      _exerciseIndex = target.$1;
      _setIndex = target.$2;
    });
    await _persist();
    if (!mounted) return;
    _startRest(restSeconds);
  }

  (int, int)? _nextUncompleted({required int afterExercise, required int afterSet}) {
    for (var e = afterExercise; e < _draft.exercises.length; e++) {
      final start = e == afterExercise ? afterSet + 1 : 0;
      final sets = _draft.exercises[e].sets;
      for (var s = start; s < sets.length; s++) {
        if (!sets[s].completed) return (e, s);
      }
    }
    return null;
  }

  void _addSet() {
    final sets = _currentExercise.sets;
    final last = sets.isEmpty ? WorkoutSet(reps: 8) : sets.last;
    final added = WorkoutSet(weight: last.weight, reps: last.reps);
    setState(() {
      _cancelHold();
      _currentExercise.sets.add(added);
      _setIndex = _currentExercise.sets.length - 1;
    });
    _persist();
  }

  void _goExercise(int delta) {
    final next = (_exerciseIndex + delta).clamp(0, _draft.exercises.length - 1);
    if (next == _exerciseIndex) return;
    setState(() {
      _cancelHold();
      _tipsExpanded = false;
      _exerciseIndex = next;
      _setIndex = _firstUncompletedSetIndex(_exerciseIndex);
    });
    _persist();
  }

  int _firstUncompletedSetIndex(int exerciseIndex) {
    final sets = _draft.exercises[exerciseIndex].sets;
    for (var i = 0; i < sets.length; i++) {
      if (!sets[i].completed) return i;
    }
    return sets.isEmpty ? 0 : sets.length - 1;
  }

  Future<void> _skipExercise() async {
    final next = _exerciseIndex + 1;
    if (next >= _draft.exercises.length) {
      await _finishWorkout();
      return;
    }
    setState(() {
      _cancelHold();
      _tipsExpanded = false;
      _exerciseIndex = next;
      _setIndex = _firstUncompletedSetIndex(next);
    });
    await _persist();
  }

  Future<void> _swapExercise() async {
    final current = _currentExercise.exercise;
    final muscle = metaFor(current).primaryMuscle;
    final usedIds = _draft.exercises.map((e) => e.exercise.id).toSet();
    final all = _allExercises();
    final alternatives = alternativesFor(
      exercise: current,
      all: all,
      excludeIds: usedIds,
      limit: 24,
    );
    if (alternatives.isEmpty) {
      _showMessage('该肌群没有可替换的动作');
      return;
    }
    final picked = await showModalBottomSheet<Exercise>(
      context: context,
      backgroundColor: const Color(0xFF1C2531),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Row(
                children: [
                  Text('替换 $muscle 动作', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _text)),
                  const Spacer(),
                  Text(current.name, style: const TextStyle(fontSize: 11, color: _muted)),
                ],
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
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: ExerciseImage(exercise: exercise, fit: BoxFit.cover),
                      ),
                    ),
                    title: Text(exercise.name, style: const TextStyle(color: _text, fontSize: 14)),
                    subtitle: Text(
                      '${metaFor(exercise).equipment.label} · ${movementPatternFor(exercise).label}',
                      style: const TextStyle(color: _muted, fontSize: 11),
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
    if (picked == null || !mounted) return;

    final hadCompleted = _currentExercise.completedSets > 0;
    final previousSets = _currentExercise.sets;
    final weight = previousSets.isEmpty ? 0.0 : previousSets.last.weight;
    final reps = previousSets.isEmpty ? 8 : previousSets.last.reps;
    final replacement = WorkoutExercise(
      exercise: picked,
      sets: List.generate(previousSets.length.clamp(1, 10).toInt(), (_) => WorkoutSet(weight: weight, reps: reps)),
    );
    setState(() {
      if (hadCompleted) {
        // 已完成的组保留在原动作下，新动作插到后面继续。
        _draft.exercises.insert(_exerciseIndex + 1, replacement);
        _exerciseIndex = _exerciseIndex + 1;
      } else {
        _draft.exercises[_exerciseIndex] = replacement;
      }
      _cancelHold();
      _tipsExpanded = false;
      _setIndex = 0;
    });
    await _persist();
  }

  List<Exercise> _allExercises() {
    return _exerciseCache ??= SampleExerciseRepository().getExercises('all');
  }

  List<Exercise>? _exerciseCache;

  Future<void> _editNote() async {
    final controller = TextEditingController(text: _currentExercise.note);
    final note = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${_currentExercise.exercise.name} 备注'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(hintText: '例如：肩膀有点紧、下次加 2.5kg'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('保存')),
        ],
      ),
    );
    if (note == null) return;
    setState(() => _currentExercise.note = note);
    await _persist();
  }

  Future<void> _finishWorkout() async {
    if (_finishing) return;
    if (_completedSets == 0) {
      _showMessage('至少完成一组再结束训练');
      return;
    }
    _finishing = true;
    _restTimer?.cancel();
    await _persist();
    final session = WorkoutSession(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      planId: _draft.planId,
      name: _draft.name,
      startedAt: _draft.startedAt,
      endedAt: DateTime.now(),
      exercises: _draft.exercises,
    );
    if (!mounted) return;
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => WorkoutSummaryScreen(session: session)),
    );
  }

  Future<void> _confirmExit() async {
    if (_finishing) return;
    if (_resting) {
      _restTimer?.cancel();
      setState(() => _resting = false);
    }
    final action = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出训练？'),
        content: Text(_completedSets > 0 ? '已完成 $_completedSets 组，可以保存为草稿下次继续。' : '还没有完成任何一组。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, 'cancel'), child: const Text('继续训练')),
          TextButton(onPressed: () => Navigator.pop(context, 'discard'), child: const Text('放弃', style: TextStyle(color: AppTheme.accentRed))),
          FilledButton(onPressed: () => Navigator.pop(context, 'save'), child: const Text('保存并退出')),
        ],
      ),
    );
    if (!mounted || action == null || action == 'cancel') return;
    final services = AppScope.of(context);
    if (action == 'save') {
      await _persist();
      if (!mounted) return;
      _popNow();
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确定放弃本次训练？'),
        content: const Text('本次记录会被删除，无法恢复。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('返回')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.accentRed),
            child: const Text('放弃'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await services.workouts.clearDraft();
    if (!mounted) return;
    _popNow();
  }

  /// PopScope 会拦截普通 pop，先把 canPop 置为 true 再在下一帧退出。
  void _popNow() {
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.pop(context);
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _fmtWeight(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }

  String _fmtDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }
}
