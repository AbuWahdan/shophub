import 'package:flutter/material.dart';

import '../../../../design/app_colors.dart';

class ProductDetailsAppBar extends StatelessWidget {
  final bool isFavorite;
  final bool isToggling;
  final VoidCallback onFavoriteTap;

  const ProductDetailsAppBar({
    super.key,
    required this.isFavorite,
    required this.isToggling,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: onSurface),
            onPressed: () {
              // TODO: wire share logic
            },
          ),
          IconButton(
            icon: isToggling
                ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: onSurface,
              ),
            )
                : Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? AppColors.error : onSurface,
            ),
            onPressed: isToggling ? null : onFavoriteTap,
          ),
        ],
      ),
    );
  }
}