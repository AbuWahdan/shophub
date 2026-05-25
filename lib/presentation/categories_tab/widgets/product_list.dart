import 'package:flutter/material.dart';

import '../../../design/app_spacing.dart';
import '../../../models/product/product_model.dart';
import 'category_tokens.dart';
import 'product_card.dart';

class CategoryProductList extends StatelessWidget {
  const CategoryProductList({super.key, required this.products});

  final List<ProductModel> products;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount =
            (constraints.maxWidth / CategoryTokens.productMinWidth)
                .floor()
                .clamp(1, 3);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSpacing.lg,
            mainAxisSpacing: AppSpacing.lg,
            childAspectRatio: crossAxisCount == 1 ? 1.45 : 0.82,
          ),
          itemBuilder: (context, index) {
            return CategoryProductCard(product: products[index]);
          },
        );
      },
    );
  }
}
