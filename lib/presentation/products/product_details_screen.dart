import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sinwar_shoping/presentation/products/widgets/product_details_add_to_cart_bar.dart';
import 'package:sinwar_shoping/presentation/products/widgets/product_details_app_bar.dart';
import 'package:sinwar_shoping/presentation/products/widgets/product_details_image_carousel.dart';
import 'package:sinwar_shoping/presentation/products/widgets/product_details_info_section.dart';
import 'package:sinwar_shoping/presentation/products/widgets/product_details_reviews_section.dart';
import 'package:sinwar_shoping/presentation/products/widgets/product_details_variant_section.dart';
import 'package:sinwar_shoping/presentation/products/widgets/provider_section.dart';

import '../../../../controllers/wishlist_controller.dart';
import '../../../../core/state/auth_state.dart';
import '../../../../design/app_spacing.dart';
import '../../../../models/product/product_model.dart';
import '../../../../widgets/floating_cart_icon/animated_floating_cart_icon.dart';
import '../../controllers/product_details_controller.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;
  final String? initialSize;
  final String? initialColor;
  final int? initialDetId;

  const ProductDetailsScreen({
    super.key,
    required this.product,
    this.initialSize,
    this.initialColor,
    this.initialDetId,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late final String _tag;
  late final ProductDetailsController _controller;

  @override
  void initState() {
    super.initState();
    _tag = 'product_details_${widget.product.id}_${DateTime.now().microsecondsSinceEpoch}';
    _controller = Get.put(
      ProductDetailsController(
        product: widget.product,
        wishlistController: context.read<WishlistController>(),
        authState: context.read<AuthState>(),
        initialSize: widget.initialSize,
        initialColor: widget.initialColor,
        initialDetId: widget.initialDetId,
      ),
      tag: _tag,
    );
  }

  @override
  void dispose() {
    Get.delete<ProductDetailsController>(tag: _tag, force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          extendBody: true,
          body: Stack(
            children: [
              _ScrollBody(controller: _controller),
              Consumer<WishlistController>(
                builder: (_, wishlist, __) => ProductDetailsAppBar(
                  isFavorite: wishlist.isInWishlist(widget.product.id),
                  isToggling: wishlist.isToggling(widget.product.id),
                  onFavoriteTap: () => _controller.handleToggleFavorite(context),
                ),
              ),
            ],
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Obx(
                () => ProductDetailsAddToCartBar(
              isLoading: _controller.isAddingToCart.value,
              onTap: () => _controller.openAddToCartSheet(context),
            ),
          ),
        ),
        AnimatedFloatingCartIcon(controller: _controller.floatingCartController),
      ],
    );
  }
}

class _ScrollBody extends StatelessWidget {
  final ProductDetailsController controller;

  const _ScrollBody({required this.controller});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(
                  () => ProductDetailsImageCarousel(
                imageController: controller.pageController,
                currentIndex: controller.currentImageIndex.value,
                imageCount: controller.imageCount,
                hasLoadedImages: controller.hasLoadedImages,
                itemImages: controller.itemImages,
                fallbackImages: controller.fallbackImages,
                isLoading: controller.isLoadingImages.value,
                loadError: controller.imageLoadError.value,
                productId: controller.product.id,
                onPageChanged: controller.onPageChanged,
                onThumbnailTap: controller.onThumbnailTap,
              ),
            ),
            Padding(
              padding: AppSpacing.insetsMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                        () => ProductDetailsInfoSection(
                      product: controller.product,
                      selectedVariant: controller.selectedVariant,
                      hasSingleVariant: controller.hasSingleVariant,
                    ),
                  ),
                  _ProviderRow(controller: controller),
                  const SizedBox(height: AppSpacing.lg),
                  Obx(
                        () => ProductDetailsVariantSection(
                      variants: controller.variants,
                      selectedVariant: controller.selectedVariant,
                      hasSingleVariant: controller.hasSingleVariant,
                      onVariantSelected: controller.selectVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Obx(
                        () => ProductDetailsReviewsSection(
                      product: controller.product,
                      comments: controller.comments.value,
                      isLoading: controller.isLoadingComments.value,
                      error: controller.commentsError.value,
                      isExpanded: controller.isReviewsExpanded.value,
                      onToggleExpanded: controller.toggleReviewsExpanded,
                      onRetry: controller.retryComments,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xxl * 5),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderRow extends StatelessWidget {
  final ProductDetailsController controller;

  const _ProviderRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    final owner = controller.product.itemOwner?.trim() ?? '';
    if (owner.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: ProviderSection(
        providerName: owner,
        onTap: controller.navigateToProvider,
      ),
    );
  }
}