import 'package:flutter/material.dart';

import '../../../../design/app_colors.dart';
import '../../../../design/app_radius.dart';
import '../../../../design/app_spacing.dart';
import '../../../../design/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/product/product_model.dart';
import '../../../../widgets/product_card/add_to_cart_bottom_sheet/widgets/product_variant_widgets.dart';

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
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(product.name, style: AppTextStyles.titleLarge),
        const SizedBox(height: AppSpacing.xs),
        _PriceRow(product: product, selectedVariant: selectedVariant),
        const SizedBox(height: AppSpacing.xs),
        if (product.rating != null)
          _RatingRow(rating: product.rating!, reviewCount: product.reviewCount),
        const SizedBox(height: AppSpacing.sm),
        if (product.description?.trim().isNotEmpty ?? false)
          _DescriptionText(description: product.description!),
        const SizedBox(height: AppSpacing.md),
        _DeliveryBadge(),
        const SizedBox(height: AppSpacing.sm),
        _StockIndicator(
          variant: selectedVariant,
          hasSingleVariant: hasSingleVariant,
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final ProductModel product;
  final ProductVariant? selectedVariant;

  const _PriceRow({required this.product, required this.selectedVariant});

  @override
  Widget build(BuildContext context) {
    final displayPrice = selectedVariant?.price ?? product.finalPrice;
    final discountPct = selectedVariant?.discount ?? product.discountPrice ?? 0;
    final hasDiscount = discountPct > 0;

    final originalPrice = hasDiscount
        ? displayPrice / (1 - discountPct / 100)
        : null;

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.sm,
      children: [
        Text(
          product.finalPrice.toString(),
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.success,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (hasDiscount && originalPrice != null) ...[
          Text(
            product.basePrice.toString(),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          _DiscountChip(percent: discountPct),
        ],
      ],
    );
  }
}

class _DiscountChip extends StatelessWidget {
  final double percent;

  const _DiscountChip({required this.percent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        '-${percent.toStringAsFixed(0)}%',
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.error,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  final double rating;
  final int? reviewCount;

  const _RatingRow({required this.rating, this.reviewCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...List.generate(
          5,
              (i) => Icon(
            i < rating.floor()
                ? Icons.star_rounded
                : (i < rating
                ? Icons.star_half_rounded
                : Icons.star_outline_rounded),
            size: 16,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          rating.toStringAsFixed(1),
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.warning,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (reviewCount != null) ...[
          const SizedBox(width: AppSpacing.xs),
          Text(
            '($reviewCount)',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class _DescriptionText extends StatelessWidget {
  final String description;

  const _DescriptionText({required this.description});

  @override
  Widget build(BuildContext context) {
    return Text(
      description,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textSecondary,
        height: 1.5,
      ),
    );
  }
}

class _DeliveryBadge extends StatelessWidget {
  const _DeliveryBadge();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: AppSpacing.insetsSm,
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_shipping_outlined, size: 16, color: AppColors.success),
          const SizedBox(width: AppSpacing.xs),
          Text(
            l10n.productFreeDelivery,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StockIndicator extends StatelessWidget {
  final ProductVariant? variant;
  final bool hasSingleVariant;

  const _StockIndicator({required this.variant, required this.hasSingleVariant});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stock = variant?.stock ?? 0;

    if (!hasSingleVariant) return const SizedBox.shrink();

    final isLow = stock > 0 && stock <= 5;
    final isOut = stock <= 0;

    if (!isLow && !isOut) return const SizedBox.shrink();

    return Text(
      isOut
          ? l10n.productOutOfStock
          : l10n.productLowStock(stock),
      style: AppTextStyles.labelMedium.copyWith(
        color: isOut ? AppColors.error : AppColors.warning,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}