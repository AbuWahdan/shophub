import 'package:flutter/material.dart';

import '../../config/app_images.dart';

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
    return Image.asset(
      path,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          AppImages.placeholder,
          fit: fit,
          width: width,
          height: height,
        );
      },
    );
  }
}
