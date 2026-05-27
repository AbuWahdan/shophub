import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../controllers/cart_controller.dart';
import '../../core/config/route.dart';
import '../../core/state/auth_state.dart';
import '../../l10n/app_localizations.dart';
import '../../models/cart_item_model.dart';
import '../../services/app_notification_service.dart';
import '../../widgets/dialogs/app_dialogs.dart';
import '../main_navigator.dart';
import 'cart/cart_screen.dart';
import 'checkout/checkout_screen.dart';

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
    final switched = MainNavigator.switchToTab(context, _homeTabIndex);
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
    // Return CartScreen directly. No Scaffold wrapper!
    return CartScreen(
      cartController: _cartController,
      onTapItem: _openProductDetails,
      onRemoveItem: (item) {
        if (item == null) return _navigateToHome();
        _confirmRemoveItem(item);
      },
      onIncrement: _onIncrement,
      onDecrement: _onDecrement,
      onCheckout: _navigateToCheckout,
      onRefresh: _loadCart,
    );
  }
}