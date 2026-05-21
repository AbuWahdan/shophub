import 'package:flutter/material.dart';

import '../../../../design/app_spacing.dart';
import '../../../../design/app_text_styles.dart';
import '../../../../models/product/product_model.dart';
import '../../../../presentation/products/widgets/rating_stars.dart';

class ProductCardInfoSection extends StatelessWidget {
  final ProductModel product;

  const ProductCardInfoSection({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.name.trim().isNotEmpty)
            Text(
              product.name.trim(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.titleSmall,
            ),
          if (product.category.trim().isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              product.category.trim(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ],
          if (product.rating > 0 || product.reviewCount > 0) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                RatingStars(rating: product.rating, size: AppSpacing.iconSm),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    product.reviewCount > 0
                        ? '${product.rating.toStringAsFixed(1)} (${product.reviewCount})'
                        : product.rating.toStringAsFixed(1),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}