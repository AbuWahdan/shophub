import 'package:flutter/material.dart';

import '../design/app_colors.dart';
import '../design/app_spacing.dart';
import '../design/app_text_styles.dart';
import '../l10n/l10n.dart';
import '../model/data.dart';
import '../model/product_api.dart';
import '../services/product_service.dart';
import '../themes/theme.dart';
import '../widgets/product_card.dart';

class SearchFilterPage extends StatefulWidget {
  const SearchFilterPage({super.key});

  @override
  State<SearchFilterPage> createState() => _SearchFilterPageState();
}

class _SearchFilterPageState extends State<SearchFilterPage> {
  final ProductService _productService = ProductService();
  bool _isLoadingProducts = false;
  List<ApiProduct> _products = [];
  String searchQuery = '';
  String selectedCategory = 'All';
  double minPrice = 0;
  double maxPrice = 10000;
  double selectedMinPrice = 0;
  double selectedMaxPrice = 10000;
  int selectedRating = 0;
  SortOption sortBy = SortOption.bestSelling;

  List<ApiProduct> get filteredProducts {
    return _products.where((product) {
      final matchesSearch =
          product.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          product.description.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory =
          selectedCategory == 'All' || product.category == selectedCategory;
      final matchesPrice =
          product.finalPrice >= selectedMinPrice &&
          product.finalPrice <= selectedMaxPrice;
      final matchesRating =
          selectedRating == 0 || product.rating >= selectedRating;
      return matchesSearch && matchesCategory && matchesPrice && matchesRating;
    }).toList()..sort((a, b) {
      switch (sortBy) {
        case SortOption.priceLowHigh:
          return a.finalPrice.compareTo(b.finalPrice);
        case SortOption.priceHighLow:
          return b.finalPrice.compareTo(a.finalPrice);
        case SortOption.bestRating:
          return b.rating.compareTo(a.rating);
        case SortOption.newest:
          return b.id.compareTo(a.id);
        case SortOption.bestSelling:
          return b.soldCount.compareTo(a.soldCount);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _products = AppData.products;
    if (_products.isEmpty) {
      _loadProducts();
    }
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoadingProducts = true);
    try {
      final remoteItems = await _productService.getProducts();
      if (!mounted) return;
      final active = remoteItems.where((item) => item.isActive == 1).toList();
      setState(() => _products = active);
      AppData.setProducts(active);
    } catch (_) {
      if (!mounted) return;
      setState(() => _products = const []);
      AppData.setProducts(const []);
    } finally {
      if (mounted) {
        setState(() => _isLoadingProducts = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProducts) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.searchFilterTitle)),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.searchFilterTitle)),
      body: Column(
        children: [
          Padding(
            padding: AppTheme.padding,
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: context.l10n.searchFilterHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: AppSpacing.horizontal(AppSpacing.lg),
            child: Row(
              children: [
                _buildFilterChip(
                  context.l10n.searchFilterCategory,
                  Icons.category,
                  () => _showCategoryBottomSheet(),
                ),
                const SizedBox(width: AppSpacing.md),
                _buildFilterChip(
                  context.l10n.searchFilterPrice,
                  Icons.attach_money,
                  () => _showPriceBottomSheet(),
                ),
                const SizedBox(width: AppSpacing.md),
                _buildFilterChip(
                  context.l10n.searchFilterRating,
                  Icons.star,
                  () => _showRatingBottomSheet(),
                ),
                const SizedBox(width: AppSpacing.md),
                _buildFilterChip(
                  context.l10n.searchFilterSort,
                  Icons.sort,
                  () => _showSortBottomSheet(),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: AppSpacing.giant,
                          color: AppColors.neutral500,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          context.l10n.searchFilterNoResults,
                          style: AppTextStyles.bodyMedium(context),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: AppSpacing.insetsLg,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      mainAxisSpacing: AppSpacing.lg,
                      crossAxisSpacing: AppSpacing.lg,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      return ProductCard(
                        product: filteredProducts[index],
                        onSelected: (product) {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => SizedBox()),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Chip(
        label: Text(label, style: AppTextStyles.bodySmall(context)),
        avatar: Icon(icon, size: AppSpacing.iconSm),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }

  void _showCategoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: AppSpacing.insetsLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.searchFilterSelectCategory,
                style: AppTextStyles.titleMedium(context),
              ),
              const SizedBox(height: AppSpacing.lg),
              ...AppData.categoryList.map((category) {
                final categoryName = category.name ?? '';
                return ListTile(
                  title: Text(
                    _categoryLabel(context, categoryName),
                    style: AppTextStyles.bodyLarge(context),
                  ),
                  trailing: selectedCategory == categoryName
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    setState(() {
                      selectedCategory = categoryName.isEmpty
                          ? 'All'
                          : categoryName;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showPriceBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: AppSpacing.insetsLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.searchFilterPriceRange,
                    style: AppTextStyles.titleMedium(context),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    '\$${selectedMinPrice.toStringAsFixed(0)} - \$${selectedMaxPrice.toStringAsFixed(0)}',
                    style: AppTextStyles.titleSmall(context),
                  ),
                  RangeSlider(
                    values: RangeValues(selectedMinPrice, selectedMaxPrice),
                    min: minPrice,
                    max: maxPrice,
                    onChanged: (RangeValues values) {
                      setModalState(() {
                        selectedMinPrice = values.start;
                        selectedMaxPrice = values.end;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {});
                        Navigator.pop(context);
                      },
                      child: Text(context.l10n.commonApply),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showRatingBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: AppSpacing.insetsLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.searchFilterMinimumRating,
                style: AppTextStyles.titleMedium(context),
              ),
              const SizedBox(height: AppSpacing.lg),
              ...List.generate(5, (index) {
                final rating = 5 - index;
                return ListTile(
                  title: Row(
                    children: List.generate(
                      rating,
                      (i) => Icon(
                        Icons.star,
                        size: AppSpacing.iconSm,
                        color: AppColors.accentYellow,
                      ),
                    ),
                  ),
                  trailing: selectedRating == rating ? Icon(Icons.check) : null,
                  onTap: () {
                    setState(() {
                      selectedRating = rating;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
              ListTile(
                title: Text(
                  context.l10n.searchFilterAnyRating,
                  style: AppTextStyles.bodyLarge(context),
                ),
                trailing: selectedRating == 0 ? Icon(Icons.check) : null,
                onTap: () {
                  setState(() {
                    selectedRating = 0;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: AppSpacing.insetsLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.searchFilterSortBy,
                style: AppTextStyles.titleMedium(context),
              ),
              const SizedBox(height: AppSpacing.lg),
              ...SortOption.values.map((sort) {
                return ListTile(
                  title: Text(_sortLabel(context, sort)),
                  trailing: sortBy == sort ? const Icon(Icons.check) : null,
                  onTap: () {
                    setState(() {
                      sortBy = sort;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
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

  String _sortLabel(BuildContext context, SortOption option) {
    final l10n = context.l10n;
    switch (option) {
      case SortOption.bestSelling:
        return l10n.searchFilterSortBestSelling;
      case SortOption.priceLowHigh:
        return l10n.searchFilterSortPriceLowHigh;
      case SortOption.priceHighLow:
        return l10n.searchFilterSortPriceHighLow;
      case SortOption.bestRating:
        return l10n.searchFilterSortBestRating;
      case SortOption.newest:
        return l10n.searchFilterSortNewest;
    }
  }
}

enum SortOption { bestSelling, priceLowHigh, priceHighLow, bestRating, newest }
