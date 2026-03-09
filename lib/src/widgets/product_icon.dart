import 'package:flutter/material.dart';
import 'package:sinwar_shoping/src/widgets/title_text.dart';

import '../design/app_colors.dart';
import '../design/app_spacing.dart';
import '../design/app_text_styles.dart';
import '../model/category.dart';
import '../themes/theme.dart';
import 'extentions.dart';
import '../shared/widgets/app_image.dart';

class ProductIcon extends StatelessWidget {
  // final String imagePath;
  // final String text;
  final ValueChanged<Categories>? onSelected;
  final Categories model;
  final String? label;
  const ProductIcon({
    super.key,
    required this.model,
    this.onSelected,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return model.id == null
        ? const SizedBox(width: AppSpacing.xs)
        : Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xl,
            ),
            child:
                Container(
                  padding: AppTheme.hPadding,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(AppSpacing.radiusLg),
                    ),
                    color: model.isSelected
                        ? Theme.of(context).colorScheme.surface
                        : AppColors.transparent,
                    border: Border.all(
                      color: model.isSelected
                          ? AppColors.accentOrange
                          : Theme.of(context).dividerColor,
                      width: model.isSelected
                          ? AppSpacing.borderThick
                          : AppSpacing.borderThin,
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      model.image != null
                          ? AppImage(path: model.image!)
                          : const SizedBox.shrink(),
                      if ((label ?? model.name) != null)
                        TitleText(
                          text: label ?? model.name!,
                          style: AppTextStyles.titleSmall,
                          fontSize: AppSpacing.xxl.toInt(),
                          color: AppColors.textHint,
                        ),
                    ],
                  ),
                ).ripple(
                  () {
                    onSelected?.call(model);
                  },
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppSpacing.radiusLg),
                  ),
                ),
          );
  }
}
