import 'package:excise/app/app_scope.dart';
import 'package:excise/app/theme.dart';
import 'package:excise/data/models/workout_models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

/// 单次训练复盘：动作、每组重量次数、RPE 与备注。
class WorkoutSessionDetailScreen extends StatelessWidget {
  final WorkoutSession session;

  const WorkoutSessionDetailScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgMain,
      appBar: AppBar(
        title: const Text('训练记录'),
        actions: [
          IconButton(
            tooltip: '删除记录',
            icon: const Icon(Icons.delete_outline_rounded, size: 21),
            onPressed: () => _delete(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          _hero(),
          const SizedBox(height: 16),
          _stats(),
          const SizedBox(height: 22),
          const Text('动作明细', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 10),
          for (final exercise in session.exercises) ...[
            _exerciseCard(exercise),
            const SizedBox(height: 8),
          ],
          if (session.exercises.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.divider.withValues(alpha: 0.5)),
              ),
              child: const Text('这次训练没有完成的动作', style: TextStyle(fontSize: 13, color: AppTheme.textTertiary)),
            ),
          if (session.rpe > 0 || session.note.isNotEmpty) ...[
            const SizedBox(height: 14),
            _notesCard(),
          ],
        ],
      ),
    );
  }

  Widget _hero() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(color: const Color(0xFF101828), borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(session.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 6),
          Text(
            '${DateFormat('M月d日 EEEE HH:mm', 'zh_CN').format(session.startedAt)} · ${_fmtDuration(session.duration)}',
            style: const TextStyle(fontSize: 12, color: Color(0xFFB6C2D4)),
          ),
        ],
      ),
    );
  }

  Widget _stats() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          _stat('动作', '${session.exercises.length}', '个'),
          _divider(),
          _stat('完成', '${session.totalSets}', '组'),
          _divider(),
          if (session.totalVolume > 0 || session.totalBodyweightReps == 0)
            _stat('容量', _fmtVolume(session.totalVolume), '')
          else
            _stat('自重', '${session.totalBodyweightReps}', '次'),
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
                TextSpan(text: value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                if (unit.isNotEmpty) TextSpan(text: ' $unit', style: const TextStyle(fontSize: 10, color: AppTheme.textTertiary)),
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

  Widget _exerciseCard(WorkoutExercise exercise) {
    final sets = exercise.sets.where((s) => s.completed).toList();
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  exercise.exercise.name,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                ),
              ),
              Text('${sets.length} 组', style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < sets.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 34,
                    child: Text('第 ${i + 1} 组', style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
                  ),
                  Text(
                    '${sets[i].isWarmup ? '热身 · ' : ''}${sets[i].weight > 0 ? '${_fmtWeight(sets[i].weight)} kg × ${sets[i].reps}' : '自重 × ${sets[i].reps}'}',
                    style: TextStyle(
                      fontSize: 13,
                      color: sets[i].isWarmup ? const Color(0xFFB26A00) : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          if (exercise.note.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              exercise.note,
              style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }

  Widget _notesCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (session.rpe > 0) ...[
            Text('RPE ${session.rpe} / 10', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            if (session.note.isNotEmpty) const SizedBox(height: 6),
          ],
          if (session.note.isNotEmpty)
            Text(session.note, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.5)),
        ],
      ),
    );
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除这条训练记录？'),
        content: const Text('删除后无法恢复，力量曲线也会随之变化。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.accentRed),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await AppScope.of(context).workouts.deleteSession(session.id);
    if (context.mounted) Navigator.pop(context);
  }

  String _fmtWeight(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }

  String _fmtVolume(double volume) {
    if (volume <= 0) return '自重';
    if (volume >= 1000) return '${(volume / 1000).toStringAsFixed(1)}t';
    return '${volume.toStringAsFixed(0)}kg';
  }

  String _fmtDuration(Duration duration) {
    final minutes = duration.inMinutes;
    if (minutes < 60) return '$minutes 分钟';
    return '${duration.inHours} 小时 ${minutes.remainder(60)} 分';
  }
}
