import 'package:flutter/material.dart';

import '../config/app_constants.dart';
import '../config/route.dart';
import '../config/ui_text.dart';
import '../design/app_colors.dart';
import '../design/app_spacing.dart';
import '../design/app_text_styles.dart';
import '../model/cart_item.dart';
import '../l10n/l10n.dart';
import '../model/data.dart';
import '../model/product_api.dart';
import '../shared/dialogs/app_dialogs.dart';
import '../shared/widgets/app_button.dart';
import '../shared/widgets/empty_state.dart';
import '../shared/widgets/app_image.dart';
import '../shared/widgets/app_snackbar.dart';
import '../shared/widgets/quantity_stepper.dart';
import '../themes/theme.dart';

class ShoppingCartPage extends StatefulWidget {
  const ShoppingCartPage({super.key});

  @override
  _ShoppingCartPageState createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  late List<CartItem> cartItems;

  @override
  void initState() {
    super.initState();
    _initializeCart();
  }

  void _initializeCart() {
    cartItems = AppData.cartItems;
  }

  void _removeItem(int index) {
    if (!mounted) return;
    setState(() {
      AppData.removeFromCartAt(index);
    });
  }

  void _updateQuantity(int index, int quantity) {
    if (!mounted) return;
    if (quantity < 1) return; // Prevent invalid quantities
    setState(() {
      cartItems[index].quantity = quantity;
    });
  }

  void _openProductDetails(CartItem cartItem) {
    final product = cartItem.product;
    Navigator.pushNamed(
      context,
      AppRoutes.productDetails,
      arguments: {
        'product': product,
        'selectedSize': cartItem.selectedSize,
        'selectedColor': cartItem.selectedColor,
      },
    );
  }

  double get totalPrice {
    return cartItems.fold(0, (sum, item) => sum + item.total);
  }

  double get originalPrice {
    return cartItems.fold(
      0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );
  }

  double get totalDiscount {
    return originalPrice - totalPrice;
  }

  void _showRemoveConfirmation(int index) {
    final l10n = context.l10n;
    AppDialogs.showConfirmation(
      context: context,
      title: l10n.cartRemoveItemTitle,
      message: l10n.cartRemoveItemMessage,
      confirmLabel: l10n.commonRemove,
      cancelLabel: l10n.commonCancel,
      onConfirm: () {
        _removeItem(index);
        AppSnackBar.show(
          context,
          message: l10n.cartItemRemoved,
          type: AppSnackBarType.info,
        );
      },
    );
  }

  Future<void> _refreshCart() async {
    if (!mounted) return;
    setState(() {
      cartItems = AppData.cartItems;
    });
  }

  Widget _buildCartItemCard(int index, CartItem item) {
    ApiProduct product = item.product;
    int quantity = item.quantity;
    double itemTotal = product.finalPrice * quantity;
    bool hasDiscount = product.discountPrice != null;
    final selectedSize = item.selectedSize;
    final selectedColor = item.selectedColor;
    final availableStock = product.stockFor(selectedSize, selectedColor);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        onTap: () => _openProductDetails(item),
        child: Padding(
          padding: AppSpacing.insetsMd,
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  Container(
                    width: AppSpacing.imageMd,
                    height: AppSpacing.imageMd,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    child: AppImage(path: product.images[0], fit: BoxFit.cover),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // Product Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.titleMedium(context),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        // Price Display
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.xs,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              '\$${product.finalPrice.toStringAsFixed(2)}',
                              style: AppTextStyles.labelLarge(
                                context,
                              ).copyWith(color: AppColors.primary),
                            ),
                            if (hasDiscount)
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: AppTextStyles.bodySmall(context)
                                    .copyWith(
                                      decoration: TextDecoration.lineThrough,
                                    ),
                              ),
                          ],
                        ),
                        Padding(
                          padding: AppSpacing.only(top: AppSpacing.xs),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                UiText.cartVariantLabel
                                    .replaceFirst('{size}', selectedSize)
                                    .replaceFirst('{color}', selectedColor),
                                style: AppTextStyles.bodySmall(context),
                              ),
                              Text(
                                context.l10n.cartAvailableStock(availableStock),
                                style: AppTextStyles.bodySmall(
                                  context,
                                ).copyWith(color: AppColors.accentOrange),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Delete Button
                  IconButton(
                    icon: const Icon(Icons.close, size: AppSpacing.iconMd),
                    onPressed: () => _showRemoveConfirmation(index),
                    color: Theme.of(context).colorScheme.onSurface,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const Divider(height: AppSpacing.lg),
              // Quantity Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.cartQuantity,
                    style: AppTextStyles.bodyMedium(context),
                  ),
                  QuantityStepper(
                    value: quantity,
                    onDecrement: quantity > 1
                        ? () => _updateQuantity(index, quantity - 1)
                        : null,
                    onIncrement: quantity < AppConstants.checkoutMaxQuantity
                        ? () => _updateQuantity(index, quantity + 1)
                        : null,
                  ),
                ],
              ),
              const Divider(height: AppSpacing.lg),
              // Item Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.cartItemTotal,
                    style: AppTextStyles.bodySmall(context),
                  ),
                  Text(
                    '\$${itemTotal.toStringAsFixed(2)}',
                    style: AppTextStyles.labelLarge(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return EmptyState(
      icon: Icons.shopping_cart_outlined,
      title: context.l10n.cartEmptyTitle,
      message: context.l10n.cartEmptyMessage,
      action: AppButton(
        label: context.l10n.cartStartShopping,
        onPressed: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        leading: const Icon(Icons.shopping_bag),
        fullWidth: false,
      ),
    );
  }

  Widget _cartItems() {
    if (cartItems.isEmpty) {
      return SizedBox.expand(child: _buildEmptyCart());
    }

    return Column(
      children: cartItems.asMap().entries.map((entry) {
        return _buildCartItemCard(entry.key, entry.value);
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scrollBody = cartItems.isEmpty
        ? LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: _buildEmptyCart(),
              ),
            ),
          )
        : ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: AppTheme.padding,
            children: [
              _cartItems(),
              const SizedBox(height: AppSpacing.hero),
            ],
          );

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.cartTitle),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(onRefresh: _refreshCart, child: scrollBody),
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : SafeArea(
              child: Container(
                padding: AppTheme.padding,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: AppSpacing.borderThin,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPriceSummaryRow(
                      context.l10n.cartSubtotal,
                      '\$${originalPrice.toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (totalDiscount > 0)
                      _buildPriceSummaryRow(
                        context.l10n.cartDiscount,
                        '-\$${totalDiscount.toStringAsFixed(2)}',
                        isDiscount: true,
                      ),
                    if (totalDiscount > 0)
                      const SizedBox(height: AppSpacing.sm),
                    _buildPriceSummaryRow(
                      context.l10n.cartShipping,
                      context.l10n.cartShippingFree,
                      isHighlight: true,
                    ),
                    const Divider(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.l10n.cartTotal,
                          style: AppTextStyles.titleMedium(context),
                        ),
                        Text(
                          '\$${totalPrice.toStringAsFixed(2)}',
                          style: AppTextStyles.titleLarge(
                            context,
                          ).copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      label: context.l10n.cartCheckout,
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.checkout);
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPriceSummaryRow(
    String label,
    String value, {
    bool isDiscount = false,
    bool isHighlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isHighlight
              ? AppTextStyles.labelLarge(
                  context,
                ).copyWith(color: AppColors.primary)
              : AppTextStyles.bodySmall(context),
        ),
        Text(
          value,
          style: isDiscount
              ? AppTextStyles.labelLarge(
                  context,
                ).copyWith(color: AppColors.primary)
              : AppTextStyles.bodySmall(context),
        ),
      ],
    );
  }
}
