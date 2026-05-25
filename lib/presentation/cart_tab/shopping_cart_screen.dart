import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../controllers/cart_controller.dart';
import '../../core/config/route.dart';
import '../../core/state/auth_state.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../design/app_text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../models/cart_item_model.dart';
import '../../services/app_notification_service.dart';
import '../../widgets/dialogs/app_dialogs.dart';
import '../home_tab/main_page.dart';
import 'checkout/checkout_screen.dart';
import 'widgets/cart_checkout_bar.dart';
import 'widgets/cart_empty_state.dart';
import 'widgets/cart_item_card.dart';
import 'widgets/cart_loading_state.dart';

class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({super.key});

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  final CartController _cartController = Get.find<CartController>();

  static const int _homeTabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCart());
  }

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
        builder: (_) => CheckoutScreen(
          cartItems: _cartController.items.toList(),
        ),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      appBar: _CartAppBar(
        cartController: _cartController,
        l10n: l10n,
        theme: theme,
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadCart,
        child: Obx(() => _buildBody(theme, l10n)),
      ),
      bottomNavigationBar: Obx(
            () {
          // Explicitly read the list length here so Obx tracks changes safely
          final _ = _cartController.items.length;
          return CartCheckoutBar(
            cartController: _cartController,
            onCheckout: _navigateToCheckout,
            l10n: l10n,
            theme: theme,
          );
        },
      ),
    );
  }

  Widget _buildBody(ThemeData theme, AppLocalizations l10n) {
    if (_cartController.isLoading.value && _cartController.items.isEmpty) {
      return const CartLoadingState();
    }

    if (_cartController.items.isEmpty) {
      return CartEmptyState(
        l10n: l10n,
        onStartShopping: _navigateToHome,
      );
    }

    return _CartItemList(
      cartController: _cartController,
      onTapItem: _openProductDetails,
      onRemoveItem: _confirmRemoveItem,
      onIncrement: _onIncrement,
      onDecrement: _onDecrement,
    );
  }
}

class _CartAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _CartAppBar({
    required this.cartController,
    required this.l10n,
    required this.theme,
  });

  final CartController cartController;
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
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
          if (cartController.items.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Chip(
              label: Text(
                '${cartController.totalItemCount} ${l10n.cartTitle.toLowerCase()}',
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
}

class _CartItemList extends StatelessWidget {
  const _CartItemList({
    required this.cartController,
    required this.onTapItem,
    required this.onRemoveItem,
    required this.onIncrement,
    required this.onDecrement,
  });

  final CartController cartController;
  final void Function(CartItemModel) onTapItem;
  final void Function(CartItemModel) onRemoveItem;
  final Future<void> Function(CartItemModel) onIncrement;
  final Future<void> Function(CartItemModel) onDecrement;

  @override
  Widget build(BuildContext context) {
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
            // Removed the redundant inner Obx completely
            children: cartController.items
                .map(
                  (item) => CartItemCard(
                key: ValueKey(item.detailId),
                item: item,
                isBusy: cartController.isItemBusy(item.detailId),
                canIncrement: cartController.canIncrement(item),
                canDecrement: cartController.canDecrement(item),
                onTap: () => onTapItem(item),
                onRemove: () => onRemoveItem(item),
                onIncrement: () => onIncrement(item),
                onDecrement: () => onDecrement(item),
              ),
            )
                .toList(),
          ),
        ),
      ),
    );
  }
}