import 'package:flutter/material.dart';
import '../../../../models/order_detail_item_model.dart';
import '../../products/widgets/item_review_section.dart';
import '../my_products/color_picker/color_parsing_extension.dart';
import '../../../design/app_colors.dart';
import '../../../design/app_spacing.dart';
import '../../../design/app_text_styles.dart';

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

    final unitPrice = item.unitPrice;
    final quantity = item.qty;

    final subtotal = unitPrice * quantity;
    final totalAfterDiscount =
        subtotal -  item.itemDiscount/100*item.unitPrice*item.qty;

    return Scaffold(
      appBar: AppBar(
        title: Text(item.itemName),
      ),

      body: SingleChildScrollView(
        padding: AppSpacing.insetsMd,

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.stretch,

          children: [


            Card(
              child: Padding(
                padding: AppSpacing.insetsLg,

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    Text(
                      item.itemName,
                      style: AppTextStyles.titleMedium,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    _row('Item ID', item.itemId.toString()),
                    _row('Detail ID', item.itemDetId.toString()),

                    if (item.brand.isNotEmpty)
                      _row('Brand', item.brand),


                      _row('Size', item.itemSize ?? ''),

                    _row('Quantity', item.qty.toString()),

                    const SizedBox(height: AppSpacing.sm),

                    /// COLOR
                    if (itemColor != null)
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,

                        children: [
                          Text(
                            'Color',
                            style: AppTextStyles.bodyMedium
                                .copyWith(
                              color: AppColors.neutral500,
                            ),
                          ),

                          Container(
                            width: 22,
                            height: 22,

                            decoration: BoxDecoration(
                              color: itemColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                AppColors.neutral300,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            /// =========================
            /// PRICING SECTION
            /// =========================
            Card(
              child: Padding(
                padding: AppSpacing.insetsLg,

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    Text(
                      'Pricing Breakdown',
                      style:
                      AppTextStyles.titleSmall,
                    ),

                    const Divider(),

                    _priceRow(
                      'Unit Price',
                      unitPrice,
                    ),

                    _priceRow(
                      'Quantity',
                      quantity.toDouble(),
                      isCurrency: false,
                    ),

                    _priceRow(
                      'Subtotal',
                      subtotal,
                      highlight: true,
                    ),

                    if (hasDiscount)
                      _priceRow(
                        'Discount',
                        item.itemDiscount/100*item.unitPrice*item.qty,
                        isNegative: true,
                      ),

                    const Divider(),

                    _priceRow(
                      'Total',
                      totalAfterDiscount,
                      highlight: true,
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            /// =========================
            /// STATUS
            /// =========================
            Container(
              padding: AppSpacing.insetsLg,

              decoration: BoxDecoration(
                color: (isDelivered
                    ? Colors.green
                    : Colors.orange)
                    .withOpacity(0.1),

                borderRadius: BorderRadius.circular(12),
              ),

              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

                children: [
                  Text(
                    'Status',
                    style: AppTextStyles.bodyMedium,
                  ),

                  Text(
                    isDelivered
                        ? 'Delivered'
                        : 'Pending',

                    style: AppTextStyles.bodyMedium
                        .copyWith(
                      color: isDelivered
                          ? Colors.green
                          : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            /// =========================
            /// REVIEW SECTION
            /// =========================
            if (isDelivered)
              Card(
                child: Padding(
                  padding: AppSpacing.insetsLg,
                  child: ItemReviewSection(
                    itemId: item.itemId,
                    currentUsername:
                    currentUsername,
                  ),
                ),
              )
            else
              Center(
                child: Text(
                  'You can review this item after delivery.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall
                      .copyWith(
                    color:
                    AppColors.neutral500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),

      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,

        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall
                .copyWith(
              color: AppColors.neutral500,
            ),
          ),

          Text(
            value,
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _priceRow(
      String label,
      double value, {
        bool isCurrency = true,
        bool isBold = false,
        bool isNegative = false,
        bool highlight = false,
      }) {
    final textColor = isNegative
        ? Colors.red
        : (highlight ? Colors.black : AppColors.neutral600);

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),

      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,

        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium,
          ),

          Text(
            isCurrency
                ? '${isNegative ? "-" : ""}${value.toStringAsFixed(2)} JOD'
                : value.toInt().toString(),

            style: AppTextStyles.bodyMedium.copyWith(
              color: textColor,
              fontWeight:
              isBold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}