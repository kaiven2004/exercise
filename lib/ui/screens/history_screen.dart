import 'package:excise/data/models/models.dart';
import 'package:excise/data/repositories/local_repositories.dart';
import 'package:excise/ui/widgets/svg_icons.dart';
import 'package:excise/app/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<TrainingSession> _history = [];
  bool _loading = true;
  final _histRepo = LocalTrainingHistoryRepository();

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    await _histRepo.init();
    setState(() {
      _history = _histRepo.getHistory();
      _loading = false;
    });
  }

  Future<void> _clearHistory() async {
    await _histRepo.clearHistory();
    setState(() => _history = []);
  }

  int get _totalWorkouts => _history.length;
  int get _thisWeekWorkouts {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return _history.where((s) => s.date.isAfter(weekStart.subtract(const Duration(days: 1)))).length;
  }
  int get _currentStreak {
    if (_history.isEmpty) return 0;
    int streak = 0;
    final sorted = List.from(_history)..sort((a, b) => b.date.compareTo(a.date));
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    DateTime checkDate = todayStart;
    for (final session in sorted) {
      final sessionDate = DateTime(session.date.year, session.date.month, session.date.day);
      if (sessionDate == checkDate) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (sessionDate.isBefore(checkDate)) {
        break;
      }
    }
    return streak;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppTheme.bgMain,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        title: const Text('训练历史', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: _history.isNotEmpty
            ? [
                IconButton(
                  icon: const Icon(Icons.delete_sweep, size: 20),
                  tooltip: '清空记录',
                  onPressed: () => _showClearDialog(context),
                ),
                const SizedBox(width: 8),
              ]
            : null,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
          ? _EmptyHistoryView()
          : _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    return CustomScrollView(
      slivers: [
        // Stats overview
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _StatPill(icon: Icons.fitness_center, label: '总训练', value: '$_totalWorkouts', color: AppTheme.primary),
                const SizedBox(width: 10),
                _StatPill(icon: Icons.calendar_today, label: '本周', value: '$_thisWeekWorkouts', color: AppTheme.accent),
                const SizedBox(width: 10),
                _StatPill(icon: Icons.local_fire_department, label: '连胜', value: '$_currentStreak', color: AppTheme.accentWarm),
              ],
            ),
          ),
        ),
        // Grouped history
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: _buildGroupedHistory(theme),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  Widget _buildGroupedHistory(ThemeData theme) {
    final grouped = <String, List<TrainingSession>>{};
    for (final session in _history) {
      final key = DateFormat('yyyy年M月', 'zh_CN').format(session.date);
      grouped.putIfAbsent(key, () => []).add(session);
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final entry = grouped.entries.elementAt(index);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 4),
              child: Text(entry.key, style: theme.textTheme.labelLarge?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.w600)),
            ),
            ...entry.value.map((session) => _HistoryCard(session: session)),
          ],
        );
      }, childCount: grouped.length),
    );
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('清空训练历史'),
        content: const Text('确定要清空所有训练记录吗？此操作不可恢复。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(onPressed: () { Navigator.pop(ctx); _clearHistory(); }, style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('清空')),
        ],
      ),
    );
  }
}

class _EmptyHistoryView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 72, height: 72, decoration: BoxDecoration(color: AppTheme.bgGrouped, shape: BoxShape.circle),
            child: const Icon(Icons.history, size: 36, color: AppTheme.textTertiary),
          ),
          const SizedBox(height: 16),
          const Text('暂无训练记录', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          Text('完成训练后记录将显示在这里', style: const TextStyle(color: AppTheme.textTertiary)),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatPill({required this.icon, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5)),
        child: Column(children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 6),
          Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label, style: theme.textTheme.bodySmall),
        ]),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final TrainingSession session;
  const _HistoryCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeStr = '${session.date.month}月${session.date.day}日 ${session.date.hour.toString().padLeft(2, '0')}:${session.date.minute.toString().padLeft(2, '0')}';
    final exerciseNames = session.exercises.map((e) => e.exercise.name).take(3).join('、');
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5)),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: const Center(child: Icon(Icons.fitness_center, size: 22, color: AppTheme.primary)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.sectionName.isNotEmpty ? session.sectionName : '力量训练', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(exerciseNames.isNotEmpty ? exerciseNames : '训练记录', style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textTertiary), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Text(timeStr, style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textTertiary)),
        ],
      ),
    );
  }
}

