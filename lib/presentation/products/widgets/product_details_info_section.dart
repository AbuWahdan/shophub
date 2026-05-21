import 'package:flutter/material.dart';

import '../../../design/app_spacing.dart';
import '../../../design/app_text_styles.dart';
import '../../../models/product/product_model.dart';
import '../../../widgets/product_card/add_to_cart_bottom_sheet/widgets/product_variant_widgets.dart';

class ProductDetailsInfoSection extends StatelessWidget {
  final ProductModel product;
  final ProductVariant? selectedVariant;
  final bool hasSingleVariant;

  const ProductDetailsInfoSection({
    super.key,
    required this.product,
    required this.selectedVariant,
    required this.hasSingleVariant,
  });

  @override
  Widget build(BuildContext context) {
    final showColorCircle = hasSingleVariant &&
        selectedVariant != null &&
        isMeaningfulProductValue(selectedVariant!.color);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (product.name.trim().isNotEmpty)
          Text(
            product.name.trim(),
            style: AppTextStyles.headingSmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        if (showColorCircle) ...[
          const SizedBox(height: AppSpacing.sm),
          ProductColorCircle(
            colorValue: selectedVariant!.color,
            showLabel: false,
          ),
        ],
        if (product.category.trim().isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(product.category.trim(), style: AppTextStyles.bodySmall),
        ],
      ],
    );
  }
}