import 'package:flutter/material.dart';

import '../../data/categories_data.dart';
import '../../models/category.dart';
import '../design/app_colors.dart';
import '../design/app_spacing.dart';
import '../design/app_text_styles.dart';
import '../l10n/l10n.dart';
import '../model/product_api.dart';
import '../services/product_service.dart';
import '../themes/theme.dart';
import '../widgets/product_card.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final ProductService _productService = ProductService();

  int? _selectedMainCategoryId;
  int? _selectedCategoryId;
  bool _isLoading = false;
  List<ApiProduct> _products = [];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final mainCategories = CategoriesData.getMainCategories();
    final subcategories = _selectedMainCategoryId == null
        ? <Category>[]
        : CategoriesData.getSubcategories(_selectedMainCategoryId!);

    return Column(
      children: [
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: AppTheme.padding,
            itemCount: mainCategories.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final category = mainCategories[index];
              final selected = _selectedMainCategoryId == category.id;
              return GestureDetector(
                onTap: () =>
                    _loadProducts(category.id, mainCategoryId: category.id),
                child: Container(
                  width: 110,
                  decoration: BoxDecoration(
                    color: selected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    boxShadow: const [AppShadows.subtleShadow],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getCategoryIcon(category.id),
                        size: 36,
                        color: selected
                            ? AppColors.textOnPrimary
                            : AppColors.textHint,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Padding(
                        padding: AppSpacing.insetsXs,
                        child: Text(
                          category.name,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: selected
                                ? AppColors.textOnPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (_selectedMainCategoryId != null) ...[
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: AppTheme.hPadding,
              itemCount: subcategories.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final sub = subcategories[index];
                return ActionChip(
                  label: Text(sub.name),
                  onPressed: () => _loadProducts(
                    sub.id,
                    mainCategoryId: _selectedMainCategoryId,
                  ),
                );
              },
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : _selectedCategoryId == null
              ? Center(child: Text(l10n.selectCategory))
              : _products.isEmpty
              ? Center(child: Text(l10n.noProductsInCategory))
              : GridView.builder(
                  padding: AppTheme.padding,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: AppSpacing.lg,
                    mainAxisSpacing: AppSpacing.lg,
                  ),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    return ProductCard(product: _products[index]);
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _loadProducts(int categoryId, {int? mainCategoryId}) async {
    setState(() {
      _isLoading = true;
      _selectedCategoryId = categoryId;
      _selectedMainCategoryId = mainCategoryId ?? _selectedMainCategoryId;
    });

    try {
      final products = await _productService.getProductsByCategory(categoryId);
      if (!mounted) return;
      setState(() {
        _products = products.where((item) => item.isActive == 1).toList();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _products = [];
        _isLoading = false;
      });
    }
  }

  IconData _getCategoryIcon(int categoryId) {
    switch (categoryId) {
      case 1:
        return Icons.devices;
      case 2:
        return Icons.computer;
      case 3:
        return Icons.phone_android;
      case 4:
        return Icons.home;
      case 5:
        return Icons.checkroom;
      case 6:
        return Icons.shopping_bag;
      case 7:
        return Icons.sports_soccer;
      case 8:
        return Icons.spa;
      case 9:
        return Icons.toys;
      case 10:
        return Icons.book;
      case 11:
        return Icons.directions_car;
      case 12:
        return Icons.fitness_center;
      case 13:
        return Icons.diamond;
      case 14:
        return Icons.pets;
      case 15:
        return Icons.music_note;
      default:
        return Icons.category;
    }
  }
}
