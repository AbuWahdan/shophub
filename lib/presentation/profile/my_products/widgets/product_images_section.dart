import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/utils/image_converter.dart';
import '../../../../design/app_colors.dart';
import '../../../../design/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/product_image_model.dart';
import '../../../../widgets/gallery_section/gallery_viewer.dart';
import 'product_section_title.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Insert-mode images section  (local XFile list, not yet uploaded)
// ─────────────────────────────────────────────────────────────────────────────

/// Images section used on the **Insert** screen.
/// Works with a local list of [XFile] picked from gallery/camera.
class InsertImagesSection extends StatelessWidget {
  const InsertImagesSection({
    super.key,
    required this.images,
    required this.defaultImageIndex,
    required this.isSubmitting,
    required this.onAddPressed,
    required this.onSetDefault,
    required this.onRemove,
  });

  final List<dynamic> images; // List<XFile>
  final int defaultImageIndex;
  final bool isSubmitting;
  final VoidCallback onAddPressed;
  final ValueChanged<int> onSetDefault;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final safeDefault = images.isEmpty
        ? 0
        : defaultImageIndex.clamp(0, images.length - 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProductSectionTitle(
          title: l10n.productImages,
          icon: Icons.image_outlined,
        ),
        const SizedBox(height: AppSpacing.md),

        // Big preview / tap-to-add
        GestureDetector(
          onTap: isSubmitting
              ? null
              : images.isEmpty
              ? onAddPressed
              : () => GalleryViewer.show(
            context,
            images: images.map<String>((x) => x.path as String).toList(),
            initialIndex: safeDefault,
          ),
          child: _BigPreviewContainer(
            imagePath: images.isEmpty ? null : images[safeDefault].path as String,
            imageCount: images.length,
          ),
        ),

        // Thumbnail strip
        if (images.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 88,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (_, i) {
                if (i == images.length) {
                  return _AddThumbnailButton(
                    isSubmitting: isSubmitting,
                    onPressed: onAddPressed,
                  );
                }
                return _LocalImageThumbnail(
                  path: images[i].path as String,
                  isDefault: i == safeDefault,
                  isSubmitting: isSubmitting,
                  onTap: () => GalleryViewer.show(
                    context,
                    images: images.map<String>((x) => x.path as String).toList(),
                    initialIndex: i,
                  ),
                  onSetDefault: () => onSetDefault(i),
                  onRemove: () => onRemove(i),
                );
              },
            ),
          ),
        ],

        if (images.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Text(
              l10n.productAddImageValidation,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Edit-mode images section  (uploaded [ProductImageModel] list)
// ─────────────────────────────────────────────────────────────────────────────

/// Images section used on the **Edit** screen.
/// Works with a server-backed list of [ProductImageModel].
class EditImagesSection extends StatelessWidget {
  const EditImagesSection({
    super.key,
    required this.images,
    required this.defaultImageId,
    required this.isSubmitting,
    required this.isUploading,
    required this.onAddPressed,
    required this.onSetDefault,
  });

  final List<ProductImageModel> images;
  final int? defaultImageId;
  final bool isSubmitting;
  final bool isUploading;
  final VoidCallback onAddPressed;
  final ValueChanged<ProductImageModel> onSetDefault;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    List<String> _galleryPaths() => images.map((img) {
      if (img.imagePath.trim().isNotEmpty) return img.imagePath.trim();
      return 'base64:${img.imageBase64}';
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProductSectionTitle(
          title: l10n.productImages,
          icon: Icons.image_outlined,
        ),
        const SizedBox(height: AppSpacing.md),
        if (images.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                l10n.productNoImagesYet,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: images.length + 1,
            itemBuilder: (_, i) {
              if (i == images.length) {
                return _AddThumbnailButton(
                  isSubmitting: isSubmitting || isUploading,
                  onPressed: onAddPressed,
                  uploading: isUploading,
                );
              }
              final image = images[i];
              final isDefault = image.isDefault ||
                  (defaultImageId != null && image.imageId == defaultImageId);
              return _ServerImageTile(
                image: image,
                isDefault: isDefault,
                isSubmitting: isSubmitting || isUploading,
                onTap: () => GalleryViewer.show(
                  context,
                  images: _galleryPaths(),
                  initialIndex: i,
                ),
                onSetDefault: () => onSetDefault(image),
              );
            },
          ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton.icon(
          onPressed: (isSubmitting || isUploading) ? null : onAddPressed,
          icon: const Icon(Icons.image_outlined),
          label: Text(isUploading ? l10n.productUploading : l10n.productAddImage),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private shared sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _BigPreviewContainer extends StatelessWidget {
  const _BigPreviewContainer({this.imagePath, required this.imageCount});

  final String? imagePath;
  final int imageCount;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: imagePath == null ? AppColors.neutral400 : AppColors.primary,
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: imagePath == null
          ? const _EmptyPreviewPlaceholder()
          : _FilledPreview(imagePath: imagePath!, imageCount: imageCount),
    );
  }
}

class _EmptyPreviewPlaceholder extends StatelessWidget {
  const _EmptyPreviewPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined,
            size: 52, color: AppColors.neutral500),
        SizedBox(height: 12),
        Text(
          'Tap to add product image',
          style: TextStyle(
            fontSize: 15,
            color: AppColors.neutral600,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'JPG, PNG supported',
          style: TextStyle(fontSize: 12, color: AppColors.neutral400),
        ),
      ],
    );
  }
}

class _FilledPreview extends StatelessWidget {
  const _FilledPreview({required this.imagePath, required this.imageCount});

  final String imagePath;
  final int imageCount;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(File(imagePath), fit: BoxFit.cover),
        ),
        Positioned(
          bottom: 10,
          left: 10,
          child: _Badge(
            color: AppColors.primary,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, size: 12, color: Colors.white),
                SizedBox(width: 4),
                Text('Default',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
        if (imageCount > 1)
          Positioned(
            top: 10,
            right: 10,
            child: _Badge(
              color: Colors.black54,
              child: Text('$imageCount photos',
                  style: const TextStyle(color: Colors.white, fontSize: 11)),
            ),
          ),
        Positioned(
          top: 10,
          left: 10,
          child: _Badge(
            color: Colors.black38,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.zoom_in, size: 12, color: Colors.white),
                SizedBox(width: 4),
                Text('Tap to view',
                    style: TextStyle(color: Colors.white, fontSize: 11)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AddThumbnailButton extends StatelessWidget {
  const _AddThumbnailButton({
    required this.isSubmitting,
    required this.onPressed,
    this.uploading = false,
  });

  final bool isSubmitting;
  final bool uploading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSubmitting ? null : onPressed,
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          border: Border.all(color: AppColors.neutral400, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_photo_alternate_outlined,
                color: AppColors.primary, size: 26),
            const SizedBox(height: 4),
            Text(
              uploading ? 'Uploading' : 'Add',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocalImageThumbnail extends StatelessWidget {
  const _LocalImageThumbnail({
    required this.path,
    required this.isDefault,
    required this.isSubmitting,
    required this.onTap,
    required this.onSetDefault,
    required this.onRemove,
  });

  final String path;
  final bool isDefault;
  final bool isSubmitting;
  final VoidCallback onTap;
  final VoidCallback onSetDefault;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: isSubmitting ? null : onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              border: Border.all(
                color: isDefault ? AppColors.primary : AppColors.neutral300,
                width: isDefault ? 2.5 : 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.sm - 1),
              child: Image.file(File(path), fit: BoxFit.cover),
            ),
          ),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: _ThumbnailIconButton(
            color: isDefault ? AppColors.warning : Colors.black45,
            icon: isDefault ? Icons.star : Icons.star_border,
            isSubmitting: isSubmitting,
            onTap: onSetDefault,
          ),
        ),
        Positioned(
          top: 2,
          left: 2,
          child: _ThumbnailIconButton(
            color: Colors.black45,
            icon: Icons.close,
            isSubmitting: isSubmitting,
            onTap: onRemove,
          ),
        ),
      ],
    );
  }
}

class _ServerImageTile extends StatelessWidget {
  const _ServerImageTile({
    required this.image,
    required this.isDefault,
    required this.isSubmitting,
    required this.onTap,
    required this.onSetDefault,
  });

  final ProductImageModel image;
  final bool isDefault;
  final bool isSubmitting;
  final VoidCallback onTap;
  final VoidCallback onSetDefault;

  @override
  Widget build(BuildContext context) {
    final bytes = ImageConverter.base64ToBytes(image.imageBase64);

    Widget imageWidget;
    if (bytes != null) {
      imageWidget = Image.memory(bytes, fit: BoxFit.cover);
    } else if (image.imagePath.trim().isNotEmpty) {
      imageWidget = Image.network(
        image.imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _BrokenImage(),
      );
    } else {
      imageWidget = _BrokenImage();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTap: isSubmitting ? null : onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageWidget,
          ),
        ),
        Positioned(
          top: 6,
          left: 6,
          child: Icon(
            isDefault ? Icons.star_rounded : Icons.star_outline_rounded,
            color: isDefault ? Colors.amber : Colors.white,
            size: 20,
          ),
        ),
        if (isDefault)
          Positioned(
            bottom: 4,
            left: 4,
            child: _Badge(
              color: Theme.of(context).colorScheme.primary,
              child: const Text(
                'Default',
                style: TextStyle(color: Colors.white, fontSize: 10),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        if (!isDefault)
          Positioned(
            right: 6,
            bottom: 6,
            child: GestureDetector(
              onTap: isSubmitting ? null : onSetDefault,
              child: _Badge(
                color: Colors.black54,
                child: const Text(
                  'Set default',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _BrokenImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).dividerColor,
      child: const Icon(Icons.broken_image_outlined),
    );
  }
}

class _ThumbnailIconButton extends StatelessWidget {
  const _ThumbnailIconButton({
    required this.color,
    required this.icon,
    required this.isSubmitting,
    required this.onTap,
  });

  final Color color;
  final IconData icon;
  final bool isSubmitting;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSubmitting ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, size: 13, color: Colors.white),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}