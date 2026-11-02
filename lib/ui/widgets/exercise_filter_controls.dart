import 'package:excise/app/theme.dart';
import 'package:excise/data/exercise_query.dart';
import 'package:excise/data/exercises/exercise_meta.dart';
import 'package:flutter/material.dart';

/// 动作库通用的筛选控件：器械、难度、排序、只看收藏。
class ExerciseFilterControls extends StatelessWidget {
  final ExerciseQuery query;
  final ValueChanged<ExerciseQuery> onChanged;

  const ExerciseFilterControls({
    super.key,
    required this.query,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _menuButton<String>(
            value: query.equipment?.name ?? 'all',
            label: query.equipment?.label ?? '器械',
            active: query.equipment != null,
            items: [
              const PopupMenuItem<String>(value: 'all', child: Text('全部器械')),
              for (final equipment in Equipment.values)
                PopupMenuItem<String>(value: equipment.name, child: Text(equipment.label)),
            ],
            onSelected: (value) => onChanged(
              value == 'all'
                  ? query.copyWith(clearEquipment: true)
                  : query.copyWith(
                      equipment: Equipment.values.firstWhere((e) => e.name == value),
                    ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _menuButton<String>(
            value: query.difficulty ?? 'all',
            label: query.difficulty ?? '难度',
            active: query.difficulty != null,
            items: [
              const PopupMenuItem<String>(value: 'all', child: Text('全部难度')),
              for (final difficulty in kSearchDifficulties)
                PopupMenuItem<String>(value: difficulty, child: Text(difficulty)),
            ],
            onSelected: (value) => onChanged(
              value == 'all'
                  ? query.copyWith(clearDifficulty: true)
                  : query.copyWith(difficulty: value),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _menuButton<ExerciseSort>(
            value: query.sort,
            label: query.sort.label,
            active: query.sort != ExerciseSort.recommended,
            items: [
              for (final sort in ExerciseSort.values)
                PopupMenuItem<ExerciseSort>(value: sort, child: Text(sort.label)),
            ],
            onSelected: (value) => onChanged(query.copyWith(sort: value)),
          ),
        ),
        const SizedBox(width: 6),
        _favoriteButton(),
      ],
    );
  }

  Widget _menuButton<T>({
    required T value,
    required String label,
    required bool active,
    required List<PopupMenuEntry<T>> items,
    required ValueChanged<T> onSelected,
  }) {
    return PopupMenuButton<T>(
      itemBuilder: (context) => items,
      onSelected: onSelected,
      tooltip: label,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 9),
        decoration: BoxDecoration(
          color: active ? AppTheme.primary.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: active ? AppTheme.primary.withValues(alpha: 0.45) : AppTheme.divider.withValues(alpha: 0.55),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  color: active ? AppTheme.primary : AppTheme.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.expand_more_rounded,
              size: 15,
              color: active ? AppTheme.primary : AppTheme.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _favoriteButton() {
    final active = query.favoritesOnly;
    return Tooltip(
      message: '只看收藏',
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: () => onChanged(query.copyWith(favoritesOnly: !active)),
        child: Container(
          width: 36,
          height: 34,
          decoration: BoxDecoration(
            color: active ? AppTheme.accentRed.withValues(alpha: 0.1) : Colors.white,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: active ? AppTheme.accentRed.withValues(alpha: 0.5) : AppTheme.divider.withValues(alpha: 0.55),
            ),
          ),
          child: Icon(
            active ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: 18,
            color: active ? AppTheme.accentRed : AppTheme.textTertiary,
          ),
        ),
      ),
    );
  }
}
