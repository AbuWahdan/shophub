import 'package:flutter/material.dart';

import '../../../design/app_spacing.dart';
import '../../../models/category_model.dart';
import 'category_tile.dart';
import 'category_tokens.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.itemCountBuilder,
    required this.iconBuilder,
    required this.onSelected,
  });

  final List<CategoryModel> categories;
  final int? selectedCategoryId;
  final String Function(CategoryModel category) itemCountBuilder;
  final IconData Function(int categoryId) iconBuilder;
  final ValueChanged<CategoryModel> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount =
            (constraints.maxWidth / CategoryTokens.minTileWidth).floor().clamp(
              2,
              4,
            );
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: CategoryTokens.tileAspectRatio,
          ),
          itemBuilder: (context, index) {
            final category = categories[index];
            return CategoryTile(
              title: category.name,
              itemCountText: itemCountBuilder(category),
              icon: iconBuilder(category.id),
              selected: selectedCategoryId == category.id,
              onTap: () => onSelected(category),
            );
          },
        );
      },
    );
  }
}
