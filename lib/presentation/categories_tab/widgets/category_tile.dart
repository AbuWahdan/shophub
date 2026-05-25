import 'package:flutter/material.dart';

import '../../../design/app_colors.dart';
import '../../../design/app_radius.dart';
import '../../../design/app_shadows.dart';
import '../../../design/app_spacing.dart';
import '../../../design/app_text_styles.dart';
import 'category_tokens.dart';

class CategoryTile extends StatefulWidget {
  const CategoryTile({
    super.key,
    required this.title,
    required this.itemCountText,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String itemCountText;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<CategoryTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: widget.selected,
      label: widget.title,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 120),
          scale: _pressed ? 0.97 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: widget.selected ? AppColors.primary : AppColors.border,
                width: widget.selected
                    ? AppSpacing.borderThin
                    : AppSpacing.borderThin / AppSpacing.borderThin,
              ),
              boxShadow: const [AppShadows.subtleShadow],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: CategoryTokens.iconBoxSize,
                  height: CategoryTokens.iconBoxSize,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: CategoryTokens.tileGradient,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(widget.icon, color: AppColors.white),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  widget.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleMedium,
                ),
                Text(
                  widget.itemCountText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
