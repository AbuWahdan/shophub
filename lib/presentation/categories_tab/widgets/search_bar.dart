import 'package:flutter/material.dart';

import '../../../design/app_colors.dart';
import '../../../design/app_radius.dart';
import '../../../design/app_spacing.dart';
import '../../../design/app_text_styles.dart';
import 'category_tokens.dart';

class CategorySearchBar extends StatelessWidget {
  const CategorySearchBar({
    super.key,
    required this.hintText,
    this.controller,
    this.onChanged,
  });

  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textHint,
          ),
          prefixIcon: const Icon(CategoryTokens.searchIcon),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
        ),
      ),
    );
  }
}
