import 'package:flutter/material.dart';
import '../../../../../design/app_colors.dart';
import '../../../../../design/app_radius.dart';
import '../../../../../design/app_spacing.dart';
import '../../../../../design/app_text_styles.dart';
import 'payment_methods_tokens.dart';

class DefaultCheckbox extends StatelessWidget {
  const DefaultCheckbox({
    super.key,
    required this.value,
    required this.label,
    required this.onChanged,
  });

  final bool value;
  final String label;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: value,
      button: true,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: AppSpacing.lg,
                height: AppSpacing.lg,
                decoration: BoxDecoration(
                  color: value ? AppColors.primary : AppColors.white,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(
                    color: value ? AppColors.primary : AppColors.border,
                    width: AppSpacing.borderThin,
                  ),
                ),
                child: value
                    ? const Icon(
                        PaymentMethodsTokens.checkIcon,
                        size: AppSpacing.iconSm,
                        color: AppColors.white,
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
            ],
          ),
        ),
      ),
    );
  }
}
