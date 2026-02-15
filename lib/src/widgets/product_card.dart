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

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      elevation: AppSpacing.sm,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.productDetails,
            arguments: {'product': product},
          );
          widget.onSelected?.call(product);
        },
        child: Padding(
          padding: AppSpacing.insetsSm,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Hero(
                        tag: 'product_${product.id}',
                        child: _buildImageSlot(context),
                      ),
                    ),
                    Positioned(
                      top: AppSpacing.sm,
                      right: AppSpacing.sm,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                        onTap: () {
                          setState(() {
                            AppData.toggleFavorite(product);
                          });
                        },
                        child: Icon(
                          product.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: product.isFavorite
                              ? AppColors.error
                              : Theme.of(context).colorScheme.onSurface,
                          size: AppSpacing.iconLg,
                          shadows: const [
                            Shadow(
                              blurRadius: 6,
                              color: Colors.black54,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                product.name.isNotEmpty ? product.name : 'Unnamed Product',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium(context),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                product.description.isNotEmpty
                    ? product.description
                    : 'No description',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall(context),
              ),
              if (product.quantity > 0) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Qty: ${product.quantity}',
                  style: AppTextStyles.bodySmall(
                    context,
                  ).copyWith(color: AppColors.accentOrange),
                ),
              ],
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  if (product.discountPrice != null &&
                      product.discountPrice! > 0) ...[
                    Text(
                      '\$${product.finalPrice.toStringAsFixed(2)}',
                      style: AppTextStyles.labelLarge(
                        context,
                      ).copyWith(color: AppColors.primary),
                    ),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: AppTextStyles.bodySmall(
                        context,
                      ).copyWith(decoration: TextDecoration.lineThrough),
                    ),
                  ] else
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: AppTextStyles.labelLarge(context),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSlot(BuildContext context) {
    final product = widget.product;

    // Handle empty images
    if (product.images.isEmpty) {
      return _buildPlaceholder(context);
    }

    final path = product.images.first.trim();

    if (path.isEmpty) {
      return _buildPlaceholder(context);
    }

    return AppImage(path: path, fit: BoxFit.cover);
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        size: AppSpacing.iconXl,
        color: Theme.of(context).hintColor,
      ),
    );
  }
}
