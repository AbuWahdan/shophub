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
import '../../services/app_notification_service.dart';
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
  final CartController _cartController = Get.find<CartController>();

  static const int _homeTabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCart());
  }

  // ── Auth helpers ────────────────────────────────────────────────────────────

  Future<String> _resolveUsername() async {
    if (!mounted) return '';
    final authState = context.read<AuthState>();
    await authState.ensureInitialized();
    return authState.user?.username.trim() ?? '';
  }

  Future<void> _loadCart() async {
    final username = await _resolveUsername();
    if (username.isNotEmpty) {
      await _cartController.loadCart(username: username);
    }
  }

  // ── Navigation ──────────────────────────────────────────────────────────────

  void _openProductDetails(CartItemModel item) {
    Navigator.pushNamed(
      context,
      AppRoutes.productDetails,
      arguments: {
        'product': item.product,
        'selectedSize': item.displaySize,
        'selectedColor': item.displayColor,
        'selectedDetId': item.itemDetId,
      },
    );
  }

  void _navigateToCheckout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CheckoutScreen(cartItems: _cartController.items.toList()),
      ),
    );
  }

  void _navigateToHome() {
    final switched = MainPage.switchToTab(context, _homeTabIndex);
    if (switched) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.main,
      (route) => false,
      arguments: {'initialTabIndex': _homeTabIndex},
    );
  }

  // ── Actions ─────────────────────────────────────────────────────────────────

  void _confirmRemoveItem(CartItemModel item) {
    final l10n = AppLocalizations.of(context);
    AppDialogs.showConfirmation(
      context: context,
      title: l10n.cartRemoveItemTitle,
      message: l10n.cartRemoveItemMessage,
      confirmLabel: l10n.commonRemove,
      cancelLabel: l10n.commonCancel,
      onConfirm: () async {
        final username = await _resolveUsername();
        if (username.isEmpty) {
          if (!mounted) return;
          AppNotificationService.instance.showError(
            context,
            l10n.notificationLoginRequired,
          );
          return;
        }
        await _cartController.removeItem(item: item, username: username);
      },
    );
  }

  Future<void> _onIncrement(CartItemModel item) async {
    final username = await _resolveUsername();
    if (username.isNotEmpty) {
      await _cartController.incrementItem(item: item, username: username);
    }
  }

  Future<void> _onDecrement(CartItemModel item) async {
    final username = await _resolveUsername();
    if (username.isNotEmpty) {
      await _cartController.decrementItem(item: item, username: username);
    }
  }

  // ── BUILD ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      appBar: _buildAppBar(theme, l10n),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadCart,
        child: Obx(() => _buildBody(theme, l10n)),
      ),
      bottomNavigationBar: Obx(() => _buildCheckoutBar(theme, l10n)),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, AppLocalizations l10n) {
    return AppBar(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Text(
        l10n.cartTitle,
        style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w800),
      ),
      actions: [
        Obx(() {
          if (_cartController.items.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Chip(
              label: Text(
                '${_cartController.totalItemCount} ${l10n.cartTitle.toLowerCase()}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              side: BorderSide.none,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBody(ThemeData theme, AppLocalizations l10n) {
    // Initial full-screen loader
    if (_cartController.isLoading.value && _cartController.items.isEmpty) {
      return const CustomScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

    // Empty state — always scrollable so pull-to-refresh works
    if (_cartController.items.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: _buildEmptyState(l10n),
          ),
        ),
      );
    }

    // Cart items list
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xl,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Column(
            children: _cartController.items
                .map(
                  (item) => Obx(
                    () => _CartItemCard(
                      key: ValueKey(item.detailId),
                      item: item,
                      isBusy: _cartController.isItemBusy(item.detailId),
                      canIncrement: _cartController.canIncrement(item),
                      canDecrement: _cartController.canDecrement(item),
                      onTap: () => _openProductDetails(item),
                      onRemove: () => _confirmRemoveItem(item),
                      onIncrement: () => _onIncrement(item),
                      onDecrement: () => _onDecrement(item),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return CustomEmptyState(
      icon: Icons.shopping_cart_outlined,
      title: l10n.cartEmptyTitle,
      subtitle: l10n.cartEmptyMessage,
      action: CustomButton(
        label: l10n.cartStartShopping,
        onPressed: _navigateToHome,
        leading: const Icon(Icons.shopping_bag),
        fullWidth: false,
      ),
    );
  }

  Widget _buildCheckoutBar(ThemeData theme, AppLocalizations l10n) {
    if (_cartController.items.isEmpty || _cartController.isLoading.value) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Price column
            Expanded(
              flex: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.cartShipping,
                    style: AppTextStyles.caption.copyWith(
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${_cartController.totalPrice.toStringAsFixed(2)}',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    l10n.cartShippingFree,
                    style: AppTextStyles.caption.copyWith(
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppSpacing.sm),

            // Checkout button
            Expanded(
              flex: 3,
              child: SizedBox(
                height: AppSpacing.buttonMd,
                child: ElevatedButton(
                  onPressed: _navigateToCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.cartCheckout,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CART ITEM CARD  (extracted widget — only rebuilds for its own item)
// ─────────────────────────────────────────────────────────────────────────────

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
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
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.5),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopRow(context, theme),
                const SizedBox(height: AppSpacing.sm),
                _buildDivider(theme),
                const SizedBox(height: AppSpacing.sm),
                _buildBottomRow(context, theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopRow(BuildContext context, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product image
        CartItemImage(imageUrl: item.imageUrl.trim()),

        const SizedBox(width: AppSpacing.md),

        // Product info
        Expanded(child: _buildProductInfo(context, theme)),

        // Remove button
        _buildRemoveButton(theme),
      ],
    );
  }

  Widget _buildProductInfo(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name
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

        // Price row
        _buildPriceRow(theme),

        const SizedBox(height: AppSpacing.xs),

        // Variant chips (size / color / brand)
        CartItemVariantChips(
          size: item.size,
          color: item.color,
          brand: item.brand,
        ),

        const SizedBox(height: AppSpacing.xs),

        // Stock indicator
        CartItemStockIndicator(
          availableStock: item.remainingStock,
          bookedQuantity: item.bookedQty,
        ),
      ],
    );
  }

  Widget _buildPriceRow(ThemeData theme) {
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              '-${item.discount.toStringAsFixed(0)}%',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRemoveButton(ThemeData theme) {
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

  Widget _buildDivider(ThemeData theme) {
    return Divider(
      height: 1,
      thickness: 1,
      color: theme.dividerColor.withValues(alpha: 0.4),
    );
  }

  Widget _buildBottomRow(BuildContext context, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Quantity stepper or spinner
        if (isBusy)
          SizedBox(
            width: AppSpacing.buttonSm * 3,
            height: AppSpacing.buttonSm,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
          )
        else
          QuantityStepper(
            value: item.bookedQty,
            decrementIcon: item.bookedQty <= 1
                ? Icons.delete_outline
                : Icons.remove,
            onDecrement: onDecrement,
            onIncrement: canIncrement ? onIncrement : null,
          ),

        // Line total
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              AppLocalizations.of(context).cartItemTotal,
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
        ),
      ],
    );
  }
}
