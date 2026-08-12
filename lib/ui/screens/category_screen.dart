import 'package:excise/data/models/models.dart';
import 'package:excise/data/repositories/sample_repository.dart';
import 'package:excise/ui/screens/exercise_list_screen.dart';
import 'package:excise/ui/widgets/svg_icons.dart';
import 'package:flutter/material.dart';

class CategoryScreen extends StatelessWidget {
  final TrainingCategory category;
  final WorkoutSection section;

  const CategoryScreen({
    super.key,
    required this.category,
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final repo = SampleExerciseRepository();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgIcon(
              assetName: category.svgIcon,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(category.name),
          ],
        ),
        leading: IconButton(
          icon: const SvgIcon(assetName: 'arrow_right', size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (category.subCategories.isNotEmpty) ...[
            ...category.subCategories.map((sub) {
              final exercises = repo.getExercises(sub.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: CategoryCard(
                  icon: sub.svgIcon,
                  name: sub.name,
                  exerciseCount: exercises.length,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ExerciseListScreen(
                        category: sub,
                        parentCategory: category,
                        section: section,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ] else ...[
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  SvgIcon(
                    assetName: category.svgIcon,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${category.name} - 暂无细分动作',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('点击此处查看全部动作', style: theme.textTheme.bodySmall),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ExerciseListScreen(
                          category: category,
                          parentCategory: category,
                          section: section,
                        ),
                      ),
                    ),
                    icon: const SvgIcon(assetName: 'strength', size: 18),
                    label: const Text('查看动作'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
