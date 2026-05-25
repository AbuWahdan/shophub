import 'package:flutter/material.dart';
import '../../../../design/app_colors.dart';
import '../../../../design/app_spacing.dart';
import '../../../../design/app_text_styles.dart';
import 'cart_badges_wrap.dart';
import 'quantity_stepper.dart';
import 'stock_indicator.dart';

class CartItemDetails extends StatelessWidget {
  const CartItemDetails({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.variant,
    required this.price,
    required this.quantity,
    required this.canIncrement,
    required this.canDecrement,
    required this.onIncrement,
    required this.onDecrement,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final String variant;
  final String price;
  final int quantity;
  final bool canIncrement;
  final bool canDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.titleSmall,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle.isNotEmpty ? subtitle : variant,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.xs),
        CartBadgesWrap(badges: [variant]),
        const SizedBox(height: AppSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            StockIndicator(countText: quantity > 0 ? 'In stock' : 'Out of stock'),
            const Spacer(),
            Text(price, style: AppTextStyles.titleSmall.copyWith(color: AppColors.priceGreen)),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: Alignment.centerLeft,
          child: QuantityStepper(
            quantity: quantity,
            canIncrement: canIncrement,
            canDecrement: canDecrement,
            onIncrement: onIncrement,
            onDecrement: onDecrement,
          ),
        ),
      ],
    );
  }
}
