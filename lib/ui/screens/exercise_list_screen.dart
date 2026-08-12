import 'package:excise/data/models/models.dart';
import 'package:excise/data/repositories/exercise_override_repository.dart';
import 'package:excise/data/repositories/sample_repository.dart';
import 'package:excise/ui/screens/exercise_detail_screen.dart';
import 'package:excise/ui/widgets/svg_icons.dart';
import 'package:flutter/material.dart';

class ExerciseListScreen extends StatefulWidget {
  final TrainingCategory category;
  final TrainingCategory parentCategory;
  final WorkoutSection section;

  const ExerciseListScreen({
    super.key,
    required this.category,
    required this.parentCategory,
    required this.section,
  });

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  late final SampleExerciseRepository _repo;
  late final ExerciseOverrideRepository _overrideRepo;

  @override
  void initState() {
    super.initState();
    _repo = SampleExerciseRepository();
    _overrideRepo = ExerciseOverrideRepository();
    _overrideRepo.init();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exercises = _repo.getExercises(widget.category.id);
    final path = _buildPath();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.category.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              path,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const SvgIcon(assetName: 'arrow_right', size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: exercises.isEmpty
          ? _EmptyState(category: widget.category)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final ex = exercises[index];
                return _ExerciseCard(
                  exercise: ex,
                  overrideRepo: _overrideRepo,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ExerciseDetailScreen(exercise: ex),
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _buildPath() {
    final parts = <String>[];
    if (widget.parentCategory.id != widget.category.id) parts.add(widget.parentCategory.name);
    parts.add(widget.category.name);
    return parts.join(' / ');
  }
}

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final ExerciseOverrideRepository overrideRepo;
  final VoidCallback onTap;
  const _ExerciseCard({required this.exercise, required this.overrideRepo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sets = overrideRepo.getEffectiveSets(exercise.id, exercise.sets);
    final reps = overrideRepo.getEffectiveReps(exercise.id, exercise.reps);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SvgIcon(
                  assetName: exercise.imageSvg,
                  size: 36,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 14),
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
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _StatChip(label: '$sets?', value: '$reps?'),
                        const SizedBox(width: 6),
                        _StatChip(label: exercise.difficulty),
                      ],
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

class _StatChip extends StatelessWidget {
  final String label;
  final String? value;
  const _StatChip({required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text('$label ${value ?? ' '}', style: theme.textTheme.bodySmall),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final TrainingCategory category;
  const _EmptyState({required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgIcon(
            assetName: 'exercise_default',
            size: 72,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            '??????',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${category.name} ???????????',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
