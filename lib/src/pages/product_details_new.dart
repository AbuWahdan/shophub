import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/utils/image_converter.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../data/repositories/comment_repository.dart';
import '../../features/products/models/product_image_model.dart';
import '../design/app_text_styles.dart';
import '../l10n/l10n.dart';
import '../model/comment_model.dart';
import '../model/data.dart';
import '../model/product_api.dart';
import '../model/cart_api.dart';
import '../services/product_service.dart';
import '../shared/widgets/add_to_cart_bottom_sheet.dart';
import '../shared/widgets/app_image.dart';
import '../shared/widgets/app_snackbar.dart';
import '../state/auth_state.dart';
import '../state/review_refresh_notifier.dart';
import '../state/wishlist_state.dart';
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
  late final CommentRepository _commentRepository;
  late PageController _imageController;
  late Future<List<CommentModel>> _commentsFuture;
  int _currentImageIndex = 0;
  String? _selectedSize;
  String? _selectedColor;
  int _selectedDetId = 0;
  bool _isExpanded = false;
  bool _isLoadingItemImages = false;
  String? _itemImagesError;
  List<ProductImageModel> _itemImages = const [];
  List<ApiProductVariant> _drawerVariants = const [];
  bool _isAddingToCart = false;
  List<ApiProductVariant> get _variants =>
      _drawerVariants.isNotEmpty ? _drawerVariants : widget.product.details;

  @override
  void initState() {
    super.initState();
    _commentRepository = Get.find<CommentRepository>();
    _imageController = PageController();
    _commentsFuture = _commentRepository.getItemComments(widget.product.id);
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
    _loadItemImages();
    _loadDrawerVariants();
    ReviewRefreshNotifier.updatedItemId.addListener(_handleReviewRefresh);
  }

  @override
  void dispose() {
    ReviewRefreshNotifier.updatedItemId.removeListener(_handleReviewRefresh);
    _imageController.dispose();
    super.dispose();
  }

  void _handleReviewRefresh() {
    final updatedItemId = ReviewRefreshNotifier.updatedItemId.value;
    if (updatedItemId != widget.product.id || !mounted) {
      return;
    }

    setState(() {
      _commentsFuture = _commentRepository.getItemComments(widget.product.id);
    });
  }

  bool get _hasBase64Images => _itemImages.isNotEmpty;

  List<String> get _fallbackImages =>
      widget.product.imagesForColor(_selectedColor);

  int get _imageCount =>
      _hasBase64Images ? _itemImages.length : _fallbackImages.length;

  Future<void> _loadItemImages() async {
    setState(() {
      _isLoadingItemImages = true;
      _itemImagesError = null;
    });
    try {
      final images = await _productService.getItemImagesBase64(
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
    final wishlistState = context.watch<WishlistState>();
    final isFavorite = wishlistState.isInWishlist(widget.product.id);
    final isTogglingFavorite = wishlistState.isToggling(widget.product.id);
    final bottomActionHeight = AppSpacing.buttonMd + (AppSpacing.lg * 2);
    widget.product.isFavorite = isFavorite;
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
                      const SizedBox(height: AppSpacing.xxl),
                      _buildReviewsSection(),
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
              backgroundColor: AppColors.transparent,
              elevation: 0,
              actions: [
                IconButton(
                  icon: isTogglingFavorite
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite
                              ? AppColors.error
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                  onPressed: isTogglingFavorite ? null : _handleToggleFavorite,
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
            boxShadow: const [AppShadows.topBarShadow],
          ),
          child: SizedBox(
            width: double.infinity,
            height: AppSpacing.buttonMd,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
              ),
              onPressed: (_isAddingToCart || isAuthLoading)
                  ? null
                  : _openAddToCartSheet,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isAddingToCart || isAuthLoading)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  if (_isAddingToCart || isAuthLoading)
                    const SizedBox(width: AppSpacing.sm),
                  Text(
                    context.l10n.productAddToCart,
                    style: AppTextStyles.buttonLarge.copyWith(
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    if (_imageCount == 0) {
      return Container(
        height: AppSpacing.imageHero,
        color: Theme.of(context).colorScheme.surface,
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image_outlined, size: 56),
      );
    }

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
                itemCount: _imageCount,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _openImageViewer(index),
                    child: Hero(
                      tag: 'product_${widget.product.id}',
                      child: _buildGalleryImage(index, fit: BoxFit.cover),
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
                  _imageCount,
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
        if (_imageCount > 1)
          Padding(
            padding: AppSpacing.symmetric(vertical: AppSpacing.md),
            child: SizedBox(
              height: AppSpacing.imageSm,
              child: ListView.separated(
                padding: AppSpacing.horizontal(AppSpacing.lg),
                scrollDirection: Axis.horizontal,
                itemCount: _imageCount,
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
                    onDoubleTap: () => _openImageViewer(index),
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
                      child: SizedBox(
                        width: AppSpacing.imageSm,
                        height: AppSpacing.imageSm,
                        child: _buildGalleryImage(index, fit: BoxFit.cover),
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
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
      ],
    );
  }

  Widget _buildGalleryImage(int index, {BoxFit fit = BoxFit.cover}) {
    if (_hasBase64Images) {
      final image = _itemImages[index];
      final bytes = ImageConverter.base64ToBytes(image.imageBase64);
      if (bytes != null) {
        return Image.memory(bytes, fit: fit);
      }
      if (image.imagePath.trim().isNotEmpty) {
        return AppImage(path: image.imagePath, fit: fit);
      }
      return const Center(child: Icon(Icons.broken_image_outlined));
    }

    final images = _fallbackImages;
    if (index < 0 || index >= images.length) {
      return const Center(child: Icon(Icons.broken_image_outlined));
    }
    return AppImage(path: images[index], fit: fit);
  }

  void _openImageViewer(int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ProductImageViewer(
          itemImages: _itemImages,
          fallbackImages: _fallbackImages,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.product.name,
          style: AppTextStyles.headlineSmall,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(widget.product.category, style: AppTextStyles.bodySmall),
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
        Text('${widget.product.rating}', style: AppTextStyles.labelLarge),
        Text(
          context.l10n.productReviews(widget.product.reviewCount),
          style: AppTextStyles.bodySmall,
        ),
        Text(
          context.l10n.productSold(widget.product.soldCount),
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.accentOrange,
          ),
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
                style: AppTextStyles.titleMedium,
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
            style: AppTextStyles.bodySmall,
          ),
          secondChild: Text(
            widget.product.description,
            style: AppTextStyles.bodySmall,
          ),
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }

  Widget _buildReviewsSection() {
    return FutureBuilder<List<CommentModel>>(
      future: _commentsFuture,
      builder: (context, snapshot) {
        final comments = snapshot.data ?? const <CommentModel>[];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reviews (${comments.length})',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            if (snapshot.connectionState == ConnectionState.waiting)
              Column(
                children: List.generate(
                  3,
                  (_) => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    padding: AppSpacing.insetsLg,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 120,
                          height: 14,
                          color: AppColors.surfaceVariant,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          width: 80,
                          height: 12,
                          color: AppColors.surfaceVariant,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Container(
                          width: double.infinity,
                          height: 12,
                          color: AppColors.surfaceVariant,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          height: 12,
                          color: AppColors.surfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (snapshot.hasError)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    snapshot.error.toString(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _commentsFuture = _commentRepository.getItemComments(
                          widget.product.id,
                        );
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              )
            else if (comments.isEmpty)
              const EmptyStateWidget(
                icon: Icons.rate_review_outlined,
                title: 'No reviews yet',
                subtitle:
                    'Be the first to share your experience with this product.',
              )
            else
              Column(
                children: comments
                    .map(
                      (comment) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _CommentReviewCard(comment: comment),
                      ),
                    )
                    .toList(),
              ),
          ],
        );
      },
    );
  }

  Future<void> _handleToggleFavorite() async {
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

    try {
      await context.read<WishlistState>().toggleWishlist(widget.product);
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
        message: 'Failed to update favorite.',
        type: AppSnackBarType.error,
      );
    }
  }

  Future<void> _openAddToCartSheet() async {
    if (kDebugMode) {
      for (final variant in _variants) {
        debugPrint(
          '[ProductDetails][DrawerVariant] detId=${variant.detId} color=${variant.color} brand=${variant.brand} size=${variant.itemSize} price=${variant.itemPrice} discount=${variant.discount} qty=${variant.itemQty}',
        );
      }
    }
    final selection = await showModalBottomSheet<AddToCartSelection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddToCartBottomSheet(
        product: widget.product,
        variants: _variants.isNotEmpty ? _variants : null,
        initialDetId: _selectedDetId > 0
            ? _selectedDetId
            : widget.product.detId,
      ),
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

class _CommentReviewCard extends StatelessWidget {
  final CommentModel comment;

  const _CommentReviewCard({required this.comment});

  String get _initials {
    final parts = comment.username
        .split(' ')
        .where((part) => part.trim().isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.insetsLg,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                foregroundColor: AppColors.primary,
                child: Text(_initials),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.username.isEmpty ? 'Anonymous' : comment.username,
                      style: AppTextStyles.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < comment.rating
                              ? Icons.star
                              : Icons.star_border,
                          size: AppSpacing.iconSm,
                          color: const Color(0xFFFFB800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (comment.createdAt != null)
                Text(
                  DateFormat.yMMMd().format(comment.createdAt!),
                  style: AppTextStyles.bodySmall,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(comment.comment, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}

class _ProductImageViewer extends StatefulWidget {
  final List<ProductImageModel> itemImages;
  final List<String> fallbackImages;
  final int initialIndex;

  const _ProductImageViewer({
    required this.itemImages,
    required this.fallbackImages,
    required this.initialIndex,
  });

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
    final imageCount = widget.itemImages.isNotEmpty
        ? widget.itemImages.length
        : widget.fallbackImages.length;

    return Scaffold(
      backgroundColor: AppColors.textPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.textPrimary,
        foregroundColor: AppColors.textOnPrimary,
        title: Text('${_index + 1}/$imageCount'),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: imageCount,
        onPageChanged: (value) {
          setState(() {
            _index = value;
          });
        },
        itemBuilder: (context, index) {
          Widget imageWidget;
          if (widget.itemImages.isNotEmpty) {
            final image = widget.itemImages[index];
            final bytes = ImageConverter.base64ToBytes(image.imageBase64);
            imageWidget = bytes != null
                ? Image.memory(bytes, fit: BoxFit.contain)
                : image.imagePath.trim().isNotEmpty
                ? AppImage(path: image.imagePath, fit: BoxFit.contain)
                : const Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.textOnPrimary,
                    size: 56,
                  );
          } else {
            imageWidget = AppImage(
              path: widget.fallbackImages[index],
              fit: BoxFit.contain,
            );
          }

          return InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Center(child: imageWidget),
          );
        },
      ),
    );
  }
}
