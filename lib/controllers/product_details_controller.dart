import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sinwar_shoping/controllers/cart_controller.dart';

import '../../../../core/api/exceptions.dart';
import '../../../../core/config/route.dart';
import '../../../../models/cart_item_model.dart';
import '../../../../models/item_comment_model.dart';
import '../../../../models/product/product_image_model.dart';
import '../../../../models/product/product_model.dart';
import '../../../../repositories/cart_repository.dart';
import '../../../../repositories/comment_repository.dart';
import '../../../../services/product_service.dart';
import '../../../controllers/floating_cart_controller.dart';
import '../../../controllers/wishlist_controller.dart';
import '../../../core/state/auth_state.dart';
import '../../../core/state/review_refresh_notifier.dart';
import '../l10n/app_localizations.dart';
import '../widgets/custom__snack_bar/custom_snack_bar.dart';
import '../widgets/product_card/add_to_cart_bottom_sheet/add_to_cart_bottom_sheet.dart';

class ProductDetailsController extends GetxController {
  final ProductModel product;
  final String? initialSize;
  final String? initialColor;
  final int? initialDetId;

  // Injected from the screen via context.read<> — both are Provider-only,
  // never registered in GetX.
  final WishlistController wishlistController;
  final AuthState authState;

  ProductDetailsController({
    required this.product,
    required this.wishlistController,
    required this.authState,
    this.initialSize,
    this.initialColor,
    this.initialDetId,
  });

  // ── Dependencies ─────────────────────────────────────────────────────────────
  late final CommentRepository _commentRepository;
  late final ProductService _productService;
  late final FloatingCartController floatingCartController;

  // ── Page controller ───────────────────────────────────────────────────────────
  final pageController = PageController();

  // ── Observable state ──────────────────────────────────────────────────────────
  final currentImageIndex = 0.obs;
  final isLoadingImages = false.obs;
  final imageLoadError = Rxn<String>();
  final itemImages = <ProductImageModel>[].obs;
  final drawerVariants = <ProductVariant>[].obs;
  final isAddingToCart = false.obs;
  final isReviewsExpanded = true.obs;
  final comments = Rxn<List<ItemCommentModel>>();
  final isLoadingComments = false.obs;
  final commentsError = Rxn<String>();

  final selectedSize = Rxn<String>();
  final selectedColor = Rxn<String>();
  final selectedDetId = 0.obs;

  // ── Computed helpers ──────────────────────────────────────────────────────────
  List<ProductVariant> get variants =>
      drawerVariants.isNotEmpty
          ? drawerVariants
          : resolveProductVariants(product, null);

  bool get hasSingleVariant => variants.length <= 1;
  bool get hasLoadedImages => itemImages.isNotEmpty;
  List<String> get fallbackImages => product.imagesForColor(selectedColor.value);
  int get imageCount => hasLoadedImages ? itemImages.length : fallbackImages.length;

  ProductVariant? get selectedVariant {
    if (variants.isEmpty) return null;
    if (selectedDetId.value > 0) {
      final byId = variants.where((v) => v.detId == selectedDetId.value).firstOrNull;
      if (byId != null) return byId;
    }
    final size = (selectedSize.value ?? '').trim();
    final color = (selectedColor.value ?? '').trim();
    return variants.firstWhere(
          (v) =>
      (size.isEmpty || v.size.trim() == size) &&
          (color.isEmpty || v.color.trim() == color),
      orElse: () => variants.first,
    );
  }

  bool get isFavorite => wishlistController.isInWishlist(product.id);
  bool get isTogglingFavorite => wishlistController.isToggling(product.id);

  // ── Lifecycle ─────────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _commentRepository = Get.find<CommentRepository>();
    _productService = ProductService();

    floatingCartController = FloatingCartController(Get.find<CartRepository>());
    Get.put<FloatingCartController>(
      floatingCartController,
      tag: 'product-details',
    );

    selectedSize.value =
        initialSize ?? (product.sizes.isNotEmpty ? product.sizes.first : null);
    selectedColor.value =
        initialColor ?? (product.colors.isNotEmpty ? product.colors.first : null);

    final initial = _matchVariantFrom(variants) ?? variants.firstOrNull;
    if (initial != null) _applyVariant(initial);

    _loadItemImages();
    _loadDrawerVariants();
    _loadComments();

    ReviewRefreshNotifier.updatedItemId.addListener(_onReviewRefresh);

    if (authState.isLoggedIn && authState.user != null) {
      floatingCartController.initializeCart(authState.user!.username);
    }
  }

  @override
  void onClose() {
    ReviewRefreshNotifier.updatedItemId.removeListener(_onReviewRefresh);
    pageController.dispose();
    if (Get.isRegistered<FloatingCartController>(tag: 'product-details')) {
      Get.delete<FloatingCartController>(tag: 'product-details');
    }
    super.onClose();
  }

  // ── Public actions ────────────────────────────────────────────────────────────
  void selectVariant(ProductVariant variant) {
    _applyVariant(variant);
    _resetCarousel();
  }

  void toggleReviewsExpanded() =>
      isReviewsExpanded.value = !isReviewsExpanded.value;

  void onPageChanged(int index) => currentImageIndex.value = index;

  void onThumbnailTap(int index) {
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    currentImageIndex.value = index;
  }

  Future<void> refresh() async {
    await Future.wait([
      _loadItemImages(),
      _loadDrawerVariants(),
      _loadComments(),
    ]);
  }

  void retryComments() => _loadComments();

  Future<void> handleToggleFavorite(BuildContext context) async {
    await authState.ensureInitialized();

    if ((authState.user?.username.trim() ?? '').isEmpty) {
      _showError(context, AppLocalizations.of(context).productAccountUnavailable);
      return;
    }

    try {
      await wishlistController.toggleWishlist(product);
    } on ProductException catch (e) {
      _showError(context, e.message);
    } catch (_) {
      _showError(context, AppLocalizations.of(context).notificationUnknownError);
    }
  }

  Future<void> openAddToCartSheet(BuildContext context) async {
    if (kDebugMode) {
      for (final v in variants) {
        debugPrint(
          '[ProductDetails] variant detId=${v.detId} size=${v.size} color=${v.color}',
        );
      }
    }

    final selection = await showModalBottomSheet<AddToCartSelection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddToCartBottomSheet(
        product: product,
        variants: variants.isNotEmpty ? variants : null,
        initialDetId: selectedDetId.value > 0 ? selectedDetId.value : product.detId,
      ),
    );

    if (selection == null) return;
    _applyVariant(selection.variant);
    await _addToCart(context: context, variant: selection.variant, qty: selection.qty);
  }

  void navigateToProvider() {
    final owner = product.itemOwner?.trim() ?? '';
    if (owner.isEmpty) return;
    Get.toNamed(AppRoutes.providerProducts, arguments: owner);
  }

  // ── Private helpers ───────────────────────────────────────────────────────────
  void _applyVariant(ProductVariant variant) {
    selectedDetId.value = variant.detId;
    selectedSize.value = variant.size;
    selectedColor.value = variant.color;
  }

  void _resetCarousel() {
    currentImageIndex.value = 0;
    if (pageController.hasClients) pageController.jumpToPage(0);
  }

  ProductVariant? _matchVariantFrom(List<ProductVariant> list) {
    if (list.isEmpty) return null;
    final preferredId = selectedDetId.value > 0
        ? selectedDetId.value
        : (initialDetId ?? product.detId);
    if (preferredId > 0) {
      final byId = list.where((v) => v.detId == preferredId).firstOrNull;
      if (byId != null) return byId;
    }
    final size = (selectedSize.value ?? initialSize ?? '').trim();
    final color = (selectedColor.value ?? initialColor ?? '').trim();
    return list.firstWhere(
          (v) =>
      (size.isEmpty || v.size.trim() == size) &&
          (color.isEmpty || v.color.trim() == color),
      orElse: () => list.first,
    );
  }

  Future<void> _loadItemImages() async {
    isLoadingImages.value = true;
    imageLoadError.value = null;
    try {
      final images = await _productService.getItemImagesBase64(itemId: product.id);
      itemImages.assignAll(images);
    } on ProductException catch (e) {
      imageLoadError.value = e.message;
    } catch (_) {
      imageLoadError.value = 'Failed to load images.';
    } finally {
      isLoadingImages.value = false;
    }
  }

  Future<void> _loadDrawerVariants() async {
    try {
      final rows = await _productService.getItemDetailsRows(itemId: product.id);
      if (rows.isEmpty) return;
      final built = rows
          .map(
            (r) => ProductVariant(
          detId: r.detId,
          brand: r.brand,
          color: r.color,
          size: r.size.toString(),
          discount: r.discount,
          price: r.price,
          stock: r.stock,
        ),
      )
          .toList();
      drawerVariants.assignAll(built);
      final matched = _matchVariantFrom(built) ?? built.first;
      _applyVariant(matched);
      _resetCarousel();
    } catch (_) {}
  }

  Future<void> _loadComments() async {
    isLoadingComments.value = true;
    commentsError.value = null;
    try {
      final result = await _commentRepository.getItemComments(itemId: product.id);
      comments.value = result;
    } catch (e) {
      commentsError.value = e.toString();
    } finally {
      isLoadingComments.value = false;
    }
  }

  void _onReviewRefresh() {
    if (ReviewRefreshNotifier.updatedItemId.value != product.id) return;
    _loadComments();
  }

  Future<void> _addToCart({
    required BuildContext context,
    required ProductVariant variant,
    required int qty,
  }) async {
    await authState.ensureInitialized();

    final username = authState.user?.username.trim() ?? '';
    if (username.isEmpty) {
      _showError(context, AppLocalizations.of(context).productAccountUnavailable);
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
        : product.resolveDetId(
      size: variant.size,
      color: variant.color,
      fallback: product.detId,
    );

    if (detId <= 0) {
      _showError(context, AppLocalizations.of(context).productVariantError);
      return;
    }

    isAddingToCart.value = true;
    selectedDetId.value = detId;
    selectedSize.value = variant.size;
    selectedColor.value = variant.color;

    try {
      await _productService.addItemToCart(
        AddToCartRequest(
          itemId: product.id,
          itemDetId: detId,
          username: username,
          deltaQty: qty,
        ),
      );

      _resetCarousel();

      Get.find<CartController>().addToCart(
        product: product,
        quantity: qty,
        size: variant.size.trim().isEmpty ? 'Default' : variant.size,
        color: variant.color.trim().isEmpty ? 'Default' : variant.color,
        detId: detId,
      );

      floatingCartController.triggerAddToCartAnimation();
      await floatingCartController.loadCart();

      if (context.mounted) {
        CustomSnackBar.show(
          context,
          message: AppLocalizations.of(context).productAddedToCart(product.name),
          type: AppSnackBarType.success,
        );
      }
    } on ProductException catch (e) {
      if (context.mounted) _showError(context, e.message);
    } catch (_) {
      if (context.mounted) {
        _showError(context, AppLocalizations.of(context).notificationCartAddError);
      }
    } finally {
      isAddingToCart.value = false;
    }
  }

  void _showError(BuildContext context, String message) {
    CustomSnackBar.show(context, message: message, type: AppSnackBarType.error);
  }
}