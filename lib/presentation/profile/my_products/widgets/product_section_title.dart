import 'package:flutter/material.dart';
import '../../../../design/app_spacing.dart';

/// Consistent section header with an icon badge and bold title.
/// Shared across [InsertProductPage] and [EditProductPage].
class ProductSectionTitle extends StatelessWidget {
  const ProductSectionTitle({
    super.key,
    required this.title,
    required this.icon,
    this.trailing,
  });

  final String title;
  final IconData icon;

  /// Optional widget placed at the far right (e.g. an "Add" button).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: colorScheme.primary, size: 20),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}