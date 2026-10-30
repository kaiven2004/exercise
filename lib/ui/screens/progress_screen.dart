import 'package:excise/app/app_scope.dart';
import 'package:excise/app/theme.dart';
import 'package:excise/data/models/workout_models.dart';
import 'package:excise/data/services/personal_record_service.dart';
import 'package:excise/ui/screens/body_stats_screen.dart';
import 'package:excise/ui/screens/workout_session_detail_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

/// 进度页：力量曲线 + 本周容量 + 最近训练 + 身体数据入口。
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  String? _selectedExerciseId;

  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);
    return Scaffold(
      backgroundColor: AppTheme.bgMain,
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: services.workouts,
          builder: (context, _) {
            final sessions = services.workouts.getSessions();
            final options = _strengthOptions(sessions);
            final selectedId = options.any((o) => o.id == _selectedExerciseId)
                ? _selectedExerciseId
                : (options.isEmpty ? null : options.first.id);
            final points = selectedId == null
                ? const <_StrengthPoint>[]
                : _strengthPoints(sessions, selectedId);
            final selected = selectedId == null
                ? null
                : () {
                    for (final option in options) {
                      if (option.id == selectedId) return option;
                    }
                    return null;
                  }();
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                const Text('进度', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const SizedBox(height: 3),
                const Text('看趋势，不看单次发挥', style: TextStyle(fontSize: 13, color: AppTheme.textTertiary)),
                const SizedBox(height: 18),
                _weekCard(sessions),
                const SizedBox(height: 18),
                _strengthCard(options, selected, points),
                const SizedBox(height: 18),
                _volumeChart(sessions),
                const SizedBox(height: 22),
                _sectionTitle('最近训练', trailing: '${sessions.length} 场'),
                const SizedBox(height: 10),
                if (sessions.isEmpty) _emptySessions() else _sessionList(sessions),
                const SizedBox(height: 22),
                _sectionTitle('身体数据'),
                const SizedBox(height: 10),
                _bodyCard(),
              ],
            );
          },
        ),
      ),
    );
  }

  /// 有重量记录的动作用于力量曲线，按训练次数从多到少。
  List<_ExerciseOption> _strengthOptions(List<WorkoutSession> sessions) {
    final names = <String, String>{};
    final counts = <String, int>{};
    for (final session in sessions) {
      for (final exercise in session.exercises) {
        final hasWeight = exercise.sets.any((s) => s.completed && s.weight > 0);
        if (!hasWeight) continue;
        names[exercise.exercise.id] = exercise.exercise.name;
        counts[exercise.exercise.id] = (counts[exercise.exercise.id] ?? 0) + 1;
      }
    }
    final options = counts.entries
        .map((e) => _ExerciseOption(id: e.key, name: names[e.key] ?? e.key, sessionCount: e.value))
        .toList();
    options.sort((a, b) {
      final byCount = b.sessionCount.compareTo(a.sessionCount);
      return byCount != 0 ? byCount : a.name.compareTo(b.name);
    });
    return options;
  }

  /// 一个动作每次训练里最强的估算 1RM。
  List<_StrengthPoint> _strengthPoints(List<WorkoutSession> sessions, String exerciseId) {
    final points = <_StrengthPoint>[];
    for (final session in sessions) {
      WorkoutExercise? target;
      for (final exercise in session.exercises) {
        if (exercise.exercise.id == exerciseId) {
          target = exercise;
          break;
        }
      }
      if (target == null) continue;

      double bestValue = 0;
      double bestWeight = 0;
      var bestReps = 0;
      for (final set in target.sets) {
        if (!set.completed || set.weight <= 0) continue;
        final value = PersonalRecordService.estimatedOneRepMax(set.weight, set.reps);
        if (value > bestValue) {
          bestValue = value;
          bestWeight = set.weight;
          bestReps = set.reps;
        }
      }
      if (bestValue <= 0) continue;
      points.add(_StrengthPoint(
        date: session.startedAt,
        estimatedOneRepMax: bestValue,
        weight: bestWeight,
        reps: bestReps,
      ));
    }
    points.sort((a, b) => a.date.compareTo(b.date));
    return points;
  }

  Widget _strengthCard(
    List<_ExerciseOption> options,
    _ExerciseOption? selected,
    List<_StrengthPoint> points,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.show_chart_rounded, size: 17, color: AppTheme.primary),
              const SizedBox(width: 6),
              const Text('力量曲线', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              const Spacer(),
              if (options.isNotEmpty && selected != null) _exerciseSelector(selected, options),
            ],
          ),
          const SizedBox(height: 12),
          if (points.length < 2)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                options.isEmpty
                    ? '完成一次有重量的动作后，这里会显示力量趋势'
                    : '「${selected?.name ?? ''}」再练一次，就能看到估算 1RM 曲线',
                style: const TextStyle(fontSize: 12, color: AppTheme.textTertiary, height: 1.5),
              ),
            )
          else ...[
            _strengthChart(points),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  '最新 ${points.last.estimatedOneRepMax.toStringAsFixed(1)} kg',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                ),
                const SizedBox(width: 8),
                Text(
                  _strengthChangeLabel(points),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: points.last.estimatedOneRepMax >= points.first.estimatedOneRepMax
                        ? AppTheme.accent
                        : AppTheme.accentRed,
                  ),
                ),
                const Spacer(),
                Text('${points.length} 次记录', style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '最佳组 ${_fmtWeight(points.last.weight)} kg × ${points.last.reps}',
              style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _exerciseSelector(_ExerciseOption selected, List<_ExerciseOption> options) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => _pickExercise(options, selected.id),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 150),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                selected.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primary),
              ),
            ),
            const Icon(Icons.expand_more_rounded, size: 16, color: AppTheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _strengthChart(List<_StrengthPoint> points) {
    final values = points.map((p) => p.estimatedOneRepMax).toList();
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final span = (maxValue - minValue).clamp(1.0, double.infinity).toDouble();
    final padding = span * 0.18;
    final minY = (minValue - padding).clamp(0.0, double.infinity).toDouble();
    final maxY = maxValue + padding;
    final interval = ((maxY - minY) / 3).clamp(1.0, double.infinity).toDouble();
    final spots = points.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.estimatedOneRepMax))
        .toList();

    return SizedBox(
      height: 150,
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: interval,
            getDrawingHorizontalLine: (_) => const FlLine(color: Color(0xFFEDEFF3), strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 34,
                interval: interval,
                getTitlesWidget: (value, meta) => Text(
                  value.toStringAsFixed(0),
                  style: const TextStyle(fontSize: 9, color: AppTheme.textTertiary),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (value, meta) {
                  final index = value.round();
                  if (index < 0 || index >= points.length) return const SizedBox.shrink();
                  final showAll = points.length <= 4;
                  final isEdge = index == 0 || index == points.length - 1;
                  final isMiddle = index == points.length ~/ 2;
                  if (!showAll && !isEdge && !isMiddle) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      DateFormat('M/d').format(points[index].date),
                      style: const TextStyle(fontSize: 9, color: AppTheme.textTertiary),
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.22,
              color: AppTheme.primary,
              barWidth: 2.5,
              dotData: FlDotData(show: points.length <= 12, getDotPainter: (spot, percent, bar, index) {
                return FlDotCirclePainter(radius: 3, color: Colors.white, strokeWidth: 2, strokeColor: AppTheme.primary);
              }),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.primary.withValues(alpha: 0.09),
              ),
            ),
          ],
          lineTouchData: const LineTouchData(enabled: true),
        ),
      ),
    );
  }

  String _strengthChangeLabel(List<_StrengthPoint> points) {
    final change = points.last.estimatedOneRepMax - points.first.estimatedOneRepMax;
    if (change.abs() < 0.05) return '与首次持平';
    final sign = change > 0 ? '+' : '';
    return '较首次 $sign${change.toStringAsFixed(1)} kg';
  }

  Future<void> _pickExercise(List<_ExerciseOption> options, String selectedId) async {
    final picked = await showModalBottomSheet<String>(
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
                child: Text('选择动作', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              ),
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: options.length,
                separatorBuilder: (_, _) => const Divider(height: 0.5, indent: 20, endIndent: 20),
                itemBuilder: (context, index) {
                  final option = options[index];
                  final active = option.id == selectedId;
                  return ListTile(
                    title: Text(
                      option.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                        color: active ? AppTheme.primary : AppTheme.textPrimary,
                      ),
                    ),
                    subtitle: Text('${option.sessionCount} 次训练', style: const TextStyle(fontSize: 11)),
                    trailing: active ? const Icon(Icons.check_rounded, size: 18, color: AppTheme.primary) : null,
                    onTap: () => Navigator.pop(context, option.id),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
    if (picked != null && mounted) setState(() => _selectedExerciseId = picked);
  }

  Widget _sectionTitle(String title, {String? trailing}) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        const Spacer(),
        if (trailing != null) Text(trailing, style: const TextStyle(fontSize: 12, color: AppTheme.textTertiary)),
      ],
    );
  }

  List<WorkoutSession> _thisWeek(List<WorkoutSession> sessions) {
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    return sessions.where((s) => !s.startedAt.isBefore(monday)).toList();
  }

  Widget _weekCard(List<WorkoutSession> sessions) {
    final week = _thisWeek(sessions);
    final volume = week.fold<double>(0, (sum, s) => sum + s.totalVolume);
    final sets = week.fold<int>(0, (sum, s) => sum + s.totalSets);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          _stat('本周训练', '${week.length}', '次'),
          _divider(),
          _stat('完成组数', '$sets', '组'),
          _divider(),
          _stat('总容量', _fmtVolume(volume), ''),
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

  Widget _volumeChart(List<WorkoutSession> sessions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monday = today.subtract(Duration(days: now.weekday - 1));
    final values = List<double>.filled(7, 0);
    for (final session in sessions) {
      final day = DateTime(session.startedAt.year, session.startedAt.month, session.startedAt.day);
      final index = day.difference(monday).inDays;
      if (index >= 0 && index < 7) values[index] += session.totalVolume;
    }
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    const labels = ['一', '二', '三', '四', '五', '六', '日'];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('本周容量', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              const Spacer(),
              Text(maxValue <= 0 ? '还没有数据' : _fmtVolume(values.reduce((a, b) => a + b)), style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 110,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < 7; i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: maxValue <= 0 ? 3 : (values[i] / maxValue * 78).clamp(3, 78),
                            decoration: BoxDecoration(
                              color: values[i] > 0 ? AppTheme.primary : const Color(0xFFEDEFF3),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            labels[i],
                            style: TextStyle(
                              fontSize: 10,
                              color: i == now.weekday - 1 ? AppTheme.primary : AppTheme.textTertiary,
                              fontWeight: i == now.weekday - 1 ? FontWeight.w700 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sessionList(List<WorkoutSession> sessions) {
    final recent = sessions.take(8).toList();
    return Column(
      children: [
        for (var i = 0; i < recent.length; i++) ...[
          _sessionRow(recent[i]),
          if (i != recent.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _sessionRow(WorkoutSession session) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => WorkoutSessionDetailScreen(session: session)),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 13, 12, 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.divider.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.check_rounded, size: 18, color: AppTheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(session.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                    const SizedBox(height: 2),
                    Text(
                      '${DateFormat('M月d日 HH:mm').format(session.startedAt)} · ${_fmtDuration(session.duration)}',
                      style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${session.totalSets} 组', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                  const SizedBox(height: 2),
                  Text(_fmtVolume(session.totalVolume), style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
                ],
              ),
              const SizedBox(width: 2),
              const Icon(Icons.chevron_right, size: 18, color: AppTheme.textTertiary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptySessions() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider.withValues(alpha: 0.5)),
      ),
      child: const Text(
        '完成第一场训练后，这里会出现容量和趋势',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13, color: AppTheme.textTertiary),
      ),
    );
  }

  Widget _bodyCard() {
    final services = AppScope.of(context);
    final measurements = services.bodyStats.getMeasurements();
    final latest = measurements.isEmpty ? null : measurements.first;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BodyStatsScreen()),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.divider.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: AppTheme.accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(11)),
                child: const Icon(Icons.monitor_weight_outlined, size: 21, color: AppTheme.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('身体数据', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                    const SizedBox(height: 2),
                    Text(
                      latest == null
                          ? '记录体重和围度，和训练一起看'
                          : '最近 ${DateFormat('M月d日').format(latest.date)} · ${latest.weight.toStringAsFixed(1)} kg',
                      style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 20, color: AppTheme.textTertiary),
            ],
          ),
        ),
      ),
    );
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

  String _fmtWeight(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }
}

class _ExerciseOption {
  final String id;
  final String name;
  final int sessionCount;

  const _ExerciseOption({
    required this.id,
    required this.name,
    required this.sessionCount,
  });
}

class _StrengthPoint {
  final DateTime date;
  final double estimatedOneRepMax;
  final double weight;
  final int reps;

  const _StrengthPoint({
    required this.date,
    required this.estimatedOneRepMax,
    required this.weight,
    required this.reps,
  });
}
