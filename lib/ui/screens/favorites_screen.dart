import 'package:excise/data/models/models.dart';
import 'package:excise/data/repositories/sample_repository.dart';
import 'package:excise/ui/screens/exercise_detail_screen.dart';
import 'package:excise/ui/widgets/svg_icons.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Exercise> _favorites = [];
  bool _loading = true;
  late final SampleExerciseRepository _repo;
  static const _key = 'favorites';

  @override
  void initState() {
    super.initState();
    _repo = SampleExerciseRepository();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_key) ?? [];
    final all = _repo.getExercises('all');
    setState(() {
      _favorites = all.where((e) => ids.contains(e.id)).toList();
      _loading = false;
    });
  }

  Future<void> _toggleFavorite(Exercise ex) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_key) ?? [];
    if (ids.contains(ex.id)) {
      ids.remove(ex.id);
    } else {
      ids.add(ex.id);
    }
    await prefs.setStringList(_key, ids);
    if (mounted) _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的收藏'),
        leading: IconButton(
          icon: const SvgIcon(assetName: 'arrow_right', size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
          ? const Center(child: Text('还没有收藏的动作\n在动作详情页点击爱心图标即可收藏'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _favorites.length,
              itemBuilder: (context, index) {
                final ex = _favorites[index];
                return _FavoriteCard(
                  exercise: ex,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ExerciseDetailScreen(exercise: ex),
                    ),
                  ),
                  onRemove: () => _toggleFavorite(ex),
                );
              },
            ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  const _FavoriteCard({
    required this.exercise,
    required this.onTap,
    required this.onRemove,
  });

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
                      '${exercise.categoryPath}  ${exercise.sets}组 x ${exercise.reps}次',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: SvgIcon(
                  assetName: 'favorite_filled',
                  size: 20,
                  color: const Color(0xFFE53935),
                ),
                onPressed: onRemove,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
