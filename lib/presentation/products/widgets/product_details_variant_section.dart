import 'package:flutter/material.dart';

import '../../../design/app_colors.dart';
import '../../../design/app_radius.dart';
import '../../../design/app_spacing.dart';
import '../../../design/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/product/product_model.dart';
import '../../../widgets/product_card/add_to_cart_bottom_sheet/widgets/product_variant_widgets.dart';
import '../../../widgets/product_card/product_variant_card_with_stock.dart';

class ProductDetailsVariantSection extends StatelessWidget {
  final List<ProductVariant> variants;
  final ProductVariant? selectedVariant;
  final bool hasSingleVariant;
  final ValueChanged<ProductVariant> onVariantSelected;

  const ProductDetailsVariantSection({
    super.key,
    required this.variants,
    required this.selectedVariant,
    required this.hasSingleVariant,
    required this.onVariantSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedVariant == null) return const SizedBox.shrink();

    return hasSingleVariant
        ? _SingleVariantCard(variant: selectedVariant!)
        : _MultiVariantList(
      variants: variants,
      selectedVariant: selectedVariant!,
      onVariantSelected: onVariantSelected,
    );
  }
}

class _SingleVariantCard extends StatelessWidget {
  final ProductVariant variant;

  const _SingleVariantCard({required this.variant});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.insetsLg,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductVariantSummary(variant: variant, showColor: false),
          const SizedBox(height: AppSpacing.md),
          _StockBadge(stock: variant.stock),
        ],
      ),
    );
  }
}

class _MultiVariantList extends StatelessWidget {
  final List<ProductVariant> variants;
  final ProductVariant selectedVariant;
  final ValueChanged<ProductVariant> onVariantSelected;

  const _MultiVariantList({
    required this.variants,
    required this.selectedVariant,
    required this.onVariantSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).productDetails,
          style: AppTextStyles.titleMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        ...variants.map(
              (variant) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ProductVariantCardWithStock(
              variant: variant,
              selected: selectedVariant.detId > 0
                  ? selectedVariant.detId == variant.detId
                  : selectedVariant.size == variant.size &&
                  selectedVariant.color == variant.color,
              quantity: 1,
              onTap: () => onVariantSelected(variant),
            ),
          ),
        ),
      ],
    );
  }
}

class _StockBadge extends StatelessWidget {
  final int stock;

  const _StockBadge({required this.stock});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (label, bg, fg) = switch (stock) {
      <= 0 => (
      l10n.stockOutOfStock,
      AppColors.error.withValues(alpha: 0.1),
      AppColors.error,
      ),
      <= 5 => (
      l10n.stockLowCount(stock),
      AppColors.warning.withValues(alpha: 0.1),
      AppColors.warning,
      ),
      _ => (
      l10n.stockAvailableCount(stock),
      AppColors.primary.withValues(alpha: 0.1),
      AppColors.primary,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: fg,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}