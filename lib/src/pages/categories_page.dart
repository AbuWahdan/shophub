import 'package:flutter/material.dart';

import '../design/app_spacing.dart';
import '../l10n/l10n.dart';
import '../model/data.dart';
import '../model/product.dart';
import '../model/product_api.dart';
import '../services/product_service.dart';
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
  List<Product> _products = [];

  List<Product> get filteredProducts {
    return _products.where((product) {
      final matchesSearch =
          product.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          product.category.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == 'All' || _selectedCategory == product.category;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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

  Future<void> _loadProducts() async {
    setState(() {
      _isLoadingProducts = true;
    });

    try {
      final remoteItems = await _productService.getProducts();
      if (!mounted) return;
      setState(() {
        _products = _mapApiProducts(remoteItems);
      });
    } on ProductException catch (error) {
      if (!mounted) return;
      debugPrint('[Categories] product API error: ${error.message}');
    } catch (_) {
      if (!mounted) return;
      debugPrint('[Categories] failed to load products.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProducts = false;
        });
      }
    }
  }

  List<Product> _mapApiProducts(List<ApiProduct> remoteItems) {
    if (remoteItems.isEmpty) return [];

    return remoteItems
        .where((item) => item.isActive == 1)
        .toList()
        .asMap()
        .entries
        .map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Product(
            id: item.id > 0 ? item.id : index + 1,
            name: item.itemName,
            category: item.category.trim().isNotEmpty
                ? item.category.trim()
                : _resolveCategoryName(item.categoryId),
            images: const [''],
            price: item.itemPrice,
            description: item.itemDesc,
            sizes: const ['Default'],
            colors: const ['Default'],
            quantity: item.itemQty,
            rating: 4,
            reviewCount: 0,
            soldCount: 0,
          );
        })
        .toList();
  }

  String _resolveCategoryName(int categoryId) {
    final match = AppData.categoryList.firstWhere(
      (category) => category.id == categoryId,
      orElse: () => AppData.categoryList.first,
    );
    return match.name ?? 'Category $categoryId';
  }
}
