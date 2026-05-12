import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../../../controllers/cart_controller.dart';
import '../../../../../core/state/auth_state.dart';
import '../../../../../design/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../models/data.dart';
import '../../../../models/product/product_model.dart';
import '../../../../../services/product_service.dart';
import '../../../custom__snack_bar/custom_snack_bar.dart';
import '../add_to_cart_bottom_sheet.dart';

/// A stateless utility that encapsulates the full "add to cart" user journey:
///
///   1. Ensure the user is authenticated.
///   2. Present [AddToCartBottomSheet] to collect variant + quantity.
///   3. Call [CartController.addItem] to persist the selection.
///   4. Sync [AppData] cache and show a result [CustomSnackBar].
///
/// Extracted from [WishlistPage] so it can be reused by any screen
/// (wishlist, order details, product listing, etc.) without duplication.
///
/// Usage:
/// ```dart
/// await AddToCartAction.execute(context: context, product: product);
/// ```
abstract final class AddToCartAction {
  /// Runs the full add-to-cart flow for [product].
  ///
  /// Returns [true] if the item was successfully added, [false] otherwise.
  /// The caller does not need to handle errors — all feedback is shown
  /// via [CustomSnackBar] internally.
  static Future<bool> execute({
    required BuildContext context,
    required ProductModel product,
  }) async {
    final authState = context.read<AuthState>();
    await authState.ensureInitialized();
    if (!context.mounted) return false;

    final username = authState.user?.username.trim() ?? '';
    final l10n = AppLocalizations.of(context);
    if (username.isEmpty) {
      CustomSnackBar.show(
        context,
        message: l10n.addToCartLoginRequired,
        type: AppSnackBarType.error,
      );
      return false;
    }

    // ── Step 1: collect variant + quantity ──────────────────────────────────
    final selection = await showModalBottomSheet<AddToCartSelection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) =>
          AddToCartBottomSheet(product: product, initialDetId: product.detId),
    );

    if (!context.mounted || selection == null) return false;

    // ── Step 2: resolve the variant detId ───────────────────────────────────
    final variant = selection.variant;
    final itemDetId = variant.detId > 0
        ? variant.detId
        : product.resolveDetId(
            size: variant.size,
            color: variant.color,
            fallback: product.detId,
          );

    if (itemDetId <= 0) {
      CustomSnackBar.show(
        context,
        message: l10n.addToCartVariantError,
        type: AppSnackBarType.error,
      );
      return false;
    }

    // ── Step 3: add via CartController ──────────────────────────────────────
    try {
      final cartController = Get.find<CartController>();
      await cartController.addItem(
        itemId: product.id,
        itemDetId: itemDetId,
        username: username,
        requestedQty: selection.qty,
      );

      if (!context.mounted) return false;

      // ── Step 4: sync AppData cache ─────────────────────────────────────────
      AppData.addToCart(
        product: product,
        quantity: selection.qty,
        size: variant.size.trim().isEmpty
            ? l10n.variantDefaultSize
            : variant.size,
        color: variant.color.trim().isEmpty
            ? l10n.variantDefaultColor
            : variant.color,
        detId: itemDetId,
      );

      CustomSnackBar.show(
        context,
        message: l10n.addToCartSuccess(product.name),
        type: AppSnackBarType.success,
      );
      return true;
    } on ProductException catch (e) {
      if (!context.mounted) return false;
      CustomSnackBar.show(
        context,
        message: e.message,
        type: AppSnackBarType.error,
      );
      return false;
    } catch (_) {
      if (!context.mounted) return false;
      CustomSnackBar.show(
        context,
        message: l10n.addToCartFailure,
        type: AppSnackBarType.error,
      );
      return false;
    }
  }
}
