import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../../models/order_detail_item_model.dart';
import '../../../core/app/app_theme.dart';
import '../../../src/shared/widgets/item_review_section.dart';
import '../../../src/state/auth_state.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({
    super.key,
    required this.orderId,
    required this.orderNo,
  });

  final int orderId;
  final String orderNo;

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late final OrderRepository _orderRepository;
  late Future<List<OrderDetailItemModel>> _detailsFuture;

  @override
  void initState() {
    super.initState();
    _orderRepository = Get.find<OrderRepository>();
    _detailsFuture = _orderRepository.getOrderDetails(widget.orderId);
  }

  Future<void> _reload() async {
    setState(() {
      _detailsFuture = _orderRepository.getOrderDetails(widget.orderId);
    });
    await _detailsFuture;
  }

  @override
  Widget build(BuildContext context) {
    final currentUsername =
        context.watch<AuthState>().user?.username.trim() ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(widget.orderNo)),
      body: FutureBuilder<List<OrderDetailItemModel>>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: AppTheme.padding,
                child: EmptyStateWidget(
                  icon: Icons.error_outline,
                  title: 'Unable to load order details',
                  subtitle: snapshot.error.toString(),
                  action: ElevatedButton.icon(
                    onPressed: _reload,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ),
              ),
            );
          }

          final items = snapshot.data ?? const <OrderDetailItemModel>[];
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: AppTheme.padding,
                child: EmptyStateWidget(
                  icon: Icons.receipt_long_outlined,
                  title: 'No order items found',
                  subtitle:
                      'There are no line items available for this order yet.',
                  action: ElevatedButton.icon(
                    onPressed: _reload,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              padding: AppTheme.padding,
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) => _OrderDetailCard(
                item: items[index],
                currentUsername: currentUsername,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OrderDetailCard extends StatelessWidget {
  const _OrderDetailCard({required this.item, required this.currentUsername});

  final OrderDetailItemModel item;
  final String currentUsername;

  @override
  Widget build(BuildContext context) {
    final isDelivered = item.deliveryStatus == 1;
    final size = item.itemSize?.trim() ?? '';

    return Card(
      child: Padding(
        padding: AppSpacing.insetsLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.itemName, style: AppTextStyles.titleSmall),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Brand: ${item.brand}',
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Color: ${item.color}',
                        style: AppTextStyles.bodySmall,
                      ),
                      if (size.isNotEmpty && size != '0') ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text('Size: $size', style: AppTextStyles.bodySmall),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: AppSpacing.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: (isDelivered ? Colors.green : Colors.amber)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                  child: Text(
                    isDelivered ? 'Delivered' : 'Pending',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isDelivered ? Colors.green : Colors.amber.shade800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '${item.qty} x \$${item.unitPrice.toStringAsFixed(2)} = \$${item.totalPrice.toStringAsFixed(2)}',
              style: AppTextStyles.bodyMedium,
            ),
            if (item.itemDiscount > 0) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Discount: ${item.itemDiscount.toStringAsFixed(2)}',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
              ),
            ],
            if (isDelivered) ...[
              const SizedBox(height: AppSpacing.sm),
              ItemReviewSection(
                itemId: item.itemId,
                currentUsername: currentUsername,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
