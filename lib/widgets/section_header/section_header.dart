import 'package:flutter/material.dart';

import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../design/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final EdgeInsets padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.sm,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        title,
        style: AppTextStyles.strong(
          AppTextStyles.bodyLarge.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }
}
