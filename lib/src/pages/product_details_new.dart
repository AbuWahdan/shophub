import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  bool _isExpanded = false;
  bool _isLoadingItemImages = false;
  String? _itemImagesError;
  List<ApiItemImage> _itemImages = const [];
  List<ApiProductVariant> _drawerVariants = const [];
  bool _isAddingToCart = false;
  List<ApiProductVariant> get _variants =>
      _drawerVariants.isNotEmpty ? _drawerVariants : widget.product.details;

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
    _loadDrawerVariants();
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

  Future<void> _loadDrawerVariants() async {
    try {
      final rows = await _productService.getItemDetailsRows(
        itemId: widget.product.id,
      );
      if (!mounted || rows.isEmpty) return;
      final variants = rows
          .map(
            (row) => ApiProductVariant(
              detId: row.detId,
              brand: row.brand,
              color: row.color,
              itemSize: row.itemSize.toString(),
              discount: row.discount,
              itemPrice: row.itemPrice,
              itemQty: row.itemQty,
            ),
          )
          .toList();
      setState(() {
        _drawerVariants = variants;
        if (variants.isNotEmpty) {
          _selectedDetId = variants.first.detId;
          _selectedSize = variants.first.itemSize;
          _selectedColor = variants.first.color;
        }
      });
    } catch (_) {
      // Keep fallback variants from grouped product if details rows fail.
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
    final authState = context.watch<AuthState>();
    final isAuthLoading = authState.isInitializing || !authState.isInitialized;
    final bottomActionHeight = AppSpacing.buttonMd + (AppSpacing.lg * 2);
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
                      _buildDescriptionSection(),
                      SizedBox(height: bottomActionHeight),
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
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
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
          child: AppButton(
            label: context.l10n.productAddToCart,
            leading: (_isAddingToCart || isAuthLoading)
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            onPressed: (_isAddingToCart || isAuthLoading)
                ? null
                : _openAddToCartSheet,
          ),
        ),
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

  Future<void> _openAddToCartSheet() async {
    if (_variants.isEmpty) {
      AppSnackBar.show(
        context,
        message: 'No variants available for this product.',
        type: AppSnackBarType.warning,
      );
      return;
    }
    if (kDebugMode) {
      for (final variant in _variants) {
        debugPrint(
          '[ProductDetails][DrawerVariant] detId=${variant.detId} color=${variant.color} brand=${variant.brand} size=${variant.itemSize} price=${variant.itemPrice} discount=${variant.discount} qty=${variant.itemQty}',
        );
      }
    }
    final selection = await showModalBottomSheet<_AddToCartSelection>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: true,
      showDragHandle: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return _VariantBottomSheet(
          variants: _variants,
          initialDetId: _selectedDetId > 0
              ? _selectedDetId
              : _variants.first.detId,
          onConfirm: (selected, qty) =>
              Navigator.of(context).pop(_AddToCartSelection(selected, qty)),
        );
      },
    );
    if (!mounted || selection == null) return;
    final variant = selection.variant;
    _selectedDetId = variant.detId;
    _selectedSize = variant.itemSize;
    _selectedColor = variant.color;
    await _addToCart(variant: variant, qty: selection.qty);
  }

  Future<void> _addToCart({
    required ApiProductVariant variant,
    required int qty,
  }) async {
    final authState = context.read<AuthState>();
    await authState.ensureInitialized();
    if (!mounted) return;
    final username = authState.user?.username.trim() ?? '';
    if (username.isEmpty) {
      AppSnackBar.show(
        context,
        message: context.l10n.productAccountUnavailable,
        type: AppSnackBarType.error,
      );
      return;
    }
    if (variant.itemQty <= 0) {
      AppSnackBar.show(
        context,
        message: 'Selected variant is out of stock.',
        type: AppSnackBarType.warning,
      );
      return;
    }

    final itemDetId = variant.detId > 0
        ? variant.detId
        : widget.product.resolveDetId(
            size: variant.itemSize,
            color: variant.color,
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
      _selectedSize = variant.itemSize;
      _selectedColor = variant.color;
      _selectedDetId = itemDetId;
    });

    try {
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
        size: variant.itemSize.trim().isEmpty ? 'Default' : variant.itemSize,
        color: variant.color.trim().isEmpty ? 'Default' : variant.color,
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

class _AddToCartSelection {
  const _AddToCartSelection(this.variant, this.qty);

  final ApiProductVariant variant;
  final int qty;
}

class _VariantBottomSheet extends StatefulWidget {
  const _VariantBottomSheet({
    required this.variants,
    required this.initialDetId,
    required this.onConfirm,
  });

  final List<ApiProductVariant> variants;
  final int initialDetId;
  final void Function(ApiProductVariant variant, int qty) onConfirm;

  @override
  State<_VariantBottomSheet> createState() => _VariantBottomSheetState();
}

class _VariantBottomSheetState extends State<_VariantBottomSheet> {
  late ApiProductVariant _selected;
  int _qty = 1;

  bool _hasMeaningfulValue(String? value) {
    final normalized = (value ?? '').trim().toLowerCase();
    return normalized.isNotEmpty &&
        normalized != '0' &&
        normalized != 'null' &&
        normalized != 'n/a';
  }

  @override
  void initState() {
    super.initState();
    _selected = widget.variants.firstWhere(
      (v) => v.detId == widget.initialDetId,
      orElse: () => widget.variants.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Select Variant', style: AppTextStyles.titleMedium(context)),
          const SizedBox(height: AppSpacing.sm),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: widget.variants.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final variant = widget.variants[index];
                final isSelected = variant.detId == _selected.detId;
                final hasDiscount = variant.discount > 0;
                final discounted =
                    variant.itemPrice * (1 - (variant.discount / 100));
                final showColor = _hasMeaningfulValue(variant.color);
                final showBrand = _hasMeaningfulValue(variant.brand);
                final showSize = _hasMeaningfulValue(variant.itemSize);
                final showDefaultVariant =
                    !showColor && !showBrand && !showSize;
                return InkWell(
                  onTap: () => setState(() {
                    _selected = variant;
                    if (_qty > variant.itemQty && variant.itemQty > 0) {
                      _qty = variant.itemQty;
                    }
                  }),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
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
                              if (showDefaultVariant)
                                Text(
                                  'Default Variant',
                                  style: AppTextStyles.labelLarge(context),
                                ),
                              if (showColor)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.xs,
                                  ),
                                  child: Text(
                                    'Color: ${variant.color.trim()}',
                                    style: AppTextStyles.bodySmall(context),
                                  ),
                                ),
                              if (showBrand)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.xs,
                                  ),
                                  child: Text(
                                    'Brand: ${variant.brand.trim()}',
                                    style: AppTextStyles.bodySmall(context),
                                  ),
                                ),
                              if (showSize)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.xs,
                                  ),
                                  child: Text(
                                    'Size: ${variant.itemSize.trim()}',
                                    style: AppTextStyles.bodySmall(context),
                                  ),
                                ),
                              const SizedBox(height: AppSpacing.xs),
                              Wrap(
                                spacing: AppSpacing.sm,
                                children: [
                                  if (variant.itemPrice > 0)
                                    Text(
                                      '\$${(hasDiscount ? discounted : variant.itemPrice).toStringAsFixed(2)}',
                                      style: AppTextStyles.labelLarge(
                                        context,
                                      ).copyWith(color: AppColors.primary),
                                    ),
                                  if (hasDiscount)
                                    Text(
                                      '\$${variant.itemPrice.toStringAsFixed(2)}',
                                      style: AppTextStyles.bodySmall(context)
                                          .copyWith(
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Text('Quantity', style: AppTextStyles.titleSmall(context)),
              const SizedBox(width: AppSpacing.md),
              IconButton(
                onPressed: _qty > 1 ? () => setState(() => _qty--) : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text(_qty.toString(), style: AppTextStyles.labelLarge(context)),
              IconButton(
                onPressed: (_selected.itemQty <= 0 || _qty >= _selected.itemQty)
                    ? null
                    : () => setState(() => _qty++),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: context.l10n.productAddToCart,
            onPressed: _selected.itemQty <= 0
                ? null
                : () => widget.onConfirm(_selected, _qty),
          ),
        ],
      ),
    );
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
