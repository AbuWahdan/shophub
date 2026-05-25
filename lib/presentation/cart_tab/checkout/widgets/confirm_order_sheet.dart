import 'package:flutter/material.dart';

import '../../../../design/app_colors.dart';
import '../../../../design/app_radius.dart';
import '../../../../design/app_spacing.dart';
import '../../../../design/app_text_styles.dart';
import '../../../../models/checkout/checkout_summary_model.dart';
import 'order_summary_card.dart';

class ConfirmOrderSheet extends StatelessWidget {
  const ConfirmOrderSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.cancelLabel,
    required this.confirmLabel,
    required this.subtotalLabel,
    required this.discountLabel,
    required this.shippingLabel,
    required this.taxLabel,
    required this.totalLabel,
    required this.summary,
    required this.onCancel,
    required this.onConfirm,
  });

  final String title;
  final String subtitle;
  final String cancelLabel;
  final String confirmLabel;
  final String subtotalLabel;
  final String discountLabel;
  final String shippingLabel;
  final String taxLabel;
  final String totalLabel;
  final CheckoutSummaryModel summary;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.headingSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            OrderSummaryCard(
              title: title,
              subtotalLabel: subtotalLabel,
              discountLabel: discountLabel,
              shippingLabel: shippingLabel,
              taxLabel: taxLabel,
              totalLabel: totalLabel,
              summary: summary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(AppSpacing.buttonMd),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                    ),
                    child: Text(cancelLabel),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FilledButton(
                    onPressed: onConfirm,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(AppSpacing.buttonMd),
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                    ),
                    child: Text(confirmLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
