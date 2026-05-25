import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../design/app_colors.dart';
import '../../../../design/app_radius.dart';
import '../../../../design/app_shadows.dart';
import '../../../../design/app_spacing.dart';
import '../../../../design/app_text_styles.dart';
import '../../../../models/checkout/checkout_summary_model.dart';

class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({
    super.key,
    required this.title,
    required this.subtotalLabel,
    required this.discountLabel,
    required this.shippingLabel,
    required this.taxLabel,
    required this.totalLabel,
    required this.summary,
  });

  final String title;
  final String subtotalLabel;
  final String discountLabel;
  final String shippingLabel;
  final String taxLabel;
  final String totalLabel;
  final CheckoutSummaryModel summary;

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
          const SizedBox(height: AppSpacing.md),
          _AmountRow(label: subtotalLabel, value: summary.subtotal),
          const SizedBox(height: AppSpacing.sm),
          _AmountRow(
            label: discountLabel,
            value: summary.totalDiscount,
            isDiscount: true,
            valueColor: AppColors.success,
          ),
          const SizedBox(height: AppSpacing.sm),
          _AmountRow(label: shippingLabel, value: 0),
          const SizedBox(height: AppSpacing.sm),
          _AmountRow(label: taxLabel, value: summary.tax),
          const Divider(height: AppSpacing.xl),
          _AmountRow(
            label: totalLabel,
            value: summary.grandTotal,
            isTotal: true,
          ),
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isDiscount = false,
    this.isTotal = false,
  });

  final String label;
  final double value;
  final Color? valueColor;
  final bool isDiscount;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.simpleCurrency(
      locale: Localizations.localeOf(context).toLanguageTag(),
    );
    final formatted = currency.format(value);

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: isTotal
                ? AppTextStyles.titleMedium
                : AppTextStyles.bodyMedium,
          ),
        ),
        Text(
          isDiscount && value > 0 ? '-$formatted' : formatted,
          style:
              (isTotal ? AppTextStyles.priceMedium : AppTextStyles.bodyMedium)
                  .copyWith(
                    color: valueColor ?? (isTotal ? AppColors.primary : null),
                    fontWeight: FontWeight.w700,
                  ),
        ),
      ],
    );
  }
}
