import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../config/app_constants.dart';
import '../design/app_colors.dart';
import '../design/app_spacing.dart';
import '../design/app_text_styles.dart';
import '../l10n/l10n.dart';
import '../model/product.dart';
import '../shared/widgets/app_button.dart';
import '../shared/widgets/app_image.dart';
import '../shared/widgets/quantity_stepper.dart';
import '../themes/theme.dart';

class ProductDetailsPage extends StatefulWidget {
  final Product product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late PageController _imageController;
  int _currentImageIndex = 0;
  String? _selectedSize;
  String? _selectedColor;
  int _quantity = 1;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _imageController = PageController();
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageCarousel(),
                Padding(
                  padding: AppTheme.padding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProductInfo(),
                      const SizedBox(height: AppSpacing.xxl),
                      _buildRatingSection(),
                      const SizedBox(height: AppSpacing.xxl),
                      _buildPriceSection(),
                      const SizedBox(height: AppSpacing.xxl),
                      _buildSizeSelector(),
                      const SizedBox(height: AppSpacing.lg),
                      _buildColorSelector(),
                      const SizedBox(height: AppSpacing.xxl),
                      _buildQuantitySection(),
                      const SizedBox(height: AppSpacing.xxl),
                      _buildShippingInfo(),
                      const SizedBox(height: AppSpacing.xxl),
                      _buildDescriptionSection(),
                      const SizedBox(height: AppSpacing.hero),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                IconButton(
                  icon: Icon(
                    widget.product.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: widget.product.isFavorite
                        ? AppColors.error
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                  onPressed: () {
                    setState(() {
                      widget.product.isFavorite = !widget.product.isFavorite;
                    });
                  },
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: AppSpacing.insetsLg,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neutral300.withOpacity(0.6),
                    blurRadius: AppSpacing.jumbo,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.l10n.productTotalPrice,
                          style: AppTextStyles.bodySmall(context),
                        ),
                        Text(
                          '\$${(widget.product.finalPrice * _quantity).toStringAsFixed(2)}',
                          style: AppTextStyles.titleLarge(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      label: context.l10n.productAddToCart,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              context.l10n.productAddedToCart(
                                widget.product.name,
                              ),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    return Stack(
      children: [
        Container(
          height: AppSpacing.imageHero,
          color: Theme.of(context).colorScheme.surface,
          child: PageView.builder(
            controller: _imageController,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemCount: widget.product.images.length,
            itemBuilder: (context, index) {
              return Hero(
                tag: 'product_${widget.product.id}',
                child: AppImage(
                  path: widget.product.images[index],
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: AppSpacing.md,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.product.images.length,
              (index) => Container(
                width: _currentImageIndex == index
                    ? AppSpacing.xxl
                    : AppSpacing.sm,
                height: AppSpacing.sm,
                margin: AppSpacing.symmetric(horizontal: AppSpacing.xs),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  color: _currentImageIndex == index
                      ? AppColors.primary
                      : Theme.of(context).colorScheme.surface.withOpacity(0.6),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.product.name,
          style: AppTextStyles.headlineSmall(context),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          widget.product.category,
          style: AppTextStyles.bodySmall(context),
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            5,
            (index) => Icon(
              index < widget.product.rating.toInt()
                  ? Icons.star
                  : Icons.star_border,
              size: AppSpacing.iconSm,
              color: AppColors.accentYellow,
            ),
          ),
        ),
        Text(
          '${widget.product.rating}',
          style: AppTextStyles.labelLarge(context),
        ),
        Text(
          context.l10n.productReviews(widget.product.reviewCount),
          style: AppTextStyles.bodySmall(context),
        ),
        Text(
          context.l10n.productSold(widget.product.soldCount),
          style: AppTextStyles.bodySmall(context)
              .copyWith(color: AppColors.accentOrange),
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '\$${widget.product.finalPrice.toStringAsFixed(2)}',
              style: AppTextStyles.headlineLarge(context)
                  .copyWith(color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            if (widget.product.discountPrice != null) ...[
              Text(
                '\$${widget.product.price.toStringAsFixed(2)}',
                style: AppTextStyles.bodyMedium(context).copyWith(
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Container(
                padding: AppSpacing.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentOrange,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(
                  '-${widget.product.discountPercentage}%',
                  style: AppTextStyles.labelSmall(context)
                      .copyWith(color: Colors.white),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: AppSpacing.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.successSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Text(
            context.l10n.productFreeShipping,
            style: AppTextStyles.labelSmall(context)
                .copyWith(color: AppColors.success),
          ),
        ),
      ],
    );
  }

  Widget _buildSizeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.productSize, style: AppTextStyles.titleMedium(context)),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: widget.product.sizes.map((size) {
            final isSelected = _selectedSize == size;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSize = size;
                });
              },
              child: Container(
                padding: AppSpacing.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : Theme.of(context).dividerColor,
                    width:
                        isSelected ? AppSpacing.borderThick : AppSpacing.borderThin,
                  ),
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.transparent,
                ),
                child: Text(
                  size,
                  style: isSelected
                      ? AppTextStyles.strong(
                          context,
                          AppTextStyles.bodyMedium(context)
                              .copyWith(color: AppColors.primary),
                        )
                      : AppTextStyles.bodyMedium(context),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.productColor, style: AppTextStyles.titleMedium(context)),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: widget.product.colors.map((color) {
            final isSelected = _selectedColor == color;
            final colorMap = {
              'Black': AppColors.chipBlack,
              'White': AppColors.chipWhite,
              'Red': AppColors.chipRed,
              'Blue': AppColors.chipBlue,
              'Green': AppColors.chipGreen,
              'Yellow': AppColors.chipYellow,
              'Gray': AppColors.chipGray,
              'Navy': AppColors.chipNavy,
              'Brown': AppColors.chipBrown,
            };
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = color;
                });
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: AppSpacing.buttonMd,
                    height: AppSpacing.buttonMd,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorMap[color] ?? AppColors.neutral500,
                      border: isSelected
                          ? Border.all(
                              color: AppColors.primary,
                              width: AppSpacing.borderHeavy,
                            )
                          : null,
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check,
                      color: AppColors.white,
                      size: AppSpacing.iconLg,
                    ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuantitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.productQuantity,
          style: AppTextStyles.titleMedium(context),
        ),
        const SizedBox(height: AppSpacing.md),
        QuantityStepper(
          value: _quantity,
          onDecrement: _quantity > 1
              ? () {
                  setState(() {
                    _quantity--;
                  });
                }
              : null,
          onIncrement: () {
            setState(() {
              _quantity++;
            });
          },
        ),
      ],
    );
  }

  Widget _buildShippingInfo() {
    final locale = Localizations.localeOf(context).toString();
    final formatter = DateFormat.yMMMd(locale);
    final startDate = formatter.format(
      DateTime.now().add(const Duration(days: AppConstants.deliveryStartDays)),
    );
    final endDate = formatter.format(
      DateTime.now().add(const Duration(days: AppConstants.deliveryEndDays)),
    );
    return Container(
      padding: AppSpacing.insetsMd,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_shipping, color: AppColors.primary),
              const SizedBox(width: AppSpacing.md),
              Text(
                context.l10n.productDeliveryEstimate,
                style: AppTextStyles.titleSmall(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.l10n.productDeliveryWindow(startDate, endDate),
            style: AppTextStyles.bodySmall(context),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Icon(Icons.assignment_return, color: AppColors.primary),
              const SizedBox(width: AppSpacing.md),
              Text(
                context.l10n.productReturnsTitle,
                style: AppTextStyles.titleSmall(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.l10n.productReturnsPolicy,
            style: AppTextStyles.bodySmall(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.productDescription,
                style: AppTextStyles.titleMedium(context),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Text(
                _isExpanded
                    ? context.l10n.productShowLess
                    : context.l10n.productShowMore,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        AnimatedCrossFade(
          firstChild: Text(
            widget.product.description.length > 100
                ? '${widget.product.description.substring(0, 100)}...'
                : widget.product.description,
            style: AppTextStyles.bodySmall(context),
          ),
          secondChild: Text(
            widget.product.description,
            style: AppTextStyles.bodySmall(context),
          ),
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }
}
