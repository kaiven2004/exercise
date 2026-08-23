import 'package:excise/data/models/models.dart';
import 'package:excise/data/repositories/sample_repository.dart';
import 'package:excise/ui/screens/exercise_detail_screen.dart';
import 'package:excise/ui/widgets/svg_icons.dart';
import 'package:excise/app/theme.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  late final SampleExerciseRepository _repo;
  List<Exercise> _results = [];
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _repo = SampleExerciseRepository();
  }

  void _onSearchChanged(String query) {
    setState(() { _results = _repo.searchExercises(query); _hasSearched = query.isNotEmpty; });
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgMain,
      appBar: AppBar(backgroundColor: Colors.white, foregroundColor: AppTheme.textPrimary,
        title: const Text('搜索动作', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        leading: IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
        TextField(controller: _controller, autofocus: true, decoration: const InputDecoration(hintText: '搜索动作名称、部位、要领...', prefixIcon: Icon(Icons.search, size: 18, color: AppTheme.textTertiary)), onChanged: _onSearchChanged),
        const SizedBox(height: 16),
        Expanded(child: _hasSearched
          ? _results.isEmpty ? const Center(child: Text('未找到相关动作', style: TextStyle(color: AppTheme.textTertiary)))
          : ListView.builder(itemCount: _results.length, itemBuilder: (context, index) {
              final ex = _results[index];
              return Padding(padding: const EdgeInsets.only(bottom: 8), child: _SearchResultCard(exercise: ex, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ExerciseDetailScreen(exercise: ex)))));
            })
          : _DefaultSuggestions()),
      ])),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onTap;
  const _SearchResultCard({required this.exercise, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(color: Colors.transparent, child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5)),
      child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: exercise.imageUrl.isNotEmpty ? (exercise.imageUrl.startsWith('assets/') ? Image.asset(exercise.imageUrl, width: 26, height: 26, fit: BoxFit.cover) : Image.network(exercise.imageUrl, width: 26, height: 26, fit: BoxFit.cover, errorBuilder: (_, __, ___) => SvgIcon(assetName: exercise.imageSvg, size: 22, color: AppTheme.primary))) : SvgIcon(assetName: exercise.imageSvg, size: 22, color: AppTheme.primary)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(exercise.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 3), Text(exercise.categoryPath, style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textTertiary)),
        ])),
        Icon(Icons.chevron_right, size: 18, color: AppTheme.textTertiary),
      ]),
    )));
  }
}

class _DefaultSuggestions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final popular = const ['上斜杠铃卧推', '平板杠铃卧推', '杠铃深蹲', '引体向上', '哑铃侧平举', '臀桥'];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('热门搜索', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: popular.map((name) => FilterChip(label: Text(name), onSelected: (_) {}, selectedColor: AppTheme.primary.withValues(alpha: 0.15), checkmarkColor: AppTheme.primary)).toList()),
    ]);
  }
}
