import 'package:flutter/material.dart';

import '../../../../design/app_colors.dart';
import '../../../../design/app_radius.dart';
import '../../../../design/app_shadows.dart';
import '../../../../design/app_spacing.dart';
import '../../../../design/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/cart_item_model.dart';
import 'cart_item_image.dart';
import 'remove_item_button.dart';

class CartItemCard extends StatelessWidget {
  const CartItemCard({
    super.key,
    required this.item,
    required this.isBusy,
    required this.canIncrement,
    required this.canDecrement,
    required this.onTap,
    required this.onRemove,
    required this.onIncrement,
    required this.onDecrement,
  });

  final CartItemModel item;
  final bool isBusy;
  final bool canIncrement;
  final bool canDecrement;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final theme       = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Material(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          splashColor: AppColors.primary.withValues(alpha: 0.06),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: AppColors.border,
                width: AppSpacing.borderThin,
              ),
              boxShadow: const [AppShadows.cardShadow],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CardImage(item: item),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _CardBody(
                            item: item,
                            isBusy: isBusy,
                            canIncrement: canIncrement,
                            canDecrement: canDecrement,
                            onIncrement: onIncrement,
                            onDecrement: onDecrement,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: AppSpacing.xs,
                    right: AppSpacing.xs,
                    child: RemoveItemButton(onPressed: onRemove),
                  ),
                  if (isBusy)
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: AppSpacing.iconLg,
                            height: AppSpacing.iconLg,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardImage extends StatelessWidget {
  const _CardImage({required this.item});

  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: CartItemImage(
        imageUrl: item.imageUrl,
      ),
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({
    required this.item,
    required this.isBusy,
    required this.canIncrement,
    required this.canDecrement,
    required this.onIncrement,
    required this.onDecrement,
  });

  final CartItemModel item;
  final bool isBusy;
  final bool canIncrement;
  final bool canDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  bool get _hasDiscount =>
      item.unitPrice > 0 &&
          item.finalUnitPrice < item.unitPrice;

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.xl),
          child: Text(
            item.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.titleSmall,
          ),
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
        ],
        if (hasColor || hasSize) ...[
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xxs,
            children: [
              if (hasColor) _VariantChip(label: item.displayColor),
              if (hasSize) _VariantChip(label: item.displaySize),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: _PriceBlock(
                item: item,
                hasDiscount: _hasDiscount,
                l10n: l10n,
              ),
            ),
            _QuantityRow(
              quantity: item.bookedQty,
              canIncrement: canIncrement,
              canDecrement: canDecrement,
              onIncrement: onIncrement,
              onDecrement: onDecrement,
            ),
          ],
        ),
        if (item.stockCount > 0 && item.stockCount <= 20) ...[
          const SizedBox(height: AppSpacing.xs),
          _LowStockLabel(stock: item.stockCount, l10n: l10n),
        ],
      ],
    );
  }
}

class _PriceBlock extends StatelessWidget {
  const _PriceBlock({
    required this.item,
    required this.hasDiscount,
    required this.l10n,
  });

  final CartItemModel item;
  final bool hasDiscount;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${l10n.jod} ${item.lineTotal.toStringAsFixed(3)}',
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.priceGreen,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (hasDiscount)
          Text(
            '${l10n.jod} ${item.originalLineTotal.toStringAsFixed(3)}',
            style: AppTextStyles.caption.copyWith(
              decoration: TextDecoration.lineThrough,
              decorationColor:
              theme.colorScheme.onSurface.withValues(alpha: 0.4),
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
      ],
    );
  }
}

class _VariantChip extends StatelessWidget {
  const _VariantChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
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

class _LowStockLabel extends StatelessWidget {
  const _LowStockLabel({required this.stock, required this.l10n});

  final int stock;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.info_outline_rounded,
          size: AppSpacing.iconSm,
          color: AppColors.warning,
        ),
        const SizedBox(width: AppSpacing.xxs),
        Text(
          l10n.stockLowCount(stock),
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.warning,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _QuantityRow extends StatelessWidget {
  const _QuantityRow({
    required this.quantity,
    required this.canIncrement,
    required this.canDecrement,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int quantity;
  final bool canIncrement;
  final bool canDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeColor = AppColors.primary;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: AppSpacing.borderThin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepBtn(
            icon: Icons.remove_rounded,
            enabled: canDecrement,
            activeColor: activeColor,
            onTap: onDecrement,
          ),
          SizedBox(
            width: AppSpacing.buttonSm,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Text(
                  '$quantity',
                  key: ValueKey<int>(quantity),
                  style: AppTextStyles.titleMedium,
                ),
              ),
            ),
          ),
          _StepBtn(
            icon: Icons.add_rounded,
            enabled: canIncrement,
            activeColor: activeColor,
            onTap: onIncrement,
          ),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({
    required this.icon,
    required this.enabled,
    required this.activeColor,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(AppRadius.md),
      splashColor: activeColor.withValues(alpha: 0.12),
      highlightColor: activeColor.withValues(alpha: 0.08),
      child: SizedBox(
        width: AppSpacing.buttonSm,
        height: AppSpacing.buttonSm,
        child: Icon(
          icon,
          size: AppSpacing.iconMd,
          color: enabled
              ? activeColor
              : activeColor.withValues(alpha: 0.38),
        ),
      ),
    );
  }
}