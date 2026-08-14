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
        children: _buildItems(context, theme, repo),
      ),
    );
  }

  List<Widget> _buildItems(BuildContext context, ThemeData theme, SampleExerciseRepository repo) {
    if (category.subCategories.isNotEmpty) {
      return category.subCategories.map((sub) {
        final exercises = repo.getExercises(sub.id);
        if (exercises.isEmpty) return const SizedBox.shrink();
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
      }).toList();
    } else {
      final exercises = repo.getExercises(category.id);
      if (exercises.isEmpty) return [];
      return exercises.map((ex) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CategoryCard(
            icon: ex.imageSvg,
            name: ex.name,
            exerciseCount: 1,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ExerciseListScreen(
                  category: category,
                  parentCategory: category,
                  section: section,
                ),
              ),
            ),
          ),
        );
      }).toList();
    }
  }
}
