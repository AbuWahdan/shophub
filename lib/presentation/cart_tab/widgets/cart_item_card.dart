import 'package:flutter/material.dart';

import '../../../design/app_colors.dart';
import '../../../design/app_radius.dart';
import '../../../design/app_spacing.dart';
import '../../../design/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/cart_item_model.dart';
import '../../../widgets/product_card/add_to_cart_bottom_sheet/widgets/quantity_stepper.dart';
import 'cart_item_widgets.dart';

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
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        child: InkWell(
          onTap: isBusy ? null : onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.5),
              ),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CartItemTopSection(
                  item: item,
                  isBusy: isBusy,
                  onRemove: onRemove,
                ),
                const SizedBox(height: AppSpacing.sm),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: theme.dividerColor.withValues(alpha: 0.4),
                ),
                const SizedBox(height: AppSpacing.sm),
                _CartItemBottomSection(
                  item: item,
                  isBusy: isBusy,
                  canIncrement: canIncrement,
                  onIncrement: onIncrement,
                  onDecrement: onDecrement,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CartItemTopSection extends StatelessWidget {
  const _CartItemTopSection({
    required this.item,
    required this.isBusy,
    required this.onRemove,
  });

  final CartItemModel item;
  final bool isBusy;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CartItemImage(imageUrl: item.imageUrl.trim()),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: _CartItemDetails(item: item)),
        _CartItemRemoveButton(isBusy: isBusy, onRemove: onRemove),
      ],
    );
  }
}

class _CartItemDetails extends StatelessWidget {
  const _CartItemDetails({required this.item});

  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.name,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.xs),
        _CartItemPriceRow(item: item),
        const SizedBox(height: AppSpacing.xs),
        CartItemVariantChips(
          size: item.size,
          color: item.color,
          brand: item.brand,
        ),
        const SizedBox(height: AppSpacing.xs),
        CartItemStockIndicator(
          availableStock: item.remainingStock,
          bookedQuantity: item.bookedQty,
        ),
      ],
    );
  }
}

class _CartItemPriceRow extends StatelessWidget {
  const _CartItemPriceRow({required this.item});

  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.xs,
      children: [
        Text(
          '\$${item.discountedPrice.toStringAsFixed(2)}',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        if (item.hasDiscount) ...[
          Text(
            '\$${item.price.toStringAsFixed(2)}',
            style: AppTextStyles.bodySmall.copyWith(
              decoration: TextDecoration.lineThrough,
              color: AppColors.textSecondary,
            ),
          ),
          _DiscountBadge(discount: item.discount),
        ],
      ],
    );
  }
}

class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.discount});

  final double discount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        '-${discount.toStringAsFixed(0)}%',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.error,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CartItemRemoveButton extends StatelessWidget {
  const _CartItemRemoveButton({
    required this.isBusy,
    required this.onRemove,
  });

  final bool isBusy;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: isBusy ? null : onRemove,
      child: Padding(
        padding: const EdgeInsets.only(left: AppSpacing.xs),
        child: Icon(
          Icons.close_rounded,
          size: 20,
          color: isBusy
              ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
              : theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

class _CartItemBottomSection extends StatelessWidget {
  const _CartItemBottomSection({
    required this.item,
    required this.isBusy,
    required this.canIncrement,
    required this.onIncrement,
    required this.onDecrement,
  });

  final CartItemModel item;
  final bool isBusy;
  final bool canIncrement;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _CartItemQuantityControl(
          item: item,
          isBusy: isBusy,
          canIncrement: canIncrement,
          onIncrement: onIncrement,
          onDecrement: onDecrement,
        ),
        _CartItemLineTotal(item: item),
      ],
    );
  }
}

class _CartItemQuantityControl extends StatelessWidget {
  const _CartItemQuantityControl({
    required this.item,
    required this.isBusy,
    required this.canIncrement,
    required this.onIncrement,
    required this.onDecrement,
  });

  final CartItemModel item;
  final bool isBusy;
  final bool canIncrement;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    if (isBusy) {
      return SizedBox(
        width: AppSpacing.buttonSm * 3,
        height: AppSpacing.buttonSm,
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    return QuantityStepper(
      value: item.bookedQty,
      decrementIcon: item.bookedQty <= 1
          ? Icons.delete_outline
          : Icons.remove,
      onDecrement: onDecrement,
      onIncrement: canIncrement ? onIncrement : null,
    );
  }
}

class _CartItemLineTotal extends StatelessWidget {
  const _CartItemLineTotal({required this.item});

  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          l10n.cartItemTotal,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '\$${item.lineTotal.toStringAsFixed(2)}',
          style: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}