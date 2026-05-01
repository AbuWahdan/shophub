import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Target dimensions for all product images.
/// Aspect ratio 1:1 at 1200 × 1200 px — e-commerce standard.
abstract final class ProductImageSpec {
  static const int size = 1200;
  static const double aspectRatio = 1.0;

  /// JPEG quality 0–100. 88 is a good balance of size vs clarity.
  static const int jpegQuality = 88;
}

/// Result returned by [ProductImageProcessor.cropAndResize].
sealed class ImageProcessResult {}

final class ImageProcessSuccess extends ImageProcessResult {
  ImageProcessSuccess({required this.file, required this.bytes});
  final File file;
  final Uint8List bytes; // ready for preview without re-reading disk
}

final class ImageProcessFailure extends ImageProcessResult {
  ImageProcessFailure(this.reason);
  final String reason;
}

/// Crops the center square of [sourceFile] then scales it to
/// [ProductImageSpec.size] × [ProductImageSpec.size].
///
/// All processing happens on an isolate via [compute]-friendly code.
/// Returns an [ImageProcessResult] — never throws.
abstract final class ProductImageProcessor {
  /// Call this after the user confirms their crop in [ProductImageCropper].
  static Future<ImageProcessResult> cropAndResize(File sourceFile) async {
    try {
      final bytes = await sourceFile.readAsBytes();
      final original = img.decodeImage(bytes);
      if (original == null) {
        return ImageProcessFailure('Could not decode image.');
      }

      // 1. Center-crop to square.
      final side = original.width < original.height
          ? original.width
          : original.height;
      final x = (original.width - side) ~/ 2;
      final y = (original.height - side) ~/ 2;
      final cropped = img.copyCrop(
        original,
        x: x,
        y: y,
        width: side,
        height: side,
      );

      // 2. Scale to target size.
      final resized = img.copyResize(
        cropped,
        width: ProductImageSpec.size,
        height: ProductImageSpec.size,
        interpolation: img.Interpolation.linear,
      );

      // 3. Encode as JPEG.
      final encoded = img.encodeJpg(resized, quality: ProductImageSpec.jpegQuality);
      final outputBytes = Uint8List.fromList(encoded);

      // 4. Write to temp file so it can be passed to the upload service.
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'product_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final outputFile =
      await File(path.join(tempDir.path, fileName)).writeAsBytes(outputBytes);

      return ImageProcessSuccess(file: outputFile, bytes: outputBytes);
    } catch (e) {
      return ImageProcessFailure(e.toString());
    }
  }
}