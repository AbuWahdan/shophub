import 'package:flutter/material.dart';

import '../../../../design/app_colors.dart';
import '../../../../design/app_radius.dart';
import '../../../../design/app_spacing.dart';
import '../../../../design/app_text_styles.dart';
import 'checkout_tokens.dart';

class SuccessStateView extends StatelessWidget {
  const SuccessStateView({
    super.key,
    required this.title,
    required this.subtitle,
    required this.orderIdLabel,
    required this.orderId,
    required this.trackOrderLabel,
    required this.onTrackOrder,
  });

  final String title;
  final String subtitle;
  final String orderIdLabel;
  final String orderId;
  final String trackOrderLabel;
  final VoidCallback onTrackOrder;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppSpacing.xxxl,
              height: AppSpacing.xxxl,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CheckoutTokens.checkIcon,
                color: AppColors.white,
                size: AppSpacing.iconLg,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.headingMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(orderIdLabel, style: AppTextStyles.bodySmall),
                  ),
                  Text(orderId, style: AppTextStyles.labelLarge),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              height: AppSpacing.buttonMd,
              child: FilledButton(
                onPressed: onTrackOrder,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
                child: Text(trackOrderLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
