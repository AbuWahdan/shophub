import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:provider/provider.dart';
import 'package:sinwar_shoping/widgets/widgets/add_to_cart_bottom_sheet.dart';
import 'package:sinwar_shoping/widgets/widgets/app_image.dart';
import 'package:sinwar_shoping/widgets/widgets/app_snackbar.dart';
import 'package:sinwar_shoping/widgets/widgets/rating_stars.dart';
import '../../core/config/route.dart';

import '../../controllers/cart_controller.dart';
import '../../models/data.dart';
import '../../models/product_api.dart';
import '../core/state/auth_state.dart';
import '../core/state/wishlist_state.dart';
import '../design/app_colors.dart';
import '../design/app_radius.dart';
import '../design/app_shadows.dart';
import '../design/app_spacing.dart';
import '../design/app_text_styles.dart';
import '../services/product_service.dart';

class ProductCard extends StatefulWidget {
  final ApiProduct product;
  final ValueChanged<ApiProduct>? onSelected;

  // FIX: optional override for the cart-button tap — used by WishlistPage
  // to open the bottom drawer within the wishlist context.
  // When null, the card's own _handleAddToCart is used (home tab behaviour).
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
  bool _isAddingToCart    = false;
  bool _isOpeningDetails  = false;

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
    final username = auth.user?.username.trim() ?? '';

    if (username.isEmpty) {
      AppSnackBar.show(
        context,
        message: 'Please log in to manage favorites',
        type: AppSnackBarType.warning,
      );
      return;
    }

    try {
      await context.read<WishlistState>().toggleWishlist(widget.product);
    } on ProductException catch (error) {
      if (!mounted) return;
      AppSnackBar.show(context, message: error.message,
          type: AppSnackBarType.error);
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(context, message: 'Failed to update favorite',
          type: AppSnackBarType.error);
    }
  }

  Future<void> _handleAddToCart() async {
    // If the parent supplied a custom tap handler, delegate immediately.
    if (widget.onCartTap != null) {
      widget.onCartTap!();
      return;
    }

    final auth = context.read<AuthState>();
    await auth.ensureInitialized();
    if (!mounted) return;
    final username = auth.user?.username.trim() ?? '';

    if (username.isEmpty) {
      AppSnackBar.show(
        context,
        message: 'Please log in to add items to cart',
        type: AppSnackBarType.warning,
      );
      return;
    }

    if (_isAddingToCart) return;
    setState(() => _isAddingToCart = true);

    try {
      // FIX: ALWAYS open the bottom drawer regardless of variant count.
      // This gives the user the quantity stepper every time.
      final selection = await showModalBottomSheet<AddToCartSelection>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => AddToCartBottomSheet(product: widget.product),
      );

      if (!mounted || selection == null) return;

      final selectedVariant = selection.variant;
      final itemDetId = selectedVariant.detId > 0
          ? selectedVariant.detId
          : widget.product.resolveDetId(
        size:     selectedVariant.itemSize,
        color:    selectedVariant.color,
        fallback: widget.product.detId,
      );

      if (itemDetId <= 0) {
        throw ProductException('Unable to determine selected product variant.');
      }

      final cartController = Get.find<CartController>();
      await cartController.addItem(
        itemId:    widget.product.id,
        itemDetId: itemDetId,
        username:  username,
        chosenQty: selection.qty,
      );

      if (!mounted) return;

      AppData.addToCart(
        product:  widget.product,
        quantity: selection.qty,
        size:  selectedVariant.itemSize.trim().isEmpty ? 'Default' : selectedVariant.itemSize,
        color: selectedVariant.color.trim().isEmpty   ? 'Default' : selectedVariant.color,
        detId: itemDetId,
      );

      AppSnackBar.show(
        context,
        message: '${widget.product.name} added to cart',
        type: AppSnackBarType.success,
      );
    } on ProductException catch (error) {
      if (!mounted) return;
      AppSnackBar.show(context, message: error.message,
          type: AppSnackBarType.error);
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(context, message: 'Failed to add to cart',
          type: AppSnackBarType.error);
    } finally {
      if (mounted) setState(() => _isAddingToCart = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final product        = widget.product;
    final theme          = Theme.of(context);
    final textDirection  = Directionality.of(context);
    final wishlistState  = context.watch<WishlistState>();
    final isFavorite     = wishlistState.isInWishlist(product.id);
    final isToggling     = wishlistState.isToggling(product.id);
    product.isFavorite   = isFavorite;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: const [AppShadows.cardShadow],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: _isOpeningDetails ? null : _openProductDetails,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Hero(
                      tag: 'product_${product.id}',
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppRadius.lg),
                        ),
                        child: _buildImageSlot(),
                      ),
                    ),
                  ),
                  if (product.discountPercentage > 0)
                    Positioned.directional(
                      textDirection: textDirection,
                      top: AppSpacing.sm,
                      start: AppSpacing.sm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.saleBadge,
                          borderRadius:
                          BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          '-${product.discountPercentage}%',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.saleBadge,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  Positioned.directional(
                    textDirection: textDirection,
                    top: AppSpacing.sm,
                    end: AppSpacing.sm,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: isToggling ? null : _handleToggleFavorite,
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface
                              .withValues(alpha: 0.86),
                          borderRadius:
                          BorderRadius.circular(AppRadius.full),
                        ),
                        child: isToggling
                            ? const SizedBox(
                          width: AppSpacing.iconMd,
                          height: AppSpacing.iconMd,
                          child: CircularProgressIndicator(
                              strokeWidth: 2),
                        )
                            : Icon(
                          isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: isFavorite
                              ? AppColors.error
                              : theme.colorScheme.onSurface,
                          size: AppSpacing.iconMd,
                        ),
                      ),
                    ),
                  ),
                  Positioned.directional(
                    textDirection: textDirection,
                    start: AppSpacing.sm,
                    end: AppSpacing.xxl,
                    bottom: AppSpacing.sm,
                    child: Align(
                      alignment: AlignmentDirectional.bottomStart,
                      child: _buildPriceTag(context),
                    ),
                  ),
                  Positioned.directional(
                    textDirection: textDirection,
                    end: AppSpacing.sm,
                    bottom: AppSpacing.sm,
                    child: _buildAddToCartButton(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.name.trim().isNotEmpty)
                    Text(
                      product.name.trim(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleSmall,
                    ),
                  if (product.rating > 0 || product.reviewCount > 0) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        RatingStars(
                          rating: product.rating,
                          size: AppSpacing.iconSm,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            product.reviewCount > 0
                                ? '${product.rating.toStringAsFixed(1)} (${product.reviewCount})'
                                : product.rating.toStringAsFixed(1),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSlot() {
    final images = widget.product.images;
    if (images.isEmpty || images.first.trim().isEmpty) {
      return _buildPlaceholder();
    }
    return AppImage(path: images.first.trim(), fit: BoxFit.cover);
  }

  Widget _buildPriceTag(BuildContext context) {
    final product = widget.product;
    final theme   = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm, vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.finalPrice.toStringAsFixed(2),
            style: AppTextStyles.labelLarge.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          if (product.discountPercentage > 0)
            Text(
              product.price.toStringAsFixed(2),
              style: AppTextStyles.caption.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
                decoration: TextDecoration.lineThrough,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddToCartButton(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isAddingToCart ? null : _handleAddToCart,
        customBorder: const CircleBorder(),
        child: Ink(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: _isAddingToCart
                ? SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.onPrimary),
              ),
            )
                : Icon(
              Icons.shopping_cart_outlined,
              size: AppSpacing.iconSm,
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.surfaceVariant,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        size: AppSpacing.iconLg,
        color: AppColors.textHint,
      ),
    );
  }
}