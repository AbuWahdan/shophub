import 'package:flutter/material.dart';

import '../design/app_colors.dart';
import '../design/app_spacing.dart';
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, this.title});

  final String? title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _searchController = TextEditingController();
  final ProductService _productService = ProductService();
  late final PageController _pageController;

  bool _hasSearchText = false;
  bool _isLoadingProducts = false;
  int _selectedCategoryIndex = 0;
  List<ApiProduct> _products = [];
  List<Categories> _categoryModels = [];

  List<String> get _categories => _categoryModels
      .where((category) => category.name != null)
      .map((category) => category.name!)
      .toList();

  String get _currentCategory {
    if (_categories.isEmpty) return 'All';
    if (_selectedCategoryIndex < 0 ||
        _selectedCategoryIndex >= _categories.length) {
      return 'All';
    }
    return _categories[_selectedCategoryIndex];
  }

  @override
  void initState() {
    super.initState();
    _products = AppData.products;
    _categoryModels = _cloneCategories();
    final allIndex = _categories.indexOf('All');
    _selectedCategoryIndex = allIndex >= 0 ? allIndex : 0;
    _syncCategorySelection(_currentCategory);
    _pageController = PageController(initialPage: _selectedCategoryIndex);
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
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

  List<ApiProduct> _productsForCategory(String category) {
    final query = _searchController.text.trim().toLowerCase();
    return _products.where((product) {
      final matchesSearch =
          query.isEmpty ||
          product.itemName.toLowerCase().contains(query) ||
          _categoryName(product).toLowerCase().contains(query);
      final matchesCategory =
          category == 'All' || _categoryName(product) == category;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  Widget _categoryWidget() {
    return Container(
      margin: AppSpacing.vertical(AppSpacing.sm),
      width: AppTheme.fullWidth(context),
      height: AppSpacing.imageMd,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _categoryModels
            .map(
              (category) => ProductIcon(
                model: category,
                label: _categoryLabel(context, category.name ?? ''),
                onSelected: (model) {
                  _setSelectedCategory(model.name ?? 'All');
                },
              ),
            )
            .toList(),
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

  Widget _buildCategoryPage(String category) {
    final categoryProducts = _productsForCategory(category);
    return RefreshIndicator(
      onRefresh: () => _loadProducts(forceRefresh: true),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          if (categoryProducts.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.inventory_2_outlined,
                title: context.l10n.searchFilterNoResults,
                message: context.l10n.searchFilterHint,
              ),
            )
          else
            SliverPadding(
              padding: AppTheme.hPadding,
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  mainAxisSpacing: AppSpacing.lg,
                  crossAxisSpacing: AppSpacing.lg,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final product = categoryProducts[index];
                  return ProductCard(product: product, onSelected: (model) {});
                }, childCount: categoryProducts.length),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProducts) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _search(),
        _categoryWidget(),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _categories.length,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _selectedCategoryIndex = index;
                _syncCategorySelection(_currentCategory);
              });
            },
            itemBuilder: (context, index) {
              return _buildCategoryPage(_categories[index]);
            },
          ),
        ),
      ],
    );
  }

  void _setSelectedCategory(String name) {
    final index = _categories.indexOf(name);
    if (index < 0) return;
    setState(() {
      _selectedCategoryIndex = index;
      _syncCategorySelection(name);
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  void _syncCategorySelection(String selectedCategory) {
    for (var item in _categoryModels) {
      item.isSelected = item.name == selectedCategory;
    }
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
        message: context.l10n.productsLoadFailed(error.message),
        type: AppSnackBarType.error,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _products = AppData.products;
      });
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
