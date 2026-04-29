import 'package:flutter/material.dart';
import '../../../../models/order_detail_item_model.dart';
import '../../../core/app/app_theme.dart';
import '../../../core/exceptions/color_parsing_extension.dart';
import '../../../design/app_colors.dart';
import '../../../design/app_spacing.dart';
import '../../../design/app_text_styles.dart';
import '../../../widgets/widgets/item_review_section.dart';

class SingleOrderedItemScreen extends StatelessWidget {
  final OrderDetailItemModel item;
  final String currentUsername;

  const SingleOrderedItemScreen({
    super.key,
    required this.item,
    required this.currentUsername,
  });

  @override
  Widget build(BuildContext context) {
    final isDelivered = item.deliveryStatus == 1;
    final itemColor = item.color.toColor();
    final hasDiscount = item.itemDiscount > 0;

    // Calculates the base subtotal assuming unitPrice is the final price and itemDiscount is applied.
    // Adjust math based on your exact API definitions if necessary.
    final subTotal = item.unitPrice * item.qty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.insetsMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Item Header Card
            Card(
              child: Padding(
                padding: AppSpacing.insetsLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.itemName, style: AppTextStyles.titleMedium),
                    const SizedBox(height: AppSpacing.md),

                    _buildDetailRow('Brand', item.brand),
                    if (item.itemSize != null && item.itemSize != '0')
                      _buildDetailRow('Size', item.itemSize!),

                    if (itemColor != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Color', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutral500)),
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: itemColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.neutral300),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Pricing Breakdown Card
            Card(
              child: Padding(
                padding: AppSpacing.insetsLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Payment Summary', style: AppTextStyles.titleSmall),
                    const Divider(height: AppSpacing.xl),

                    _buildPriceRow('Unit Price', item.unitPrice),
                    _buildPriceRow('Quantity', item.qty.toDouble(), isCurrency: false),

                    if (hasDiscount) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Discount Applied', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
                          Text(
                            '- ${item.itemDiscount.toStringAsFixed(2)}',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
                          ),
                        ],
                      ),
                    ],

                    const Divider(height: AppSpacing.xl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Amount', style: AppTextStyles.titleMedium),
                        Text(
                          item.totalPrice.toStringAsFixed(2),
                          style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Rating Section (Only shown if delivered)
            if (isDelivered) ...[
              Text('Rate Your Item', style: AppTextStyles.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              Card(
                child: Padding(
                  padding: AppSpacing.insetsLg,
                  child: ItemReviewSection(
                    itemId: item.itemId,
                    currentUsername: currentUsername,
                  ),
                ),
              ),
            ] else ...[
              Center(
                child: Text(
                  'Rating will be available once the item is delivered.',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral500),
                  textAlign: TextAlign.center,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutral500)),
          Text(value, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double value, {bool isCurrency = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutral500)),
          Text(
            isCurrency ? value.toStringAsFixed(2) : value.toInt().toString(),
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}