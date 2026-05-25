import 'package:flutter/material.dart';

import '../../../design/app_colors.dart';
import '../../../design/app_radius.dart';
import '../../../design/app_spacing.dart';
import '../../../design/app_text_styles.dart';
import '../../../models/category_model.dart';

class SubcategoryChips extends StatelessWidget {
  const SubcategoryChips({
    super.key,
    required this.title,
    required this.subcategories,
    required this.selectedCategoryId,
    required this.onSelected,
  });

  final String title;
  final List<CategoryModel> subcategories;
  final int? selectedCategoryId;
  final ValueChanged<CategoryModel> onSelected;

  @override
  Widget build(BuildContext context) {
    if (subcategories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: AppSpacing.buttonMd,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: subcategories.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final subcategory = subcategories[index];
              final selected = selectedCategoryId == subcategory.id;
              return ChoiceChip(
                selected: selected,
                label: Text(subcategory.name),
                onSelected: (_) => onSelected(subcategory),
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.white,
                labelStyle: AppTextStyles.labelMedium.copyWith(
                  color: selected ? AppColors.white : AppColors.textSecondary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  side: BorderSide(
                    color: selected ? AppColors.primary : AppColors.border,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
