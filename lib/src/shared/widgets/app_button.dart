import 'package:flutter/material.dart';

import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../design/app_text_styles.dart';

enum AppButtonStyle { primary, secondary, outlined, danger }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonStyle style;
  final bool fullWidth;
  final Widget? leading;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = AppButtonStyle.primary,
    this.fullWidth = true,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: AppSpacing.sm),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelLarge(context),
          ),
        ),
      ],
    );

    final button = switch (style) {
      AppButtonStyle.primary => ElevatedButton(
          onPressed: onPressed,
          child: buttonChild,
        ),
      AppButtonStyle.secondary => ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surface,
            foregroundColor: Theme.of(context).colorScheme.primary,
          ),
          child: buttonChild,
        ),
      AppButtonStyle.outlined => OutlinedButton(
          onPressed: onPressed,
          child: buttonChild,
        ),
      AppButtonStyle.danger => ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.white,
          ),
          child: buttonChild,
        ),
    };

    if (!fullWidth) return button;
    return SizedBox(
      width: double.infinity,
      height: AppSpacing.buttonMd,
      child: button,
    );
  }
}
