import 'package:flutter/material.dart';

import 'package:excise/data/exercises/image_map.dart';
import 'package:excise/data/models/models.dart';
import 'package:excise/ui/widgets/svg_icons.dart';

/// 统一的动作图片组件。
///
/// 解析顺序：GIF 示范（详情）> GIF 首帧缩略图（列表）> 分类 SVG 占位。
/// 通用 Pexels 照片与动作不对应，不再参与展示。
class ExerciseImage extends StatelessWidget {
  final Exercise exercise;

  /// true 显示动图（详情页），false 显示首帧缩略图（列表）。
  final bool animated;

  final double? width;
  final double? height;
  final BoxFit fit;

  /// 占位图标相对短边的比例。
  final double iconScale;

  const ExerciseImage({
    super.key,
    required this.exercise,
    this.animated = false,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.iconScale = 0.45,
  });

  @override
  Widget build(BuildContext context) {
    final path = animated
        ? getExerciseGif(exercise.id) ?? getExerciseThumb(exercise.id)
        : getExerciseThumb(exercise.id);
    if (path == null) return _fallback(context);

    return Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      gaplessPlayback: true,
      filterQuality: FilterQuality.medium,
      errorBuilder: (context, error, stackTrace) => _fallback(context),
    );
  }

  Widget _fallback(BuildContext context) {
    final theme = Theme.of(context);
    final side = width != null && height != null
        ? (width! < height! ? width! : height!)
        : (width ?? height ?? 56);
    return Container(
      width: width,
      height: height,
      color: theme.colorScheme.primary.withValues(alpha: 0.08),
      alignment: Alignment.center,
      child: SvgIcon(
        assetName: svgIconForCategory(exercise.categoryPath),
        size: side * iconScale,
        color: theme.colorScheme.primary,
      ),
    );
  }
}

/// 叶子分类 → 已存在的 SVG 图标名。分类图标缺失时也会回退到这里。
String svgIconForCategory(String categoryPath) {
  final parts = categoryPath.split(' / ').map((e) => e.trim()).toList();
  final leaf = parts.isEmpty ? '' : parts.last;
  const byLeaf = {
    '上胸': 'chest_upper',
    '中胸': 'chest',
    '下胸': 'chest_lower',
    '胸部训练': 'chest',
    '前束': 'shoulder_front',
    '中束': 'shoulder_mid',
    '后束': 'shoulder_rear',
    '肩袖肌群': 'shoulder',
    '肩部训练': 'shoulder',
    '背阔肌': 'back_lats',
    '上背厚度': 'back',
    '斜方下束': 'back_traps',
    '下背/竖脊肌': 'back',
    '背部训练': 'back',
    '肱二头肌': 'arm',
    '肱三头肌': 'arm',
    '前臂': 'arm',
    '手臂训练': 'arm',
    '股四头肌': 'leg_quads',
    '腘绳肌': 'leg_hamstrings',
    '臀部训练': 'leg_glutes',
    '内收肌群': 'leg',
    '小腿训练': 'leg',
    '下肢训练': 'leg',
    '腹直肌': 'core_abs',
    '腹斜肌': 'core_obliques',
    '深层核心': 'core',
    '抗伸展': 'core',
    '核心训练': 'core',
  };
  final icon = byLeaf[leaf];
  if (icon != null) return icon;
  if (parts.isNotEmpty && parts.first == '功能训练') return 'functional';
  if (parts.isNotEmpty && parts.first == '瑜伽训练') return 'yoga';
  return 'exercise_default';
}
