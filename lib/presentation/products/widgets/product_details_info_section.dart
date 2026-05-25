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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0), // Matches .info { padding: 12px; }
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.name.trim().isNotEmpty)
            Text(
              product.name.trim(),
              style: AppTextStyles.titleLarge.copyWith(
                fontSize: 16, // Matching HTML exactly
                fontWeight: FontWeight.w800, // Matching HTML exactly
                color: Theme.of(context).colorScheme.onSurface,
              ),
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
            const SizedBox(height: 10), // Matches your desc top-margin
            Text(
              product.category.trim(),
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 12,
                color: Colors.grey.shade600, // Matches .desc { color: #666; }
              ),
            ),
          ],
        ],
      ),
    );
  }
}