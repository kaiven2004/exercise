import 'package:excise/data/models/models.dart';
import 'package:excise/data/repositories/body_stats_repository.dart';
import 'package:excise/ui/screens/body_measurement_input_dialog.dart';
import 'package:excise/ui/widgets/svg_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BodyStatsScreen extends StatefulWidget {
  const BodyStatsScreen({super.key});
  @override
  State<BodyStatsScreen> createState() => _BodyStatsScreenState();
}

class _BodyStatsScreenState extends State<BodyStatsScreen> {
  final _repo = BodyStatsRepository();
  List<BodyMeasurement> _records = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _repo.init();
    setState(() {
      _records = _repo.getMeasurements();
      _loading = false;
    });
  }

  Future<void> _addRecord() async {
    final result = await showDialog<BodyMeasurement>(
      context: context,
      builder: (_) => const BodyMeasurementInputDialog(),
    );
    if (result != null && mounted) {
      await _repo.addMeasurement(result);
      await _load();
    }
  }

  Future<void> _editRecord(BodyMeasurement m) async {
    final result = await showDialog<BodyMeasurement>(
      context: context,
      builder: (_) => BodyMeasurementInputDialog(existing: m),
    );
    if (result != null && mounted) {
      await _repo.deleteMeasurement(m.id);
      await _repo.addMeasurement(result);
      await _load();
    }
  }

  Future<void> _deleteRecord(BodyMeasurement m) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('删除记录'),
        content: Text('确定删除 ' + _formatDate(m.date) + ' 的体重 ' + m.weight.toStringAsFixed(1) + 'kg 记录？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(context, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('删除')),
        ],
      ),
    );
    if (ok == true && mounted) {
      await _repo.deleteMeasurement(m.id);
      await _load();
    }
  }

  String _formatDate(DateTime d) {
    return d.year.toString() + '-' + d.month.toString().padLeft(2, '0') + '-' + d.day.toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('身体数据'),
        leading: IconButton(
          icon: const SvgIcon(assetName: 'arrow_right', size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _records.isEmpty
          ? _EmptyView(onAdd: _addRecord)
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _WeightChart(records: _records, theme: theme),
                  const SizedBox(height: 20),
                  _MetricCards(records: _records, theme: theme),
                  const SizedBox(height: 16),
                  const Text('历史记录', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 8),
                  ..._records.map((m) => _RecordCard(
                    measurement: m,
                    theme: theme,
                    onTapEdit: () => _editRecord(m),
                    onTapDelete: () => _deleteRecord(m),
                  )),
                  const SizedBox(height: 100),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addRecord,
        backgroundColor: theme.colorScheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('记录', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyView({required this.onAdd});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 80, height: 80, decoration: BoxDecoration(color: const Color(0xFFE3F2FD), shape: BoxShape.circle),
          child: const Icon(Icons.monitor_heart, size: 40, color: Color(0xFF1565C0)),
        ),
        const SizedBox(height: 16),
        const Text('暂无身体数据', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        const Text('记录体重和围度变化', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 24),
        FilledButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: const Text('添加第一条记录')),
      ]),
    );
  }
}

class _WeightChart extends StatelessWidget {
  final List<BodyMeasurement> records;
  final ThemeData theme;
  const _WeightChart({required this.records, required this.theme});

  @override
  Widget build(BuildContext context) {
    if (records.length < 2) {
      return _ChartPlaceholder(theme: theme);
    }
    final sorted = List<BodyMeasurement>.from(records)..sort((a, b) => a.date.compareTo(b.date));
    final spots = sorted.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.weight)).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.trending_up, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            Text('体重趋势', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const Spacer(),
            Text('\ 次记录', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 5),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) => Text('', style: const TextStyle(fontSize: 10, color: Colors.grey)))),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
                    final idx = v.toInt();
                    if (idx < 0 || idx >= sorted.length) return const SizedBox.shrink();
                    final d = sorted[idx].date;
                    return Text('\/', style: const TextStyle(fontSize: 9, color: Colors.grey));
                  })),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.2,
                    color: theme.colorScheme.primary,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: theme.colorScheme.primary.withValues(alpha: 0.1)),
                    barWidth: 2.5,
                  ),
                ],
                minY: spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 3,
                maxY: spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 3,
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _ChartPlaceholder extends StatelessWidget {
  final ThemeData theme;
  const _ChartPlaceholder({required this.theme});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Icon(Icons.trending_up, size: 32, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
          const SizedBox(height: 8),
          Text('至少记录 2 次数据', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const Text('才能查看趋势图表', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ]),
      ),
    );
  }
}

class _MetricCards extends StatelessWidget {
  final List<BodyMeasurement> records;
  final ThemeData theme;
  const _MetricCards({required this.records, required this.theme});

  @override
  Widget build(BuildContext context) {
    final latest = records.isNotEmpty ? records.first : null;
    if (latest == null) return const SizedBox.shrink();
    final cards = <_MetricCardData>[
      _MetricCardData(label: '体重', value: latest.weight > 0 ? latest.weight.toStringAsFixed(1) : '-', unit: 'kg', color: const Color(0xFF1565C0)),
      _MetricCardData(label: '体脂率', value: latest.bodyFatPercent > 0 ? latest.bodyFatPercent.toStringAsFixed(1) : '-', unit: '%', color: const Color(0xFF0277BD)),
      _MetricCardData(label: '胸围', value: latest.chest > 0 ? latest.chest.toStringAsFixed(1) : '-', unit: 'cm', color: const Color(0xFF00838F)),
      _MetricCardData(label: '腰围', value: latest.waist > 0 ? latest.waist.toStringAsFixed(1) : '-', unit: 'cm', color: const Color(0xFF6A1B9A)),
      _MetricCardData(label: '臂围', value: latest.arm > 0 ? latest.arm.toStringAsFixed(1) : '-', unit: 'cm', color: const Color(0xFFE65100)),
      _MetricCardData(label: '腿围', value: latest.thigh > 0 ? latest.thigh.toStringAsFixed(1) : '-', unit: 'cm', color: const Color(0xFF2E7D32)),
    ];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: cards.map((c) => SizedBox(
        width: (MediaQuery.of(context).size.width - 56) / 2 - 5,
        child: _MetricCard(data: c, theme: theme),
      )).toList(),
    );
  }
}

class _MetricCardData {
  final String label;
  final String value;
  final String unit;
  final Color color;
  const _MetricCardData({required this.label, required this.value, required this.unit, required this.color});
}

class _MetricCard extends StatelessWidget {
  final _MetricCardData data;
  final ThemeData theme;
  const _MetricCard({required this.data, required this.theme});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(data.label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 6),
          Row(children: [
            Text(data.value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: data.color)),
            Text(data.unit, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ]),
        ]),
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  final BodyMeasurement measurement;
  final ThemeData theme;
  final VoidCallback onTapEdit;
  final VoidCallback onTapDelete;
  const _RecordCard({required this.measurement, required this.theme, required this.onTapEdit, required this.onTapDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTapEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(10)),
              child: const Center(child: SvgIcon(assetName: 'favorite_filled', size: 22, color: Color(0xFF1565C0))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(measurement.weight > 0 ? measurement.weight.toStringAsFixed(1) + ' kg' : '无体重数据', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(_formatDate(measurement.date), style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              if (measurement.bodyFatPercent > 0) Text('体脂 ' + measurement.bodyFatPercent.toStringAsFixed(1) + '%  ·  胸' + measurement.chest.toStringAsFixed(1) + 'cm  ·  腰' + measurement.waist.toStringAsFixed(1) + 'cm', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ])),
            IconButton(icon: const Icon(Icons.delete_outline, size: 20), onPressed: onTapDelete, color: Colors.red[300]),
          ]),
        ),
      ),
    );
  }

}
