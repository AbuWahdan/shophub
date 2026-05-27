import 'package:flutter/material.dart';

import '../../../../design/app_colors.dart';
import '../../../../design/app_radius.dart';
import '../../../../design/app_spacing.dart';
import '../../../../design/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';

class ProductDetailsAddToCartBar extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const ProductDetailsAddToCartBar({
    super.key,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 4,
              shadowColor: AppColors.primary.withOpacity(0.5),
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.xxl),
              ),
            ),
            onPressed: isLoading ? null : onTap,
            child: isLoading
                ? SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.onPrimary,
              ),
            )
                : Text(
              l10n.productAddToCart,
              style: AppTextStyles.buttonLarge.copyWith(
                color: AppColors.onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}