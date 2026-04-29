import 'package:flutter/material.dart';
import '../../../../models/data.dart';
import '../../../core/app/app_theme.dart';
import '../../../core/config/app_constants.dart';
import '../../../core/config/route.dart';
import '../../../design/app_colors.dart';
import '../../../design/app_radius.dart';
import '../../../design/app_spacing.dart';
import '../../../design/app_text_styles.dart';
import '../../home_tab/main_page.dart';

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

  List<Map<String, dynamic>> _items() {
    final raw = receipt['items'];
    if (raw is List) {
      return raw.whereType<Map>().map((item) {
        return Map<String, dynamic>.from(item);
      }).toList();
    }
    return const [];
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
    final items = _items();

    return Scaffold(
      appBar: AppBar(title: const Text('Order Confirmation')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.insetsMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: AppSpacing.lg,
                      height: AppSpacing.lg,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: AppColors.primary,
                        size: AppSpacing.xxxl,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Order Placed Successfully!',
                      style: AppTextStyles.headingLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Thank you for your purchase.',
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (orderId.isNotEmpty)
                _DetailRow(label: 'Order ID', value: orderId),
              _DetailRow(
                label: 'Total',
                value: '\$${amount.toStringAsFixed(2)}',
                highlight: true,
              ),
              if (items.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Text('Items', style: AppTextStyles.headingSmall),
                const SizedBox(height: AppSpacing.sm),
                ...items.map((item) {
                  final name = item['item_name']?.toString() ??
                      item['ITEM_NAME']?.toString() ??
                      'Item';
                  final qty = item['item_qty']?.toString() ??
                      item['ITEM_QTY']?.toString() ??
                      '1';
                  final price = item['item_price']?.toString() ??
                      item['ITEM_PRICE']?.toString() ??
                      '';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      '$name  x$qty  ${price.isNotEmpty ? '\$$price' : ''}',
                      style: AppTextStyles.bodySmall,
                    ),
                  );
                }),
              ],
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                height: AppSpacing.buttonMd,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  onPressed: () => _handleContinue(context),
                  child: Text(
                    'Continue Shopping',
                    style: AppTextStyles.buttonLarge.copyWith(
                      color: AppColors.primary,
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
    final switched = MainPage.switchToTab(
      context,
      AppConstants.homeTabIndex,
    );
    if (switched) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.main ,
      (route) => false,
      arguments: {'initialTabIndex': AppConstants.homeTabIndex},
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
