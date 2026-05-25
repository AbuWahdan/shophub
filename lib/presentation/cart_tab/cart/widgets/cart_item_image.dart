import 'package:flutter/material.dart';

import '../../../../design/app_radius.dart';
import '../../../../design/app_spacing.dart';

class CartItemImage extends StatelessWidget {
  const CartItemImage({Key? key, this.imageUrl}) : super(key: key);

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.imageSm,
      height: AppSpacing.imageSm,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        color: Theme.of(context).colorScheme.surfaceVariant,
        image: imageUrl != null && imageUrl!.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: imageUrl == null || imageUrl!.isEmpty
          ? Icon(Icons.image_not_supported, size: AppSpacing.iconLg)
          : null,
    );
  }
}
