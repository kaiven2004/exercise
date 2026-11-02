import 'package:excise/app/theme.dart';
import 'package:excise/data/exercises/exercise_meta.dart';
import 'package:excise/data/models/models.dart';
import 'package:excise/data/models/workout_models.dart';
import 'package:excise/ui/widgets/exercise_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

/// 动作库统一的列表卡片：示范缩略图、名称、肌群/器械/难度标签、上次表现。
class ExerciseResultCard extends StatelessWidget {
  final Exercise exercise;
  final bool isFavorite;
  final LastPerformance? last;
  final int usageCount;
  final VoidCallback onTap;

  const ExerciseResultCard({
    super.key,
    required this.exercise,
    required this.onTap,
    this.isFavorite = false,
    this.last,
    this.usageCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final meta = metaFor(exercise);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: AppTheme.divider.withValues(alpha: 0.45)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 54,
                  height: 54,
                  child: ExerciseImage(exercise: exercise, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            exercise.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        if (isFavorite)
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(Icons.favorite_rounded, size: 13, color: AppTheme.accentRed),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _tag(meta.primaryMuscle, AppTheme.primary),
                        _tag(meta.equipment.label, AppTheme.textSecondary),
                        if (meta.compound) _tag('复合', AppTheme.accent),
                        if (exercise.difficulty.isNotEmpty) _tag(exercise.difficulty, AppTheme.textTertiary),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _subtitle(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, size: 18, color: AppTheme.textTertiary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500)),
    );
  }

  String _subtitle() {
    if (last != null) {
      return '上次 ${DateFormat('M月d日').format(last!.date)} · ${last!.label}';
    }
    if (usageCount > 0) return '练过 $usageCount 次';
    return exercise.categoryPath;
  }
}
