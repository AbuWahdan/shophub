import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:sinwar_shoping/widgets/custom_empty_state/custom_empty_state.dart';

import '../../controllers/cart_controller.dart';
import '../../core/config/route.dart';
import '../../design/app_colors.dart';
import '../../design/app_radius.dart';
import '../../design/app_spacing.dart';
import '../../design/app_text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../models/cart_item_model.dart';
import '../../core/state/auth_state.dart';
import '../../widgets/dialogs/app_dialogs.dart';
import '../../widgets/custom_button/custom_button.dart';
import '../../widgets/product_card/add_to_cart_bottom_sheet/widgets/quantity_stepper.dart';
import '../home_tab/main_page.dart';
import 'checkout/checkout_screen.dart';
import 'widgets/cart_item_widgets.dart';

class ShoppingCartPage extends StatefulWidget {
  const ShoppingCartPage({super.key});

  @override
  State<ShoppingCartPage> createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  final CartController cartController = Get.find<CartController>();

  static const int homeTabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCartFromApi();
    });
  }

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

  void _openProductDetails(CartItemModel cartItem) {
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

  double get totalPrice =>
      cartController.items.fold(0, (sum, item) => sum + item.total);

  void _showRemoveConfirmation(CartItemModel cartItem) {
    final l10n = AppLocalizations.of(context);
    AppDialogs.showConfirmation(
      context: context,
      title: l10n.cartRemoveItemTitle,
      message: l10n.cartRemoveItemMessage,
      confirmLabel: l10n.commonRemove,
      cancelLabel: l10n.commonCancel,
      onConfirm: () async {
        final username = await _getUsername();
        if (username.isEmpty) {
          Get.snackbar(
            'Error',
            'Please log in to manage your cart.',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
        final success = await cartController.removeItem(
          item: cartItem,
          username: username,
        );
        if (!mounted || !success) return;
      },
    );
  }

  // ── Cart item card ─────────────────────────────────────────────────────────

  Widget _buildCartItemCard(CartItemModel item) {
    final isUpdating =
        cartController.itemLoading[cartController.itemKey(item)] == true;

    final imageUrl = item.itemImgUrl.trim();
    final hasDiscount = item.discount > 0 && item.discount < 100;
    final finalPrice = item.finalPrice;
    final itemTotal = finalPrice * item.bookedQty;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        onTap: isUpdating ? null : () => _openProductDetails(item),
        child: Padding(
          padding: AppSpacing.insetsMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top row: image + info + delete ─────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product image
                  CartItemImage(imageUrl: imageUrl),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product name
                        Text(
                          item.itemName,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: AppSpacing.xs),

                        // Price info
                        Row(
                          children: [
                            Text(
                              '\$${finalPrice.toStringAsFixed(2)}',
                              style: AppTextStyles.bodyMedium,
                            ),
                            if (hasDiscount) ...[
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                '\$${item.itemPrice.toStringAsFixed(2)}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.sm,
                                  ),
                                ),
                                child: Text(
                                  '-${item.discount.toStringAsFixed(0)}%',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: AppSpacing.xs),

                        // ✅ FIX: Variant chips (size, color, brand)
                        CartItemVariantChips(
                          size: item.itemSize,
                          color: item.color,
                          brand: item.brand,
                        ),

                        const SizedBox(height: AppSpacing.xs),

                        // ✅ FIX: Stock indicator (uses real availableQty)
                        CartItemStockIndicator(
                          availableStock: item.remainingAvailableQty,
                          bookedQuantity: item.bookedQty,
                        ),
                      ],
                    ),
                  ),

                  // Delete button
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

              // ── Bottom row: quantity stepper + item total ───────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context).cartQuantity,
                    style: AppTextStyles.bodyMedium,
                  ),

                  // ✅ FIX: Show spinner only for THIS item
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
                      value: item.bookedQty,
                      decrementIcon: item.bookedQty <= 1
                          ? Icons.delete_outline
                          : Icons.remove,
                      onDecrement: () async {
                        final username = await _getUsername();
                        if (username.isNotEmpty) {
                          await cartController.decrementItem(
                            item: item,
                            username: username,
                          );
                        }
                      },

                      // ✅ FIX: Enable increment only if stock allows
                      // Uses cartController.canIncrement() for validation
                      onIncrement: cartController.canIncrement(item)
                          ? () async {
                              final username = await _getUsername();
                              if (username.isNotEmpty) {
                                await cartController.incrementItem(
                                  item: item,
                                  username: username,
                                );
                              }
                            }
                          : null,
                    ),
                ],
              ),

              const Divider(height: AppSpacing.lg),

              // Item subtotal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context).cartItemTotal,
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
    return CustomEmptyState(
      icon: Icons.shopping_cart_outlined,
      title: AppLocalizations.of(context).cartEmptyTitle,
      subtitle: AppLocalizations.of(context).cartEmptyMessage,
      action: CustomButton(
        label: AppLocalizations.of(context).cartStartShopping,
        onPressed: () {
          final switched = MainPage.switchToTab(context, homeTabIndex);
          if (switched) return;
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.main,
            (route) => false,
            arguments: {'initialTabIndex': homeTabIndex},
          );
        },
        leading: const Icon(Icons.shopping_bag),
        fullWidth: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).cartTitle),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: _loadCartFromApi,
        child: Obx(() {
          if (cartController.isLoading.value && cartController.items.isEmpty) {
            return const CustomScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            );
          }

          if (cartController.items.isEmpty) {
            return LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: _buildEmptyCart(),
                ),
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: AppSpacing.insetsMd,
                  child: Column(
                    children: [
                      // ✅ FIX: Each item wrapped in Obx for reactive updates
                      // Only the affected item rebuilds on quantity change
                      ...cartController.items.map(
                        (item) => Obx(() => _buildCartItemCard(item)),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
      bottomNavigationBar: Obx(() {
        if (cartController.items.isEmpty || cartController.isLoading.value) {
          return const SizedBox.shrink();
        }

        return SafeArea(
          child: Container(
            padding: AppSpacing.insetsMd,
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
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        Text(
                          '${AppLocalizations.of(context).cartShipping}: '
                          '${AppLocalizations.of(context).cartShippingFree}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
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
                            foregroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CheckoutScreen(
                                  cartItems: cartController.items.toList(),
                                ),
                              ),
                            );
                          },
                          child: Text(
                            AppLocalizations.of(context).cartCheckout,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(color: AppColors.black),
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
