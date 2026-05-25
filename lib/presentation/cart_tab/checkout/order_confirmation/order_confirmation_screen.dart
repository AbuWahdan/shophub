import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../models/data.dart';
import '../../../../core/config/route.dart';
import '../../../../design/app_colors.dart';
import '../../../../design/app_radius.dart';
import '../../../../design/app_spacing.dart';
import '../../../../design/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/success_state_view.dart';
import '../../../main_navigator.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({
    super.key,
    required this.receipt,
    required this.total,
    this.onContinue,
  });

  final Map<String, dynamic> receipt;
  final double total;
  final VoidCallback? onContinue;
  static const int homeTabIndex = 0;

  String _stringFor(List<String> keys) {
    for (final key in keys) {
      final value = receipt[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return '';
  }

  double _doubleFor(List<String> keys) {
    for (final key in keys) {
      final value = receipt[key];
      if (value is num) return value.toDouble();
      if (value != null) {
        final parsed = double.tryParse(value.toString());
        if (parsed != null) return parsed;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final orderId = _stringFor(const [
      'order_id',
      'ORDER_ID',
      'receipt_id',
      'RECEIPT_ID',
      'id',
      'ID',
    ]);
    final amount = _doubleFor(const ['total', 'TOTAL', 'amount', 'AMOUNT']);
    final l10n = AppLocalizations.of(context);
    final currency = NumberFormat.simpleCurrency(
      locale: Localizations.localeOf(context).toLanguageTag(),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.orderPlacedSuccessTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.insetsMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SuccessStateView(
                title: l10n.orderPlacedSuccessTitle,
                subtitle: l10n.orderPlacedSuccessSubtitle,
                orderIdLabel: l10n.orderIdLabel,
                orderId: orderId,
                trackOrderLabel: l10n.trackOrderButton,
                onTrackOrder: () => _handleContinue(context),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (orderId.isNotEmpty)
                _DetailRow(label: l10n.orderIdLabel, value: orderId),
              _DetailRow(
                label: l10n.totalLabel,
                value: currency.format(amount),
                highlight: true,
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                height: AppSpacing.buttonMd,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  onPressed: () => _handleContinue(context),
                  child: Text(
                    l10n.trackOrderButton,
                    style: AppTextStyles.buttonLarge.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleContinue(BuildContext context) {
    onContinue?.call();
    AppData.setCartItems(const []);
    final switched = MainNavigator.switchToTab(context, homeTabIndex);
    if (switched) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.main,
      (route) => false,
      arguments: {'initialTabIndex': homeTabIndex},
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final textStyle = highlight
        ? AppTextStyles.labelLarge.copyWith(color: AppColors.primary)
        : AppTextStyles.bodySmall;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Text(value, style: textStyle),
        ],
      ),
    );
  }
}
