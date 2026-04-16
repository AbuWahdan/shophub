import 'package:flutter/material.dart';

import '../../design/app_text_styles.dart';

class ProductSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool hasSearchText;
  final VoidCallback? onClear;
  final VoidCallback? onCameraTap;
  final ValueChanged<String>? onChanged;

  const ProductSearchBar({
    super.key,
    required this.controller,
    required this.hintText,
    required this.hasSearchText,
    this.onClear,
    this.onCameraTap,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.6);

    return Container(
      height: AppSpacing.buttonSm,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusMd)),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: AppTextStyles.bodySmall,
          contentPadding: AppSpacing.only(
            left: AppSpacing.sm,
            right: AppSpacing.sm,
            top: AppSpacing.xs,
          ),
          suffixIconConstraints: const BoxConstraints(
            minHeight: AppSpacing.buttonSm,
            minWidth: 96,
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  hasSearchText ? Icons.close : Icons.camera_alt_outlined,
                  color: iconColor,
                ),
                onPressed: hasSearchText ? onClear : onCameraTap,
              ),
              IconButton(
                icon: Icon(Icons.search, color: iconColor),
                onPressed: null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
