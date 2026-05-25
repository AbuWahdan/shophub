import 'package:flutter/material.dart';

import '../../../../design/app_colors.dart';
import '../../../../design/app_radius.dart';
import '../../../../design/app_shadows.dart';
import '../../../../design/app_spacing.dart';
import '../../../../design/app_text_styles.dart';
import 'checkout_tokens.dart';

class PromoCodeInput extends StatelessWidget {
  const PromoCodeInput({
    super.key,
    required this.controller,
    required this.hintText,
    required this.isLoading,
    required this.isApplied,
    required this.errorText,
    required this.appliedText,
  });

  final TextEditingController controller;
  final String hintText;
  final bool isLoading;
  final bool isApplied;
  final String? errorText;
  final String appliedText;

  @override
  Widget build(BuildContext context) {
    final color = errorText != null
        ? AppColors.error
        : isApplied
        ? AppColors.success
        : AppColors.border;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color),
        boxShadow: const [AppShadows.subtleShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CheckoutTokens.promoIcon,
                color: isApplied ? AppColors.success : AppColors.textHint,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  controller: controller,
                  textCapitalization: TextCapitalization.characters,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textHint,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: AppSpacing.iconMd,
                  height: AppSpacing.iconMd,
                  child: CircularProgressIndicator(
                    strokeWidth: AppSpacing.borderThin,
                  ),
                )
              else if (isApplied)
                const Icon(Icons.check_circle_outline, color: AppColors.success)
              else if (errorText != null)
                const Icon(Icons.error_outline, color: AppColors.error),
            ],
          ),
          if (errorText != null || isApplied) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              isApplied ? appliedText : errorText!,
              style: AppTextStyles.bodySmall.copyWith(
                color: isApplied ? AppColors.success : AppColors.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
