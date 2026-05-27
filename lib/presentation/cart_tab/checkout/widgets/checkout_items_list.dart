import 'package:flutter/material.dart';

import '../../../../design/app_spacing.dart';
import '../../../../models/cart_item_model.dart';
import 'checkout_item_card.dart';

class CheckoutItemsList extends StatelessWidget {
  const CheckoutItemsList({super.key, required this.items});

  final List<CartItemModel> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: CheckoutItemCard(item: item),
            ),
          )
          .toList(),
    );
  }
}
