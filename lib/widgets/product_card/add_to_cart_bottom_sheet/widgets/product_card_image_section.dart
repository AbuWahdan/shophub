import 'package:flutter/material.dart';

import '../../../../design/app_colors.dart';
import '../../../../design/app_radius.dart';
import '../../../../design/app_spacing.dart';
import '../../../../design/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/product/product_model.dart';
import '../../../../services/product_service.dart';
import '../../../custom_image.dart';

/// Image area of a [ProductCard].
///
/// Overlay layout (top-to-bottom, start-to-end):
///   TL  → wishlist toggle
///   TR  → discount percentage ribbon
///   BL  → price tag (final price + crossed-out original when discounted)
///   BR  → add-to-cart button
///
/// A second "savings amount" badge sits just below the ribbon (TR) so
/// the customer sees both *how much off* and *how much saved* at a glance.
class ProductCardImageSection extends StatefulWidget {
  const ProductCardImageSection({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.isToggling,
    required this.isAddingToCart,
    required this.onFavoriteTap,
    required this.onCartTap,
  });

  final ProductModel product;
  final bool isFavorite;
  final bool isToggling;
  final bool isAddingToCart;
  final VoidCallback onFavoriteTap;
  final VoidCallback onCartTap;

  @override
  State<ProductCardImageSection> createState() =>
      _ProductCardImageSectionState();
}

class _ProductCardImageSectionState extends State<ProductCardImageSection> {
  static final Map<int, String> _imageCache = {};

  late final Future<String?> _coverFuture;

  @override
  void initState() {
    super.initState();
    _coverFuture = _resolveCoverImage();
  }

  Future<String?> _resolveCoverImage() async {
    final id = widget.product.id;
    if (_imageCache.containsKey(id)) return _imageCache[id];

    try {
      final images = await ProductService().getItemImages(itemId: id);
      if (images.isNotEmpty) {
        final path = images.first.imagePath.trim();
        if (path.isNotEmpty) {
          _imageCache[id] = path;
          return path;
        }
      }
    } catch (_) {}

    final legacyImages = widget.product.images;
    if (legacyImages.isNotEmpty && legacyImages.first.trim().isNotEmpty) {
      return legacyImages.first.trim();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme     = Theme.of(context);
    final textDir   = Directionality.of(context);
    final product   = widget.product;
    final hasDiscount = product.discountPercentage > 0;

    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Stack(
        children: [
          _CoverImage(
            product: product,
            coverFuture: _coverFuture,
            theme: theme,
          ),

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

          if (hasDiscount) ...[
            Positioned.directional(
              textDirection: textDir,
              top: 0,
              end: 0,
              child: _DiscountRibbon(
                discountPercentage: product.discountPercentage,
              ),
            ),
            Positioned.directional(
              textDirection: textDir,
              top: AppSpacing.xxl + AppSpacing.xs,
              end: AppSpacing.xs,
              child: _SavingsAmountBadge(
                savingsAmount: product.basePrice - product.finalPrice,
              ),
            ),
          ],

          Positioned.directional(
            textDirection: textDir,
            start: AppSpacing.sm,
            bottom: AppSpacing.sm,
            child: _PriceTag(product: product, theme: theme),
          ),

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

class _CoverImage extends StatelessWidget {
  const _CoverImage({
    required this.product,
    required this.coverFuture,
    required this.theme,
  });

  final ProductModel product;
  final Future<String?> coverFuture;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Hero(
        tag: 'product_${product.id}',
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg),
          ),
          child: FutureBuilder<String?>(
            future: coverFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _ImageLoadingPlaceholder(theme: theme);
              }
              final path = snapshot.data;
              if (path != null && path.isNotEmpty) {
                return CustomImage(path: path, fit: BoxFit.cover);
              }
              return _ImageErrorPlaceholder(theme: theme);
            },
          ),
        ),
      ),
    );
  }
}

class _ImageLoadingPlaceholder extends StatelessWidget {
  const _ImageLoadingPlaceholder({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: SizedBox(
        width: AppSpacing.iconMd,
        height: AppSpacing.iconMd,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _ImageErrorPlaceholder extends StatelessWidget {
  const _ImageErrorPlaceholder({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_search_rounded,
        size: AppSpacing.iconLg,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
      ),
    );
  }
}

class _WishlistButton extends StatelessWidget {
  const _WishlistButton({
    required this.isFavorite,
    required this.isToggling,
    required this.onTap,
  });

  final bool isFavorite;
  final bool isToggling;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme    = Theme.of(context);
    final diameter = (MediaQuery.sizeOf(context).width * 0.10).clamp(28.0, 40.0);
    final iconSize = diameter * 0.50;

    return Semantics(
      button: true,
      label: isFavorite ? 'Remove from wishlist' : 'Add to wishlist',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: isToggling ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            color: isFavorite
                ? AppColors.wishlistActive.withValues(alpha: 0.12)
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
              color: AppColors.wishlistActive,
            ),
          )
              : AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              key: ValueKey<bool>(isFavorite),
              color: isFavorite
                  ? AppColors.wishlistActive
                  : theme.colorScheme.onSurface,
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }
}

class _DiscountRibbon extends StatelessWidget {
  const _DiscountRibbon({required this.discountPercentage});

  final int discountPercentage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ClipPath(
      clipper: _RibbonClipper(),
      child: Container(
        width: AppSpacing.ribbonSize,
        height: AppSpacing.ribbonSize,
        color: AppColors.saleBadge,
        alignment: const Alignment(0, -0.3),
        child: Text(
          l10n.productDiscountPercent(discountPercentage),
          textAlign: TextAlign.center,
          style: AppTextStyles.discountRibbon,
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

class _SavingsAmountBadge extends StatelessWidget {
  const _SavingsAmountBadge({required this.savingsAmount});

  final double savingsAmount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.priceGreen,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        boxShadow: [
          BoxShadow(
            color: AppColors.priceGreen.withValues(alpha: 0.35),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        l10n.productSavingsShort(savingsAmount.toStringAsFixed(2)),
        style: AppTextStyles.savingsBadge,
      ),
    );
  }
}

class _PriceTag extends StatelessWidget {
  const _PriceTag({required this.product, required this.theme});

  final ProductModel product;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final hasDiscount = product.discountPercentage > 0;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs + 1,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.finalPrice.toStringAsFixed(2),
            style: AppTextStyles.priceLabel.copyWith(
              color: AppColors.priceGreen,
            ),
          ),
          if (hasDiscount)
            Text(
              product.basePrice.toStringAsFixed(2),
              style: AppTextStyles.originalPrice.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                decoration: TextDecoration.lineThrough,
                decorationColor:
                theme.colorScheme.onSurface.withValues(alpha: 0.45),
              ),
            ),
        ],
      ),
    );
  }
}

class _CartButton extends StatelessWidget {
  const _CartButton({required this.isLoading, required this.onTap});

  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme    = Theme.of(context);
    final diameter = (MediaQuery.sizeOf(context).width * 0.09).clamp(28.0, 40.0);
    final iconSize = diameter * 0.48;
    final l10n = AppLocalizations.of(context);

    return Semantics(
      button: true,
      label: l10n.addToCart,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          customBorder: const CircleBorder(),
          splashColor: AppColors.primary.withValues(alpha: 0.18),
          highlightColor: AppColors.primary.withValues(alpha: 0.10),
          child: Ink(
            width: diameter,
            height: diameter,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                width: iconSize * 0.75,
                height: iconSize * 0.75,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
                  : Icon(
                Icons.shopping_cart_outlined,
                size: iconSize,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}