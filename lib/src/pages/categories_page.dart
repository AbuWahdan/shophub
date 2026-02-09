import 'package:flutter/material.dart';

import '../design/app_spacing.dart';
import '../design/app_text_styles.dart';
import '../l10n/l10n.dart';
import '../model/data.dart';
import '../model/product.dart';
import '../themes/theme.dart';
import '../widgets/product_card.dart';
import '../widgets/product_icon.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  String searchQuery = '';
  final Set<String> _selectedCategories = {'All'};
  List<Product> get filteredProducts {
    return AppData.productList.where((product) {
      final matchesSearch =
          product.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          product.category.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory = _selectedCategories.contains('All') ||
          _selectedCategories.contains(product.category);
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppTheme.padding,
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: context.l10n.categoriesSearchHint,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Align(
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
                        if (model.name == 'All') {
                          _showCategoryMultiSelect();
                          return;
                        }
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
            return Padding(
              padding: AppSpacing.insetsLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.categoriesSelectTitle,
                    style: AppTextStyles.titleMedium(context),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: ListView(
                      children: categories.map((category) {
                        final name = category.name!;
                        final isAll = name == 'All';
                        final isSelected = _selectedCategories.contains(name);
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
            );
          },
        );
      },
    );
  }
}
