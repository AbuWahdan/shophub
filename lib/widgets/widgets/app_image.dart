import 'package:flutter/material.dart';

import '../../core/config/app_images.dart';


class AppImage extends StatelessWidget {
  final String path;
  final BoxFit fit;
  final double? width;
  final double? height;

  const AppImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final trimmedPath = path.trim();
    final isNetwork =
        trimmedPath.startsWith('http://') || trimmedPath.startsWith('https://');

    final fallback = Image.asset(
      AppImages.placeholder,
      fit: fit,
      width: width,
      height: height,
    );

    if (isNetwork) {
      return Image.network(
        trimmedPath,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => fallback,
      );
    }

    return Image.asset(
      trimmedPath,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }
}
