import 'package:excise/data/models/models.dart';
import 'package:excise/data/repositories/sample_repository.dart';
import 'package:excise/ui/screens/exercise_detail_screen.dart';
import 'package:excise/ui/widgets/svg_icons.dart';
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
    setState(() {
      _results = _repo.searchExercises(query);
      _hasSearched = query.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('搜索动作'),
        leading: IconButton(
          icon: const SvgIcon(assetName: 'arrow_right', size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: '搜索动作名称、部位、要领...',
                prefixIcon: SvgIcon(assetName: 'search', size: 20),
              ),
              onChanged: _onSearchChanged,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _hasSearched
                  ? _results.isEmpty
                        ? const Center(child: Text('未找到相关动作'))
                        : ListView.builder(
                            itemCount: _results.length,
                            itemBuilder: (context, index) {
                              final ex = _results[index];
                              return _ExerciseResultCard(
                                exercise: ex,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ExerciseDetailScreen(exercise: ex),
                                  ),
                                ),
                              );
                            },
                          )
                  : _DefaultSuggestions(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseResultCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onTap;
  const _ExerciseResultCard({required this.exercise, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SvgIcon(
                  assetName: exercise.imageSvg,
                  size: 28,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exercise.categoryPath,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SvgIcon(assetName: 'arrow_right', size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _DefaultSuggestions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final popular = const ['上斜杠铃卧推', '平板杠铃卧推', '杠铃深蹲', '引体向上', '哑铃侧平举', '臀桥'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('热门搜索', style: theme.textTheme.titleSmall),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: popular
              .map(
                (name) => Chip(
                  label: Text(name),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
