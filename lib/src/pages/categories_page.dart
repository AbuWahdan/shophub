import 'package:flutter/material.dart';

import '../design/app_spacing.dart';
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
  String selectedCategory = 'All';
  List<Product> get filteredProducts {
    return AppData.productList.where((product) {
      final matchesSearch =
          product.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          product.category.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory =
          selectedCategory == 'All' || product.category == selectedCategory;
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
                        setState(() {
                          for (var item in AppData.categoryList) {
                            item.isSelected = false;
                          }
                          model.isSelected = true;
                          selectedCategory = model.name!;
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
}
