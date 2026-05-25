import 'package:flutter/material.dart';

import '../../../models/product/product_model.dart';
import '../../../widgets/product_card/product_card.dart' as shared;

class CategoryProductCard extends StatelessWidget {
  const CategoryProductCard({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return shared.ProductCard(product: product);
  }
}
