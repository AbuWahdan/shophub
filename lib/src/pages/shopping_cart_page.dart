import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_constants.dart';
import '../config/route.dart';
import '../config/ui_text.dart';
import '../design/app_colors.dart';
import '../design/app_spacing.dart';
import '../design/app_text_styles.dart';
import '../model/cart_api.dart';
import '../model/cart_item.dart';
import '../l10n/l10n.dart';
import '../model/data.dart';
import '../model/product_api.dart';
import '../pages/checkout_screen.dart';
import '../pages/main_page.dart';
import '../services/product_service.dart';
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
  final ProductService _productService = ProductService();
  late List<CartItem> cartItems;
  bool _isLoading = false;
  String? _errorMessage;
  final Set<int> _itemsBeingUpdated = <int>{};

  @override
  void initState() {
    super.initState();
    _initializeCart();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCartFromApi();
    });
  }

  void _initializeCart() {
    cartItems = AppData.cartItems;
  }

  void _removeItem(int index) {
    if (!mounted) return;
    setState(() {
      AppData.removeFromCartAt(index);
      cartItems = AppData.cartItems;
    });
  }

  Future<void> _updateQuantity(int index, int newQuantity) async {
    if (!mounted) return;
    final cartItem = cartItems[index];
    final oldQuantity = cartItem.quantity;
    final username = context.read<AuthState>().user?.username.trim() ?? '';

    if (newQuantity < 1) {
      _showRemoveConfirmation(index);
      return;
    }

    if (newQuantity == oldQuantity) return;

    // Optimistic update
    setState(() {
      _itemsBeingUpdated.add(index);
      cartItems[index].quantity = newQuantity;
    });

    try {
      if (newQuantity > oldQuantity) {
        // Increment quantity
        final addRequest = AddItemToCartRequest(
          itemId: cartItem.selectedDetId > 0
              ? cartItem.product.id
              : cartItem.product.id,
          itemDetId: cartItem.selectedDetId,
          username: username,
          itemQty: newQuantity - oldQuantity,
        );
        await _productService.addItemToCart(addRequest);
      } else if (newQuantity < oldQuantity) {
        // Decrement - delete and re-add with new quantity
        // Or if we have a dedicated decrease API, use that
        // For now, we'll mark as updated but in real implementation
        // you might call a separate decrease API or delete and re-add
        final qtyDifference = oldQuantity - newQuantity;
        for (int i = 0; i < qtyDifference; i++) {
          await _productService.deleteItemFromCart(
            detailId: cartItem.selectedDetId,
            modifiedBy: username,
          );
        }
      }

      if (!mounted) return;

      setState(() {
        _itemsBeingUpdated.remove(index);
      });

      AppSnackBar.show(
        context,
        message:
            'Quantity updated successfully.',
        type: AppSnackBarType.success,
      );
      
      // ✅ CRITICAL FIX: Refresh cart from backend after update
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadCartFromApi();
        }
      });
    } on ProductException catch (error) {
      if (!mounted) return;

      setState(() {
        _itemsBeingUpdated.remove(index);
        // Revert optimistic update
        cartItems[index].quantity = oldQuantity;
      });

      AppSnackBar.show(
        context,
        message: error.message,
        type: AppSnackBarType.error,
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _itemsBeingUpdated.remove(index);
        // Revert optimistic update
        cartItems[index].quantity = oldQuantity;
      });

      AppSnackBar.show(
        context,
        message: 'Failed to update quantity. Please try again.',
        type: AppSnackBarType.error,
      );
    }
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
        'selectedDetId': cartItem.selectedDetId,
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
      onConfirm: () async {
        final cartItem = cartItems[index];
        final username = context.read<AuthState>().user?.username.trim() ?? '';

        setState(() {
          _itemsBeingUpdated.add(index);
        });

        try {
          await _productService.deleteItemFromCart(
            detailId: cartItem.selectedDetId,
            modifiedBy: username,
          );

          if (!mounted) return;

          _removeItem(index);

          AppSnackBar.show(
            context,
            message: l10n.cartItemRemoved,
            type: AppSnackBarType.info,
          );
          
          // ✅ CRITICAL FIX: Refresh cart from backend after delete
          // This ensures item won't reappear when user navigates/refreshes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _loadCartFromApi();
            }
          });
        } on ProductException catch (error) {
          if (!mounted) return;

          setState(() {
            _itemsBeingUpdated.remove(index);
          });

          AppSnackBar.show(
            context,
            message: error.message,
            type: AppSnackBarType.error,
          );
        } catch (error) {
          if (!mounted) return;

          setState(() {
            _itemsBeingUpdated.remove(index);
          });

          AppSnackBar.show(
            context,
            message: 'Failed to remove item. Please try again.',
            type: AppSnackBarType.error,
          );
        }
      },
    );
  }

  Future<void> _refreshCart() async {
    await _loadCartFromApi();
  }

  Future<void> _loadCartFromApi() async {
    if (!mounted) return;
    final username = context.read<AuthState>().user?.username.trim() ?? '';
    if (username.isEmpty) {
      setState(() {
        _errorMessage = null;
        _isLoading = false;
        AppData.setCartItems(const []);
        cartItems = AppData.cartItems;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiItems = await _productService.getItemCart(username: username);
      if (!mounted) return;
      final mapped = apiItems
          .map(
            (item) => CartItem(
              product: item.toProduct(),
              quantity: item.itemQty > 0 ? item.itemQty : 1,
              selectedSize: item.itemSize.trim().isEmpty
                  ? 'Default'
                  : item.itemSize,
              selectedColor: item.color.trim().isEmpty ? 'Default' : item.color,
              selectedDetId: item.itemDetId,
            ),
          )
          .toList();
      setState(() {
        AppData.setCartItems(mapped);
        cartItems = AppData.cartItems;
        _isLoading = false;
      });
    } on ProductException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load cart items.';
        _isLoading = false;
      });
    }
  }

  Widget _buildCartItemCard(int index, CartItem item) {
    ApiProduct product = item.product;
    int quantity = item.quantity;
    double itemTotal = product.finalPrice * quantity;
    bool hasDiscount = product.discountPrice != null;
    final selectedSize = item.selectedSize;
    final selectedColor = item.selectedColor;
    final isUpdating = _itemsBeingUpdated.contains(index);
    final availableStock = product.quantity;

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
                  // Product Image
                  Container(
                    width: AppSpacing.imageMd,
                    height: AppSpacing.imageMd,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    child: AppImage(
                      path: product.images.isNotEmpty
                          ? product.images.first
                          : '',
                      fit: BoxFit.cover,
                    ),
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
                          style: AppTextStyles.titleMedium,
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
                                context.l10n
                                    .cartAvailableStock(availableStock),
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
                  // Delete Button
                  IconButton(
                    icon: const Icon(Icons.close, size: AppSpacing.iconMd),
                    onPressed: isUpdating ? null : () =>
                        _showRemoveConfirmation(index),
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
                      onDecrement: quantity > 1
                          ? () => _updateQuantity(index, quantity - 1)
                          : null,
                      onIncrement:
                          quantity < AppConstants.checkoutMaxQuantity
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
          if (switched) {
            return;
          }
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

  Widget _cartItems() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: AppSpacing.xl),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null && _errorMessage!.trim().isNotEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: AppSpacing.iconXl),
            const SizedBox(height: AppSpacing.md),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: context.l10n.retry,
              onPressed: _loadCartFromApi,
              fullWidth: false,
            ),
          ],
        ),
      );
    }

    if (cartItems.isEmpty) {
      return _buildEmptyCart();
    }

    return Column(
      children: cartItems.asMap().entries.map((entry) {
        return _buildCartItemCard(entry.key, entry.value);
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showSummary =
        !_isLoading &&
        (_errorMessage == null || _errorMessage!.trim().isEmpty) &&
        cartItems.isNotEmpty;

    final scrollBody = LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Padding(
            padding: AppTheme.padding,
            child: Column(
              children: [
                _cartItems(),
                if (showSummary) const SizedBox(height: AppSpacing.hero),
              ],
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.cartTitle),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(onRefresh: _refreshCart, child: scrollBody),
      bottomNavigationBar: showSummary
          ? SafeArea(
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
                          style: AppTextStyles.titleMedium,
                        ),
                        Text(
                          '\$${totalPrice.toStringAsFixed(2)}',
                          style: AppTextStyles.titleLarge.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      height: AppSpacing.buttonMd,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textOnPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusLg,
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CheckoutScreen(cartItems: cartItems),
                            ),
                          );
                        },
                        child: Text(
                          context.l10n.cartCheckout,
                          style: AppTextStyles.buttonLarge.copyWith(
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
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
              ? AppTextStyles.labelLarge.copyWith(color: AppColors.primary)
              : AppTextStyles.bodySmall,
        ),
        Text(
          value,
          style: isDiscount
              ? AppTextStyles.labelLarge.copyWith(color: AppColors.primary)
              : AppTextStyles.bodySmall,
        ),
      ],
    );
  }
}
