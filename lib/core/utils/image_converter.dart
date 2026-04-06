import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageConverter {
  const ImageConverter._();

  static Future<String?> fileToBase64(File file) async {
    try {
      if (!await file.exists()) return null;
      final bytes = await file.readAsBytes();
      return base64Encode(bytes);
    } catch (error) {
      debugPrint('[ImageConverter] fileToBase64 error: $error');
      return null;
    }
  }

  static Uint8List? base64ToBytes(String base64String) {
    try {
      if (base64String.trim().isEmpty) return null;
      final clean = base64String.contains(',')
          ? base64String.split(',').last
          : base64String;
      return base64Decode(clean);
    } catch (error) {
      debugPrint('[ImageConverter] base64ToBytes error: $error');
      return null;
    }
  }

  static Future<String?> compressAndConvert(
    File file, {
    int quality = 80,
  }) async {
    try {
      final compressed = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        quality: quality,
      );
      if (compressed == null) return null;
      return base64Encode(compressed);
    } catch (error) {
      debugPrint('[ImageConverter] compressAndConvert error: $error');
      return null;
    }
  }
}
