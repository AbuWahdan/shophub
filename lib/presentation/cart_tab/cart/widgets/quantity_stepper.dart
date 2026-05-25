import 'package:flutter/material.dart';

import '../../../../design/app_colors.dart';
import '../../../../design/app_spacing.dart';

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    Key? key,
    required this.quantity,
    required this.canIncrement,
    required this.canDecrement,
    required this.onIncrement,
    required this.onDecrement,
  }) : super(key: key);

  final int quantity;
  final bool canIncrement;
  final bool canDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ActionButton(
            icon: Icons.remove,
            onTap: canDecrement ? onDecrement : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Text('$quantity', style: Theme.of(context).textTheme.bodyMedium),
          ),
          _ActionButton(
            icon: Icons.add,
            onTap: canIncrement ? onIncrement : null,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({Key? key, required this.icon, this.onTap}) : super(key: key);

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: 40,
      child: Material(
        color: onTap != null ? Theme.of(context).colorScheme.surfaceVariant : Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Icon(icon, size: 18, color: onTap != null ? AppColors.primaryDark : AppColors.textHint),
        ),
      ),
    );
  }
}
