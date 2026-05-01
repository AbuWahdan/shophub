import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:crop_your_image/crop_your_image.dart';

import 'product_image_processor.dart';

/// A full-screen interactive crop screen that enforces a 1:1 aspect ratio.
///
/// **Usage — open from any page that picks product images:**
/// ```dart
/// final result = await ProductImageCropper.show(context, sourceFile: picked);
/// if (result != null) {
///   // result.file  → temp File ready to read / upload
///   // result.bytes → Uint8List ready for Image.memory preview
/// }
/// ```
///
/// Returns `null` if the user cancels.
class ProductImageCropper extends StatefulWidget {
  const ProductImageCropper._({required this.sourceFile});

  final File sourceFile;

  /// Opens [ProductImageCropper] as a full-screen modal route.
  /// Returns an [ImageProcessSuccess] on confirm, `null` on cancel.
  static Future<ImageProcessSuccess?> show(
      BuildContext context, {
        required File sourceFile,
      }) {
    return Navigator.of(context).push<ImageProcessSuccess?>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ProductImageCropper._(sourceFile: sourceFile),
      ),
    );
  }

  @override
  State<ProductImageCropper> createState() => _ProductImageCropperState();
}

class _ProductImageCropperState extends State<ProductImageCropper> {
  final CropController _cropController = CropController();

  late final Future<Uint8List> _imageFuture;
  bool _isCropping = false;

  @override
  void initState() {
    super.initState();
    _imageFuture = widget.sourceFile.readAsBytes();
  }

  Future<void> _onConfirmCrop() async {
    setState(() => _isCropping = true);
    // crop_your_image calls onCropped; we trigger it here.
    _cropController.crop();
  }

  Future<void> _onCropped(Uint8List croppedBytes) async {
    // Write to a temp file so ProductImageProcessor can work with it.
    final tempDir = await Directory.systemTemp.createTemp('crop_');
    final tempFile = File(
      '${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await tempFile.writeAsBytes(croppedBytes);

    // Resize to 1200 × 1200.
    final result = await ProductImageProcessor.cropAndResize(tempFile);

    if (!mounted) return;

    if (result is ImageProcessSuccess) {
      Navigator.of(context).pop(result);
    } else if (result is ImageProcessFailure) {
      setState(() => _isCropping = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to process image: ${result.reason}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const _CropperTitle(),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Cancel',
          onPressed: _isCropping ? null : () => Navigator.of(context).pop(null),
        ),
        actions: [
          _ConfirmButton(
            isCropping: _isCropping,
            onPressed: _onConfirmCrop,
          ),
        ],
      ),
      body: FutureBuilder<Uint8List>(
        future: _imageFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          if (snapshot.hasError || snapshot.data == null) {
            return const Center(
              child: Text(
                'Could not load image.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return Stack(
            children: [
              Crop(
                controller: _cropController,
                image: snapshot.data!,
                // Enforce 1:1 — locked, user cannot change ratio.
                aspectRatio: ProductImageSpec.aspectRatio,
                fixCropRect: false,
                onCropped: _onCropped,
                onStatusChanged: (_) {},
                baseColor: Colors.black,
                maskColor: Colors.black.withOpacity(0.55),
                cornerDotBuilder: (size, cornerIndex) =>
                    _CropCornerDot(size: size),
              ),

              // Overlay shown while processing.
              if (_isCropping)
                const _ProcessingOverlay(),

              // Hint bar at the bottom.
              if (!_isCropping)
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _CropHintBar(),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private sub-widgets — all stateless, all composable
// ─────────────────────────────────────────────────────────────────────────────

class _CropperTitle extends StatelessWidget {
  const _CropperTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Crop Photo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '${ProductImageSpec.size} × ${ProductImageSpec.size} px  ·  1:1',
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
      ],
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({
    required this.isCropping,
    required this.onPressed,
  });

  final bool isCropping;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: TextButton(
        onPressed: isCropping ? null : onPressed,
        child: Text(
          isCropping ? 'Processing…' : 'Use Photo',
          style: TextStyle(
            color: isCropping ? Colors.white38 : Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class _CropCornerDot extends StatelessWidget {
  const _CropCornerDot({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _ProcessingOverlay extends StatelessWidget {
  const _ProcessingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Preparing image…',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _CropHintBar extends StatelessWidget {
  const _CropHintBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      color: Colors.black.withOpacity(0.6),
      child: const Text(
        'Drag and pinch to adjust  ·  Square crop enforced',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white60, fontSize: 12),
      ),
    );
  }
}