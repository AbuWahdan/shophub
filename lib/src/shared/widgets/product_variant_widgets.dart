import 'package:flutter/material.dart';

import '../../design/app_text_styles.dart';
import '../../model/product_api.dart';
import '../../themes/theme.dart';
import 'color_picker/color_utils.dart';
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

double discountedVariantPrice(ApiProductVariant variant) {
  if (variant.discount <= 0 || variant.discount >= 100) {
    return variant.itemPrice;
  }
  return variant.itemPrice * (1 - (variant.discount / 100));
}

class ProductColorCircle extends StatelessWidget {
  const ProductColorCircle({
    super.key,
    required this.colorValue,
    this.size = 18,
    this.label,
  });

  final String colorValue;
  final double size;
  final String? label;

  @override
  Widget build(BuildContext context) {
    if (!isMeaningfulProductValue(colorValue)) {
      return const SizedBox.shrink();
    }

    final resolvedColor = parseApiColor(colorValue) ?? Colors.grey;
    final normalizedLabel = (label ?? colorValue).trim();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: resolvedColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: AppSpacing.borderThin,
            ),
          ),
        ),
        if (normalizedLabel.isNotEmpty) ...[
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              normalizedLabel,
              style: AppTextStyles.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
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

  final ApiProductVariant variant;
  final bool showColor;
  final CrossAxisAlignment priceAlignment;

  @override
  Widget build(BuildContext context) {
    final hasColor = showColor && isMeaningfulProductValue(variant.color);
    final hasBrand = isMeaningfulProductValue(variant.brand);
    final hasSize = isMeaningfulProductValue(variant.itemSize);
    final hasPrice = variant.itemPrice > 0;
    final hasDiscount = variant.discount > 0 && variant.discount < 100;
    final discountedPrice = discountedVariantPrice(variant);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasColor)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              children: [
                Text('Color', style: AppTextStyles.bodySmall),
                const SizedBox(width: AppSpacing.xs),
                Expanded(child: ProductColorCircle(colorValue: variant.color)),
              ],
            ),
          ),
        if (hasBrand)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Text(
              'Brand: ${variant.brand.trim()}',
              style: AppTextStyles.bodySmall,
            ),
          ),
        if (hasSize)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Text(
              'Size: ${variant.itemSize.trim()}',
              style: AppTextStyles.bodySmall,
            ),
          ),
        if (hasPrice)
          Column(
            crossAxisAlignment: priceAlignment,
            children: [
              Text(
                '\$${(hasDiscount ? discountedPrice : variant.itemPrice).toStringAsFixed(2)}',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
              if (hasDiscount)
                Text(
                  '\$${variant.itemPrice.toStringAsFixed(2)}',
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
    required this.isSelected,
    required this.quantity,
    required this.onTap,
    this.onQuantityChanged,
    this.showQuantityStepper = false,
    this.showSelectionIndicator = true,
  });

  final ApiProductVariant variant;
  final bool isSelected;
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
        variant.itemQty > 0 &&
        quantity < variant.itemQty &&
        onQuantityChanged != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: AppSpacing.insetsMd,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.primary : theme.dividerColor,
            width: isSelected ? AppSpacing.borderThick : AppSpacing.borderThin,
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
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isSelected ? AppColors.primary : theme.dividerColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
