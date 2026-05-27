import 'package:flutter/material.dart';

import '../../../../design/app_colors.dart';
import '../../../../design/app_radius.dart';
import '../../../../design/app_spacing.dart';
import '../../../../design/app_text_styles.dart';

/// A ± quantity stepper widget.
///
/// Sizes are driven by [AppSpacing] tokens so the widget scales
/// correctly on every screen density.  Disabled states are rendered
/// at 38 % opacity so the affordance is clear in both light and dark
/// themes without hard-coding a colour.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    this.onIncrement,
    this.onDecrement,
    this.decrementIcon = Icons.remove_rounded,
  });

  final int value;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final IconData decrementIcon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeColor   = AppColors.primary;
    final disabledAlpha = 0.38;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: AppSpacing.borderThin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            icon: decrementIcon,
            onTap: onDecrement,
            activeColor: activeColor,
            disabledAlpha: disabledAlpha,
            semanticLabel: 'Decrease quantity',
          ),
          _CountDisplay(value: value),
          _StepperButton(
            icon: Icons.add_rounded,
            onTap: onIncrement,
            activeColor: activeColor,
            disabledAlpha: disabledAlpha,
            semanticLabel: 'Increase quantity',
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.onTap,
    required this.activeColor,
    required this.disabledAlpha,
    required this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final Color activeColor;
  final double disabledAlpha;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;
    final iconColor = isDisabled
        ? activeColor.withValues(alpha: disabledAlpha)
        : activeColor;

    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: !isDisabled,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        splashColor: activeColor.withValues(alpha: 0.12),
        highlightColor: activeColor.withValues(alpha: 0.08),
        child: SizedBox(
          width: AppSpacing.buttonSm,
          height: AppSpacing.buttonSm,
          child: Icon(icon, color: iconColor, size: AppSpacing.iconMd),
        ),
      ),
    );
  }
}

class _CountDisplay extends StatelessWidget {
  const _CountDisplay({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: child,
      ),
      child: SizedBox(
        key: ValueKey<int>(value),
        width: AppSpacing.buttonSm,
        child: Center(
          child: Text(
            '$value',
            style: AppTextStyles.titleMedium,
          ),
        ),
      ),
    );
  }
}