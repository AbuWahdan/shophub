import 'package:flutter/material.dart';

import '../../../../design/app_colors.dart';
import '../../../../design/app_radius.dart';
import '../../../../design/app_spacing.dart';
import '../../../../design/app_text_styles.dart';
import '../../../../models/product/product_model.dart';
import '../../../../services/product_service.dart';
import '../../../custom_image.dart';

class ProductCardImageSection extends StatefulWidget {
  final ProductModel product;
  final bool isFavorite;
  final bool isToggling;
  final bool isAddingToCart;
  final VoidCallback onFavoriteTap;
  final VoidCallback onCartTap;

  const ProductCardImageSection({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.isToggling,
    required this.isAddingToCart,
    required this.onFavoriteTap,
    required this.onCartTap,
  });

  @override
  State<ProductCardImageSection> createState() => _ProductCardImageSectionState();
}

class _ProductCardImageSectionState extends State<ProductCardImageSection> {
  static final _cache = <int, String>{};

  late Future<String?> _coverFuture;

  @override
  void initState() {
    super.initState();
    _coverFuture = _loadCover();
  }

  Future<String?> _loadCover() async {
    final id = widget.product.id;
    if (_cache.containsKey(id)) return _cache[id];

    try {
      final images = await ProductService().getItemImages(itemId: id);
      if (images.isNotEmpty) {
        final path = images.first.imagePath.trim();
        if (path.isNotEmpty) {
          _cache[id] = path;
          return path;
        }
      }
    } catch (_) {}

    // Fallback to legacy product.images list
    final legacy = widget.product.images;
    if (legacy.isNotEmpty && legacy.first.trim().isNotEmpty) {
      return legacy.first.trim();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textDir = Directionality.of(context);

    // AspectRatio 4:3 — image height is always 75% of card width.
    // No fixed height → no overflow on any device.
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Stack(
        children: [
          // ── Cover image ──────────────────────────────────────────────────
          Positioned.fill(
            child: Hero(
              tag: 'product_${widget.product.id}',
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.lg),
                ),
                child: FutureBuilder<String?>(
                  future: _coverFuture,
                  builder: (context, snapshot) {
                    final path = snapshot.data;
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        alignment: Alignment.center,
                        child: const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }
                    if (path != null && path.isNotEmpty) {
                      return CustomImage(path: path, fit: BoxFit.cover);
                    }
                    return _ImagePlaceholder();
                  },
                ),
              ),
            ),
          ),

          // ── Wishlist button (top-start) ───────────────────────────────────
          Positioned.directional(
            textDirection: textDir,
            top: AppSpacing.sm,
            start: AppSpacing.sm,
            child: _WishlistButton(
              isFavorite: widget.isFavorite,
              isToggling: widget.isToggling,
              onTap: widget.onFavoriteTap,
            ),
          ),

          // ── Discount ribbon (top-end) ─────────────────────────────────────
          if (widget.product.discountPercentage > 0)
            Positioned.directional(
              textDirection: textDir,
              top: 0,
              end: 0,
              child: _DiscountRibbon(discount: widget.product.discountPercentage),
            ),

          // ── Price tag (bottom-start) ──────────────────────────────────────
          Positioned.directional(
            textDirection: textDir,
            start: AppSpacing.sm,
            bottom: AppSpacing.sm,
            child: _PriceTag(product: widget.product, theme: theme),
          ),

          // ── Cart button (bottom-end) ──────────────────────────────────────
          Positioned.directional(
            textDirection: textDir,
            end: AppSpacing.sm,
            bottom: AppSpacing.sm,
            child: _CartButton(
              isLoading: widget.isAddingToCart,
              onTap: widget.onCartTap,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _ImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        size: AppSpacing.iconLg,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
      ),
    );
  }
}

class _WishlistButton extends StatelessWidget {
  final bool isFavorite;
  final bool isToggling;
  final VoidCallback onTap;

  const _WishlistButton({
    required this.isFavorite,
    required this.isToggling,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Size is 10% of screen width, clamped between 28–40 logical px.
    final size = (MediaQuery.sizeOf(context).width * 0.10).clamp(28.0, 40.0);
    final iconSize = size * 0.5;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isToggling ? null : onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isFavorite
              ? AppColors.error.withValues(alpha: 0.12)
              : theme.colorScheme.surface.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: isToggling
            ? SizedBox(
          width: iconSize,
          height: iconSize,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.error,
          ),
        )
            : Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? AppColors.error : theme.colorScheme.onSurface,
          size: iconSize,
        ),
      ),
    );
  }
}

class _DiscountRibbon extends StatelessWidget {
  final int discount;

  const _DiscountRibbon({required this.discount});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _RibbonClipper(),
      child: Container(
        width: 48,
        height: 48,
        color: AppColors.saleBadge,
        alignment: const Alignment(0, -0.4),
        child: Text(
          '-$discount%',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 9,
            height: 1.1,
          ),
        ),
      ),
    );
  }
}

class _RibbonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size s) => Path()
    ..moveTo(0, 0)
    ..lineTo(s.width, 0)
    ..lineTo(s.width, s.height)
    ..lineTo(s.width / 2, s.height - 10)
    ..lineTo(0, s.height)
    ..close();

  @override
  bool shouldReclip(_RibbonClipper old) => false;
}

class _PriceTag extends StatelessWidget {
  final ProductModel product;
  final ThemeData theme;

  const _PriceTag({required this.product, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.finalPrice.toStringAsFixed(2),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.priceGreen,
            ),
          ),
          if (product.discountPercentage > 0)
            Text(
              product.price.toStringAsFixed(2),
              style: TextStyle(
                fontSize: 10,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                decoration: TextDecoration.lineThrough,
              ),
            ),
        ],
      ),
    );
  }
}

class _CartButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _CartButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Responsive size: 9% of screen width, clamped 28–38px
    final size = (MediaQuery.sizeOf(context).width * 0.09).clamp(28.0, 38.0);
    final iconSize = size * 0.48;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        customBorder: const CircleBorder(),
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
              width: iconSize * 0.8,
              height: iconSize * 0.8,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.cartIconColor,
              ),
            )
                : Icon(
              Icons.shopping_cart_outlined,
              size: iconSize,
              color: AppColors.cartIconColor,
            ),
          ),
        ),
      ),
    );
  }
}