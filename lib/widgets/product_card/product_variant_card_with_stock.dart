import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sinwar_shoping/design/app_colors.dart';
import 'package:sinwar_shoping/design/app_radius.dart';
import 'package:sinwar_shoping/design/app_spacing.dart';
import 'package:sinwar_shoping/design/app_text_styles.dart';
import 'package:sinwar_shoping/l10n/app_localizations.dart';
import 'package:sinwar_shoping/models/product/product_model.dart';
import 'add_to_cart_bottom_sheet/widgets/quantity_stepper.dart';

/// Enhanced variant card widget with integrated stock display
///
/// **Changes:**
/// - Border width reduced to 25% (borderThick * 0.25 = 3.0px)
/// - "Available Qty" badge integrated inside the card (top-right)
/// - Maintains selection state and quantity controls
class ProductVariantCardWithStock extends StatelessWidget {
  const ProductVariantCardWithStock({
    super.key,
    required this.variant,
    required this.selected,
    required this.quantity,
    required this.onTap,
    this.onQuantityChanged,
    this.showQuantityStepper = false,
    this.showSelectionIndicator = true,
  });

  final ProductVariant variant;
  final bool selected;
  final int quantity;
  final VoidCallback onTap;
  final ValueChanged<int>? onQuantityChanged;
  final bool showQuantityStepper;
  final bool showSelectionIndicator;

  static const double _borderWidth = AppSpacing.borderThick / AppSpacing.xs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final canDecrement = quantity > 1 && onQuantityChanged != null;
    final canIncrement =
        variant.stock > 0 &&
        quantity < variant.stock &&
        onQuantityChanged != null;
    final stockStatus = variant.stock <= 0
        ? l10n.stockOut
        : variant.stock <= 5
        ? l10n.stockOnlyLeft(variant.stock)
        : l10n.cartAvailableStock(variant.stock);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        padding: AppSpacing.insetsMd,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: selected ? AppColors.primary : theme.dividerColor,
            width: selected
                ? _borderWidth
                : (_borderWidth - (AppSpacing.xs / AppSpacing.borderThin)).clamp(0.0, double.infinity),
          ),
        ),
        child: Stack(
          children: [
            // Main content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildVariantSummary(context)),
                    if (showQuantityStepper) ...[
                      const SizedBox(width: AppSpacing.md),
                      QuantityStepper(
                        value: quantity,
                        onDecrement: canDecrement
                            ? () {
                                onQuantityChanged?.call(quantity - 1);
                              }
                            : null,
                        onIncrement: canIncrement
                            ? () {
                                onQuantityChanged?.call(quantity + 1);
                              }
                            : null,
                      ),
                    ],
                  ],
                ),
              ],
            ),
            // Stock badge (top-right corner)
            Positioned(top: 0, right: 0, child: _buildStockBadge(stockStatus)),
          ],
        ),
      ),
    );
  }

  Widget _buildVariantSummary(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Color circle (if meaningful)
        if (_isMeaningfulValue(variant.color))
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              children: [
                Text(
                  AppLocalizations.of(context).productColor,
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(child: _buildColorCircle(variant.color)),
              ],
            ),
          ),
        // Brand
        if (_isMeaningfulValue(variant.brand))
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Text(
              '${AppLocalizations.of(context).productBrand}: ${variant.brand.trim()}',
              style: AppTextStyles.bodySmall,
            ),
          ),
        // Size
        if (_isMeaningfulValue(variant.size))
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Text(
              '${AppLocalizations.of(context).productSize}: ${variant.size.trim()}',
              style: AppTextStyles.bodySmall,
            ),
          ),
        // Price
        if (variant.price > 0) _buildPriceRow(context),
      ],
    );
  }

  Widget _buildPriceRow(BuildContext context) {
    final hasDiscount = variant.discount > 0 && variant.discount < 100;
    final discountedPrice = hasDiscount
        ? variant.price * (1 - (variant.discount / 100))
        : variant.price;
    final currency = NumberFormat.simpleCurrency(
      locale: Localizations.localeOf(context).toLanguageTag(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasDiscount)
          Text(
            currency.format(discountedPrice),
            style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
          ),
        Text(
          currency.format(variant.price),
          style: AppTextStyles.bodySmall.copyWith(
            decoration: hasDiscount ? TextDecoration.lineThrough : null,
          ),
        ),
      ],
    );
  }

  Widget _buildStockBadge(String stockStatus) {
    final isOutOfStock = variant.stock <= 0;
    final isLowStock = variant.stock > 0 && variant.stock <= 5;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isOutOfStock
            ? AppColors.error
            : isLowStock
            ? AppColors.warning
            : AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        stockStatus,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildColorCircle(String colorValue) {
    final color = _parseColor(colorValue);
    return SizedBox(
      width: AppSpacing.iconMd,
      height: AppSpacing.iconMd,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(
            color: AppColors.border,
            width: AppSpacing.xs / AppSpacing.borderThin,
          ),
        ),
      ),
    );
  }

  Color _parseColor(String value) {
    final hex = value.replaceAll('#', '').trim();
    if (hex.length == 6) {
      try {
        return Color(int.parse('FF$hex', radix: 16));
      } catch (_) {
        return AppColors.border;
      }
    }
    return AppColors.border;
  }

  bool _isMeaningfulValue(String? value) {
    final normalized = (value ?? '').trim().toLowerCase();
    return normalized.isNotEmpty &&
        normalized != '0' &&
        normalized != 'null' &&
        normalized != 'n/a' &&
        normalized != 'default' &&
        normalized != 'unknown';
  }
}
