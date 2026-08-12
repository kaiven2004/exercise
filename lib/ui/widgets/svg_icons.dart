import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// SVG 图标组件
/// 所有图标均使用 SVG，不使用 emoji
class SvgIcon extends StatelessWidget {
  final String assetName;
  final double size;
  final Color? color;
  final double? width;
  final double? height;

  const SvgIcon({
    super.key,
    required this.assetName,
    this.size = 24,
    this.color,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SvgPicture.asset(
      'assets/svgs/$assetName.svg',
      width: width ?? size,
      height: height ?? size,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : theme.iconTheme.color != null
          ? ColorFilter.mode(theme.iconTheme.color!, BlendMode.srcIn)
          : null,
      fit: BoxFit.contain,
    );
  }
}

/// 带 SVG 的按钮
class SvgIconButton extends StatelessWidget {
  final String icon;
  final VoidCallback onPressed;
  final String? label;
  final Color? fillColor;
  final Color? iconColor;
  final double size;

  const SvgIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.label,
    this.fillColor,
    this.iconColor,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final color = fillColor ?? Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgIcon(assetName: icon, size: size * 0.45, color: color),
            if (label != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  label!,
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 分类卡片
class CategoryCard extends StatelessWidget {
  final String icon;
  final String name;
  final int exerciseCount;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.icon,
    required this.name,
    required this.exerciseCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: SvgIcon(
                  assetName: icon,
                  size: 30,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$exerciseCount 个动作',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              SvgIcon(
                assetName: 'arrow_right',
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
