import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../../controllers/cart_controller.dart';
import '../../../../models/data.dart';
import '../../controllers/wishlist_controller.dart';
import '../../core/config/route.dart';
import '../../core/state/auth_state.dart';
import '../../design/app_radius.dart';
import '../../design/app_shadows.dart';
import '../../models/product/product_model.dart';
import '../../services/product_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/app_notification_service.dart';
import 'add_to_cart_bottom_sheet/add_to_cart_bottom_sheet.dart';
import 'add_to_cart_bottom_sheet/widgets/product_card_image_section.dart';
import 'add_to_cart_bottom_sheet/widgets/product_card_info_section.dart';

class ProductCard extends StatefulWidget {
  final ProductModel product;
  final ValueChanged<ProductModel>? onSelected;
  final VoidCallback? onCartTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onSelected,
    this.onCartTap,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isAddingToCart = false;
  bool _isOpeningDetails = false;

  Future<void> _openProductDetails() async {
    if (_isOpeningDetails) return;
    setState(() => _isOpeningDetails = true);
    widget.onSelected?.call(widget.product);
    try {
      await Navigator.pushNamed(
        context,
        AppRoutes.productDetails,
        arguments: {'product': widget.product},
      );
    } finally {
      if (mounted) setState(() => _isOpeningDetails = false);
    }
  }

  Future<void> _handleToggleFavorite() async {
    final auth = context.read<AuthState>();
    await auth.ensureInitialized();
    if (!mounted) return;

    if ((auth.user?.username.trim() ?? '').isEmpty) {
      AppNotificationService.instance.showWarning(
        context,
        AppLocalizations.of(context).notificationLoginRequired,
      );
      return;
    }

    try {
      await context.read<WishlistController>().toggleWishlist(widget.product);
    } on ProductException catch (e) {
      if (!mounted) return;
      AppNotificationService.instance.showError(context, e.message);
    } catch (_) {
      if (!mounted) return;
      AppNotificationService.instance.showError(
        context,
        AppLocalizations.of(context).notificationUnknownError,
      );
    }
  }

  Future<void> _handleAddToCart() async {
    if (widget.onCartTap != null) {
      widget.onCartTap!();
      return;
    }

    final auth = context.read<AuthState>();
    await auth.ensureInitialized();
    if (!mounted) return;

    final username = auth.user?.username.trim() ?? '';
    if (username.isEmpty) {
      AppNotificationService.instance.showWarning(
        context,
        AppLocalizations.of(context).notificationLoginRequired,
      );
      return;
    }

    if (_isAddingToCart) return;
    setState(() => _isAddingToCart = true);

    try {
      final selection = await showModalBottomSheet<AddToCartSelection>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => AddToCartBottomSheet(
          product: widget.product,
          initialDetId: widget.product.detId,
        ),
      );

      if (!mounted || selection == null) return;

      final selectedVariant = selection.variant;
      final itemDetId = selectedVariant.detId > 0
          ? selectedVariant.detId
          : widget.product.resolveDetId(
        size: selectedVariant.size,
        color: selectedVariant.color,
        fallback: widget.product.detId,
      );

      if (itemDetId <= 0) {
        throw ProductException('Unable to determine selected product variant.');
      }

      await Get.find<CartController>().addItem(
        itemId: widget.product.id,
        itemDetId: itemDetId,
        username: username,
        requestedQty: selection.qty,
      );

      if (!mounted) return;

      AppData.addToCart(
        product: widget.product,
        quantity: selection.qty,
        size: selectedVariant.size.trim().isEmpty ? 'Default' : selectedVariant.size,
        color: selectedVariant.color.trim().isEmpty ? 'Default' : selectedVariant.color,
        detId: itemDetId,
      );

      AppNotificationService.instance.showSuccess(
        context,
        AppLocalizations.of(context).notificationProductAddedToCart(widget.product.name),
      );
    } on ProductException catch (e) {
      if (!mounted) return;
      AppNotificationService.instance.showError(context, e.message);
    } catch (_) {
      if (!mounted) return;
      AppNotificationService.instance.showError(
        context,
        AppLocalizations.of(context).notificationCartAddError,
      );
    } finally {
      if (mounted) setState(() => _isAddingToCart = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final wishlistState = context.watch<WishlistController>();
    final isFavorite = wishlistState.isInWishlist(product.id);
    final isToggling = wishlistState.isToggling(product.id);
    product.isFavorite = isFavorite;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: const [AppShadows.cardShadow],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          onTap: _isOpeningDetails ? null : _openProductDetails,
          child: // ✅ AFTER
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Wrap the Image section in Expanded
              Expanded(
                child: ProductCardImageSection(
                  product: product,
                  isFavorite: isFavorite,
                  isToggling: isToggling,
                  isAddingToCart: _isAddingToCart,
                  onFavoriteTap: _handleToggleFavorite,
                  onCartTap: _handleAddToCart,
                ),
              ),
              // 2. Info section takes exactly the space it needs at the bottom
              ProductCardInfoSection(product: product),
            ],
          )
        ),
      ),
    );
  }
}