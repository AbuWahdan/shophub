import 'package:flutter/material.dart';
import '../../../data/categories_data.dart';
import '../../../models/data.dart';
import '../../../models/product_api.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../design/app_text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../services/product_service.dart';
import '../../widgets/widgets/product_search_bar.dart';
import '../../widgets/product_card.dart';
import 'camera_picker_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, this.title});

  final String? title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _searchController = TextEditingController();
  final ProductService _productService = ProductService();
  final PageController _pageController = PageController();

  bool _hasSearchText = false;
  bool _isLoading = false;
  int _currentCategoryIndex = 0;
  int? _selectedCategoryId;
  String? _errorMessage;
  List<ApiProduct> _products = [];
  final Map<int, List<ApiProduct>> _productsByTab = <int, List<ApiProduct>>{};
  final Map<int, String?> _errorsByTab = <int, String?>{};
  final Set<int> _loadedTabs = <int>{};

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  List<ApiProduct> get _filteredProducts {
    final query = _searchController.text.trim().toLowerCase();
    return _products.where((product) {
      if (query.isEmpty) return true;
      final category =
          CategoriesData.getCategoryById(product.categoryId)?.name ??
          product.category;
      return product.itemName.toLowerCase().contains(query) ||
          category.toLowerCase().contains(query);
    }).toList();
  }

  int get _currentTabKey => _selectedCategoryId ?? 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final mainCategories = CategoriesData.getMainCategories();

    return Column(
      children: [
        Container(
          margin: AppSpacing.insetsMd,
          child: ProductSearchBar(
            controller: _searchController,
            hintText: l10n.homeSearchHint,
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
            onCameraTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CameraPickerScreen()),
              );
            },
          ),
        ),
        SizedBox(
          height: 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding:AppSpacing.insetsMd,
            itemCount: mainCategories.length + 1,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              if (index == 0) {
                return FilterChip(
                  label: Text(l10n.categoryAll),
                  selected: _currentCategoryIndex == 0,
                  onSelected: (_) {
                    _jumpToCategoryIndex(0);
                  },
                );
              }

              final category = mainCategories[index - 1];
              return FilterChip(
                label: Text(category.name),
                selected: _selectedCategoryId == category.id,
                onSelected: (_) {
                  _jumpToCategoryIndex(index);
                },
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: mainCategories.length + 1,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) => _buildProductsContent(l10n),
          ),
        ),
      ],
    );
  }

  Widget _buildProductsContent(AppLocalizations l10n) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_errorMessage != null && _products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.errorLoadingProducts,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(onPressed: _loadProducts, child: Text(l10n.retry)),
          ],
        ),
      );
    }

    if (_filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.noProductsInCategory,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadProducts(forceRefresh: true),
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding:AppSpacing.insetsMd,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.82,
          mainAxisSpacing: AppSpacing.lg,
          crossAxisSpacing: AppSpacing.lg,
        ),
        itemCount: _filteredProducts.length,
        itemBuilder: (context, index) {
          return ProductCard(product: _filteredProducts[index]);
        },
      ),
    );
  }

  void _jumpToCategoryIndex(int index) {
    if (_currentCategoryIndex == index) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  void _onPageChanged(int index) {
    final categories = CategoriesData.getMainCategories();
    setState(() {
      _currentCategoryIndex = index;
      _selectedCategoryId = index == 0 ? null : categories[index - 1].id;
    });
    _loadProducts();
  }

  Future<void> _loadProducts({bool forceRefresh = false}) async {
    final tabKey = _currentTabKey;
    if (!forceRefresh && _loadedTabs.contains(tabKey)) {
      setState(() {
        _products = _productsByTab[tabKey] ?? const <ApiProduct>[];
        _errorMessage = _errorsByTab[tabKey];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = _errorsByTab[tabKey];
    });

    try {
      final products = _selectedCategoryId == null
          ? await _productService.getProducts(forceRefresh: forceRefresh)
          : await _productService.getProductsByCategory(
              _selectedCategoryId!,
              forceRefresh: forceRefresh,
            );
      if (!mounted) return;
      final active = products.where((item) => item.isActive == 1).toList();
      setState(() {
        _productsByTab[tabKey] = active;
        _errorsByTab.remove(tabKey);
        _loadedTabs.add(tabKey);
        _products = active;
        _errorMessage = null;
        _isLoading = false;
      });
      if (_selectedCategoryId == null) {
        AppData.setProducts(active);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _products =
            _productsByTab[tabKey] ??
            (_selectedCategoryId == null ? AppData.products : const []);
        _errorsByTab[tabKey] = error.toString();
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }
}
