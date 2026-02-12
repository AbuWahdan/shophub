import 'package:flutter/material.dart';
import 'package:sinwar_shoping/src/config/route.dart';

import '../design/app_colors.dart';
import '../design/app_spacing.dart';
import '../design/app_text_styles.dart';
import '../model/data.dart';
import '../model/product.dart';
import '../shared/widgets/app_image.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final ValueChanged<Product>? onSelected;
  const ProductCard({super.key, required this.product, this.onSelected});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  @override
  Widget build(BuildContext context) {
    AppData.syncFavoriteFor(widget.product);
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
            arguments: {'product': widget.product},
          );
          widget.onSelected?.call(widget.product);
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
                        tag: 'product_${widget.product.id}',
                        child: _buildImageSlot(context),
                      ),
                    ),
                    Positioned(
                      top: AppSpacing.sm,
                      right: AppSpacing.sm,
                      child: IconButton(
                        icon: Icon(
                          widget.product.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: widget.product.isFavorite
                              ? AppColors.error
                              : Theme.of(context).iconTheme.color,
                        ),
                        onPressed: () {
                          setState(() {
                            AppData.toggleFavorite(widget.product);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium(context),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                widget.product.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall(context),
              ),
              if (widget.product.quantity > 0) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Qty: ${widget.product.quantity}',
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
                  if (widget.product.discountPrice != null) ...[
                    Text(
                      '\$${widget.product.finalPrice.toStringAsFixed(2)}',
                      style: AppTextStyles.labelLarge(
                        context,
                      ).copyWith(color: AppColors.primary),
                    ),
                    Text(
                      '\$${widget.product.price.toStringAsFixed(2)}',
                      style: AppTextStyles.bodySmall(
                        context,
                      ).copyWith(decoration: TextDecoration.lineThrough),
                    ),
                  ] else
                    Text(
                      '\$${widget.product.price.toStringAsFixed(2)}',
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
    final path = widget.product.images.isNotEmpty
        ? widget.product.images.first.trim()
        : '';
    if (path.isEmpty) {
      return Container(
        color: Theme.of(context).colorScheme.surface,
        alignment: Alignment.center,
        child: Icon(
          Icons.image_outlined,
          size: AppSpacing.iconXl,
          color: Theme.of(context).hintColor,
        ),
      );
    }
    return AppImage(path: path, fit: BoxFit.cover);
  }
}
