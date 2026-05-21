import 'package:flutter/material.dart';

import '../../../design/app_colors.dart';
import '../../../design/app_spacing.dart';
import '../../../design/app_text_styles.dart';
import '../../../models/product/product_image_model.dart';
import '../../../widgets/custom_image.dart';
import '../../../widgets/gallery_section/gallery_viewer.dart';

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
    if (imageCount == 0) {
      return _EmptyImagePlaceholder();
    }

    return Column(
      children: [
        _MainImagePager(
          controller: imageController,
          currentIndex: currentIndex,
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
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
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
        .map((img) =>
    img.imagePath.trim().isNotEmpty ? img.imagePath.trim() : img.imageBase64)
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

// ─────────────────────────────────────────────────────────────────────────────

class _EmptyImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSpacing.imageLg,
      color: Theme.of(context).colorScheme.surface,
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image_outlined, size: 56),
    );
  }
}

class _MainImagePager extends StatelessWidget {
  final PageController controller;
  final int currentIndex;
  final int imageCount;
  final bool hasLoadedImages;
  final List<ProductImageModel> itemImages;
  final List<String> fallbackImages;
  final int productId;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onImageTap;

  const _MainImagePager({
    required this.controller,
    required this.currentIndex,
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
    return Stack(
      children: [
        Container(
          height: AppSpacing.imageLg,
          color: Theme.of(context).colorScheme.surface,
          child: PageView.builder(
            controller: controller,
            onPageChanged: onPageChanged,
            itemCount: imageCount,
            itemBuilder: (context, index) => GestureDetector(
              onTap: () => onImageTap(index),
              child: Hero(
                tag: 'product_$productId',
                child: _GalleryImage(
                  index: index,
                  hasLoadedImages: hasLoadedImages,
                  itemImages: itemImages,
                  fallbackImages: fallbackImages,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: AppSpacing.md,
          left: 0,
          right: 0,
          child: _PageIndicator(
            count: imageCount,
            currentIndex: currentIndex,
          ),
        ),
      ],
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;

  const _PageIndicator({required this.count, required this.currentIndex});

  // ✅ AFTER
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0), // Adds a safe breathing room on the edges
      child: Wrap(                                           // Changed from Row to Wrap
        alignment: WrapAlignment.center,                     // Changed from mainAxisAlignment
        runSpacing: 4.0,                                     // Adds vertical spacing if the dots wrap to a second line
        children: List.generate(count, (i) {
          final isActive = i == currentIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isActive ? AppSpacing.xxl : AppSpacing.sm,
            height: AppSpacing.sm,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.xs),
              color: isActive
                  ? AppColors.primary
                  : Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
            ),
          );
        }),
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
      padding: AppSpacing.insetsMd,
      child: SizedBox(
        height: AppSpacing.imageSm,
        child: ListView.separated(
          padding: AppSpacing.horizontal(AppSpacing.lg),
          scrollDirection: Axis.horizontal,
          itemCount: imageCount,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
          itemBuilder: (context, i) {
            final isActive = i == currentIndex;
            return GestureDetector(
              onTap: () => onTap(i),
              onDoubleTap: () => onDoubleTap(i),
              child: Container(
                padding: AppSpacing.insetsSm,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
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
                  child: _GalleryImage(
                    index: i,
                    hasLoadedImages: hasLoadedImages,
                    itemImages: itemImages,
                    fallbackImages: fallbackImages,
                  ),
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
        return const Center(child: Icon(Icons.broken_image_outlined));
      }
      final path = itemImages[index].imagePath.trim();
      if (path.isNotEmpty) {
        return CustomImage(path: path, fit: BoxFit.cover);
      }
      return const Center(child: Icon(Icons.broken_image_outlined));
    }

    if (index < 0 || index >= fallbackImages.length) {
      return const Center(child: Icon(Icons.broken_image_outlined));
    }
    return CustomImage(path: fallbackImages[index], fit: BoxFit.cover);
  }
}