import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../design/app_spacing.dart';
import '../design/app_text_styles.dart';
import '../l10n/l10n.dart';
import '../model/data.dart';
import '../model/product_api.dart';
import '../services/product_service.dart';
import '../shared/widgets/app_snackbar.dart';
import '../shared/widgets/product_search_bar.dart';
import '../themes/theme.dart';
import '../widgets/product_card.dart';
import '../widgets/product_icon.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, this.title});

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _searchController = TextEditingController();
  final ProductService _productService = ProductService();
  bool _hasSearchText = false;
  bool _isLoadingProducts = false;
  final Set<String> _selectedCategories = {'All'};
  List<ApiProduct> _products = [];

  List<ApiProduct> get _filteredProducts {
    final query = _searchController.text.trim().toLowerCase();
    return _products.where((product) {
      final matchesSearch =
          query.isEmpty ||
          product.itemName.toLowerCase().contains(query) ||
          _categoryName(product).toLowerCase().contains(query);
      final matchesCategory =
          _selectedCategories.contains('All') ||
          _selectedCategories.contains(_categoryName(product));
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

  Widget _categoryWidget() {
    return Container(
      margin: AppSpacing.vertical(AppSpacing.sm),
      width: AppTheme.fullWidth(context),
      height: AppSpacing.imageMd,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: AppData.categoryList
            .map(
              (category) => ProductIcon(
                model: category,
                label: _categoryLabel(context, category.name ?? ''),
                onSelected: (model) {
                  setState(() {
                    _selectedCategories
                      ..clear()
                      ..add(model.name ?? 'All');
                    _syncCategorySelection();
                  });
                },
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _productWidget() {
    return Container(
      margin: AppSpacing.vertical(AppSpacing.sm),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          mainAxisSpacing: AppSpacing.lg,
          crossAxisSpacing: AppSpacing.lg,
        ),
        itemCount: _filteredProducts.length,
        itemBuilder: (context, index) {
          final product = _filteredProducts[index];
          return ProductCard(
            product: product,
            onSelected: (model) {
              setState(() {});
            },
          );
        },
      ),
    );
  }

  Widget _search() {
    return Container(
      margin: AppTheme.padding,
      child: ProductSearchBar(
        controller: _searchController,
        hintText: context.l10n.homeSearchHint,
        hasSearchText: _hasSearchText,
        onClear: () {
          _searchController.clear();
          setState(() {
            _hasSearchText = false;
          });
        },
        onChanged: (value) {
          setState(() {
            _hasSearchText = value.trim().isNotEmpty;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _loadProducts(forceRefresh: true),
      child: SizedBox(
        height: MediaQuery.of(context).size.height - AppSpacing.massive,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          dragStartBehavior: DragStartBehavior.down,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              _search(),
              if (_isLoadingProducts)
                const LinearProgressIndicator(minHeight: AppSpacing.borderThin),
              Padding(
                padding: AppTheme.hPadding,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _showCategoryMultiSelect,
                    icon: const Icon(Icons.tune),
                    label: Text(
                      _selectedCategories.contains('All')
                          ? context.l10n.categoriesAll
                          : context.l10n.categoriesSelectedCount(
                              _selectedCategories.length,
                            ),
                    ),
                  ),
                ),
              ),
              _categoryWidget(),
              _productWidget(),
            ],
          ),
        ),
      ),
    );
  }

  void _syncCategorySelection() {
    for (var item in AppData.categoryList) {
      final name = item.name ?? '';
      item.isSelected = _selectedCategories.contains('All')
          ? name == 'All'
          : _selectedCategories.contains(name);
    }
  }

  void _showCategoryMultiSelect() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final categories = AppData.categoryList
                .where((category) => category.name != null)
                .toList();
            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: Padding(
                  padding: AppSpacing.insetsLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.categoriesSelectTitle,
                        style: AppTextStyles.titleMedium(context),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Expanded(
                        child: ListView(
                          children: categories.map((category) {
                            final name = category.name!;
                            final isAll = name == 'All';
                            final isSelected = _selectedCategories.contains(
                              name,
                            );
                            return CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                _categoryLabel(context, name),
                                style: AppTextStyles.bodyLarge(context),
                              ),
                              value: isSelected,
                              onChanged: (checked) {
                                setModalState(() {
                                  if (isAll) {
                                    _selectedCategories
                                      ..clear()
                                      ..add('All');
                                  } else if (checked == true) {
                                    _selectedCategories.remove('All');
                                    _selectedCategories.add(name);
                                  } else {
                                    _selectedCategories.remove(name);
                                    if (_selectedCategories.isEmpty) {
                                      _selectedCategories.add('All');
                                    }
                                  }
                                });
                                setState(_syncCategorySelection);
                              },
                              controlAffinity: ListTileControlAffinity.trailing,
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
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

  Future<void> _loadProducts({bool forceRefresh = false}) async {
    setState(() {
      _isLoadingProducts = true;
    });

    try {
      final remoteItems = await _productService.getProducts(
        forceRefresh: forceRefresh,
      );
      if (!mounted) return;
      final activeProducts = remoteItems
          .where((item) => item.isActive == 1)
          .toList();
      setState(() {
        _products = activeProducts;
      });
      AppData.setProducts(activeProducts);
    } on ProductException catch (error) {
      if (!mounted) return;
      setState(() {
        _products = AppData.products;
      });
      AppSnackBar.show(
        context,
        message: 'Failed to load products: ${error.message}',
        type: AppSnackBarType.error,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _products = AppData.products;
      });
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
