import 'package:excise/app/app_scope.dart';
import 'package:excise/app/theme.dart';
import 'package:excise/data/models/workout_models.dart';
import 'package:excise/ui/screens/body_stats_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

/// 进度页：本周容量 + 最近训练 + 身体数据入口。
/// 力量曲线与更细的肌群统计留给后续迭代，这里先把可复盘的数据接上。
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
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
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                const Text('进度', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const SizedBox(height: 3),
                Text('看趋势，不看单次发挥', style: TextStyle(fontSize: 13, color: AppTheme.textTertiary)),
                const SizedBox(height: 18),
                _weekCard(sessions),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
      decoration: BoxDecoration(
        color: Colors.white,
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
        ],
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
}
