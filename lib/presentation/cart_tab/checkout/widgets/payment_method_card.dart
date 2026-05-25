import 'package:flutter/material.dart';

import '../../../../design/app_colors.dart';
import '../../../../design/app_radius.dart';
import '../../../../design/app_shadows.dart';
import '../../../../design/app_spacing.dart';
import '../../../../design/app_text_styles.dart';
import '../../../../models/payment_method_model.dart';

class PaymentMethodCard extends StatelessWidget {
  const PaymentMethodCard({
    super.key,
    required this.title,
    required this.methods,
    required this.selectedMethodId,
    required this.selectedCardNumber,
    required this.isLoading,
    required this.errorText,
    required this.retryLabel,
    required this.onRetry,
    required this.onChanged,
  });

  final String title;
  final List<PaymentMethodModel> methods;
  final int? selectedMethodId;
  final String? selectedCardNumber;
  final bool isLoading;
  final String? errorText;
  final String retryLabel;
  final VoidCallback onRetry;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: const [AppShadows.subtleShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.titleLarge),
          if (isLoading) ...[
            const SizedBox(height: AppSpacing.md),
            const LinearProgressIndicator(),
          ],
          if (errorText != null && methods.isEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              errorText!,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            ),
            TextButton(onPressed: onRetry, child: Text(retryLabel)),
          ],
          const SizedBox(height: AppSpacing.sm),
          ...methods.map(
            (method) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.md),
                onTap: () => onChanged(method.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    color: selectedMethodId == method.id
                        ? AppColors.surfaceVariant
                        : AppColors.neutral100,
                    border: Border.all(
                      color: selectedMethodId == method.id
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(method.icon, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(method.label, style: AppTextStyles.bodyMedium),
                            if (selectedMethodId == method.id &&
                                selectedCardNumber != null) ...[
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                selectedCardNumber!,
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ],
                        ),
                      ),
                      _SelectionDot(selected: selectedMethodId == method.id),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionDot extends StatelessWidget {
  const _SelectionDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: AppSpacing.lg,
      height: AppSpacing.lg,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.neutral300,
          width: AppSpacing.borderThin,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: AppSpacing.sm,
                height: AppSpacing.sm,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
              ),
            )
          : null,
    );
  }
}
