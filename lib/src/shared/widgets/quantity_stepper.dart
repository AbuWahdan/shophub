import 'package:flutter/material.dart';

import '../../design/app_spacing.dart';
import '../../design/app_text_styles.dart';

class QuantityStepper extends StatelessWidget {
  final int value;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  const QuantityStepper({
    super.key,
    required this.value,
    this.onIncrement,
    this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: onDecrement,
            constraints: const BoxConstraints(
              minWidth: AppSpacing.buttonSm,
              minHeight: AppSpacing.buttonSm,
            ),
            padding: EdgeInsets.zero,
          ),
          SizedBox(
            width: AppSpacing.buttonSm,
            child: Center(
              child: Text(
                '$value',
                style: AppTextStyles.titleMedium(context),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: onIncrement,
            constraints: const BoxConstraints(
              minWidth: AppSpacing.buttonSm,
              minHeight: AppSpacing.buttonSm,
            ),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
