import 'package:flutter/material.dart';
import 'package:sinwar_shoping/src/config/app_images.dart';

import '../design/app_colors.dart';
import '../design/app_spacing.dart';
import '../design/app_text_styles.dart';
import '../model/product.dart';
import '../pages/product_details_new.dart';
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
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      elevation: AppSpacing.sm,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsPage(product: widget.product),
            ),
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
                    Center(
                      child: Hero(
                        tag: 'product_${widget.product.id}',
                        child: AppImage(
                          path: widget.product.images.isNotEmpty
                              ? widget.product.images.first
                              : AppImages.placeholder,
                          fit: BoxFit.cover,
                        ),
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
                            widget.product.isFavorite =
                                !widget.product.isFavorite;
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
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  if (widget.product.discountPrice != null) ...[
                    Text(
                      '\$${widget.product.finalPrice.toStringAsFixed(2)}',
                      style: AppTextStyles.labelLarge(context)
                          .copyWith(color: AppColors.primary),
                    ),
                    Text(
                      '\$${widget.product.price.toStringAsFixed(2)}',
                      style: AppTextStyles.bodySmall(context).copyWith(
                        decoration: TextDecoration.lineThrough,
                      ),
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
}
