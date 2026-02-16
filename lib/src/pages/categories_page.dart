import 'package:flutter/material.dart';

import '../design/app_colors.dart';
import '../design/app_spacing.dart';
import '../design/app_text_styles.dart';
import '../l10n/l10n.dart';
import '../model/category.dart';
import '../model/data.dart';
import '../model/product_api.dart';
import '../services/product_service.dart';
import '../shared/widgets/app_snackbar.dart';
import '../shared/widgets/empty_state.dart';
import '../shared/widgets/product_search_bar.dart';
import '../themes/theme.dart';
import '../widgets/product_card.dart';
import '../widgets/product_icon.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final TextEditingController _searchController = TextEditingController();
  final ProductService _productService = ProductService();

  bool _hasSearchText = false;
  bool _isLoadingProducts = false;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  List<ApiProduct> _products = [];
  List<Categories> _categoryModels = [];

  List<ApiProduct> get _filteredProducts {
    return _products.where((product) {
      final matchesSearch =
          product.itemName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          _categoryName(
            product,
          ).toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == 'All' ||
          _selectedCategory == _categoryName(product);
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _products = AppData.products;
    _categoryModels = _cloneCategories();
    _syncCategorySelection('All');
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Categories> _cloneCategories() {
    return AppData.categoryList
        .map(
          (category) => Categories(
            id: category.id,
            name: category.name,
            image: category.image,
            isSelected: false,
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProducts) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadProducts(forceRefresh: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppTheme.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductSearchBar(
              controller: _searchController,
              hintText: context.l10n.categoriesSearchHint,
              hasSearchText: _hasSearchText,
              onClear: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _hasSearchText = false;
                });
              },
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _hasSearchText = value.trim().isNotEmpty;
                });
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _showAllCategoriesPicker,
                icon: const Icon(Icons.grid_view),
                label: Text(context.l10n.categoriesAll),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: AppSpacing.imageMd,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _categoryModels
                    .map(
                      (category) => ProductIcon(
                        model: category,
                        label: _categoryLabel(context, category.name ?? ''),
                        onSelected: (model) {
                          final selected = model.name ?? 'All';
                          setState(() {
                            _selectedCategory = selected;
                            _syncCategorySelection(selected);
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_filteredProducts.isEmpty)
              SizedBox(
                height: AppTheme.fullHeight(context) * 0.45,
                child: EmptyState(
                  icon: Icons.category_outlined,
                  title: context.l10n.searchFilterNoResults,
                  message: context.l10n.searchFilterHint,
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  mainAxisSpacing: AppSpacing.lg,
                  crossAxisSpacing: AppSpacing.lg,
                ),
                itemCount: _filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = _filteredProducts[index];
                  return ProductCard(product: product, onSelected: (model) {});
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showAllCategoriesPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: AppSpacing.insetsLg,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.categoriesAll,
                  style: AppTextStyles.titleMedium(context),
                ),
                const SizedBox(height: AppSpacing.md),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: _categoryModels
                        .where((item) => item.name != null)
                        .map((item) {
                          final categoryName = item.name!;
                          return ListTile(
                            title: Text(_categoryLabel(context, categoryName)),
                            trailing: _selectedCategory == categoryName
                                ? const Icon(
                                    Icons.check,
                                    color: AppColors.primary,
                                  )
                                : null,
                            onTap: () {
                              setState(() {
                                _selectedCategory = categoryName;
                                _syncCategorySelection(categoryName);
                              });
                              Navigator.pop(context);
                            },
                          );
                        })
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _categoryLabel(BuildContext context, String category) {
    final l10n = context.l10n;
    switch (category) {
      case 'All':
        return l10n.categoryAll;
      case 'Sneakers':
        return l10n.categorySneakers;
      case 'Jackets':
        return l10n.categoryJackets;
      case 'Watches':
        return l10n.categoryWatches;
      case 'Electronics':
        return l10n.categoryElectronics;
      case 'Clothing':
        return l10n.categoryClothing;
      default:
        return category;
    }
  }

  void _syncCategorySelection(String selectedCategory) {
    for (var item in _categoryModels) {
      item.isSelected = item.name == selectedCategory;
    }
  }

  Future<void> _loadProducts({bool forceRefresh = false}) async {
    setState(() {
      _isLoadingProducts = true;
    });

    try {
      final remoteItems = await _productService.getProducts(
        forceRefresh: forceRefresh,
      );
      if (!mounted) return;
      setState(() {
        _products = remoteItems.where((item) => item.isActive == 1).toList();
      });
      AppData.setProducts(_products);
    } on ProductException catch (error) {
      if (!mounted) return;
      setState(() => _products = AppData.products);
      AppSnackBar.show(
        context,
        message: context.l10n.productsLoadFailed(error.message),
        type: AppSnackBarType.error,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _products = AppData.products);
      AppSnackBar.show(
        context,
        message: context.l10n.productsLoadFailedGeneric,
        type: AppSnackBarType.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProducts = false;
        });
      }
    }
  }

  String _resolveCategoryName(int categoryId) {
    final match = AppData.categoryList.firstWhere(
      (category) => category.id == categoryId,
      orElse: () => AppData.categoryList.first,
    );
    return match.name ?? 'Category $categoryId';
  }

  String _categoryName(ApiProduct product) {
    final category = product.category.trim();
    if (category.isNotEmpty) return category;
    return _resolveCategoryName(product.categoryId);
  }
}
