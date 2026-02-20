import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../config/app_constants.dart';
import '../config/route.dart';
import '../config/ui_text.dart';
import '../design/app_colors.dart';
import '../design/app_spacing.dart';
import '../design/app_text_styles.dart';
import '../l10n/l10n.dart';
import '../model/data.dart';
import '../model/product_api.dart';
import '../model/cart_api.dart';
import '../services/product_service.dart';
import '../shared/widgets/app_button.dart';
import '../shared/widgets/app_image.dart';
import '../shared/widgets/app_snackbar.dart';
import '../state/auth_state.dart';
import '../themes/theme.dart';

class ProductDetailsPage extends StatefulWidget {
  final ApiProduct product;
  final String? initialSize;
  final String? initialColor;
  final int? initialDetId;

  const ProductDetailsPage({
    super.key,
    required this.product,
    this.initialSize,
    this.initialColor,
    this.initialDetId,
  });

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  final ProductService _productService = ProductService();
  late PageController _imageController;
  int _currentImageIndex = 0;
  String? _selectedSize;
  String? _selectedColor;
  int _selectedDetId = 0;
  int _quantity = 1;
  bool _isExpanded = false;
  bool _isLoadingItemImages = false;
  String? _itemImagesError;
  List<ApiItemImage> _itemImages = const [];
  bool _isAddingToCart = false;
  List<ApiProductVariant> get _variants => widget.product.details;
  ApiProductVariant? get _selectedVariant {
    if (_variants.isEmpty) return null;
    for (final variant in _variants) {
      if (variant.detId == _selectedDetId && _selectedDetId > 0) {
        return variant;
      }
    }
    for (final variant in _variants) {
      if (variant.itemSize == _selectedSize &&
          variant.color == _selectedColor) {
        return variant;
      }
    }
    return _variants.first;
  }

  double get _selectedBasePrice =>
      _selectedVariant?.itemPrice ?? widget.product.price;
  double get _selectedDiscountPercent =>
      _selectedVariant?.discount ??
      widget.product.discountPercentage.toDouble();
  double get _selectedFinalPrice {
    final discount = _selectedDiscountPercent;
    if (discount <= 0) return _selectedBasePrice;
    final discounted = _selectedBasePrice * (1 - (discount / 100));
    return discounted < 0 ? 0 : discounted;
  }

  int get _selectedAvailableQty =>
      _selectedVariant?.itemQty ?? widget.product.itemQty;

  @override
  void initState() {
    super.initState();
    _imageController = PageController();
    _selectedSize =
        widget.initialSize ??
        (widget.product.sizes.isNotEmpty ? widget.product.sizes.first : null);
    _selectedColor =
        widget.initialColor ??
        (widget.product.colors.isNotEmpty ? widget.product.colors.first : null);
    if (_variants.isNotEmpty) {
      final firstVariant = _variants.first;
      _selectedSize = firstVariant.itemSize;
      _selectedColor = firstVariant.color;
      _selectedDetId = firstVariant.detId;
    } else {
      final selectedSize = _selectedSize ?? '';
      final selectedColor = _selectedColor ?? '';
      _selectedDetId = widget.product.resolveDetId(
        size: selectedSize,
        color: selectedColor,
        fallback: widget.initialDetId ?? widget.product.detId,
      );
    }
    AppData.syncFavoriteFor(widget.product);
    _loadItemImages();
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  List<String> get _displayImages {
    if (_itemImages.isNotEmpty) {
      return _itemImages.map((image) => image.imagePath).toList();
    }
    return widget.product.imagesForColor(_selectedColor);
  }

  Future<void> _loadItemImages() async {
    setState(() {
      _isLoadingItemImages = true;
      _itemImagesError = null;
    });
    try {
      final images = await _productService.loadItemImages(
        itemId: widget.product.id,
      );
      if (!mounted) return;
      setState(() {
        _itemImages = images;
      });
    } on ProductException catch (error) {
      if (!mounted) return;
      setState(() {
        _itemImagesError = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _itemImagesError = 'Failed to load item images.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingItemImages = false;
        });
      }
    }
  }

  void _resetImageCarousel() {
    if (_currentImageIndex != 0) {
      setState(() {
        _currentImageIndex = 0;
      });
    }
    if (_imageController.hasClients) {
      _imageController.jumpToPage(0);
    }
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
                      const SizedBox(height: AppSpacing.lg),
                      _buildVariantsSection(),
                      const SizedBox(height: AppSpacing.xxl),
                      _buildCommentsSection(),
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
                      AppData.toggleFavorite(widget.product);
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
                      color: AppColors.neutral300.withValues(alpha: 0.6),
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
                            '\$${(_selectedFinalPrice * _quantity).toStringAsFixed(2)}',
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
                        leading: _isAddingToCart
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : null,
                        onPressed: _isAddingToCart ? null : _onAddToCartPressed,
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
    final images = _displayImages;
    return Column(
      children: [
        Stack(
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
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _openImageViewer(images, index),
                    child: Hero(
                      tag: 'product_${widget.product.id}',
                      child: AppImage(path: images[index], fit: BoxFit.cover),
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
                  images.length,
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
                          : Theme.of(
                              context,
                            ).colorScheme.surface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (images.length > 1)
          Padding(
            padding: AppSpacing.symmetric(vertical: AppSpacing.md),
            child: SizedBox(
              height: AppSpacing.imageSm,
              child: ListView.separated(
                padding: AppSpacing.horizontal(AppSpacing.lg),
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final isActive = _currentImageIndex == index;
                  return GestureDetector(
                    onTap: () {
                      _imageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    onDoubleTap: () => _openImageViewer(images, index),
                    child: Container(
                      padding: AppSpacing.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                        border: Border.all(
                          color: isActive
                              ? AppColors.primary
                              : Theme.of(context).dividerColor,
                          width: isActive
                              ? AppSpacing.borderThick
                              : AppSpacing.borderThin,
                        ),
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      child: AppImage(
                        path: images[index],
                        width: AppSpacing.imageSm,
                        height: AppSpacing.imageSm,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        if (_isLoadingItemImages)
          const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.md),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        if (_itemImagesError != null && _itemImagesError!.trim().isNotEmpty)
          Padding(
            padding: AppSpacing.horizontal(AppSpacing.lg),
            child: Text(
              _itemImagesError!,
              style: AppTextStyles.bodySmall(
                context,
              ).copyWith(color: AppColors.error),
            ),
          ),
      ],
    );
  }

  void _openImageViewer(List<String> images, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            _ProductImageViewer(images: images, initialIndex: initialIndex),
      ),
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
        Text(widget.product.category, style: AppTextStyles.bodySmall(context)),
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
          style: AppTextStyles.bodySmall(
            context,
          ).copyWith(color: AppColors.accentOrange),
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    final discount = _selectedDiscountPercent;
    final hasDiscount = discount > 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '\$${_selectedFinalPrice.toStringAsFixed(2)}',
              style: AppTextStyles.headlineLarge(
                context,
              ).copyWith(color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            if (hasDiscount) ...[
              Text(
                '\$${_selectedBasePrice.toStringAsFixed(2)}',
                style: AppTextStyles.bodyMedium(
                  context,
                ).copyWith(decoration: TextDecoration.lineThrough),
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
                  '-${discount.toStringAsFixed(discount == discount.roundToDouble() ? 0 : 1)}%',
                  style: AppTextStyles.labelSmall(
                    context,
                  ).copyWith(color: Colors.white),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          context.l10n.productAvailableStock(_selectedAvailableQty),
          style: AppTextStyles.bodySmall(
            context,
          ).copyWith(color: AppColors.accentOrange),
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
            style: AppTextStyles.labelSmall(
              context,
            ).copyWith(color: AppColors.success),
          ),
        ),
      ],
    );
  }

  Widget _buildVariantsSection() {
    if (_variants.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Variants', style: AppTextStyles.titleMedium(context)),
        const SizedBox(height: AppSpacing.sm),
        ..._variants.map((variant) {
          final isSelected =
              _selectedDetId > 0 && variant.detId == _selectedDetId;
          final basePrice = variant.itemPrice;
          final discount = variant.discount;
          final finalPrice = discount > 0
              ? (basePrice * (1 - (discount / 100)))
              : basePrice;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              onTap: () => _selectVariant(variant),
              child: Container(
                padding: AppSpacing.insetsMd,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : Theme.of(context).dividerColor,
                    width: isSelected
                        ? AppSpacing.borderThick
                        : AppSpacing.borderThin,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${variant.brand} | ${variant.color} | ${variant.itemSize}',
                            style: AppTextStyles.labelLarge(context),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Price: \$${finalPrice.toStringAsFixed(2)}'
                            '${discount > 0 ? ' (Discount ${discount.toStringAsFixed(discount == discount.roundToDouble() ? 0 : 1)}%)' : ''}',
                            style: AppTextStyles.bodySmall(context),
                          ),
                          Text(
                            context.l10n.productAvailableStock(variant.itemQty),
                            style: AppTextStyles.bodySmall(
                              context,
                            ).copyWith(color: AppColors.accentOrange),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle, color: AppColors.primary),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Text(
              context.l10n.productQuantity,
              style: AppTextStyles.titleSmall(context),
            ),
            const SizedBox(width: AppSpacing.md),
            IconButton(
              onPressed: _quantity > 1
                  ? () => _changeQuantity(_quantity - 1)
                  : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text(
              _quantity.toString(),
              style: AppTextStyles.labelLarge(context),
            ),
            IconButton(
              onPressed:
                  _quantity < AppConstants.checkoutMaxQuantity &&
                      _quantity < _selectedAvailableQty
                  ? () => _changeQuantity(_quantity + 1)
                  : null,
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ],
    );
  }

  void _selectVariant(ApiProductVariant variant) {
    setState(() {
      _selectedDetId = variant.detId;
      _selectedSize = variant.itemSize;
      _selectedColor = variant.color;
      if (variant.itemQty > 0 && _quantity > variant.itemQty) {
        _quantity = variant.itemQty;
      }
      if (_quantity < 1) {
        _quantity = 1;
      }
    });
    _resetImageCarousel();
  }

  void _changeQuantity(int nextValue) {
    if (nextValue < 1) return;
    final maxAllowed = _selectedAvailableQty > 0
        ? _selectedAvailableQty
        : AppConstants.checkoutMaxQuantity;
    if (nextValue > maxAllowed) return;
    setState(() {
      _quantity = nextValue;
    });
  }

  Widget _buildCommentsSection() {
    final comments = AppData.commentsForProduct(widget.product.id);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              UiText.commentsTitle,
              style: AppTextStyles.titleMedium(context),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.productComments,
                  arguments: {
                    'productId': widget.product.id,
                    'productName': widget.product.name,
                  },
                );
              },
              child: const Text(UiText.commentsViewAll),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (comments.isEmpty)
          Text(UiText.commentsEmpty, style: AppTextStyles.bodySmall(context))
        else
          ...comments
              .take(2)
              .map(
                (comment) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.productComments,
                      arguments: {
                        'productId': widget.product.id,
                        'productName': widget.product.name,
                      },
                    );
                  },
                  title: Text(comment.userName),
                  subtitle: Text(
                    comment.comment,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: AppColors.accentYellow),
                      Text(comment.rating.toString()),
                    ],
                  ),
                ),
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

  Future<void> _onAddToCartPressed() async {
    final authState = context.read<AuthState>();
    final username = authState.user?.username.trim() ?? '';
    if (username.isEmpty) {
      AppSnackBar.show(
        context,
        message: context.l10n.productAccountUnavailable,
        type: AppSnackBarType.error,
      );
      return;
    }
    if (_selectedAvailableQty <= 0) {
      AppSnackBar.show(
        context,
        message: 'Selected variant is out of stock.',
        type: AppSnackBarType.warning,
      );
      return;
    }

    final activeVariant = _selectedVariant;
    final itemDetId = (activeVariant?.detId ?? _selectedDetId) > 0
        ? (activeVariant?.detId ?? _selectedDetId)
        : widget.product.resolveDetId(
            size: _selectedSize ?? '',
            color: _selectedColor ?? '',
            fallback: widget.product.detId,
          );
    if (itemDetId <= 0) {
      AppSnackBar.show(
        context,
        message: 'Unable to determine selected product variant.',
        type: AppSnackBarType.error,
      );
      return;
    }

    setState(() {
      _isAddingToCart = true;
      _selectedSize = activeVariant?.itemSize ?? _selectedSize;
      _selectedColor = activeVariant?.color ?? _selectedColor;
      _selectedDetId = itemDetId;
    });

    try {
      final qty = _quantity <= 0 ? 1 : _quantity;
      await _productService.addItemToCart(
        AddItemToCartRequest(
          itemId: widget.product.id,
          itemDetId: itemDetId,
          username: username,
          itemQty: qty,
        ),
      );

      if (!mounted) return;
      _resetImageCarousel();
      AppData.addToCart(
        product: widget.product,
        quantity: qty,
        size: _selectedSize ?? 'Default',
        color: _selectedColor ?? 'Default',
        detId: itemDetId,
      );
      AppSnackBar.show(
        context,
        message: context.l10n.productAddedToCart(widget.product.name),
        type: AppSnackBarType.success,
      );
    } on ProductException catch (error) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: error.message,
        type: AppSnackBarType.error,
      );
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: 'Failed to add item to cart.',
        type: AppSnackBarType.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }
}

class _ProductImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _ProductImageViewer({required this.images, required this.initialIndex});

  @override
  State<_ProductImageViewer> createState() => _ProductImageViewerState();
}

class _ProductImageViewerState extends State<_ProductImageViewer> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_index + 1}/${widget.images.length}'),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.images.length,
        onPageChanged: (value) {
          setState(() {
            _index = value;
          });
        },
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Center(
              child: AppImage(path: widget.images[index], fit: BoxFit.contain),
            ),
          );
        },
      ),
    );
  }
}
