import 'package:flutter/material.dart';

import '../../../../design/app_spacing.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    final activeColor = Colors.green;
    final inactiveColor = colorScheme.error;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? activeColor.withOpacity(0.4)
              : inactiveColor.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        title: const Text(
          'Product active',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          isActive ? 'Visible to customers' : 'Hidden from customers',
          style: TextStyle(
            color: isActive ? activeColor : inactiveColor,
            fontSize: 12,
          ),
        ),
        secondary: Icon(
          isActive ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: isActive ? activeColor : inactiveColor,
        ),
        value: isActive,
        activeColor: activeColor,
        onChanged: isDisabled ? null : onChanged,
      ),
    );
  }
}