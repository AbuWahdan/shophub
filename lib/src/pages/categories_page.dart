import 'package:flutter/material.dart';

import '../design/app_spacing.dart';
import '../l10n/l10n.dart';
import '../model/data.dart';
import '../model/product_api.dart';
import '../services/product_service.dart';
import '../shared/widgets/app_snackbar.dart';
import '../shared/widgets/product_search_bar.dart';
import '../themes/theme.dart';
import '../widgets/product_card.dart';
import '../widgets/product_icon.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final TextEditingController _searchController = TextEditingController();
  final ProductService _productService = ProductService();
  bool _hasSearchText = false;
  bool _isLoadingProducts = false;
  String searchQuery = '';
  String _selectedCategory = 'All';
  List<ApiProduct> _products = [];

  List<ApiProduct> get filteredProducts {
    return _products.where((product) {
      final matchesSearch =
          product.itemName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          _categoryName(
            product,
          ).toLowerCase().contains(searchQuery.toLowerCase());
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
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _loadProducts(forceRefresh: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppTheme.padding,
        child: Column(
          children: [
            ProductSearchBar(
              controller: _searchController,
              hintText: context.l10n.categoriesSearchHint,
              hasSearchText: _hasSearchText,
              onClear: () {
                _searchController.clear();
                setState(() {
                  searchQuery = '';
                  _hasSearchText = false;
                });
              },
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  _hasSearchText = value.trim().isNotEmpty;
                });
              },
            ),
            if (_isLoadingProducts)
              const LinearProgressIndicator(minHeight: AppSpacing.borderThin),
            const SizedBox(height: AppSpacing.lg),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: context.l10n.categoriesSelectTitle,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              items: AppData.categoryList
                  .where((item) => item.name != null)
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item.name!,
                      child: Text(_categoryLabel(context, item.name!)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedCategory = value;
                  _syncCategorySelection(value);
                });
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: AppSpacing.imageMd,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: AppData.categoryList
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
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                mainAxisSpacing: AppSpacing.lg,
                crossAxisSpacing: AppSpacing.lg,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return ProductCard(product: product, onSelected: (model) {});
              },
            ),
          ],
        ),
      ),
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
    for (var item in AppData.categoryList) {
      final name = item.name ?? '';
      item.isSelected = name == selectedCategory;
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
        message: 'Failed to load products: ${error.message}',
        type: AppSnackBarType.error,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _products = AppData.products);
      AppSnackBar.show(
        context,
        message: 'Failed to load products',
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
