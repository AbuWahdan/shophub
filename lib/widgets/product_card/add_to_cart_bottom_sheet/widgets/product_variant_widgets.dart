import 'package:flutter/material.dart';

import '../../../../../design/app_colors.dart';
import '../../../../design/app_radius.dart';
import '../../../../design/app_spacing.dart';
import '../../../../design/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/product/product_model.dart';
import 'quantity_stepper.dart';

bool isMeaningfulValue(String? value) {
  final normalized = (value ?? '').trim().toLowerCase();
  return normalized.isNotEmpty &&
      normalized != '0' &&
      normalized != 'null' &&
      normalized != 'n/a' &&
      normalized != 'default' &&
      normalized != 'unknown';
}

double effectiveVariantPrice(ProductVariant variant) {
  if (variant.discount <= 0 || variant.discount >= 100) return variant.price;
  return variant.price * (1 - variant.discount / 100);
}

/// A circular colour swatch parsed from a CSS hex string, with an
/// optional text label beside it.
class ProductColorSwatch extends StatelessWidget {
  const ProductColorSwatch({
    super.key,
    required this.hexColor,
    this.showLabel = false,
    this.size = AppSpacing.iconMd,
  });

  final String hexColor;
  final bool showLabel;
  final double size;

  Color _parse(String value) {
    final hex = value.replaceAll('#', '').trim();
    if (hex.length == 6) {
      final v = int.tryParse('FF$hex', radix: 16);
      return v == null ? AppColors.neutral300 : Color(v);
    }
    if (hex.length == 8) {
      final v = int.tryParse(hex, radix: 16);
      return v == null ? AppColors.neutral300 : Color(v);
    }
    return AppColors.border;
  }

  @override
  Widget build(BuildContext context) {
    final color = _parse(hexColor);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(
              color: AppColors.border,
              width: AppSpacing.borderThin,
            ),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: AppSpacing.xs),
          Text(hexColor, style: AppTextStyles.bodySmall),
        ],
      ],
    );
  }
}

/// Compact summary column: colour swatch, brand, size, final price
/// with crossed-out original when discounted.
class ProductVariantSummary extends StatelessWidget {
  const ProductVariantSummary({
    super.key,
    required this.variant,
    this.showColor = true,
    this.priceAlignment = CrossAxisAlignment.start,
  });

  final ProductVariant variant;
  final bool showColor;
  final CrossAxisAlignment priceAlignment;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final hasColor    = showColor && isMeaningfulValue(variant.color);
    final hasBrand    = isMeaningfulValue(variant.brand);
    final hasSize     = isMeaningfulValue(variant.size);
    final hasPrice    = variant.price > 0;
    final hasDiscount = variant.discount > 0 && variant.discount < 100;
    final finalPrice  = effectiveVariantPrice(variant);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasColor)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              children: [
                Text(
                  l10n.productColor,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                ProductColorSwatch(hexColor: variant.color),
              ],
            ),
          ),
        if (hasBrand)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
            child: Text(
              '${l10n.productBrand}: ${variant.brand.trim()}',
              style: AppTextStyles.bodySmall,
            ),
          ),
        if (hasSize)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
            child: Text(
              '${l10n.productSize}: ${variant.size.trim()}',
              style: AppTextStyles.bodySmall,
            ),
          ),
        if (hasPrice) ...[
          const SizedBox(height: AppSpacing.xxs),
          Column(
            crossAxisAlignment: priceAlignment,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                finalPrice.toStringAsFixed(2),
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.priceGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (hasDiscount)
                Text(
                  variant.price.toStringAsFixed(2),
                  style: AppTextStyles.bodySmall.copyWith(
                    decoration: TextDecoration.lineThrough,
                    decorationColor:
                    theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Full variant row card used inside the add-to-cart bottom sheet.
///
/// Features:
///  - Animated selection border using [AnimatedContainer].
///  - Stock availability chip (low-stock warning + out-of-stock).
///  - Discount % badge when applicable.
///  - Optional quantity stepper.
///  - Optional radio-style selection indicator.
class ProductVariantOptionCard extends StatelessWidget {
  const ProductVariantOptionCard({
    super.key,
    required this.variant,
    required this.isSelected,
    required this.quantity,
    required this.onTap,
    this.onQuantityChanged,
    this.showQuantityStepper = false,
    this.showSelectionIndicator = true,
  });

  final ProductVariant variant;
  final bool isSelected;
  final int quantity;
  final VoidCallback onTap;
  final ValueChanged<int>? onQuantityChanged;
  final bool showQuantityStepper;
  final bool showSelectionIndicator;

  static const int _lowStockThreshold = 5;

  @override
  Widget build(BuildContext context) {
    final theme       = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n        = AppLocalizations.of(context);

    final isOutOfStock = variant.stock <= 0;
    final isLowStock   = !isOutOfStock && variant.stock <= _lowStockThreshold;
    final hasDiscount  = variant.discount > 0 && variant.discount < 100;

    final canDecrement = !isOutOfStock && quantity > 1 && onQuantityChanged != null;
    final canIncrement = !isOutOfStock &&
        quantity < variant.stock &&
        onQuantityChanged != null;

    return Semantics(
      selected: isSelected,
      enabled: !isOutOfStock,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.06)
              : colorScheme.surface,
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : colorScheme.outlineVariant,
            width: isSelected
                ? AppSpacing.borderThick
                : AppSpacing.borderThin,
          ),
        ),
        child: InkWell(
          onTap: isOutOfStock ? null : onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          splashColor: AppColors.primary.withValues(alpha: 0.08),
          child: Padding(
            padding: AppSpacing.insetsMd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ProductVariantSummary(variant: variant),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasDiscount)
                          _DiscountBadge(
                            percentage: variant.discount.toInt(),
                            l10n: l10n,
                          ),
                        if (showSelectionIndicator && !showQuantityStepper) ...[
                          const SizedBox(height: AppSpacing.xs),
                          _SelectionIndicator(isSelected: isSelected),
                        ],
                      ],
                    ),
                  ],
                ),
                if (isOutOfStock || isLowStock) ...[
                  const SizedBox(height: AppSpacing.xs),
                  _StockChip(
                    isOutOfStock: isOutOfStock,
                    stock: variant.stock,
                    l10n: l10n,
                  ),
                ],
                if (showQuantityStepper && !isOutOfStock) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: QuantityStepper(
                      value: quantity,
                      onDecrement: canDecrement
                          ? () {
                        onTap();
                        onQuantityChanged?.call(quantity - 1);
                      }
                          : null,
                      onIncrement: canIncrement
                          ? () {
                        onTap();
                        onQuantityChanged?.call(quantity + 1);
                      }
                          : null,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.percentage, required this.l10n});

  final int percentage;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.saleBadge,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        l10n.productDiscountPercent(percentage),
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StockChip extends StatelessWidget {
  const _StockChip({
    required this.isOutOfStock,
    required this.stock,
    required this.l10n,
  });

  final bool isOutOfStock;
  final int stock;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = isOutOfStock
        ? (
    l10n.stockOutOfStock,
    AppColors.errorSurface,
    AppColors.error,
    )
        : (
    l10n.stockLowCount(stock),
    AppColors.warningSurface,
    AppColors.warning,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: Icon(
        isSelected
            ? Icons.check_circle_rounded
            : Icons.radio_button_unchecked_rounded,
        key: ValueKey<bool>(isSelected),
        color: isSelected
            ? AppColors.primary
            : Theme.of(context).colorScheme.outlineVariant,
        size: AppSpacing.iconMd,
      ),
    );
  }
}