import 'package:excise/data/repositories/exercise_override_repository.dart';
import 'package:excise/data/models/models.dart';
import 'package:excise/data/repositories/local_repositories.dart';
import 'package:excise/ui/widgets/svg_icons.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
class ExerciseDetailScreen extends StatefulWidget {
  final Exercise exercise;
  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _isFavorite = false;
  bool _loading = true;
  late final LocalFavoriteRepository _favRepo;
  late final LocalTrainingHistoryRepository _histRepo;
  late final ExerciseOverrideRepository _overrideRepo;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _hasVideo = false;
  bool _editing = false;

  late int _sets = 3;
  late int _reps = 12;
  late String _restSeconds = '60';

  TextEditingController _setsController = TextEditingController();
  TextEditingController _repsController = TextEditingController();
  TextEditingController _restController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _favRepo = LocalFavoriteRepository();
    _histRepo = LocalTrainingHistoryRepository();
    _initRepositories();
  }

  Future<void> _initRepositories() async {
    await _favRepo.init();
    await _histRepo.init();
    setState(() {
      _isFavorite = _favRepo.isFavorite(widget.exercise);
      _loading = false;
    });
    await _overrideRepo.init();
    _sets = _overrideRepo.getOverrideSets(widget.exercise.id) ?? widget.exercise.sets;
    _reps = _overrideRepo.getOverrideReps(widget.exercise.id) ?? widget.exercise.reps;
    _restSeconds = _overrideRepo.getOverrideRest(widget.exercise.id) ?? widget.exercise.restSeconds;
    _setsController.text = _sets.toString();
    _repsController.text = _reps.toString();
    _restController.text = _restSeconds;
    _loadVideo();
  }

  Future<void> _loadVideo() async {
    final path = widget.exercise.videoPath;
    if (path.isEmpty) {
      setState(() => _hasVideo = false);
      return;
    }
    try {
      _videoController = VideoPlayerController.asset('assets/videos/$path');
      await _videoController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: false,
        looping: true,
        showControls: true,
        placeholder: Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Center(
            child: SvgIcon(assetName: 'play_circle', size: 48),
          ),
        ),
      );
      setState(() => _hasVideo = true);
    } catch (e) {
      setState(() => _hasVideo = false);
    }
  }

  @override
  void dispose() {
    _setsController.dispose();
    _repsController.dispose();
    _restController.dispose();
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _saveEdit() async {
    final setsVal = int.tryParse(_setsController.text);
    final repsVal = int.tryParse(_repsController.text);
    final restVal = int.tryParse(_restController.text);
    if (setsVal != null) _sets = setsVal;
    if (repsVal != null) _reps = repsVal;
    if (restVal != null) _restSeconds = restVal.toString();
    await _overrideRepo.saveOverride(
      widget.exercise.id,
      sets: _sets,
      reps: _reps,
      restSeconds: _restSeconds,
    );
    setState(() => _editing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已保存修改')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;
    final theme = Theme.of(context);

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(ex.name)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(ex.name),
        actions: [
          IconButton(
            icon: SvgIcon(
              assetName: _isFavorite ? 'favorite_filled' : 'favorite',
              size: 22,
              color: _isFavorite ? const Color(0xFFE53935) : null,
            ),
            onPressed: () {
              setState(() => _isFavorite = !_isFavorite);
              _favRepo.toggleFavorite(ex);
            },
          ),
          IconButton(
            icon: SvgIcon(assetName: _editing ? 'check' : 'edit', size: 22, color: const Color(0xFF1565C0)),
            onPressed: () {
              if (_editing) {
                _saveEdit();
              } else {
                setState(() => _editing = true);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_hasVideo) ...[
            _VideoPlayerWidget(chewieController: _chewieController!),
            const SizedBox(height: 16),
          ] else if (ex.videoPath.isNotEmpty) ...[
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgIcon(assetName: 'play_circle', size: 48),
                    SizedBox(height: 8),
                    Text('视频加载中...', style: TextStyle(color: Colors.white54)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ] else ...[
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: SvgIcon(
                  assetName: ex.imageSvg,
                  size: 100,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          _InfoSection(
            title: '基本信息',
            items: [
              _InfoRow(label: '锻炼部位', value: ex.categoryPath),
              _InfoRow(label: '难度', value: ex.difficulty),
              if (_editing)
                _EditableInfoRow(label: '组数', controller: _setsController)
              else
                _InfoRow(label: '组数', value: '${_sets} 组'),
              if (_editing)
                _EditableInfoRow(label: '次数', controller: _repsController)
              else
                _InfoRow(
                  label: '次数',
                  value: ex.reps <= 60 ? '${_reps} 次' : '${_reps} 秒',
                ),
              if (_editing)
                _EditableInfoRow(label: '组间休息（秒）', controller: _restController)
              else
                _InfoRow(label: '组间休息', value: '${_restSeconds} 秒'),
            ],
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: '动作要领',
            items: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(ex.description, style: theme.textTheme.bodyMedium),
              ),
            ],
          ),
          if (ex.tips.isNotEmpty) ...[
            const SizedBox(height: 16),
            _InfoSection(
              title: '注意事项',
              items: ex.tips
                  .map(
                    (tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 3, right: 8),
                            child: SvgIcon(
                              assetName: 'favorite',
                              size: 14,
                              color: Color(0xFFFFB300),
                            ),
                          ),
                          Expanded(
                            child: Text(tip, style: theme.textTheme.bodyMedium),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _confirmStart(context, ex),
              child: const Text(
                '开始训练',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmStart(BuildContext context, Exercise ex) {
    final session = TrainingSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      sectionName: ex.categoryPath.split(' / ').first,
      categoryPath: ex.categoryPath,
      exercises: [
        ExerciseLog(
          exercise: ex,
          completedSets: _editing ? _sets : ex.sets,
          totalReps: (_editing ? _sets : ex.sets) * (_editing ? _reps : ex.reps),
        ),
      ],
    );
    _histRepo.addSession(session);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已将 "${ex.name}" 加入训练记录'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _VideoPlayerWidget extends StatelessWidget {
  final ChewieController chewieController;
  const _VideoPlayerWidget({required this.chewieController});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Chewie(controller: chewieController),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> items;
  const _InfoSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...items,
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            '${label}  ',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditableInfoRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  const _EditableInfoRow({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            '${label}  ',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFF1565C0),
                    width: 2,
                  ),
                ),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
