import 'package:flutter/material.dart';

import '../../../../../design/app_colors.dart';
import '../../../../../design/app_radius.dart';
import '../../../../../design/app_shadows.dart';
import '../../../../../design/app_spacing.dart';
import '../../../../../design/app_text_styles.dart';

class SaveCardButton extends StatefulWidget {
  const SaveCardButton({
    super.key,
    required this.label,
    required this.isSaving,
    required this.onPressed,
  });

  final String label;
  final bool isSaving;
  final VoidCallback? onPressed;

  @override
  State<SaveCardButton> createState() => _SaveCardButtonState();
}

class _SaveCardButtonState extends State<SaveCardButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed == null
          ? null
          : (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          height: AppSpacing.buttonMd,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: const [AppShadows.buttonShadow],
          ),
          child: FilledButton(
            onPressed: widget.onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.transparent,
              shadowColor: AppColors.transparent,
              textStyle: AppTextStyles.buttonLarge,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
            child: widget.isSaving
                ? const SizedBox(
                    width: AppSpacing.iconMd,
                    height: AppSpacing.iconMd,
                    child: CircularProgressIndicator(
                      strokeWidth: AppSpacing.borderThin,
                      color: AppColors.white,
                    ),
                  )
                : FittedBox(child: Text(widget.label)),
          ),
        ),
      ),
    );
  }
}
