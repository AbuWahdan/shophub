import 'package:flutter/material.dart';
import '../../../../../design/app_colors.dart';
import '../../../../design/app_radius.dart';
import '../../../../design/app_spacing.dart';
import '../../../../design/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/product/product_model.dart';
import 'quantity_stepper.dart';

bool isMeaningfulProductValue(String? value) {
  final normalized = (value ?? '').trim().toLowerCase();
  return normalized.isNotEmpty &&
      normalized != '0' &&
      normalized != 'null' &&
      normalized != 'n/a' &&
      normalized != 'default' &&
      normalized != 'unknown';
}

double discountedVariantPrice(ProductVariant variant) {
  if (variant.discount <= 0 || variant.discount >= 100) {
    return variant.price;
  }
  return variant.price * (1 - (variant.discount / 100));
}

class ProductColorCircle extends StatelessWidget {
  const ProductColorCircle({
    super.key,
    required this.colorValue,
    this.showLabel = false,
    this.size = AppSpacing.iconMd,
  });

  final String colorValue;
  final bool showLabel;
  final double size;

  Color _parseColor(String value) {
    final hex = value.replaceAll('#', '').trim();
    if (hex.length == 6) {
      final parsed = int.tryParse('FF$hex', radix: 16);
      return parsed == null ? AppColors.neutral300 : Color(parsed);
    }
    if (hex.length == 8) {
      final parsed = int.tryParse(hex, radix: 16);
      return parsed == null ? AppColors.neutral300 : Color(parsed);
    }
    return AppColors.border;
  }

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(colorValue);
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
              width: AppSpacing.xs / AppSpacing.borderThin,
            ),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: AppSpacing.xs),
          Text(colorValue, style: AppTextStyles.bodySmall),
        ],
      ],
    );
  }
}

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
    final hasColor = showColor && isMeaningfulProductValue(variant.color);
    final hasBrand = isMeaningfulProductValue(variant.brand);
    final hasSize = isMeaningfulProductValue(variant.size);
    final hasPrice = variant.price > 0;
    final hasDiscount = variant.discount > 0 && variant.discount < 100;
    final discountedPrice = discountedVariantPrice(variant);
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasColor)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              children: [
                Text(l10n.productColor, style: AppTextStyles.bodySmall),
                const SizedBox(width: AppSpacing.xs),
                Expanded(child: ProductColorCircle(colorValue: variant.color)),
              ],
            ),
          ),
        if (hasBrand)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Text(
              '${l10n.productBrand}: ${variant.brand.trim()}',
              style: AppTextStyles.bodySmall,
            ),
          ),
        if (hasSize)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Text(
              '${l10n.productSize}: ${variant.size.trim()}',
              style: AppTextStyles.bodySmall,
            ),
          ),
        if (hasPrice)
          Column(
            crossAxisAlignment: priceAlignment,
            children: [
              Text(
                (hasDiscount ? discountedPrice : variant.price).toStringAsFixed(
                  2,
                ),
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
              if (hasDiscount)
                Text(
                  variant.price.toStringAsFixed(2),
                  style: AppTextStyles.bodySmall.copyWith(
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class ProductVariantOptionCard extends StatelessWidget {
  const ProductVariantOptionCard({
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canDecrement = quantity > 1 && onQuantityChanged != null;
    final canIncrement =
        variant.stock > 0 &&
        quantity < variant.stock &&
        onQuantityChanged != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        padding: AppSpacing.insetsMd,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: selected ? AppColors.primary : theme.dividerColor,
            width: selected ? AppSpacing.borderThick : AppSpacing.borderThin,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: ProductVariantSummary(variant: variant)),
            if (showQuantityStepper) ...[
              const SizedBox(width: AppSpacing.md),
              QuantityStepper(
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
            ] else if (showSelectionIndicator)
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.md),
                child: Icon(
                  selected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: selected ? AppColors.primary : theme.dividerColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
