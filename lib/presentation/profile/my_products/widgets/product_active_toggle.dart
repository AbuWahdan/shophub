import 'package:flutter/material.dart';

import '../../../../design/app_radius.dart';
import '../../../../design/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';

/// A [SwitchListTile] that controls the product-level `is_active` flag.
/// Only shown on the **Edit** screen — new products are always created active.
class ProductActiveToggle extends StatelessWidget {
  const ProductActiveToggle({
    super.key,
    required this.isActive,
    required this.isDisabled,
    required this.onChanged,
  });

  final bool isActive;
  final bool isDisabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final activeColor = colorScheme.primary;
    final inactiveColor = colorScheme.error;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isActive
              ? activeColor.withOpacity(0.35)
              : inactiveColor.withOpacity(0.35),
          width: 1.5,
        ),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        title: Text(
          l10n.productActiveLabel,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          isActive
              ? l10n.productActiveVisibleSubtitle
              : l10n.productActiveHiddenSubtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isActive ? activeColor : inactiveColor,
          ),
        ),
        secondary: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: (isActive ? activeColor : inactiveColor).withOpacity(0.12),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Icon(
            isActive ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: isActive ? activeColor : inactiveColor,
            size: 22,
          ),
        ),
        value: isActive,
        activeColor: activeColor,
        activeTrackColor: activeColor.withOpacity(0.25),
        onChanged: isDisabled ? null : onChanged,
      ),
    );
  }
}