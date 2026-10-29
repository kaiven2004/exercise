import 'package:excise/data/models/models.dart';
import 'package:excise/data/repositories/sample_repository.dart';
import 'package:excise/ui/screens/exercise_list_screen.dart';
import 'package:excise/ui/widgets/exercise_image.dart';
import 'package:excise/ui/widgets/svg_icons.dart';
import 'package:excise/app/theme.dart';
import 'package:flutter/material.dart';

class CategoryScreen extends StatelessWidget {
  final TrainingCategory category;
  final WorkoutSection section;
  const CategoryScreen({super.key, required this.category, required this.section});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final repo = SampleExerciseRepository();
    final sectionColors = {
      WorkoutSection.strength: AppTheme.primary,
      WorkoutSection.functional: const Color(0xFF34C759),
      WorkoutSection.yoga: const Color(0xFFAF52DE),
    };
    final color = sectionColors[section] ?? AppTheme.primary;

    return Scaffold(
      backgroundColor: AppTheme.bgMain,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          SvgIcon(assetName: category.svgIcon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        ]),
        centerTitle: false,
        leading: IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _buildItems(context, repo, color).toList(),
      ),
    );
  }

  Iterable<Widget> _buildItems(BuildContext context, SampleExerciseRepository repo, Color color) sync* {
    for (final sub in category.subCategories) {
      final exercises = repo.getExercises(sub.id);
      if (exercises.isEmpty) continue;
      yield Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _ModernSubCard(icon: sub.svgIcon, name: sub.name, count: exercises.length, color: color, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ExerciseListScreen(category: sub, parentCategory: category, section: section)))),
      );
    }
    if (category.subCategories.isEmpty) {
      final exercises = repo.getExercises(category.id);
      for (final ex in exercises) {
        yield Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _ModernExerciseRowCard(exercise: ex, color: color, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ExerciseListScreen(category: category, parentCategory: category, section: section)))),
        );
      }
    }
  }
}

class _ModernSubCard extends StatelessWidget {
  final String icon;
  final String name;
  final int count;
  final Color color;
  final VoidCallback onTap;
  const _ModernSubCard({required this.icon, required this.name, required this.count, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(color: Colors.transparent, child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(14), child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Row(
        children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: SvgIcon(assetName: icon, size: 24, color: color)),
          const SizedBox(width: 14),
          Expanded(child: Text(name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 15))),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Text('$count', style: theme.textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w600))),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, size: 18, color: AppTheme.textTertiary),
        ],
      ),
    )));
  }
}

class _ModernExerciseRowCard extends StatelessWidget {
  final Exercise exercise;
  final Color color;
  final VoidCallback onTap;
  const _ModernExerciseRowCard({required this.exercise, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(color: Colors.transparent, child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(14), child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 48,
              height: 48,
              child: ExerciseImage(exercise: exercise, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(exercise.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 15))),
          Icon(Icons.chevron_right, size: 18, color: AppTheme.textTertiary),
        ],
      ),
    )));
  }
}
