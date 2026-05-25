import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/cart_controller.dart';
import '../../../design/app_colors.dart';
import '../../../design/app_spacing.dart';
import '../../../design/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/cart_item_model.dart';
import 'widgets/order_summary_section.dart';
import 'widgets/empty_cart_view.dart';
import 'widgets/cart_item_card.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({
    Key? key,
    required this.cartController,
    required this.onTapItem,
    required this.onRemoveItem,
    required this.onIncrement,
    required this.onDecrement,
    required this.onCheckout,
    required this.onRefresh,
  }) : super(key: key);

  final CartController cartController;
  final void Function(CartItemModel) onTapItem;
  final void Function(CartItemModel?) onRemoveItem;
  final Future<void> Function(CartItemModel) onIncrement;
  final Future<void> Function(CartItemModel) onDecrement;
  final VoidCallback onCheckout;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surfaceContainerLowest,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          l10n.shoppingCartTitle,
          style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: onRefresh,
        child: Obx(() {
          if (cartController.isLoading.value && cartController.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (cartController.items.isEmpty) {
            return EmptyCartView(
              title: l10n.emptyCartTitle,
              subtitle: l10n.emptyCartSubtitle,
              actionLabel: l10n.continueShoppingButton,
              onAction: () => onRemoveItem.call(null),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.xl + 160,
            ),
            itemCount: cartController.items.length,
            itemBuilder: (context, index) {
              final item = cartController.items[index];
              return CartItemCard(
                key: ValueKey(item.detailId),
                item: item,
                isBusy: cartController.isItemBusy(item.detailId),
                canIncrement: cartController.canIncrement(item),
                canDecrement: cartController.canDecrement(item),
                onTap: () => onTapItem(item),
                onRemove: () => onRemoveItem(item),
                onIncrement: () => onIncrement(item),
                onDecrement: () => onDecrement(item),
              );
            },
          );
        }),
      ),
      bottomNavigationBar: Obx(() {
        final _ = cartController.items.length;
        return OrderSummarySection(
          cartController: cartController,
          onCheckout: onCheckout,
        );
      }),
    );
  }
}
