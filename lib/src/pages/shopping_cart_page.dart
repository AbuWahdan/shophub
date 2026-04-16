import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart'; // Add GetX

import '../../controllers/cart_controller.dart';
import '../config/app_constants.dart';
import '../config/route.dart';
import '../config/ui_text.dart';
import '../design/app_text_styles.dart';
import '../model/cart_api.dart';
import '../l10n/l10n.dart';
import '../model/product_api.dart';
import '../pages/checkout_screen.dart';
import '../pages/main_page.dart';
import '../state/auth_state.dart';
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
  State<ShoppingCartPage> createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  // 1. Inject the controller
  final CartController cartController = Get.find<CartController>();

  @override
  void initState() {
    super.initState();
    // Fetch data on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCartFromApi();
    });
  }

  // Helper to fetch username safely
  Future<String> _getUsername() async {
    if (!mounted) return '';
    final authState = context.read<AuthState>();
    await authState.ensureInitialized();
    return authState.user?.username.trim() ?? '';
  }

  Future<void> _loadCartFromApi() async {
    final username = await _getUsername();
    if (username.isNotEmpty) {
      await cartController.loadCart(username: username);
    }
  }

  // Helper matching the controller's logic to check loading states
  // int _itemKey(ApiCartItem item) => item.cartItemId > 0
  //     ? item.cartItemId
  //     : (item.detailId > 0 ? item.detailId : item.itemDetId);

  void _openProductDetails(ApiCartItem cartItem) {
    Navigator.pushNamed(
      context,
      AppRoutes.productDetails,
      arguments: {
        'product': cartItem.product,
        'selectedSize': cartItem.displaySize,
        'selectedColor': cartItem.displayColor,
        'selectedDetId': cartItem.itemDetId,
      },
    );
  }

  // 2. Computed property directly from the reactive list
  double get totalPrice {
    return cartController.items.fold(0, (sum, item) => sum + item.total);
  }

  void _showRemoveConfirmation(ApiCartItem cartItem) {
    final l10n = context.l10n;
    AppDialogs.showConfirmation(
      context: context,
      title: l10n.cartRemoveItemTitle,
      message: l10n.cartRemoveItemMessage,
      confirmLabel: l10n.commonRemove,
      cancelLabel: l10n.commonCancel,
      onConfirm: () async {
        final username = await _getUsername();
        if (username.isEmpty) {
          AppSnackBar.show(context, message: context.l10n.productAccountUnavailable, type: AppSnackBarType.error);
          return;
        }

        // Await the boolean result from the controller
        bool success = await cartController.removeItem(item: cartItem, username: username);

        if (mounted && success) {
          AppSnackBar.show(
            context,
            message: l10n.cartItemRemoved,
            type: AppSnackBarType.info,
          );
        }
      },
    );
  }

  Widget _buildCartItemCard(ApiCartItem item) {
    ApiProduct product = item.product;
    int quantity = item.itemQty;
    double itemTotal = product.finalPrice * quantity;
    bool hasDiscount = product.discountPrice != null;
    final selectedSize = item.displaySize;
    final selectedColor = item.displayColor;

    // 4. Read per-item loading state from Controller
    final isUpdating = cartController.itemLoading[cartController.itemKey(item)] == true;

    final availableStock = item.availableQty > 0
        ? item.availableQty
        : product.quantity;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        onTap: isUpdating ? null : () => _openProductDetails(item),
        child: Padding(
          padding: AppSpacing.insetsMd,
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: AppSpacing.imageMd,
                    height: AppSpacing.imageMd,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    child: AppImage(
                      path: product.images.isNotEmpty ? product.images.first : '',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.xs,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              '\$${product.finalPrice.toStringAsFixed(2)}',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                            if (hasDiscount)
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: AppTextStyles.bodySmall.copyWith(
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
                                style: AppTextStyles.bodySmall,
                              ),
                              Text(
                                context.l10n.cartAvailableStock(availableStock),
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.accentOrange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: AppSpacing.iconMd),
                    onPressed: isUpdating
                        ? null
                        : () => _showRemoveConfirmation(item),
                    color: Theme.of(context).colorScheme.onSurface,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const Divider(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.cartQuantity,
                    style: AppTextStyles.bodyMedium,
                  ),
                  if (isUpdating)
                    const SizedBox(
                      width: 50,
                      height: 40,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else
                    QuantityStepper(
                      value: quantity,
                      decrementIcon: quantity <= 1
                          ? Icons.delete_outline
                          : Icons.remove,
                      // 5. Delegate quantity logic directly to controller
                      onDecrement: () async {
                        final username = await _getUsername();
                        if (username.isNotEmpty) {
                          cartController.decrementItem(item: item, username: username);
                        }
                      },
                      onIncrement: quantity < AppConstants.checkoutMaxQuantity
                          ? () async {
                        final username = await _getUsername();
                        if (username.isNotEmpty) {
                          cartController.incrementItem(item: item, username: username);
                        }
                      }
                          : null,
                    ),
                ],
              ),
              const Divider(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.cartItemTotal,
                    style: AppTextStyles.bodySmall,
                  ),
                  Text(
                    '\$${itemTotal.toStringAsFixed(2)}',
                    style: AppTextStyles.labelLarge,
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
          final switched = MainPage.switchToTab(
            context,
            AppConstants.homeTabIndex,
          );
          if (switched) return;

          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.main,
                (route) => false,
            arguments: {'initialTabIndex': AppConstants.homeTabIndex},
          );
        },
        leading: const Icon(Icons.shopping_bag),
        fullWidth: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 6. Wrap the dynamic parts of the UI in Obx
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.cartTitle),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Obx(() {
        if (cartController.isLoading.value && cartController.items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: AppSpacing.xl),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (cartController.items.isEmpty) {
          return _buildEmptyCart();
        }

        return RefreshIndicator(
          onRefresh: _loadCartFromApi,
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: AppTheme.padding,
                  child: Column(
                    children: [
                      ...cartController.items.map((item) => _buildCartItemCard(item)),
                      const SizedBox(height: AppSpacing.hero),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
      // Bottom Navigation Bar is also wrapped in Obx because total price and visibility change
      bottomNavigationBar: Obx(() {
        if (cartController.items.isEmpty || cartController.isLoading.value) {
          return const SizedBox.shrink();
        }

        return SafeArea(
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
                Row(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\$${totalPrice.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${context.l10n.cartShipping}: ${context.l10n.cartShippingFree}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: SizedBox(
                        height: AppSpacing.buttonMd,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textOnPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CheckoutScreen(
                                  // Pass the items directly from the controller
                                  cartItems: cartController.items.toList(),
                                ),
                              ),
                            );
                          },
                          child: Text(
                            context.l10n.cartCheckout,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(color: AppColors.textOnPrimary),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}