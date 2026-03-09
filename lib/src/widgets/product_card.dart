import 'package:flutter/material.dart';
import 'package:sinwar_shoping/src/config/route.dart';

import '../design/app_colors.dart';
import '../design/app_spacing.dart';
import '../design/app_text_styles.dart';
import '../model/data.dart';
import '../model/product_api.dart';
import '../shared/widgets/app_image.dart';

class ProductCard extends StatefulWidget {
  final ApiProduct product;
  final ValueChanged<ApiProduct>? onSelected;
  const ProductCard({super.key, required this.product, this.onSelected});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
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
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      onTap: () {
                        setState(() => AppData.toggleFavorite(product));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.86),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Icon(
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
                  Wrap(
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
