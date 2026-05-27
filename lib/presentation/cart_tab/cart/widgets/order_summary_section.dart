import 'package:flutter/material.dart';

import '../../../../controllers/cart_controller.dart';
import '../../../../design/app_colors.dart';
import '../../../../design/app_radius.dart';
import '../../../../design/app_spacing.dart';
import '../../../../design/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';

/// Sticky bottom panel showing the cart price breakdown and checkout CTA.
///
/// Price rows:
///   Subtotal  — original total before any discounts
///   Discount  — total amount saved (hidden when 0)
///   Total     — final amount the customer pays (green, bold)
class OrderSummarySection extends StatelessWidget {
  const OrderSummarySection({
    super.key,
    required this.cartController,
    required this.onCheckout,
  });

  final CartController cartController;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {

    final l10n         = AppLocalizations.of(context);
    final theme        = Theme.of(context);
    final colorScheme  = theme.colorScheme;

    final originalTotal  = cartController.originalTotalPrice;
    final finalTotal     = cartController.totalPrice;
    final totalDiscount  = originalTotal - finalTotal;
    final hasDiscount    = totalDiscount > 0.001;

    return SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: colorScheme.outlineVariant,
                width: AppSpacing.borderThin,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PriceRow(
                  label: l10n.subtotalLabel,
                  value: '${l10n.jod} ${originalTotal.toStringAsFixed(3)}',
                ),
                if (hasDiscount) ...[
                  const SizedBox(height: AppSpacing.xs),
                  _PriceRow(
                    label: l10n.discountLabel,
                    value: '- ${l10n.jod} ${totalDiscount.toStringAsFixed(3)}',
                    valueColor: AppColors.priceGreen,
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Divider(
                    color: colorScheme.outlineVariant,
                    thickness: AppSpacing.borderThin,
                    height: 0,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.totalLabel,
                            style: AppTextStyles.caption.copyWith(
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            '${l10n.jod} ${finalTotal.toStringAsFixed(3)}',
                            style: AppTextStyles.titleLarge.copyWith(
                              color: AppColors.priceGreen,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (hasDiscount)
                            Text(
                              '${l10n.jod} ${originalTotal.toStringAsFixed(3)}',
                              style: AppTextStyles.caption.copyWith(
                                decoration: TextDecoration.lineThrough,
                                decorationColor:
                                colorScheme.onSurface.withValues(alpha: 0.38),
                                color:
                                colorScheme.onSurface.withValues(alpha: 0.38),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    _CheckoutButton(l10n: l10n, onPressed: onCheckout),
                  ],
                ),
              ],
            ),
          ),
        ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            color: valueColor ?? colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _CheckoutButton extends StatelessWidget {
  const _CheckoutButton({required this.l10n, required this.onPressed});

  final AppLocalizations l10n;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: 160,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        child: Text(
          l10n.proceedToCheckoutButton,
          style: AppTextStyles.buttonLarge,
        ),
      ),
    );
  }
}