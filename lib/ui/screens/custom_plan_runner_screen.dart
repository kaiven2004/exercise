import 'dart:async';
import 'package:excise/data/models/models.dart';
import 'package:excise/data/repositories/exercise_override_repository.dart';
import 'package:excise/data/repositories/local_repositories.dart';
import 'package:excise/ui/widgets/svg_icons.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class CustomPlanRunnerScreen extends StatefulWidget {
  final CustomPlan plan;
  const CustomPlanRunnerScreen({super.key, required this.plan});

  @override
  State<CustomPlanRunnerScreen> createState() => _CustomPlanRunnerScreenState();
}

class _CustomPlanRunnerScreenState extends State<CustomPlanRunnerScreen>
    with TickerProviderStateMixin {
  late List<int> _completedSets;
  late List<Timer?> _setTimers;
  late List<Duration> _setDurations;
  int _currentExerciseIndex = 0;
  bool _running = false;
  Duration _totalElapsed = Duration.zero;
  Duration _setElapsed = Duration.zero;
  Timer? _totalTimer;
  Timer? _setTimer;
  bool _resting = false;
  Duration _restRemaining = Duration.zero;
  Timer? _restTimer;
  late final CustomPlan _plan;
  late final LocalTrainingHistoryRepository _histRepo;
  late final ExerciseOverrideRepository _overrideRepo;

  @override
  void initState() {
    super.initState();
    _plan = widget.plan;
    _histRepo = LocalTrainingHistoryRepository();
    _completedSets = List.generate(_plan.exercises.length, (_) => 0);
    _setTimers = List.generate(_plan.exercises.length, (_) => null);
    _setDurations = List.generate(_plan.exercises.length, (_) => Duration.zero);
    _histRepo.init();
    _overrideRepo = ExerciseOverrideRepository();
    _overrideRepo.init();
  }

  @override
  void dispose() {
    _totalTimer?.cancel();
    _setTimer?.cancel();
    _restTimer?.cancel();
    for (final t in _setTimers) t?.cancel();
    super.dispose();
  }

  void _startSession() {
    setState(() {
      _running = true;
      _currentExerciseIndex = 0;
      _completedSets = List.generate(_plan.exercises.length, (_) => 0);
      _setDurations = List.generate(_plan.exercises.length, (_) => Duration.zero);
      _totalElapsed = Duration.zero;
      _setElapsed = Duration.zero;
      _resting = false;
    });
    _totalTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _totalElapsed = _totalElapsed + const Duration(seconds: 1));
    });
    _setTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _setElapsed = _setElapsed + const Duration(seconds: 1));
    });
  }

  void _completeSet() {
    if (_currentExerciseIndex >= _plan.exercises.length) return;
    _setTimers[_currentExerciseIndex]?.cancel();
    _setDurations[_currentExerciseIndex] = _setElapsed;
    setState(() => _completedSets[_currentExerciseIndex]++);
    if (_completedSets[_currentExerciseIndex] >= _effSets(_plan.exercises[_currentExerciseIndex])) {
      if (_currentExerciseIndex < _plan.exercises.length - 1) {
        _startRest(_effRest(_plan.exercises[_currentExerciseIndex]));
      } else {
        _finishPlan();
      }
    } else {
      _startRest(_effRest(_plan.exercises[_currentExerciseIndex]));
    }
  }

  void _startRest(String restSecondsStr) {
    _setTimer?.cancel();
    final restSeconds = int.tryParse(restSecondsStr) ?? 60;
    setState(() {
      _resting = true;
      _restRemaining = Duration(seconds: restSeconds);
    });
    _restTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        if (_restRemaining.inSeconds <= 0) return;
        _restRemaining = _restRemaining - const Duration(seconds: 1);
        if (_restRemaining.inSeconds <= 0) {
          _restRemaining = Duration.zero;
          _restTimer?.cancel();
          if (mounted) _onRestFinished();
        }
      });
    });
  }

  Future<void> _onRestFinished() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(pattern: [0, 300, 100, 300, 100, 300]);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('休息结束！点击继续下一组'),
        backgroundColor: Color(0xFFFF9800),
        duration: Duration(seconds: 2),
      ));
    }
  }

  void _finishPlan() {
    _totalTimer?.cancel();
    _setTimer?.cancel();
    _restTimer?.cancel();
    setState(() => _running = false);
    final session = TrainingSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      sectionName: '自定义训练',
      categoryPath: _plan.name,
      exercises: _plan.exercises.map((item) => ExerciseLog(
        exercise: item.exercise,
        completedSets: _completedSets[_plan.exercises.indexOf(item)],
        totalReps: _completedSets[_plan.exercises.indexOf(item)] * _effReps(item),
      )).toList(),
    );
    _histRepo.addSession(session);
    if (mounted) {
      showDialog(context: context, builder: (ctx) => AlertDialog(
        title: const Text('训练完成'),
        content: Text('《${_plan.name}》已完成，总用时${_formatDuration(_totalElapsed)}'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('确定'))],
      ));
    }
  }

  void _continueAfterRest() {
    _restTimer?.cancel();
    setState(() {
      _resting = false;
      if (_completedSets[_currentExerciseIndex] >= _effSets(_plan.exercises[_currentExerciseIndex]) && _currentExerciseIndex < _plan.exercises.length - 1) _currentExerciseIndex++;
      _setElapsed = Duration.zero;
    });
    _setTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _setElapsed = _setElapsed + const Duration(seconds: 1));
    });
  }

  Widget _buildButton() {
    final label = _resting ? '休息结束，继续' : (_running ? '完成组' : '开始训练');
    final action = _resting ? _continueAfterRest : (_running ? _completeSet : _startSession);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: SizedBox(
        height: 56, width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _resting ? const Color(0xFFFF9800) : const Color(0xFF1565C0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: action,
          child: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_plan.exercises.isEmpty) {
      return Scaffold(appBar: AppBar(title: Text(_plan.name)), body: const Center(child: Text('计划中没有动作，请先编辑计划')));
    }
    final current = _plan.exercises[_currentExerciseIndex];
    final progress = _completedSets[_currentExerciseIndex] / _effSets(current);
    return Scaffold(
      appBar: AppBar(title: Text(_plan.name)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            LinearProgressIndicator(value: progress, backgroundColor: theme.colorScheme.surfaceContainerHighest, valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1565C0))),
            Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0), child: Row(
              children: [
                Text('动作 ${_currentExerciseIndex + 1}/${_plan.exercises.length}', style: theme.textTheme.titleSmall),
                const Spacer(),
                Text('第${_completedSets[_currentExerciseIndex] + 1}/${current.sets} 组', style: theme.textTheme.titleSmall),
              ],
            )),
            const SizedBox(height: 12),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Card(
              child: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(width: 100, height: 100, decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(20)),
                  child: SvgIcon(assetName: current.exercise.imageSvg, size: 56, color: const Color(0xFF1565C0))),
                const SizedBox(height: 16),
                Text(current.exercise.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Text(current.exercise.categoryPath, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 20),
                SizedBox(height: 56, child: Row(children: [
                  Expanded(child: _StatBox(label: '目标', value: '${current.sets}组')),
                  const SizedBox(width: 8),
                  Expanded(child: _StatBox(label: '次数', value: '${current.reps}次')),
                  if (current.weight.isNotEmpty) const SizedBox(width: 8),
                  Expanded(child: _StatBox(label: '重量', value: '${current.weight}')),
                  const SizedBox(width: 8),
                  Expanded(child: _StatBox(label: '休息', value: '${current.restSeconds}s')),
                ])),
              ])),
            ),
          ),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _TimerDisplay(label: '总用时', duration: _totalElapsed, color: const Color(0xFF1565C0)),
              const SizedBox(width: 32),
              _TimerDisplay(label: '本组用时', duration: _setElapsed, color: const Color(0xFF0277BD)),
            ])),
            if (_resting) Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Column(children: [
              Text('组间休息', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 4),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SizedBox(width: 160, height: 6, child: LinearProgressIndicator(
                  value: _restRemaining.inSeconds / (int.tryParse(current.restSeconds) ?? 1),
                  backgroundColor: Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF9800))),
                ),
                const SizedBox(width: 12),
                Text('${_restRemaining.inSeconds}秒', style: theme.textTheme.titleLarge?.copyWith(color: const Color(0xFFFF9800), fontWeight: FontWeight.bold)),
              ]),
            ])),
            _buildButton(),
            const SizedBox(height: 88),
          ],
        ),
      ),
    );
  }

  int _effSets(CustomExerciseItem item) => _overrideRepo.getEffectiveSets(item.exercise.id, item.sets);
  int _effReps(CustomExerciseItem item) => _overrideRepo.getEffectiveReps(item.exercise.id, item.reps);
  String _effRest(CustomExerciseItem item) => _overrideRepo.getEffectiveRest(item.exercise.id, item.restSeconds);

  String _formatDuration(Duration d) {
    final min = d.inMinutes.toString().padLeft(2, '0');
    final sec = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }
}

class _TimerDisplay extends StatelessWidget {
  final String label;
  final Duration duration;
  final Color color;
  const _TimerDisplay({required this.label, required this.duration, required this.color});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(children: [
      Text(_formatDuration(duration), style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color)),
      const SizedBox(height: 2),
      Text(label, style: theme.textTheme.bodySmall),
    ]);
  }
  String _formatDuration(Duration d) {
    final min = d.inMinutes.toString().padLeft(2, '0');
    final sec = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  const _StatBox({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(padding: const EdgeInsets.symmetric(vertical: 6), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF1565C0)), textAlign: TextAlign.center),
      const SizedBox(height: 2),
      Text(label, style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
    ]));
  }
}