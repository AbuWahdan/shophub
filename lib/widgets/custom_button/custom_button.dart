import 'package:flutter/material.dart';

import '../../design/app_colors.dart';
import '../../design/app_radius.dart';
import '../../design/app_shadows.dart';
import '../../design/app_spacing.dart';
import '../../design/app_text_styles.dart';

enum AppButtonStyle { primary, secondary, outlined, danger }

class CustomButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonStyle style;
  final bool fullWidth;
  final Widget? leading;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = AppButtonStyle.primary,
    this.fullWidth = true,
    this.leading,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.pill),
    );

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.leading != null) ...[
          widget.leading!,
          const SizedBox(width: AppSpacing.sm),
        ],
        Flexible(
          child: Text(
            widget.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                (widget.style == AppButtonStyle.secondary ||
                    widget.style == AppButtonStyle.outlined)
                ? AppTextStyles.buttonLarge.copyWith(color: AppColors.primary)
                : AppTextStyles.buttonLarge,
          ),
        ),
      ],
    );

    Widget button;
    if (isDisabled) {
      button = Material(
        color: AppColors.border,
        shape: shape,
        child: Center(
          child: DefaultTextStyle(
            style: AppTextStyles.buttonLarge.copyWith(
              color: AppColors.textHint,
            ),
            child: child,
          ),
        ),
      );
    } else if (widget.style == AppButtonStyle.primary) {
      button = Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight],
          ),
          boxShadow: const [AppShadows.buttonShadow],
        ),
        child: Material(
          color: AppColors.transparent,
          shape: shape,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            onTap: widget.onPressed,
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            child: Center(child: child),
          ),
        ),
      );
    } else if (widget.style == AppButtonStyle.danger) {
      button = Material(
        color: AppColors.error,
        shape: shape,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          onTap: widget.onPressed,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: Center(child: child),
        ),
      );
    } else {
      button = Material(
        color: AppColors.transparent,
        shape: shape,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          onTap: widget.onPressed,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: const Border.fromBorderSide(
                BorderSide(color: AppColors.primary),
              ),
            ),
            child: Center(child: child),
          ),
        ),
      );
    }

    final wrapped = AnimatedOpacity(
      duration: const Duration(milliseconds: 140),
      opacity: _pressed ? 0.92 : 1,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 140),
        scale: _pressed ? 0.98 : 1,
        child: button,
      ),
    );

    if (!widget.fullWidth) {
      return SizedBox(height: AppSpacing.buttonMd, child: wrapped);
    }

    return SizedBox(
      width: double.infinity,
      height: AppSpacing.buttonMd,
      child: wrapped,
    );
  }
}
