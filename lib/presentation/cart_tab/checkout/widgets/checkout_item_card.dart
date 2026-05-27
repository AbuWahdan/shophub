import 'package:flutter/material.dart';

import '../../../../design/app_colors.dart';
import '../../../../design/app_radius.dart';
import '../../../../design/app_shadows.dart';
import '../../../../design/app_spacing.dart';
import '../../../../design/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/cart_item_model.dart';
import '../../../../widgets/custom_image.dart';
import 'checkout_tokens.dart';

/// Read-only order line card used in the checkout summary screen.
///
/// Shows:
///   - Product image
///   - Name, brand/description, variant chips (color · size · qty)
///   - Final line total in green
///   - Crossed-out original line total when a discount applies
class CheckoutItemCard extends StatelessWidget {
  const CheckoutItemCard({super.key, required this.item});

  final CartItemModel item;

  bool get _hasDiscount =>
      item.unitPrice > 0 && item.finalUnitPrice < item.unitPrice;

  @override
  Widget build(BuildContext context) {
    final theme       = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n        = AppLocalizations.of(context);

    final hasColor = item.displayColor.trim().isNotEmpty &&
        item.displayColor.trim().toLowerCase() != 'default';
    final hasSize = item.displaySize.trim().isNotEmpty &&
        item.displaySize.trim().toLowerCase() != 'default';
    final hasBrand = item.brand.trim().isNotEmpty;

    final variantParts = [
      l10n.checkoutQuantity(item.bookedQty),
      if (hasColor) item.displayColor,
      if (hasSize) item.displaySize,
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.border,
          width: AppSpacing.borderThin,
        ),
        boxShadow: const [AppShadows.subtleShadow],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: CustomImage(
                path: item.imageUrl,
                width: CheckoutTokens.imageSize,
                height: CheckoutTokens.imageSize,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleSmall,
                  ),
                  if (hasBrand) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      item.brand.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ] else if (item.description.trim().isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      item.description.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                  if (variantParts.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.xxs,
                      children: variantParts
                          .map((part) => _VariantPill(label: part))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${l10n.jod} ${item.lineTotal.toStringAsFixed(3)}',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.priceGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (_hasDiscount) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    '${l10n.jod} ${item.originalLineTotal.toStringAsFixed(3)}',
                    style: AppTextStyles.caption.copyWith(
                      decoration: TextDecoration.lineThrough,
                      decorationColor:
                      colorScheme.onSurface.withValues(alpha: 0.38),
                      color: colorScheme.onSurface.withValues(alpha: 0.38),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VariantPill extends StatelessWidget {
  const _VariantPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xxs),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: AppSpacing.borderThin,
        ),
      ),
      child: Text(label, style: AppTextStyles.labelSmall),
    );
  }
}