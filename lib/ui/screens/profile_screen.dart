import 'package:excise/app/app_scope.dart';
import 'package:excise/app/theme.dart';
import 'package:excise/ui/screens/body_stats_screen.dart';
import 'package:excise/ui/screens/favorites_screen.dart';
import 'package:flutter/material.dart';

/// 我的：收藏、身体数据、训练偏好与关于。收藏不再占用底部导航。
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context).settings;
    return Scaffold(
      backgroundColor: AppTheme.bgMain,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            const Text('我的', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 3),
            const Text('数据都在本机，不需要账号', style: TextStyle(fontSize: 13, color: AppTheme.textTertiary)),
            const SizedBox(height: 18),
            _group([
              _row(
                icon: Icons.favorite_border_rounded,
                color: AppTheme.accentRed,
                title: '收藏的动作',
                subtitle: '从动作库收藏，训练时快速找到',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                ),
              ),
              _row(
                icon: Icons.monitor_weight_outlined,
                color: AppTheme.accent,
                title: '身体数据',
                subtitle: '体重、体脂、围度记录',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BodyStatsScreen()),
                ),
              ),
            ]),
            const SizedBox(height: 16),
            _group([
              _infoRow(
                icon: Icons.straighten_rounded,
                color: AppTheme.primary,
                title: '重量单位',
                subtitle: '公斤 (kg)',
              ),
              ListenableBuilder(
                listenable: settings,
                builder: (context, _) => _switchRow(
                  icon: Icons.timer_outlined,
                  color: AppTheme.accentWarm,
                  title: '自动休息',
                  subtitle: settings.restEnabled ? '完成一组后自动开始休息计时' : '已关闭，完成一组后直接进入下一组',
                  value: settings.restEnabled,
                  onChanged: settings.setRestEnabled,
                ),
              ),
            ]),
            const SizedBox(height: 16),
            _group([
              _row(
                icon: Icons.info_outline_rounded,
                color: AppTheme.textTertiary,
                title: '关于',
                subtitle: '训练工具 · 本地数据 · v1',
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: 'Excise',
                  applicationVersion: 'v1',
                  applicationLegalese:
                      '本地优先的训练工具，不做账号与云同步。\n\n'
                      '部分动作示范图来自 free-exercise-db（Unlicense / 公共领域）\n'
                      'https://github.com/yuhonas/free-exercise-db',
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _group(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              const Divider(height: 0.5, indent: 62, endIndent: 16, color: AppTheme.divider),
          ],
        ],
      ),
    );
  }

  Widget _leading(IconData icon, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(11)),
      child: Icon(icon, size: 21, color: color),
    );
  }

  Widget _row({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          child: Row(
            children: [
              _leading(icon, color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
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

  /// 只展示当前值，不做跳转，不再用「即将支持」占位。
  Widget _infoRow({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 16, 12),
      child: Row(
        children: [
          _leading(icon, color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _switchRow({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 10, 8),
      child: Row(
        children: [
          _leading(icon, color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
