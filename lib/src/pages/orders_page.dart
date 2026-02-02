import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../design/app_colors.dart';
import '../design/app_spacing.dart';
import '../design/app_text_styles.dart';
import '../l10n/l10n.dart';
import '../l10n/order_l10n.dart';
import '../model/data.dart';
import '../model/order.dart';
import '../shared/widgets/app_image.dart';
import '../themes/theme.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.ordersTitle)),
      body: ListView.builder(
        padding: AppTheme.padding,
        itemCount: AppData.orderList.length,
        itemBuilder: (context, index) {
          final order = AppData.orderList[index];
          return _buildOrderCard(context, order);
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailsPage(order: order),
            ),
          );
        },
        child: Padding(
          padding: AppSpacing.insetsLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.ordersOrderId(order.id),
                    style: AppTextStyles.titleSmall(context),
                  ),
                  Container(
                    padding: AppSpacing.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                    child: Text(
                      order.status.label(context),
                      style: AppTextStyles.labelSmall(context)
                          .copyWith(color: _getStatusColor(order.status)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                context.l10n.ordersPlacedOn(
                  DateFormat.yMMMd(Localizations.localeOf(context).toString())
                      .format(order.date),
                ),
                style: AppTextStyles.bodySmall(context),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.ordersItemCount(order.items.length),
                    style: AppTextStyles.bodySmall(context),
                  ),
                  Text(
                    '\$${order.total.toStringAsFixed(2)}',
                    style: AppTextStyles.titleMedium(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                context.l10n.ordersEstimatedDelivery(order.estimatedDelivery),
                style: AppTextStyles.bodySmall(context)
                    .copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.processing:
        return AppColors.primary;
      case OrderStatus.shipped:
        return AppColors.secondary;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }
}

class OrderDetailsPage extends StatelessWidget {
  final Order order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.orderDetailsTitle)),
      body: SingleChildScrollView(
        padding: AppTheme.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusTimeline(context),
            const SizedBox(height: AppSpacing.xxxl),
            Text(
              context.l10n.orderDetailsItems,
              style: AppTextStyles.titleMedium(context),
            ),
            const SizedBox(height: AppSpacing.lg),
            ...order.items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: Row(
                  children: [
                    AppImage(
                      path: item.image,
                      width: AppSpacing.imageSm,
                      height: AppSpacing.imageSm,
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: AppTextStyles.bodyLarge(context),
                          ),
                          if (item.selectedSize != null)
                            Text(
                              context.l10n.orderDetailsSize(
                                item.selectedSize!,
                              ),
                              style: AppTextStyles.bodySmall(context),
                            ),
                          if (item.selectedColor != null)
                            Text(
                              context.l10n.orderDetailsColor(
                                item.selectedColor!,
                              ),
                              style: AppTextStyles.bodySmall(context),
                            ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          context.l10n.orderDetailsQuantity(item.quantity),
                          style: AppTextStyles.labelLarge(context),
                        ),
                        Text(
                          '\$${item.price}',
                          style: AppTextStyles.bodyMedium(context),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            const Divider(height: AppSpacing.xxxl),
            _buildSummaryRow(
              context,
              context.l10n.orderDetailsSubtotal,
              order.subtotal,
            ),
            _buildSummaryRow(
              context,
              context.l10n.orderDetailsShipping,
              order.shipping,
            ),
            if (order.discount > 0)
              _buildSummaryRow(
                context,
                context.l10n.orderDetailsDiscount,
                -order.discount,
              ),
            const Divider(),
            _buildSummaryRow(
              context,
              context.l10n.orderDetailsTotal,
              order.total,
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTimeline(BuildContext context) {
    final statuses = [
      OrderStatus.pending,
      OrderStatus.processing,
      OrderStatus.shipped,
      OrderStatus.delivered,
    ];

    final currentStatusIndex = statuses.indexOf(order.status);

    return Column(
      children: [
        Text(
          context.l10n.orderDetailsStatus,
          style: AppTextStyles.titleMedium(context),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            ...List.generate(statuses.length, (index) {
              final isCompleted = index <= currentStatusIndex;
              return Expanded(
                child: Column(
                  children: [
                    Container(
                      width: AppSpacing.jumbo,
                      height: AppSpacing.jumbo,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? AppColors.success
                            : AppColors.neutral300,
                      ),
                      child: Center(
                        child: Icon(
                          isCompleted ? Icons.check : Icons.circle,
                          color: isCompleted
                              ? AppColors.white
                              : AppColors.neutral500,
                          size: AppSpacing.iconMd,
                        ),
                      ),
                    ),
                    if (index < statuses.length - 1)
                      Container(
                        height: AppSpacing.borderThick,
                        color: isCompleted
                            ? AppColors.success
                            : AppColors.neutral300,
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: statuses.map((status) {
            return Text(
              status.label(context),
              style: AppTextStyles.bodySmall(context),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    double value, {
    bool isBold = false,
  }) {
    return Padding(
      padding: AppSpacing.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isBold
                ? AppTextStyles.titleSmall(context)
                : AppTextStyles.bodySmall(context),
          ),
          Text(
            '\$${value.toStringAsFixed(2)}',
            style: isBold
                ? AppTextStyles.titleSmall(context)
                : AppTextStyles.bodySmall(context),
          ),
        ],
      ),
    );
  }
}
