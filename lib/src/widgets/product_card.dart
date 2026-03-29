import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sinwar_shoping/src/config/route.dart';

import '../design/app_text_styles.dart';
import '../model/data.dart';
import '../model/product_api.dart';
import '../model/cart_api.dart';
import '../services/product_service.dart';
import '../shared/widgets/add_to_cart_bottom_sheet.dart';
import '../shared/widgets/app_image.dart';
import '../shared/widgets/app_snackbar.dart';
import '../state/auth_state.dart';
import '../state/wishlist_state.dart';

class ProductCard extends StatefulWidget {
  final ApiProduct product;
  final ValueChanged<ApiProduct>? onSelected;
  const ProductCard({super.key, required this.product, this.onSelected});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  final ProductService _productService = ProductService();
  bool _isAddingToCart = false;

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
      AppSnackBar.show(
        context,
        message: error.message,
        type: AppSnackBarType.error,
      );
    } catch (error) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: 'Failed to update favorite',
        type: AppSnackBarType.error,
      );
    }
  }

  /// ✅ NEW: Handle add to cart from product card
  Future<void> _handleAddToCart() async {
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
              size: selectedVariant.itemSize,
              color: selectedVariant.color,
              fallback: widget.product.detId,
            );

      if (itemDetId <= 0) {
        throw ProductException('Unable to determine selected product variant.');
      }

      // Add to cart with selected options
      await _productService.addItemToCart(
        AddItemToCartRequest(
          itemId: widget.product.id,
          itemDetId: itemDetId,
          username: username,
          itemQty: selection.qty,
        ),
      );

      if (!mounted) return;

      // Update AppData cache
      AppData.addToCart(
        product: widget.product,
        quantity: selection.qty,
        size: selectedVariant.itemSize.trim().isEmpty
            ? 'Default'
            : selectedVariant.itemSize,
        color: selectedVariant.color.trim().isEmpty
            ? 'Default'
            : selectedVariant.color,
        detId: itemDetId,
      );

      AppSnackBar.show(
        context,
        message: '${widget.product.name} added to cart',
        type: AppSnackBarType.success,
      );
    } on ProductException catch (error) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: error.message,
        type: AppSnackBarType.error,
      );
    } catch (error) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: 'Failed to add to cart',
        type: AppSnackBarType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isAddingToCart = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final theme = Theme.of(context);
    final textDirection = Directionality.of(context);
    final wishlistState = context.watch<WishlistState>();
    final isFavorite = wishlistState.isInWishlist(product.id);
    final isTogglingFavorite = wishlistState.isToggling(product.id);
    product.isFavorite = isFavorite;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: const [AppShadows.cardShadow],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.productDetails,
            arguments: {'product': product},
          );
          widget.onSelected?.call(product);
        },
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
                        child: _buildImageSlot(context),
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
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          '-${product.discountPercentage}%',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.saleBadgeText,
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
                      onTap: isTogglingFavorite ? null : _handleToggleFavorite,
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withValues(
                            alpha: 0.86,
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: isTogglingFavorite
                            ? const SizedBox(
                                width: AppSpacing.iconMd,
                                height: AppSpacing.iconMd,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
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
              padding: AppSpacing.insetsMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name.isNotEmpty ? product.name : 'Unnamed Product',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.headingSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: AppSpacing.iconSm,
                        color: AppColors.star,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '${product.rating.toStringAsFixed(1)} (${product.reviewCount})',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSlot(BuildContext context) {
    final product = widget.product;
    if (product.images.isEmpty || product.images.first.trim().isEmpty) {
      return _buildPlaceholder();
    }
    return AppImage(path: product.images.first.trim(), fit: BoxFit.cover);
  }

  Widget _buildPriceTag(BuildContext context) {
    final product = widget.product;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
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
            '\$${product.finalPrice.toStringAsFixed(2)}',
            style: AppTextStyles.labelLarge.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          if (product.discountPercentage > 0)
            Text(
              '\$${product.price.toStringAsFixed(2)}',
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
          width: 32,
          height: 32,
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
                        theme.colorScheme.onPrimary,
                      ),
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
        size: AppSpacing.iconXl,
        color: AppColors.textHint,
      ),
    );
  }
}
