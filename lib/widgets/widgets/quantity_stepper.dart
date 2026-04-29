import 'package:flutter/material.dart';

import '../../design/app_radius.dart';
import '../../design/app_spacing.dart';
import '../../design/app_text_styles.dart';

class QuantityStepper extends StatelessWidget {
  final int value;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final IconData decrementIcon;

  const QuantityStepper({
    super.key,
    required this.value,
    this.onIncrement,
    this.onDecrement,
    this.decrementIcon = Icons.remove,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).colorScheme.onSurface;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onDecrement,
            child: SizedBox(
              width: AppSpacing.buttonSm,
              height: AppSpacing.buttonSm,
              child: Icon(
                decrementIcon,
                color: onDecrement == null
                    ? iconColor.withValues(alpha: 0.38)
                    : iconColor,
              ),
            ),
          ),
          SizedBox(
            width: AppSpacing.buttonSm,
            child: Center(
              child: Text('$value', style: AppTextStyles.titleMedium),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onIncrement,
            child: SizedBox(
              width: AppSpacing.buttonSm,
              height: AppSpacing.buttonSm,
              child: Icon(
                Icons.add,
                color: onIncrement == null
                    ? iconColor.withValues(alpha: 0.38)
                    : iconColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
