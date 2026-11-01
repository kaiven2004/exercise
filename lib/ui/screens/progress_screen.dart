import 'package:excise/app/app_scope.dart';
import 'package:excise/app/theme.dart';
import 'package:excise/data/exercises/exercise_meta.dart';
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
            _ExerciseOption? selected;
            for (final option in options) {
              if (option.id == selectedId) selected = option;
            }
            final points = selected == null
                ? const <_StrengthPoint>[]
                : _strengthPoints(sessions, selected);
            final records = _personalRecords(sessions);
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
                _muscleCard(sessions),
                const SizedBox(height: 18),
                _recordCard(records),
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

  /// 有正式组记录的动作用于趋势图：有重量看 1RM，自重看单组最佳次数。
  List<_ExerciseOption> _strengthOptions(List<WorkoutSession> sessions) {
    final names = <String, String>{};
    final counts = <String, int>{};
    final bodyweight = <String, bool>{};
    for (final session in sessions) {
      for (final exercise in session.exercises) {
        final working = exercise.sets
            .where((s) => s.completed && !s.isWarmup && s.reps > 0)
            .toList();
        if (working.isEmpty) continue;
        final id = exercise.exercise.id;
        names[id] = exercise.exercise.name;
        counts[id] = (counts[id] ?? 0) + 1;
        final weighted = working.any((s) => s.weight > 0);
        bodyweight[id] = (bodyweight[id] ?? true) && !weighted;
      }
    }
    final options = counts.entries
        .map((e) => _ExerciseOption(
              id: e.key,
              name: names[e.key] ?? e.key,
              sessionCount: e.value,
              bodyweight: bodyweight[e.key] ?? false,
            ))
        .toList();
    options.sort((a, b) {
      final byCount = b.sessionCount.compareTo(a.sessionCount);
      return byCount != 0 ? byCount : a.name.compareTo(b.name);
    });
    return options;
  }

  /// 一个动作每次训练里的最佳表现。
  List<_StrengthPoint> _strengthPoints(List<WorkoutSession> sessions, _ExerciseOption option) {
    final points = <_StrengthPoint>[];
    for (final session in sessions) {
      WorkoutExercise? target;
      for (final exercise in session.exercises) {
        if (exercise.exercise.id == option.id) {
          target = exercise;
          break;
        }
      }
      if (target == null) continue;

      if (option.bodyweight) {
        var bestReps = 0;
        for (final set in target.sets) {
          if (!set.completed || set.isWarmup || set.weight > 0) continue;
          if (set.reps > bestReps) bestReps = set.reps;
        }
        if (bestReps <= 0) continue;
        points.add(_StrengthPoint(
          date: session.startedAt,
          value: bestReps.toDouble(),
          weight: 0,
          reps: bestReps,
          bodyweight: true,
        ));
        continue;
      }

      double bestValue = 0;
      double bestWeight = 0;
      var bestReps = 0;
      for (final set in target.sets) {
        if (!set.completed || set.isWarmup || set.weight <= 0) continue;
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
        value: bestValue,
        weight: bestWeight,
        reps: bestReps,
        bodyweight: false,
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
    final bodyweight = selected?.bodyweight ?? false;
    final title = bodyweight ? '自重趋势' : '力量曲线';
    final unit = bodyweight ? '次' : 'kg';
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
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
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
                    ? '完成一次训练后，这里会显示力量或自重趋势'
                    : selected == null
                        ? '完成一次这个动作后，这里会显示趋势'
                        : bodyweight
                            ? '「${selected.name}」再练一次，就能看到次数曲线'
                            : '「${selected.name}」再练一次，就能看到估算 1RM 曲线',
                style: const TextStyle(fontSize: 12, color: AppTheme.textTertiary, height: 1.5),
              ),
            )
          else ...[
            _strengthChart(points, bodyweight),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  bodyweight
                      ? '最新 ${points.last.reps} 次'
                      : '最新 ${points.last.value.toStringAsFixed(1)} kg',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                ),
                const SizedBox(width: 8),
                Text(
                  _strengthChangeLabel(points, unit),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: points.last.value >= points.first.value
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
              bodyweight
                  ? '最佳单组 ${points.last.reps} 次'
                  : '最佳组 ${_fmtWeight(points.last.weight)} kg × ${points.last.reps}',
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

  Widget _strengthChart(List<_StrengthPoint> points, bool bodyweight) {
    final values = points.map((p) => p.value).toList();
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final span = (maxValue - minValue).clamp(1.0, double.infinity).toDouble();
    final padding = span * 0.18;
    final minY = (minValue - padding).clamp(0.0, double.infinity).toDouble();
    final maxY = maxValue + padding;
    final interval = ((maxY - minY) / 3).clamp(1.0, double.infinity).toDouble();
    final spots = points.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.value))
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
                  bodyweight ? value.toInt().toString() : value.toStringAsFixed(0),
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

  String _strengthChangeLabel(List<_StrengthPoint> points, String unit) {
    final change = points.last.value - points.first.value;
    if (change.abs() < 0.05) return '与首次持平';
    final sign = change > 0 ? '+' : '';
    return '较首次 $sign${change.toStringAsFixed(1)} $unit';
  }

  /// 本周正式组按主要肌群汇总，热身组不计入。
  Widget _muscleCard(List<WorkoutSession> sessions) {
    final week = _thisWeek(sessions);
    final counts = <String, int>{};
    for (final session in week) {
      for (final exercise in session.exercises) {
        final sets = exercise.sets.where((s) => s.completed && !s.isWarmup).length;
        if (sets <= 0) continue;
        final muscle = metaFor(exercise.exercise).primaryMuscle;
        counts[muscle] = (counts[muscle] ?? 0) + sets;
      }
    }
    final entries = counts.entries.toList()
      ..sort((a, b) {
        final ia = kMuscleGroupOrder.indexOf(a.key);
        final ib = kMuscleGroupOrder.indexOf(b.key);
        return (ia < 0 ? 99 : ia).compareTo(ib < 0 ? 99 : ib);
      });
    final total = entries.fold<int>(0, (sum, e) => sum + e.value);
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.donut_small_rounded, size: 17, color: AppTheme.primary),
              const SizedBox(width: 6),
              const Text('本周肌群分布', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              const Spacer(),
              Text('$total 组', style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
            ],
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 14),
              child: Text('本周还没有完成正式组', style: TextStyle(fontSize: 12, color: AppTheme.textTertiary)),
            )
          else
            for (var i = 0; i < entries.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
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
                      width: 44,
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
      ),
    );
  }

  /// 所有动作的历史最佳：有重量按估算 1RM，自重按单组次数。
  List<_RecordEntry> _personalRecords(List<WorkoutSession> sessions) {
    final weighted = <String, _RecordEntry>{};
    final bodyweight = <String, _RecordEntry>{};
    for (final session in sessions) {
      for (final exercise in session.exercises) {
        final id = exercise.exercise.id;
        for (final set in exercise.sets) {
          if (!set.completed || set.isWarmup || set.reps <= 0) continue;
          if (set.weight > 0) {
            final value = PersonalRecordService.estimatedOneRepMax(set.weight, set.reps);
            final existing = weighted[id];
            if (existing == null ||
                value > existing.value + 0.05 ||
                (value >= existing.value - 0.05 && set.reps > existing.reps)) {
              weighted[id] = _RecordEntry(
                exerciseId: id,
                name: exercise.exercise.name,
                bodyweight: false,
                weight: set.weight,
                reps: set.reps,
                value: value,
                date: session.startedAt,
              );
            }
          } else {
            final existing = bodyweight[id];
            if (existing == null || set.reps > existing.reps) {
              bodyweight[id] = _RecordEntry(
                exerciseId: id,
                name: exercise.exercise.name,
                bodyweight: true,
                weight: 0,
                reps: set.reps,
                value: set.reps.toDouble(),
                date: session.startedAt,
              );
            }
          }
        }
      }
    }
    // 同一动作既有重量又有自重记录时，优先展示重量纪录。
    final merged = <String, _RecordEntry>{...bodyweight, ...weighted};
    final records = merged.values.toList()..sort((a, b) => b.date.compareTo(a.date));
    return records;
  }

  Widget _recordCard(List<_RecordEntry> records) {
    final top = records.take(5).toList();
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
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
              const Icon(Icons.emoji_events_rounded, size: 17, color: Color(0xFFFF9500)),
              const SizedBox(width: 6),
              const Text('个人纪录', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              const Spacer(),
              Text('${records.length} 项', style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
            ],
          ),
          const SizedBox(height: 10),
          if (top.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text('完成带次数记录的训练后，这里会汇总个人纪录', style: TextStyle(fontSize: 12, color: AppTheme.textTertiary)),
            )
          else
            for (var i = 0; i < top.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9500).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFFF9500)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            top[i].name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            '${top[i].setLabel} · ${top[i].recordLabel}',
                            style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('M月d日').format(top[i].date),
                      style: const TextStyle(fontSize: 10, color: AppTheme.textTertiary),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
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
                    subtitle: Text(
                      '${option.sessionCount} 次训练${option.bodyweight ? ' · 自重' : ''}',
                      style: const TextStyle(fontSize: 11),
                    ),
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
    final bodyweightReps = week.fold<int>(0, (sum, s) => sum + s.totalBodyweightReps);
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
          if (volume > 0 || bodyweightReps == 0)
            _stat('总容量', _fmtVolume(volume), '')
          else
            _stat('自重次数', '$bodyweightReps', '次'),
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
    final volumeValues = List<double>.filled(7, 0);
    final repsValues = List<double>.filled(7, 0);
    for (final session in sessions) {
      final day = DateTime(session.startedAt.year, session.startedAt.month, session.startedAt.day);
      final index = day.difference(monday).inDays;
      if (index >= 0 && index < 7) {
        volumeValues[index] += session.totalVolume;
        repsValues[index] += session.totalBodyweightReps;
      }
    }
    // 整周都没有重量记录时改用自重次数，避免柱状图永远是空的。
    final hasVolume = volumeValues.any((v) => v > 0);
    final hasReps = repsValues.any((v) => v > 0);
    final useReps = !hasVolume && hasReps;
    final values = useReps ? repsValues : volumeValues;
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final total = values.reduce((a, b) => a + b);
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
              Text(
                useReps ? '本周自重次数' : '本周容量',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
              ),
              const Spacer(),
              Text(
                maxValue <= 0
                    ? '还没有数据'
                    : (useReps ? '${total.toStringAsFixed(0)} 次' : _fmtVolume(total)),
                style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary),
              ),
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
  final bool bodyweight;

  const _ExerciseOption({
    required this.id,
    required this.name,
    required this.sessionCount,
    required this.bodyweight,
  });
}

class _StrengthPoint {
  final DateTime date;
  final double value;
  final double weight;
  final int reps;
  final bool bodyweight;

  const _StrengthPoint({
    required this.date,
    required this.value,
    required this.weight,
    required this.reps,
    required this.bodyweight,
  });
}

class _RecordEntry {
  final String exerciseId;
  final String name;
  final bool bodyweight;
  final double weight;
  final int reps;
  final double value;
  final DateTime date;

  const _RecordEntry({
    required this.exerciseId,
    required this.name,
    required this.bodyweight,
    required this.weight,
    required this.reps,
    required this.value,
    required this.date,
  });

  String get setLabel {
    if (bodyweight) return '$reps 次';
    final w = weight == weight.roundToDouble() ? weight.toInt().toString() : weight.toStringAsFixed(1);
    return '$w kg × $reps';
  }

  String get recordLabel {
    if (bodyweight) return '最佳 $reps 次';
    return '估算 1RM ${value.toStringAsFixed(1)} kg';
  }
}
