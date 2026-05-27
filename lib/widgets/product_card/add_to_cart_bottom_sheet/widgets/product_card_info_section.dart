import 'package:flutter/material.dart';

import '../../../../design/app_colors.dart';
import '../../../../design/app_radius.dart';
import '../../../../design/app_spacing.dart';
import '../../../../design/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/product/product_model.dart';
import '../../../../presentation/products/comments/widgets/rating_stars.dart';

/// Bottom section of a [ProductCard]: name, category, rating row,
/// and an optional "savings" chip when the product has a discount.
///
/// Every colour is resolved from [Theme] or [AppColors] tokens — no
/// hardcoded hex values — so light and dark themes both render correctly.
class ProductCardInfoSection extends StatelessWidget {
  const ProductCardInfoSection({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final theme      = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n       = AppLocalizations.of(context);

    final hasName     = product.name.trim().isNotEmpty;
    final hasCategory = product.category.trim().isNotEmpty;
    final hasRating   = product.rating > 0 || product.reviewCount > 0;
    final hasSavings  = product.discountPercentage > 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasName)
            Text(
              product.name.trim(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.titleSmall,
            ),
          if (hasCategory) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(
              product.category.trim(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ],
          if (hasRating) ...[
            const SizedBox(height: AppSpacing.xs),
            _RatingRow(product: product),
          ],
          if (hasSavings) ...[
            const SizedBox(height: AppSpacing.xs),
            _SavingsChip(
              savingsAmount: product.basePrice - product.finalPrice,
              l10n: l10n,
            ),
          ],
        ],
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final hasReviews = product.reviewCount > 0;

    return Row(
      children: [
        RatingStars(rating: product.rating, size: AppSpacing.iconSm),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            hasReviews
                ? '${product.rating.toStringAsFixed(1)} (${product.reviewCount})'
                : product.rating.toStringAsFixed(1),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption,
          ),
        ),
      ],
    );
  }
}

class _SavingsChip extends StatelessWidget {
  const _SavingsChip({
    required this.savingsAmount,
    required this.l10n,
  });

  final double savingsAmount;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.savingsSurface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        l10n.productSavings(savingsAmount.toStringAsFixed(2)),
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.priceGreen,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}