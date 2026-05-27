import 'package:flutter/material.dart';

import '../../../../design/app_colors.dart';
import '../../../../design/app_radius.dart';
import '../../../../design/app_spacing.dart';
import '../../../../design/app_text_styles.dart';
import '../../../../models/product/product_image_model.dart';
import '../../../../widgets/custom_image.dart';
import '../../../../widgets/gallery_section/gallery_viewer.dart';

class ProductDetailsImageCarousel extends StatelessWidget {
  final PageController imageController;
  final int currentIndex;
  final int imageCount;
  final bool hasLoadedImages;
  final List<ProductImageModel> itemImages;
  final List<String> fallbackImages;
  final bool isLoading;
  final String? loadError;
  final int productId;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onThumbnailTap;

  const ProductDetailsImageCarousel({
    super.key,
    required this.imageController,
    required this.currentIndex,
    required this.imageCount,
    required this.hasLoadedImages,
    required this.itemImages,
    required this.fallbackImages,
    required this.isLoading,
    required this.loadError,
    required this.productId,
    required this.onPageChanged,
    required this.onThumbnailTap,
  });

  @override
  Widget build(BuildContext context) {
    if (imageCount == 0) return const _EmptyImagePlaceholder();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MainImagePager(
          controller: imageController,
          imageCount: imageCount,
          hasLoadedImages: hasLoadedImages,
          itemImages: itemImages,
          fallbackImages: fallbackImages,
          productId: productId,
          onPageChanged: onPageChanged,
          onImageTap: (i) => _openViewer(context, i),
        ),
        if (imageCount > 1)
          _ThumbnailStrip(
            imageCount: imageCount,
            currentIndex: currentIndex,
            hasLoadedImages: hasLoadedImages,
            itemImages: itemImages,
            fallbackImages: fallbackImages,
            onTap: onThumbnailTap,
            onDoubleTap: (i) => _openViewer(context, i),
          ),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.md),
            child: Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        if (loadError != null && loadError!.trim().isNotEmpty)
          Padding(
            padding: AppSpacing.horizontal(AppSpacing.lg),
            child: Text(
              loadError!,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
      ],
    );
  }

  void _openViewer(BuildContext context, int initialIndex) {
    final paths = hasLoadedImages
        ? itemImages
        .map(
          (img) => img.imagePath.trim().isNotEmpty
          ? img.imagePath.trim()
          : img.imageBase64,
    )
        .where((s) => s.isNotEmpty)
        .toList()
        : List<String>.from(fallbackImages);

    if (paths.isEmpty) return;

    GalleryViewer.show(
      context,
      images: paths,
      initialIndex: initialIndex.clamp(0, paths.length - 1),
    );
  }
}

class _EmptyImagePlaceholder extends StatelessWidget {
  const _EmptyImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Container(
        color: Theme.of(context).colorScheme.surfaceVariant,
        alignment: Alignment.center,
        child: Icon(
          Icons.broken_image_outlined,
          size: 56,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _MainImagePager extends StatelessWidget {
  final PageController controller;
  final int imageCount;
  final bool hasLoadedImages;
  final List<ProductImageModel> itemImages;
  final List<String> fallbackImages;
  final int productId;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onImageTap;

  const _MainImagePager({
    required this.controller,
    required this.imageCount,
    required this.hasLoadedImages,
    required this.itemImages,
    required this.fallbackImages,
    required this.productId,
    required this.onPageChanged,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Container(
        width: double.infinity,
        color: Theme.of(context).colorScheme.surface,
        child: PageView.builder(
          controller: controller,
          onPageChanged: onPageChanged,
          itemCount: imageCount,
          itemBuilder: (context, index) {
            final image = _GalleryImage(
              index: index,
              hasLoadedImages: hasLoadedImages,
              itemImages: itemImages,
              fallbackImages: fallbackImages,
            );
            return GestureDetector(
              onTap: () => onImageTap(index),
              // Hero only on the first image — PageView renders all visible
              // pages simultaneously, so wrapping every item causes duplicate
              // tags within the same subtree.
              child: index == 0
                  ? Hero(tag: 'product_$productId', child: image)
                  : image,
            );
          },
        ),
      ),
    );
  }
}

class _ThumbnailStrip extends StatelessWidget {
  final int imageCount;
  final int currentIndex;
  final bool hasLoadedImages;
  final List<ProductImageModel> itemImages;
  final List<String> fallbackImages;
  final ValueChanged<int> onTap;
  final ValueChanged<int> onDoubleTap;

  const _ThumbnailStrip({
    required this.imageCount,
    required this.currentIndex,
    required this.hasLoadedImages,
    required this.itemImages,
    required this.fallbackImages,
    required this.onTap,
    required this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: SizedBox(
        height: 56,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: imageCount,
          separatorBuilder: (_, __) =>
          const SizedBox(width: AppSpacing.xs),
          itemBuilder: (context, i) {
            final isActive = i == currentIndex;
            return GestureDetector(
              onTap: () => onTap(i),
              onDoubleTap: () => onDoubleTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: isActive
                        ? AppColors.primary
                        : AppColors.transparent,
                    width: 2,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: _GalleryImage(
                  index: i,
                  hasLoadedImages: hasLoadedImages,
                  itemImages: itemImages,
                  fallbackImages: fallbackImages,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GalleryImage extends StatelessWidget {
  final int index;
  final bool hasLoadedImages;
  final List<ProductImageModel> itemImages;
  final List<String> fallbackImages;

  const _GalleryImage({
    required this.index,
    required this.hasLoadedImages,
    required this.itemImages,
    required this.fallbackImages,
  });

  @override
  Widget build(BuildContext context) {
    if (hasLoadedImages) {
      if (index < 0 || index >= itemImages.length) {
        return const _BrokenImageIcon();
      }
      final path = itemImages[index].imagePath.trim();
      if (path.isNotEmpty) {
        return CustomImage(path: path, fit: BoxFit.cover);
      }
      return const _BrokenImageIcon();
    }

    if (index < 0 || index >= fallbackImages.length) {
      return const _BrokenImageIcon();
    }
    return CustomImage(path: fallbackImages[index], fit: BoxFit.cover);
  }
}

class _BrokenImageIcon extends StatelessWidget {
  const _BrokenImageIcon();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.broken_image_outlined,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}