import 'package:excise/app/app_scope.dart';
import 'package:excise/app/theme.dart';
import 'package:excise/data/models/workout_models.dart';
import 'package:excise/data/workout_templates.dart';
import 'package:excise/ui/screens/library_home_screen.dart';
import 'package:excise/ui/screens/quick_start_screen.dart';
import 'package:excise/ui/screens/search_screen.dart';
import 'package:excise/ui/screens/workout_runner_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  bool _checkedStartup = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_checkedStartup) return;
    _checkedStartup = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkStartup());
  }

  Future<void> _checkStartup() async {
    if (!mounted) return;
    final services = AppScope.of(context);
    if (services.favorites.removedLegacyFavorites) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('部分收藏因动作数据修复需要重新收藏')),
      );
    }
    final draft = services.workouts.getDraft();
    if (draft != null && draft.isStale) {
      final keep = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('继续上次训练？'),
          content: Text('「${draft.name}」是 ${DateFormat('M月d日 HH:mm').format(draft.startedAt)} 开始的，已经超过 24 小时。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('放弃'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('继续'),
            ),
          ],
        ),
      );
      if (keep == false) {
        await services.workouts.clearDraft();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);
    return ListenableBuilder(
      listenable: services.workouts,
      builder: (context, _) {
        final draft = services.workouts.getDraft();
        final sessions = services.workouts.getSessions();
        return Scaffold(
          backgroundColor: AppTheme.bgMain,
          body: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: () async => setState(() {}),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                children: [
                  _header(),
                  const SizedBox(height: 18),
                  _mainCard(draft, sessions),
                  const SizedBox(height: 18),
                  _quickStartCard(),
                  const SizedBox(height: 22),
                  _sectionTitle('模板', trailing: '4 套'),
                  const SizedBox(height: 10),
                  _templateRow(),
                  const SizedBox(height: 22),
                  _sectionTitle('本周'),
                  const SizedBox(height: 10),
                  _weekOverview(sessions),
                  const SizedBox(height: 22),
                  _sectionTitle('最近训练'),
                  const SizedBox(height: 10),
                  _recentList(sessions),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _header() {
    final now = DateTime.now();
    final greeting = now.hour < 12 ? '早上好' : (now.hour < 18 ? '下午好' : '晚上好');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const SizedBox(height: 3),
              Text(
                DateFormat('M月d日 EEEE', 'zh_CN').format(now),
                style: const TextStyle(fontSize: 13, color: AppTheme.textTertiary),
              ),
            ],
          ),
        ),
        _headerButton(
          icon: Icons.grid_view_rounded,
          tooltip: '动作库',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LibraryHomeScreen()),
          ),
        ),
        const SizedBox(width: 8),
        _headerButton(
          icon: Icons.search_rounded,
          tooltip: '搜索',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SearchScreen()),
          ),
        ),
      ],
    );
  }

  Widget _headerButton({required IconData icon, required String tooltip, required VoidCallback onTap}) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.divider.withValues(alpha: 0.5)),
            ),
            child: Icon(icon, size: 21, color: AppTheme.textSecondary),
          ),
        ),
      ),
    );
  }

  Widget _mainCard(WorkoutDraft? draft, List<WorkoutSession> sessions) {
    if (draft != null && draft.exercises.isNotEmpty) {
      final elapsed = DateTime.now().difference(draft.startedAt).inMinutes;
      return _darkCard(
        eyebrow: '继续训练',
        title: draft.name,
        subtitle: '已完成 ${draft.completedSets}/${draft.totalSets} 组 · ${elapsed < 1 ? '刚刚开始' : '$elapsed 分钟'}',
        actionLabel: '继续',
        onAction: () => _openRunner(draft),
      );
    }
    final last = sessions.isEmpty ? null : sessions.first;
    return _darkCard(
      eyebrow: '今天练什么',
      title: last == null ? '先选一套模板开始' : '接着上次的节奏',
      subtitle: last == null
          ? '不用想太多，跟着模板练完就是进步。'
          : '上次：${last.name} · ${DateFormat('M月d日').format(last.startedAt)}',
      actionLabel: '快速开始',
      onAction: _openQuickStart,
    );
  }

  Widget _darkCard({
    required String eyebrow,
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF101828),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(eyebrow, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF8FA3BF), letterSpacing: 1)),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFFB6C2D4), height: 1.4)),
          const SizedBox(height: 18),
          SizedBox(
            height: 42,
            child: FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF101828),
                padding: const EdgeInsets.symmetric(horizontal: 22),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
              ),
              child: Text(actionLabel, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickStartCard() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: _openQuickStart,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.divider.withValues(alpha: 0.45)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(11)),
                child: const Icon(Icons.timer_outlined, size: 22, color: AppTheme.primary),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('快速开始', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                    SizedBox(height: 2),
                    Text('选部位和时间，自动配好动作', style: TextStyle(fontSize: 12, color: AppTheme.textTertiary)),
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

  Widget _sectionTitle(String title, {String? trailing}) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        const Spacer(),
        if (trailing != null)
          Text(trailing, style: const TextStyle(fontSize: 12, color: AppTheme.textTertiary)),
      ],
    );
  }

  Widget _templateRow() {
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: kWorkoutTemplates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final template = kWorkoutTemplates[index];
          final exercises = template.resolveExercises();
          final minutes = estimateMinutes(buildWorkoutExercises(exercises));
          return _templateCard(template, exercises.length, minutes);
        },
      ),
    );
  }

  Widget _templateCard(WorkoutTemplate template, int count, int minutes) {
    const accents = [AppTheme.primary, AppTheme.accent, AppTheme.accentWarm, AppTheme.accentPurple];
    final color = accents[kWorkoutTemplates.indexOf(template) % accents.length];
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _previewTemplate(template),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 172,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.divider.withValues(alpha: 0.45)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(9)),
                child: Icon(Icons.fitness_center, size: 17, color: color),
              ),
              const Spacer(),
              Text(template.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const SizedBox(height: 3),
              Text(template.tagline, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
              const SizedBox(height: 8),
              Text('$count 个动作 · 约 $minutes 分钟', style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _weekOverview(List<WorkoutSession> sessions) {
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final weekSessions = sessions.where((s) => !s.startedAt.isBefore(monday)).toList();
    final volume = weekSessions.fold<double>(0, (sum, s) => sum + s.totalVolume);
    final bodyweightReps = weekSessions.fold<int>(0, (sum, s) => sum + s.totalBodyweightReps);
    final streak = _streakWeeks(sessions);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          _stat('训练', '${weekSessions.length}', '次'),
          _statDivider(),
          if (volume > 0 || bodyweightReps == 0)
            _stat('容量', _formatVolume(volume), '')
          else
            _stat('自重', '$bodyweightReps', '次'),
          _statDivider(),
          _stat('连续', '$streak', '周'),
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
                TextSpan(text: value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.textPrimary, fontFeatures: [FontFeature.tabularFigures()])),
                if (unit.isNotEmpty)
                  TextSpan(text: ' $unit', style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
              ],
            ),
          ),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
        ],
      ),
    );
  }

  Widget _statDivider() => Container(width: 0.5, height: 26, color: AppTheme.divider);

  int _streakWeeks(List<WorkoutSession> sessions) {
    if (sessions.isEmpty) return 0;
    DateTime mondayOf(DateTime date) {
      final day = DateTime(date.year, date.month, date.day);
      return day.subtract(Duration(days: day.weekday - 1));
    }

    final trained = sessions.map((s) => mondayOf(s.startedAt)).toSet();
    final thisMonday = mondayOf(DateTime.now());
    var cursor = trained.contains(thisMonday) ? thisMonday : thisMonday.subtract(const Duration(days: 7));
    var streak = 0;
    while (trained.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 7));
    }
    return streak;
  }

  Widget _recentList(List<WorkoutSession> sessions) {
    if (sessions.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 22),
        alignment: Alignment.center,
        child: const Text('还没有训练记录，练完第一场就会出现在这里', style: TextStyle(fontSize: 13, color: AppTheme.textTertiary)),
      );
    }
    final recent = sessions.take(3).toList();
    return Column(
      children: [
        for (var i = 0; i < recent.length; i++) ...[
          _recentRow(recent[i]),
          if (i != recent.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _recentRow(WorkoutSession session) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 13, 10, 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider.withValues(alpha: 0.45)),
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
                  '${DateFormat('M月d日').format(session.startedAt)} · ${session.totalSets} 组 · ${_formatVolume(session.totalVolume)}',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _repeat(session),
            style: TextButton.styleFrom(foregroundColor: AppTheme.primary, padding: const EdgeInsets.symmetric(horizontal: 10)),
            child: const Text('再来一次', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  String _formatVolume(double volume) {
    if (volume >= 1000) return '${(volume / 1000).toStringAsFixed(1)}t';
    return '${volume.toStringAsFixed(0)}kg';
  }

  Future<void> _previewTemplate(WorkoutTemplate template) async {
    final services = AppScope.of(context);
    final exercises = template.resolveExercises();
    final workout = buildWorkoutExercises(
      exercises,
      lastPerformances: services.workouts.getLastPerformances(),
    );
    final minutes = estimateMinutes(workout);
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (context) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: AppTheme.divider, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Text(template.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const SizedBox(height: 4),
              Text('${template.tagline} · ${exercises.length} 个动作 · 约 $minutes 分钟', style: const TextStyle(fontSize: 12, color: AppTheme.textTertiary)),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: workout.length,
                  separatorBuilder: (_, __) => const Divider(height: 18),
                  itemBuilder: (context, index) {
                    final item = workout[index];
                    return Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.exercise.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                              const SizedBox(height: 2),
                              Text(item.exercise.categoryPath.split(' / ').last, style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
                            ],
                          ),
                        ),
                        Text('${item.sets.length} 组 × ${item.sets.first.reps}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                  ),
                  child: const Text('开始训练', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed == true) {
      await _startWorkout(
        WorkoutDraft(
          name: template.name,
          planId: template.id,
          startedAt: DateTime.now(),
          exercises: workout,
        ),
      );
    }
  }

  Future<void> _repeat(WorkoutSession session) async {
    final exercises = session.exercises.map((e) {
      return WorkoutExercise(
        exercise: e.exercise,
        sets: e.sets
            .map((s) => WorkoutSet(weight: 0, reps: s.reps))
            .toList(),
      );
    }).toList();
    await _startWorkout(
      WorkoutDraft(
        name: session.name,
        planId: session.planId,
        startedAt: DateTime.now(),
        exercises: exercises,
      ),
    );
  }

  Future<void> _startWorkout(WorkoutDraft draft) async {
    final services = AppScope.of(context);
    final existing = services.workouts.getDraft();
    if (existing != null && existing.hasProgress) {
      final replace = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('还有未完成的训练'),
          content: const Text('开始新的训练会覆盖当前草稿。'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('覆盖')),
          ],
        ),
      );
      if (replace != true) return;
    }
    await services.workouts.saveDraft(draft);
    if (!mounted) return;
    await _openRunner(draft);
  }

  Future<void> _openRunner(WorkoutDraft draft) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WorkoutRunnerScreen(initialDraft: draft)),
    );
  }

  Future<void> _openQuickStart() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QuickStartScreen()),
    );
  }
}
