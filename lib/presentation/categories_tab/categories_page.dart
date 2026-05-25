import 'package:flutter/material.dart';

import '../../../data/categories_data.dart';
import '../../../models/category_model.dart';
import '../../models/product/product_model.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../l10n/app_localizations.dart';
import '../../services/product_service.dart';
import 'widgets/category_grid.dart';
import 'widgets/category_state_handler.dart';
import 'widgets/category_tokens.dart';
import 'widgets/product_list.dart';
import 'widgets/search_bar.dart';
import 'widgets/subcategory_chips.dart';

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
  String? _errorMessage;
  List<ProductModel> _products = [];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mainCategories = CategoriesData.getMainCategories();
    final subcategories = _selectedMainCategoryId == null
        ? <CategoryModel>[]
        : CategoriesData.getSubcategories(_selectedMainCategoryId!);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(CategoryTokens.backIcon),
        ),
        centerTitle: true,
        title: Text(l10n.categoriesTitle),
        actions: [
          IconButton(
            tooltip: l10n.searchCategoriesHint,
            onPressed: () {},
            icon: const Icon(CategoryTokens.searchIcon),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _reloadCurrentCategory(forceRefresh: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            CategoryTokens.bottomReserve,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CategorySearchBar(hintText: l10n.searchCategoriesHint),
              const SizedBox(height: AppSpacing.lg),
              CategoryGrid(
                categories: mainCategories,
                selectedCategoryId: _selectedMainCategoryId,
                itemCountBuilder: (category) =>
                    l10n.categoryItemCount(category.children.length),
                iconBuilder: _getCategoryIcon,
                onSelected: (category) =>
                    _loadProducts(category.id, mainCategoryId: category.id),
              ),
              const SizedBox(height: AppSpacing.lg),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: _selectedMainCategoryId == null
                    ? const SizedBox.shrink()
                    : SubcategoryChips(
                        key: ValueKey(_selectedMainCategoryId),
                        title: l10n.subCategoriesTitle,
                        subcategories: subcategories,
                        selectedCategoryId: _selectedCategoryId,
                        onSelected: (subcategory) => _loadProducts(
                          subcategory.id,
                          mainCategoryId: _selectedMainCategoryId,
                        ),
                      ),
              ),
              const SizedBox(height: AppSpacing.lg),
              CategoryStateHandler(
                isLoading: _isLoading,
                errorMessage: _errorMessage,
                hasSelectedCategory: _selectedCategoryId != null,
                hasProducts: _products.isNotEmpty,
                selectCategoryMessage: l10n.searchFilterSelectCategory,
                emptyMessage: l10n.noProductsInCategory,
                retryLabel: l10n.retry,
                onRetry: _reloadCurrentCategory,
                child: CategoryProductList(products: _products),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadProducts(int categoryId, {int? mainCategoryId}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
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
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _products = [];
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _reloadCurrentCategory({bool forceRefresh = false}) async {
    final categoryId = _selectedCategoryId;
    if (categoryId == null) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products = await _productService.getProductsByCategory(
        categoryId,
        forceRefresh: forceRefresh,
      );
      if (!mounted) return;
      setState(() {
        _products = products.where((item) => item.isActive == 1).toList();
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
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
