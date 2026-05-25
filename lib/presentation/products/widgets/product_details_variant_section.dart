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

// Updated _MultiVariantList to use a Wrap similar to your HTML .colors/.sizes
// --------------------------------------------------------------------------

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
        const Text("Options", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: variants.map((variant) {
            final isSelected = selectedVariant.detId == variant.detId;
            return InkWell(
              onTap: () => onVariantSelected(variant),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF4e54c8) : const Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${variant.size} / ${variant.color}",
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            );
          }).toList(),
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