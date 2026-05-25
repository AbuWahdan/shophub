import 'package:flutter/material.dart';

import '../../../../controllers/cart_controller.dart';
import '../../../../design/app_colors.dart';
import '../../../../design/app_radius.dart';
import '../../../../design/app_spacing.dart';
import '../../../../design/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';


class OrderSummarySection extends StatelessWidget {
  const OrderSummarySection({Key? key, required this.cartController, required this.onCheckout}) : super(key: key);

  final CartController cartController;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    if (cartController.items.isEmpty || cartController.isLoading.value) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SummaryRow(label: l10n.subtotalLabel, value: '\$${cartController.totalPrice.toStringAsFixed(2)}'),
                      const SizedBox(height: 6),
                      _SummaryRow(label: l10n.discountLabel, value: '\$0.00'),
                      const SizedBox(height: 6),
                      _SummaryRow(label: l10n.taxLabel, value: '\$0.00'),
                      const SizedBox(height: 8),
                      _SummaryRow(label: l10n.totalLabel, value: '\$${cartController.totalPrice.toStringAsFixed(2)}', isTotal: true),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                SizedBox(
                  width: 180,
                  child: ElevatedButton(
                    onPressed: onCheckout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                      elevation: 0,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(l10n.proceedToCheckoutButton, style: AppTextStyles.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
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

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({Key? key, required this.label, required this.value, this.isTotal = false}) : super(key: key);

  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: AppTextStyles.caption.copyWith(color: Theme.of(context).colorScheme.tertiary))),
        Text(value, style: isTotal ? AppTextStyles.titleLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800) : AppTextStyles.bodyMedium),
      ],
    );
  }
}
