import 'package:flutter/material.dart';
import '../../../../design/app_spacing.dart';
import '../../../../models/cart_item_model.dart';
import 'cart_item_image.dart';
import 'cart_item_details.dart';
import 'remove_item_button.dart';

class CartItemCard extends StatelessWidget {
  const CartItemCard({
    Key? key,
    required this.item,
    required this.isBusy,
    required this.canIncrement,
    required this.canDecrement,
    required this.onTap,
    required this.onRemove,
    required this.onIncrement,
    required this.onDecrement,
  }) : super(key: key);

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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        elevation: 0,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CartItemImage(imageUrl: item.imageUrl),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: CartItemDetails(
                        title: item.name,
                        subtitle: item.description,
                        variant: item.displaySize,
                        price: '\$${item.lineTotal.toStringAsFixed(2)}',
                        quantity: item.bookedQty,
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
                top: AppSpacing.sm,
                right: AppSpacing.sm,
                child: RemoveItemButton(onPressed: onRemove),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
