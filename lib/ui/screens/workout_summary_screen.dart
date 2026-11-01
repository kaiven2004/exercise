import 'dart:async';

import 'package:excise/app/app_scope.dart';
import 'package:excise/app/theme.dart';
import 'package:excise/data/exercises/exercise_meta.dart';
import 'package:excise/data/models/workout_models.dart';
import 'package:excise/data/services/personal_record_service.dart';
import 'package:excise/ui/screens/workout_runner_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

/// 训练总结。保存后清除草稿；「再来一次」立即用同样的动作开新训练。
class WorkoutSummaryScreen extends StatefulWidget {
  final WorkoutSession session;

  const WorkoutSummaryScreen({super.key, required this.session});

  @override
  State<WorkoutSummaryScreen> createState() => _WorkoutSummaryScreenState();
}

class _WorkoutSummaryScreenState extends State<WorkoutSummaryScreen> {
  static const _dark = Color(0xFF101828);

  late final List<WorkoutExercise> _exercises;
  late final WorkoutSession _preview;

  final TextEditingController _noteController = TextEditingController();
  List<PrResult> _prs = const [];
  bool _prsLoaded = false;
  int _rpe = 0;
  bool _saving = false;
  bool _allowPop = false;
  bool _persisted = false;

  @override
  void initState() {
    super.initState();
    // 只保留真正完成的组，避免把计划组算进历史。
    _exercises = widget.session.exercises
        .where((e) => e.completedSets > 0)
        .map(
          (e) => WorkoutExercise(
            exercise: e.exercise,
            sets: e.sets
                .where((s) => s.completed)
                .map((s) => WorkoutSet(
                      weight: s.weight,
                      reps: s.reps,
                      completed: true,
                      completedAt: s.completedAt,
                      isWarmup: s.isWarmup,
                    ))
                .toList(),
            note: e.note,
          ),
        )
        .toList();
    _preview = WorkoutSession(
      id: widget.session.id,
      planId: widget.session.planId,
      name: widget.session.name,
      startedAt: widget.session.startedAt,
      endedAt: widget.session.endedAt,
      exercises: _exercises,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prsLoaded) return;
    _prsLoaded = true;
    final history = AppScope.of(context).workouts.getSessions();
    _prs = PersonalRecordService.detect(_preview, history);
    // 进入总结页即落库并清草稿，避免直接返回时记录丢失。
    unawaited(_autoPersist());
  }

  Future<void> _autoPersist() async {
    if (_persisted || _exercises.isEmpty) return;
    _persisted = true;
    await _persistSession();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Duration get _duration {
    final value = widget.session.endedAt.difference(widget.session.startedAt);
    return value.isNegative ? Duration.zero : value;
  }

  int get _totalSets => _exercises.fold(0, (sum, e) => sum + e.completedSets);

  double get _totalVolume => _exercises.fold(0.0, (sum, e) => sum + e.volume);

  int get _totalBodyweightReps => _exercises.fold(0, (sum, e) => sum + e.bodyweightReps);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _saveAndLeave();
      },
      child: Scaffold(
        backgroundColor: AppTheme.bgMain,
        body: SafeArea(
          child: Column(
            children: [
              _topBar(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  children: [
                    _hero(),
                    const SizedBox(height: 14),
                    _statsCard(),
                    if (_prs.isNotEmpty) ...[
                      const SizedBox(height: 22),
                      _sectionTitle('新纪录'),
                      const SizedBox(height: 10),
                      for (final pr in _prs.take(3)) ...[
                        _prCard(pr),
                        const SizedBox(height: 8),
                      ],
                    ],
                    const SizedBox(height: 22),
                    _sectionTitle('训练量分布'),
                    const SizedBox(height: 10),
                    _muscleCard(),
                    const SizedBox(height: 22),
                    _sectionTitle('今天感觉如何'),
                    const SizedBox(height: 10),
                    _rpeCard(),
                    const SizedBox(height: 22),
                    _sectionTitle('备注'),
                    const SizedBox(height: 10),
                    _noteField(),
                  ],
                ),
              ),
              _bottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 16, 6),
      child: Row(
        children: [
          const SizedBox(width: 40, height: 40),
          const Expanded(
            child: Text(
              '训练总结',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            ),
          ),
          const SizedBox(width: 40, height: 40),
        ],
      ),
    );
  }

  Widget _hero() {
    final date = DateFormat('M月d日 HH:mm', 'zh_CN').format(widget.session.startedAt);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(color: _dark, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: const Color(0xFF30D158).withValues(alpha: 0.16), shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, size: 22, color: Color(0xFF30D158)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('训练完成', style: TextStyle(fontSize: 12, color: Color(0xFF8FA3BF), letterSpacing: 1)),
                    const SizedBox(height: 3),
                    Text(
                      widget.session.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _fmtDuration(_duration),
                style: const TextStyle(
                  fontSize: 40,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text('总用时', style: TextStyle(fontSize: 12, color: Color(0xFFB6C2D4))),
              ),
              const Spacer(),
              Text(date, style: const TextStyle(fontSize: 11, color: Color(0xFF8FA3BF))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          _stat('动作', '${_exercises.length}', '个'),
          _divider(),
          _stat('完成', '$_totalSets', '组'),
          _divider(),
          if (_totalVolume > 0)
            _stat('容量', _fmtVolume(_totalVolume), '')
          else
            _stat('自重', '$_totalBodyweightReps', '次'),
          _divider(),
          _stat('新纪录', '${_prs.length}', '项'),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, String unit) {
    return Expanded(
      child: Column(
        children: [
          RichText(
            textDirection: TextDirection.ltr,
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                if (unit.isNotEmpty)
                  TextSpan(text: ' $unit', style: const TextStyle(fontSize: 10, color: AppTheme.textTertiary)),
              ],
            ),
          ),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
        ],
      ),
    );
  }

  Widget _divider() => Container(width: 0.5, height: 26, color: AppTheme.divider);

  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary));
  }

  Widget _prCard(PrResult pr) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFF9500).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: const Color(0xFFFF9500).withValues(alpha: 0.14), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.emoji_events_rounded, size: 21, color: Color(0xFFFF9500)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pr.exerciseName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                const SizedBox(height: 2),
                Text('${pr.setLabel} · ${pr.recordLabel}', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          if (pr.kind == PrKind.estimatedOneRepMax)
            Text(
              '+${pr.improvement.toStringAsFixed(1)}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFFF9500)),
            ),
        ],
      ),
    );
  }

  Widget _muscleCard() {
    final counts = <String, int>{};
    for (final exercise in _exercises) {
      final muscle = metaFor(exercise.exercise).primaryMuscle;
      counts[muscle] = (counts[muscle] ?? 0) + exercise.completedWorkingSets;
    }
    final entries = counts.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) {
        final ia = kMuscleGroupOrder.indexOf(a.key);
        final ib = kMuscleGroupOrder.indexOf(b.key);
        return (ia < 0 ? 99 : ia).compareTo(ib < 0 ? 99 : ib);
      });
    final maxSets = entries.isEmpty ? 1 : entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    const colors = [
      AppTheme.primary,
      AppTheme.accent,
      AppTheme.accentWarm,
      AppTheme.accentPurple,
      AppTheme.accentTeal,
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < entries.length; i++) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Text(entries[i].key, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: entries[i].value / maxSets,
                        minHeight: 8,
                        backgroundColor: const Color(0xFFF0F1F4),
                        color: colors[i % colors.length],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 42,
                    child: Text(
                      '${entries[i].value} 组',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (entries.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 14),
              child: Text('还没有完成任何组', style: TextStyle(fontSize: 12, color: AppTheme.textTertiary)),
            ),
        ],
      ),
    );
  }

  Widget _rpeCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _rpe == 0 ? 'RPE 用力程度（可选）' : 'RPE $_rpe / 10',
            style: const TextStyle(fontSize: 12, color: AppTheme.textTertiary),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var value = 1; value <= 10; value++)
                _rpeChip(value),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rpeChip(int value) {
    final selected = _rpe == value;
    return GestureDetector(
      onTap: () => setState(() => _rpe = selected ? 0 : value),
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : const Color(0xFFF4F5F7),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          '$value',
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? Colors.white : AppTheme.textSecondary,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }

  Widget _noteField() {
    return TextField(
      controller: _noteController,
      maxLines: 3,
      maxLength: 200,
      style: const TextStyle(fontSize: 14, height: 1.5),
      decoration: InputDecoration(
        hintText: '例如：今天状态不错，卧推下次加 2.5kg',
        hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textTertiary),
        filled: true,
        fillColor: Colors.white,
        counterText: '',
        contentPadding: const EdgeInsets.all(14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppTheme.divider.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppTheme.divider.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.primary),
        ),
      ),
    );
  }

  Widget _bottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.divider, width: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: _saving ? null : () => _save(repeat: false),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                _saving ? '保存中…' : '保存并完成',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          TextButton(
            onPressed: _saving ? null : () => _save(repeat: true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.textSecondary),
            child: const Text('再来一次', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  WorkoutSession _buildSession() {
    return WorkoutSession(
      id: widget.session.id,
      planId: widget.session.planId,
      name: widget.session.name,
      startedAt: widget.session.startedAt,
      endedAt: widget.session.endedAt,
      exercises: _exercises,
      rpe: _rpe,
      note: _noteController.text.trim(),
    );
  }

  Future<void> _persistSession() async {
    if (_exercises.isEmpty) return;
    final services = AppScope.of(context);
    await services.workouts.saveSession(_buildSession());
    await services.workouts.clearDraft();
  }

  Future<void> _save({required bool repeat}) async {
    if (_saving) return;
    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('没有完成任何一组，先回去完成一组再保存')),
      );
      return;
    }
    setState(() => _saving = true);
    final services = AppScope.of(context);
    final session = _buildSession();
    await services.workouts.saveSession(session);
    await services.workouts.clearDraft();
    _persisted = true;
    if (!mounted) return;

    if (!repeat) {
      _leaveToRoot();
      return;
    }

    final draft = WorkoutDraft(
      name: session.name,
      planId: session.planId,
      startedAt: DateTime.now(),
      exercises: session.exercises
          .map(
            (e) => WorkoutExercise(
              exercise: e.exercise,
              sets: e.sets
                  .map((s) => WorkoutSet(weight: s.weight, reps: s.reps))
                  .toList(),
            ),
          )
          .toList(),
    );
    await services.workouts.saveDraft(draft);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => WorkoutRunnerScreen(initialDraft: draft)),
    );
  }

  /// 返回时先保存当前 RPE/备注，再退出；记录在进入页面时已经落库。
  Future<void> _saveAndLeave() async {
    await _persistSession();
    if (!mounted) return;
    _popNow();
  }

  /// PopScope 会拦截普通 pop，先允许退出，再在下一帧执行。
  void _leaveToRoot() {
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.popUntil(context, (route) => route.isFirst);
    });
  }

  void _popNow() {
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.pop(context);
    });
  }

  String _fmtDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String _fmtVolume(double volume) {
    if (volume <= 0) return '自重';
    if (volume >= 1000) return '${(volume / 1000).toStringAsFixed(1)}t';
    return '${volume.toStringAsFixed(0)}kg';
  }
}
