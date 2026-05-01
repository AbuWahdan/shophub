import 'package:flutter/material.dart';

import '../../../data/categories_data.dart';
import '../../../models/data.dart';
import '../../../models/product_model.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../design/app_text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../services/product_service.dart';
import '../../widgets/widgets/product_search_bar.dart';
import '../../widgets/product_card.dart';
import 'camera_picker/camera_picker_screen.dart';

/// Root widget for the Home tab.
/// Owns all state; delegates rendering to focused sub-widgets.
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
  int _currentCategoryIndex = 0;
  int? _selectedCategoryId;

  /// Per-tab state — keyed by category id (null = "All").
  final Map<int, _TabState> _tabStates = {};

  @override
  void initState() {
    super.initState();
    _loadTab();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Stable key for the currently visible tab.
  int get _tabKey => _selectedCategoryId ?? 0;

  _TabState get _currentTab => _tabStates[_tabKey] ?? const _TabState();

  List<ProductModel> get _filteredProducts {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _currentTab.products;
    return _currentTab.products.where((p) {
      final categoryName =
          CategoriesData.getCategoryById(p.categoryId)?.name ?? p.category;
      return p.itemName.toLowerCase().contains(query) ||
          categoryName.toLowerCase().contains(query);
    }).toList();
  }

  // ── Data loading ──────────────────────────────────────────────────────────

  Future<void> _loadTab({bool forceRefresh = false}) async {
    final tabKey = _tabKey;
    final existing = _tabStates[tabKey];

    // Return cached data unless a forced refresh is requested.
    if (!forceRefresh && (existing?.isLoaded ?? false)) {
      setState(() {}); // repaint with cached data
      return;
    }

    setState(() {
      _tabStates[tabKey] = (existing ?? const _TabState()).copyWith(
        isLoading: true,
        // FIX: clear the previous error BEFORE showing the loading state
        // so the error view never flashes while a new request is in-flight.
        error: null,
      );
    });

    try {
      final raw = _selectedCategoryId == null
          ? await _productService.getProducts(forceRefresh: forceRefresh)
          : await _productService.getProductsByCategory(
        _selectedCategoryId!,
        forceRefresh: forceRefresh,
      );
      if (!mounted) return;

      final active = raw.where((p) => p.isActive == 1).toList();

      if (_selectedCategoryId == null) {
        AppData.setProducts(active);
      }

      setState(() {
        _tabStates[tabKey] = _TabState(
          products: active,
          isLoaded: true,
          isLoading: false,
        );
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _tabStates[tabKey] = _TabState(
          // Keep stale data visible if we already had some.
          products: existing?.products ?? const [],
          isLoaded: existing?.isLoaded ?? false,
          isLoading: false,
          error: error.toString(),
        );
      });
    }
  }

  // ── Category / page navigation ────────────────────────────────────────────

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
    _loadTab();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mainCategories = CategoriesData.getMainCategories();

    return Column(
      children: [
        _SearchRow(
          controller: _searchController,
          hasSearchText: _hasSearchText,
          onChanged: (value) =>
              setState(() => _hasSearchText = value.trim().isNotEmpty),
          onClear: () {
            _searchController.clear();
            setState(() => _hasSearchText = false);
          },
          onCameraTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CameraPickerScreen()),
          ),
        ),
        _CategoryTabBar(
          categories: mainCategories,
          currentIndex: _currentCategoryIndex,
          selectedCategoryId: _selectedCategoryId,
          onTabSelected: _jumpToCategoryIndex,
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: mainCategories.length + 1,
            onPageChanged: _onPageChanged,
            itemBuilder: (_, __) => _ProductTabContent(
              tabState: _currentTab,
              products: _filteredProducts,
              onRefresh: () => _loadTab(forceRefresh: true),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Per-tab immutable state container
// ─────────────────────────────────────────────────────────────────────────────

/// Immutable snapshot of a single category tab's loading state.
class _TabState {
  const _TabState({
    this.products = const [],
    this.isLoading = false,
    this.isLoaded = false,
    this.error,
  });

  final List<ProductModel> products;
  final bool isLoading;
  final bool isLoaded;
  final String? error;

  _TabState copyWith({
    List<ProductModel>? products,
    bool? isLoading,
    bool? isLoaded,
    String? error,
    bool clearError = false,
  }) {
    return _TabState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      isLoaded: isLoaded ?? this.isLoaded,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets — each owns exactly one concern
// ─────────────────────────────────────────────────────────────────────────────

class _SearchRow extends StatelessWidget {
  const _SearchRow({
    required this.controller,
    required this.hasSearchText,
    required this.onChanged,
    required this.onClear,
    required this.onCameraTap,
  });

  final TextEditingController controller;
  final bool hasSearchText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final VoidCallback onCameraTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: AppSpacing.insetsMd,
      child: ProductSearchBar(
        controller: controller,
        hintText: l10n.homeSearchHint,
        hasSearchText: hasSearchText,
        onClear: onClear,
        onChanged: onChanged,
        onCameraTap: onCameraTap,
      ),
    );
  }
}

class _CategoryTabBar extends StatelessWidget {
  const _CategoryTabBar({
    required this.categories,
    required this.currentIndex,
    required this.selectedCategoryId,
    required this.onTabSelected,
  });

  final List<dynamic> categories; // List<CategoryModel>
  final int currentIndex;
  final int? selectedCategoryId;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: AppSpacing.tabHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.insetsMd,
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (_, index) {
          if (index == 0) {
            return FilterChip(
              label: Text(l10n.categoryAll),
              selected: currentIndex == 0,
              onSelected: (_) => onTabSelected(0),
            );
          }
          final category = categories[index - 1];
          return FilterChip(
            label: Text(category.name as String),
            selected: selectedCategoryId == category.id,
            onSelected: (_) => onTabSelected(index),
          );
        },
      ),
    );
  }
}

class _ProductTabContent extends StatelessWidget {
  const _ProductTabContent({
    required this.tabState,
    required this.products,
    required this.onRefresh,
  });

  final _TabState tabState;
  final List<ProductModel> products;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (tabState.isLoading && products.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    // FIX: only show error when there is an error AND no products to show.
    // Previously _errorMessage was set while loading, causing a flash.
    if (tabState.error != null && products.isEmpty) {
      return _ErrorView(onRetry: onRefresh);
    }

    if (products.isEmpty) {
      return _EmptyView();
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: AppSpacing.insetsMd,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.82,
          mainAxisSpacing: AppSpacing.lg,
          crossAxisSpacing: AppSpacing.lg,
        ),
        itemCount: products.length,
        itemBuilder: (_, index) => ProductCard(product: products[index]),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.textHint),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.errorLoadingProducts,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton(
            onPressed: onRetry,
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
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
}