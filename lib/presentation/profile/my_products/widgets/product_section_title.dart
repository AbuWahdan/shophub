import 'package:flutter/material.dart';
import '../../../../design/app_radius.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colorScheme.outline.withOpacity(0.65)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: colorScheme.primary, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailing != null) ...[
            trailing!,
          ],
        ],
      ),
    );
  }
}