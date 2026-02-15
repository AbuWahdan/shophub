import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../config/app_constants.dart';
import '../config/route.dart';
import '../config/ui_text.dart';
import '../design/app_colors.dart';
import '../design/app_spacing.dart';
import '../design/app_text_styles.dart';
import '../l10n/l10n.dart';
import '../model/data.dart';
import '../model/product_api.dart';
import '../shared/widgets/app_button.dart';
import '../shared/widgets/app_image.dart';
import '../shared/widgets/app_snackbar.dart';
import '../themes/theme.dart';

class ProductDetailsPage extends StatefulWidget {
  final ApiProduct product;
  final String? initialSize;
  final String? initialColor;

  const ProductDetailsPage({
    super.key,
    required this.product,
    this.initialSize,
    this.initialColor,
  });

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
    _selectedSize =
        widget.initialSize ??
        (widget.product.sizes.isNotEmpty ? widget.product.sizes.first : null);
    _selectedColor =
        widget.initialColor ??
        (widget.product.colors.isNotEmpty ? widget.product.colors.first : null);
    AppData.syncFavoriteFor(widget.product);
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  List<String> get _displayImages =>
      widget.product.imagesForColor(_selectedColor);

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
                        onPressed: () async {
                          final selection = await _showVariantPickerSheet();
                          if (!mounted || selection == null) return;
                          setState(() {
                            _selectedSize = selection.size;
                            _selectedColor = selection.color;
                            _quantity = selection.quantity;
                          });
                          _resetImageCarousel();
                          AppData.addToCart(
                            product: widget.product,
                            quantity: selection.quantity,
                            size: selection.size,
                            color: selection.color,
                          );
                          if (!mounted) return;
                          AppSnackBar.show(
                            context,
                            message: context.l10n.productAddedToCart(
                              widget.product.name,
                            ),
                            type: AppSnackBarType.success,
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
                            ).colorScheme.surface.withOpacity(0.6),
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
                separatorBuilder: (_, __) =>
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '\$${widget.product.finalPrice.toStringAsFixed(2)}',
              style: AppTextStyles.headlineLarge(
                context,
              ).copyWith(color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            if (widget.product.discountPrice != null) ...[
              Text(
                '\$${widget.product.price.toStringAsFixed(2)}',
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
                  '-${widget.product.discountPercentage}%',
                  style: AppTextStyles.labelSmall(
                    context,
                  ).copyWith(color: Colors.white),
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
            style: AppTextStyles.labelSmall(
              context,
            ).copyWith(color: AppColors.success),
          ),
        ),
      ],
    );
  }

  Future<_VariantSelection?> _showVariantPickerSheet() async {
    String? selectedSize = _selectedSize;
    String? selectedColor = _selectedColor;
    int quantity = _quantity;

    return showModalBottomSheet<_VariantSelection>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final availableStock = selectedSize != null && selectedColor != null
                ? widget.product.stockFor(selectedSize!, selectedColor!)
                : null;
            final quantityItems = List<int>.generate(
              AppConstants.checkoutMaxQuantity,
              (index) => index + 1,
            );
            final canSubmit =
                selectedSize != null && selectedColor != null && quantity >= 1;

            return Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                top: AppSpacing.lg,
                bottom:
                    MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.productSize,
                    style: AppTextStyles.titleMedium(context),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<String>(
                    value: selectedSize,
                    items: widget.product.sizes
                        .map(
                          (size) => DropdownMenuItem<String>(
                            value: size,
                            child: Text(size),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setModalState(() {
                        selectedSize = value;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    context.l10n.productColor,
                    style: AppTextStyles.titleMedium(context),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<String>(
                    value: selectedColor,
                    items: widget.product.colors
                        .map(
                          (color) => DropdownMenuItem<String>(
                            value: color,
                            child: Row(
                              children: [
                                Container(
                                  width: AppSpacing.iconSm,
                                  height: AppSpacing.iconSm,
                                  decoration: BoxDecoration(
                                    color: _colorForName(color),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Theme.of(context).dividerColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(color),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setModalState(() {
                        selectedColor = value;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    context.l10n.productQuantity,
                    style: AppTextStyles.titleMedium(context),
                  ),
                  if (availableStock != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      context.l10n.productAvailableStock(availableStock),
                      style: AppTextStyles.bodySmall(
                        context,
                      ).copyWith(color: AppColors.accentOrange),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<int>(
                    value: quantity,
                    items: quantityItems
                        .map(
                          (qty) => DropdownMenuItem<int>(
                            value: qty,
                            child: Text(qty.toString()),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setModalState(() {
                        quantity = value;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: context.l10n.productAddToCart,
                    onPressed: canSubmit
                        ? () {
                            Navigator.pop(
                              context,
                              _VariantSelection(
                                size: selectedSize!,
                                color: selectedColor!,
                                quantity: quantity,
                              ),
                            );
                          }
                        : null,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _colorForName(String colorName) {
    const colorMap = <String, Color>{
      'Black': AppColors.chipBlack,
      'White': AppColors.chipWhite,
      'Red': AppColors.chipRed,
      'Blue': AppColors.chipBlue,
      'Green': AppColors.chipGreen,
      'Yellow': AppColors.chipYellow,
      'Gray': AppColors.chipGray,
      'Navy': AppColors.chipNavy,
      'Brown': AppColors.chipBrown,
      'Silver': AppColors.neutral500,
    };
    return colorMap[colorName] ?? AppColors.neutral500;
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
}

class _VariantSelection {
  final String size;
  final String color;
  final int quantity;

  const _VariantSelection({
    required this.size,
    required this.color,
    required this.quantity,
  });
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
