import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../design/app_colors.dart';
import '../../../../design/app_radius.dart';
import '../../../../design/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/product/product_image_model.dart';
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
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 140,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 1,
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            side: BorderSide(color: Theme.of(context).colorScheme.outline),
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
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 52,
            color: AppColors.neutral500,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.productTapToAddImage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.neutral600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.productImageFormatsHint,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.neutral400,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilledPreview extends StatelessWidget {
  const _FilledPreview({required this.imagePath, required this.imageCount});

  final String imagePath;
  final int imageCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Image.file(File(imagePath), fit: BoxFit.cover),
        ),
        Positioned(
          bottom: 10,
          left: 10,
          child: _Badge(
            color: theme.colorScheme.primary,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, size: 12, color: Colors.white),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  l10n.productDefaultLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
              child: Text(
                '+$imageCount',
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ),
        Positioned(
          top: 10,
          left: 10,
          child: _Badge(
            color: Colors.black38,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.zoom_in, size: 12, color: Colors.white),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  l10n.productTapToView,
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
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
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: isSubmitting ? null : onPressed,
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.neutral400, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_photo_alternate_outlined,
              color: AppColors.primary,
              size: 26,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              uploading ? l10n.productUploading : l10n.productAddImage,
              textAlign: TextAlign.center,
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
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(
                color: isDefault ? AppColors.primary : AppColors.neutral300,
                width: isDefault ? 2.5 : 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm - 1),
              child: Image.file(File(path), fit: BoxFit.cover),
            ),
          ),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: _ThumbnailIconButton(
            color: isDefault ? AppColors.warning : AppColors.neutral600.withOpacity(0.75),
            icon: isDefault ? Icons.star : Icons.star_border,
            isSubmitting: isSubmitting,
            onTap: onSetDefault,
          ),
        ),
        Positioned(
          top: 2,
          left: 2,
          child: _ThumbnailIconButton(
            color: AppColors.neutral600.withOpacity(0.75),
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
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTap: isSubmitting ? null : onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Container(
              color: theme.cardColor,
            ),
          ),
        ),
        Positioned(
          top: 6,
          left: 6,
          child: Icon(
            isDefault ? Icons.star_rounded : Icons.star_outline_rounded,
            color: isDefault ? AppColors.warning : AppColors.white,
            size: 20,
          ),
        ),
        if (isDefault)
          Positioned(
            bottom: 4,
            left: 4,
            child: _Badge(
              color: theme.colorScheme.primary,
              child: Text(
                l10n.productDefaultLabel,
                style: const TextStyle(color: Colors.white, fontSize: 10),
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
                child: Text(
                  l10n.productSetDefault,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
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
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: child,
    );
  }
}