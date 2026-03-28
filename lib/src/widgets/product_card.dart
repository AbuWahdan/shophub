import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sinwar_shoping/src/config/route.dart';

import '../design/app_colors.dart';
import '../design/app_spacing.dart';
import '../design/app_text_styles.dart';
import '../model/data.dart';
import '../model/product_api.dart';
import '../model/cart_api.dart';
import '../services/product_service.dart';
import '../shared/widgets/app_image.dart';
import '../shared/widgets/app_snackbar.dart';
import '../state/auth_state.dart';

class ProductCard extends StatefulWidget {
  final ApiProduct product;
  final ValueChanged<ApiProduct>? onSelected;
  const ProductCard({super.key, required this.product, this.onSelected});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  final ProductService _productService = ProductService();
  bool _isTogglingFavorite = false;
  bool _isAddingToCart = false;

  Future<void> _handleToggleFavorite() async {
    final auth = context.read<AuthState>();
    final username = auth.user?.username.trim() ?? '';

    if (username.isEmpty) {
      AppSnackBar.show(
        context,
        message: 'Please log in to manage favorites',
        type: AppSnackBarType.warning,
      );
      return;
    }

    if (_isTogglingFavorite) return;

    setState(() => _isTogglingFavorite = true);

    try {
      await _productService.toggleFavorite(
        itemId: widget.product.id,
        username: username,
      );

      if (!mounted) return;

      setState(() {
        widget.product.isFavorite = !widget.product.isFavorite;
        // ✅ CRITICAL FIX: Update AppData cache so wishlist page reflects changes
        AppData.toggleFavorite(widget.product);
        _isTogglingFavorite = false;
      });
    } on ProductException catch (error) {
      if (!mounted) return;
      setState(() => _isTogglingFavorite = false);
      AppSnackBar.show(
        context,
        message: error.message,
        type: AppSnackBarType.error,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isTogglingFavorite = false);
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
      // Show variant selection bottom sheet
      final selection = await showModalBottomSheet<_CartAddSelection>(
        context: context,
        builder: (context) => _AddToCartBottomSheet(
          product: widget.product,
        ),
      );

      if (!mounted || selection == null) return;

      // Add to cart with selected options
      await _productService.addItemToCart(
        AddItemToCartRequest(
          itemId: widget.product.id,
          itemDetId: selection.variant.detId,
          username: username,
          itemQty: selection.qty,
        ),
      );

      if (!mounted) return;

      // Update AppData cache
      AppData.addToCart(
        product: widget.product,
        quantity: selection.qty,
        size: selection.variant.itemSize,
        color: selection.variant.color,
        detId: selection.variant.detId,
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
    AppData.syncFavoriteFor(product);

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
                    Positioned(
                      top: AppSpacing.sm,
                      left: AppSpacing.sm,
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
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: GestureDetector(
                      onTap: _isTogglingFavorite ? null : _handleToggleFavorite,
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.86),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: _isTogglingFavorite
                            ? const SizedBox(
                                width: AppSpacing.iconMd,
                                height: AppSpacing.iconMd,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(
                                product.isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: product.isFavorite
                                    ? AppColors.error
                                    : AppColors.textPrimary,
                                size: AppSpacing.iconMd,
                              ),
                      ),
                    ),
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
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: AppSpacing.sm,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              '\$${product.finalPrice.toStringAsFixed(2)}',
                              style: AppTextStyles.priceMedium,
                            ),
                            if (product.discountPercentage > 0)
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: AppTextStyles.priceOriginal,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // ✅ NEW: Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    child: _isAddingToCart
                        ? const SizedBox(
                            height: 36,
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : ElevatedButton.icon(
                            onPressed: _handleAddToCart,
                            icon: const Icon(Icons.shopping_cart, size: 16),
                            label: const Text('', maxLines: 1),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.sm,
                              ),
                            ),
                          ),
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

/// ✅ NEW: Bottom sheet for selecting variant & quantity when adding from product card
class _AddToCartBottomSheet extends StatefulWidget {
  final ApiProduct product;

  const _AddToCartBottomSheet({required this.product});

  @override
  State<_AddToCartBottomSheet> createState() => _AddToCartBottomSheetState();
}

class _AddToCartBottomSheetState extends State<_AddToCartBottomSheet> {
  late ApiProductVariant _selectedVariant;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    final variants = widget.product.details.isNotEmpty
        ? widget.product.details
        : [
            ApiProductVariant(
              detId: widget.product.detId,
             // itemId: widget.product.id,
              brand: 'Unknown',
              color: 'Default',
              itemSize: 'Default',
              discount: 0,
              itemPrice: widget.product.price,
              itemQty: widget.product.quantity,
              //isActive: 1,
            )
          ];
    _selectedVariant = variants.first;
  }

  @override
  Widget build(BuildContext context) {
    final variants = widget.product.details.isNotEmpty
        ? widget.product.details
        : [
            ApiProductVariant(
              detId: widget.product.detId,
              //itemId: widget.product.id,
              brand: 'Unknown',
              color: 'Default',
              itemSize: 'Default',
              discount: 0,
              itemPrice: widget.product.price,
              itemQty: widget.product.quantity,
              //isActive: 1,
            )
          ];

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Options',
              style: AppTextStyles.headingMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            if (variants.length > 1)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Variant', style: AppTextStyles.labelLarge),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    height: 50,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: variants.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final variant = variants[index];
                        final isSelected = _selectedVariant.detId == variant.detId;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedVariant = variant),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textHint,
                              ),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.1)
                                  : Colors.transparent,
                            ),
                            child: Center(
                              child: Text(
                                '${variant.color} - ${variant.itemSize}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            Text('Quantity', style: AppTextStyles.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                ),
                Expanded(
                  child: Center(child: Text('$_quantity')),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _quantity < (_selectedVariant.itemQty > 0 ? _selectedVariant.itemQty : 10)
                      ? () => setState(() => _quantity++)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  _CartAddSelection(_selectedVariant, _quantity),
                );
              },
              child: const Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }
}

/// ✅ NEW: Data class for cart selection
class _CartAddSelection {
  final ApiProductVariant variant;
  final int qty;

  _CartAddSelection(this.variant, this.qty);
}
