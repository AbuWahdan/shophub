import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sinwar_shoping/presentation/products/widgets/product_details_image_carousel.dart';
import 'package:sinwar_shoping/presentation/products/widgets/product_details_info_section.dart';
import 'package:sinwar_shoping/presentation/products/widgets/product_details_variant_section.dart';

import '../../../models/cart_item_model.dart';
import '../../../models/data.dart';
import '../../../models/item_comment_model.dart';
import '../../controllers/wishlist_controller.dart';
import '../../core/config/route.dart';
import '../../core/state/auth_state.dart';
import '../../core/state/review_refresh_notifier.dart';
import '../../design/app_colors.dart';
import '../../design/app_radius.dart';
import '../../design/app_shadows.dart';
import '../../design/app_spacing.dart';
import '../../design/app_text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../models/product/product_image_model.dart';
import '../../models/product/product_model.dart';
import '../../repositories/cart_repository.dart';
import '../../repositories/comment_repository.dart';
import '../../services/product_service.dart';
import '../../widgets/custom__snack_bar/custom_snack_bar.dart';
import '../../widgets/floating_cart_icon/animated_floating_cart_icon.dart';
import '../../widgets/product_card/add_to_cart_bottom_sheet/add_to_cart_bottom_sheet.dart';
import '../../widgets/product_card/add_to_cart_bottom_sheet/widgets/product_variant_widgets.dart';
import '../../controllers/floating_cart_controller.dart';
import 'widgets/product_details_reviews_section.dart';

class ProductDetails extends StatefulWidget {
  final ProductModel product;
  final String? initialSize;
  final String? initialColor;
  final int? initialDetId;

  const ProductDetails({
    super.key,
    required this.product,
    this.initialSize,
    this.initialColor,
    this.initialDetId,
  });

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  late final CommentRepository _commentRepository;
  late final FloatingCartController _floatingCartController;
  late Future<List<ItemCommentModel>> _commentsFuture;

  final ProductService _productService = ProductService();
  late PageController _imageController;

  int _currentImageIndex = 0;
  String? _selectedSize;
  String? _selectedColor;
  int _selectedDetId = 0;
  bool _isExpanded = false;
  bool _isLoadingImages = false;
  String? _imageLoadError;
  List<ProductImageModel> _itemImages = const [];
  List<ProductVariant> _drawerVariants = const [];
  bool _isAddingToCart = false;

  List<ProductVariant> get _variants =>
      _drawerVariants.isNotEmpty
          ? _drawerVariants
          : resolveProductVariants(widget.product, null);

  bool get _hasSingleVariant => _variants.length <= 1;

  ProductVariant? get _selectedVariant {
    if (_variants.isEmpty) return null;
    if (_selectedDetId > 0) {
      final byId = _variants.where((v) => v.detId == _selectedDetId).firstOrNull;
      if (byId != null) return byId;
    }
    final size = (_selectedSize ?? '').trim();
    final color = (_selectedColor ?? '').trim();
    return _variants.firstWhere(
          (v) =>
      (size.isEmpty || v.size.trim() == size) &&
          (color.isEmpty || v.color.trim() == color),
      orElse: () => _variants.first,
    );
  }

  @override
  void initState() {
    super.initState();
    _commentRepository = Get.find<CommentRepository>();
    _floatingCartController = FloatingCartController(Get.find<CartRepository>());
    Get.put<FloatingCartController>(_floatingCartController, tag: 'product-details');

    _imageController = PageController();
    _commentsFuture = _commentRepository.getItemComments(itemId: widget.product.id);

    _selectedSize = widget.initialSize ??
        (widget.product.sizes.isNotEmpty ? widget.product.sizes.first : null);
    _selectedColor = widget.initialColor ??
        (widget.product.colors.isNotEmpty ? widget.product.colors.first : null);

    final initialVariant = _matchVariantFrom(_variants) ?? _variants.firstOrNull;
    if (initialVariant != null) _setSelectedVariant(initialVariant);

    _loadItemImages();
    _loadDrawerVariants();
    ReviewRefreshNotifier.updatedItemId.addListener(_onReviewRefresh);

    final auth = context.read<AuthState>();
    if (auth.isLoggedIn && auth.user != null) {
      _floatingCartController.initializeCart(auth.user!.username);
    }
  }

  @override
  void dispose() {
    ReviewRefreshNotifier.updatedItemId.removeListener(_onReviewRefresh);
    _imageController.dispose();
    if (Get.isRegistered<FloatingCartController>(tag: 'product-details')) {
      Get.delete<FloatingCartController>(tag: 'product-details');
    }
    super.dispose();
  }

  void _onReviewRefresh() {
    if (ReviewRefreshNotifier.updatedItemId.value != widget.product.id || !mounted) return;
    setState(() {
      _commentsFuture = _commentRepository.getItemComments(itemId: widget.product.id);
    });
  }

  bool get _hasLoadedImages => _itemImages.isNotEmpty;
  List<String> get _fallbackImages => widget.product.imagesForColor(_selectedColor);
  int get _imageCount => _hasLoadedImages ? _itemImages.length : _fallbackImages.length;

  Future<void> _loadItemImages() async {
    setState(() {
      _isLoadingImages = true;
      _imageLoadError = null;
    });
    try {
      final images = await _productService.getItemImagesBase64(itemId: widget.product.id);
      if (mounted) setState(() => _itemImages = images);
    } on ProductException catch (e) {
      if (mounted) setState(() => _imageLoadError = e.message);
    } catch (_) {
      if (mounted) setState(() => _imageLoadError = 'Failed to load images.');
    } finally {
      if (mounted) setState(() => _isLoadingImages = false);
    }
  }

  Future<void> _loadDrawerVariants() async {
    try {
      final rows = await _productService.getItemDetailsRows(itemId: widget.product.id);
      if (!mounted || rows.isEmpty) return;
      final variants = rows
          .map((r) => ProductVariant(
        detId: r.detId,
        brand: r.brand,
        color: r.color,
        size: r.size.toString(),
        discount: r.discount,
        price: r.price,
        stock: r.stock,
      ))
          .toList();
      setState(() {
        _drawerVariants = variants;
        final matched = _matchVariantFrom(variants) ?? variants.first;
        _setSelectedVariant(matched);
      });
      _resetCarousel();
    } catch (_) {}
  }

  void _resetCarousel() {
    if (_currentImageIndex != 0) setState(() => _currentImageIndex = 0);
    if (_imageController.hasClients) _imageController.jumpToPage(0);
  }

  ProductVariant? _matchVariantFrom(List<ProductVariant> variants) {
    if (variants.isEmpty) return null;
    final preferredDetId = _selectedDetId > 0
        ? _selectedDetId
        : (widget.initialDetId ?? widget.product.detId);
    if (preferredDetId > 0) {
      final byId = variants.where((v) => v.detId == preferredDetId).firstOrNull;
      if (byId != null) return byId;
    }
    final size = (_selectedSize ?? widget.initialSize ?? '').trim();
    final color = (_selectedColor ?? widget.initialColor ?? '').trim();
    return variants.firstWhere(
          (v) =>
      (size.isEmpty || v.size.trim() == size) &&
          (color.isEmpty || v.color.trim() == color),
      orElse: () => variants.first,
    );
  }

  void _setSelectedVariant(ProductVariant variant) {
    _selectedDetId = variant.detId;
    _selectedSize = variant.size;
    _selectedColor = variant.color;
  }

  void _selectVariant(ProductVariant variant) {
    setState(() => _setSelectedVariant(variant));
    _resetCarousel();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final wishlist = context.watch<WishlistController>();
    final isFavorite = wishlist.isInWishlist(widget.product.id);
    final isTogglingFavorite = wishlist.isToggling(widget.product.id);
    widget.product.isFavorite = isFavorite;

    return Stack(
      children: [
        Scaffold(
          body: Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  await Future.wait([_loadItemImages(), _loadDrawerVariants()]);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProductDetailsImageCarousel(
                        imageController: _imageController,
                        currentIndex: _currentImageIndex,
                        imageCount: _imageCount,
                        hasLoadedImages: _hasLoadedImages,
                        itemImages: _itemImages,
                        fallbackImages: _fallbackImages,
                        isLoading: _isLoadingImages,
                        loadError: _imageLoadError,
                        productId: widget.product.id,
                        onPageChanged: (i) => setState(() => _currentImageIndex = i),
                        onThumbnailTap: (i) {
                          _imageController.animateToPage(
                            i,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                          setState(() => _currentImageIndex = i);
                        },
                      ),
                      Padding(
                        padding: AppSpacing.insetsMd,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ProductDetailsInfoSection(
                              product: widget.product,
                              selectedVariant: _selectedVariant,
                              hasSingleVariant: _hasSingleVariant,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            ProductDetailsVariantSection(
                              variants: _variants,
                              selectedVariant: _selectedVariant,
                              hasSingleVariant: _hasSingleVariant,
                              onVariantSelected: _selectVariant,
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                            ProductDetailsReviewsSection(
                              product: widget.product,
                              commentsFuture: _commentsFuture,
                              isExpanded: _isExpanded,
                              onToggleExpanded: () =>
                                  setState(() => _isExpanded = !_isExpanded),
                              onRetryComments: () => setState(() {
                                _commentsFuture = _commentRepository
                                    .getItemComments(itemId: widget.product.id);
                              }),
                            ),
                            const SizedBox(height: AppSpacing.xxl * 3),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _AppBarOverlay(
                isFavorite: isFavorite,
                isToggling: isTogglingFavorite,
                onFavoriteTap: _handleToggleFavorite,
              ),
            ],
          ),
          bottomNavigationBar: _AddToCartBar(
            isLoading: _isAddingToCart || auth.isInitializing || !auth.isInitialized,
            onTap: _openAddToCartSheet,
          ),
        ),
        AnimatedFloatingCartIcon(controller: _floatingCartController),
      ],
    );
  }

  Future<void> _handleToggleFavorite() async {
    final auth = context.read<AuthState>();
    await auth.ensureInitialized();
    if (!mounted) return;

    if ((auth.user?.username.trim() ?? '').isEmpty) {
      CustomSnackBar.show(
        context,
        message: AppLocalizations.of(context).productAccountUnavailable,
        type: AppSnackBarType.error,
      );
      return;
    }

    try {
      await context.read<WishlistController>().toggleWishlist(widget.product);
    } on ProductException catch (e) {
      if (!mounted) return;
      CustomSnackBar.show(context, message: e.message, type: AppSnackBarType.error);
    } catch (_) {
      if (!mounted) return;
      CustomSnackBar.show(
        context,
        message: AppLocalizations.of(context).notificationUnknownError,
        type: AppSnackBarType.error,
      );
    }
  }

  Future<void> _openAddToCartSheet() async {
    if (kDebugMode) {
      for (final v in _variants) {
        debugPrint('[ProductDetails] variant detId=${v.detId} size=${v.size} color=${v.color}');
      }
    }

    final selection = await showModalBottomSheet<AddToCartSelection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddToCartBottomSheet(
        product: widget.product,
        variants: _variants.isNotEmpty ? _variants : null,
        initialDetId: _selectedDetId > 0 ? _selectedDetId : widget.product.detId,
      ),
    );

    if (!mounted || selection == null) return;
    _setSelectedVariant(selection.variant);
    await _addToCart(variant: selection.variant, qty: selection.qty);
  }

  Future<void> _addToCart({required ProductVariant variant, required int qty}) async {
    final auth = context.read<AuthState>();
    await auth.ensureInitialized();
    if (!mounted) return;

    final username = auth.user?.username.trim() ?? '';
    if (username.isEmpty) {
      CustomSnackBar.show(
        context,
        message: AppLocalizations.of(context).productAccountUnavailable,
        type: AppSnackBarType.error,
      );
      return;
    }

    if (variant.stock <= 0) {
      CustomSnackBar.show(
        context,
        message: AppLocalizations.of(context).productOutOfStock,
        type: AppSnackBarType.warning,
      );
      return;
    }

    final detId = variant.detId > 0
        ? variant.detId
        : widget.product.resolveDetId(
      size: variant.size,
      color: variant.color,
      fallback: widget.product.detId,
    );

    if (detId <= 0) {
      CustomSnackBar.show(
        context,
        message: AppLocalizations.of(context).productVariantError,
        type: AppSnackBarType.error,
      );
      return;
    }

    setState(() {
      _isAddingToCart = true;
      _selectedSize = variant.size;
      _selectedColor = variant.color;
      _selectedDetId = detId;
    });

    try {
      await _productService.addItemToCart(
        AddToCartRequest(
          itemId: widget.product.id,
          itemDetId: detId,
          username: username,
          deltaQty: qty,
        ),
      );

      if (!mounted) return;
      _resetCarousel();

      AppData.addToCart(
        product: widget.product,
        quantity: qty,
        size: variant.size.trim().isEmpty ? 'Default' : variant.size,
        color: variant.color.trim().isEmpty ? 'Default' : variant.color,
        detId: detId,
      );

      _floatingCartController.triggerAddToCartAnimation();
      await _floatingCartController.loadCart();

      if (!mounted) return;
      CustomSnackBar.show(
        context,
        message: AppLocalizations.of(context).productAddedToCart(widget.product.name),
        type: AppSnackBarType.success,
      );
    } on ProductException catch (e) {
      if (!mounted) return;
      CustomSnackBar.show(context, message: e.message, type: AppSnackBarType.error);
    } catch (_) {
      if (!mounted) return;
      CustomSnackBar.show(
        context,
        message: AppLocalizations.of(context).notificationCartAddError,
        type: AppSnackBarType.error,
      );
    } finally {
      if (mounted) setState(() => _isAddingToCart = false);
    }
  }
}

class _AppBarOverlay extends StatelessWidget {
  final bool isFavorite;
  final bool isToggling;
  final VoidCallback onFavoriteTap;

  const _AppBarOverlay({
    required this.isFavorite,
    required this.isToggling,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: isToggling
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
            onPressed: isToggling ? null : onFavoriteTap,
          ),
        ],
      ),
    );
  }
}

class _AddToCartBar extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _AddToCartBar({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: AppSpacing.insetsLg,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [AppShadows.subtleShadow],
        ),
        child: SizedBox(
          width: double.infinity,
          height: AppSpacing.buttonMd,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
            onPressed: isLoading ? null : onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading) ...[
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Text(
                  AppLocalizations.of(context).productAddToCart,
                  style: AppTextStyles.buttonLarge.copyWith(color: AppColors.black),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}