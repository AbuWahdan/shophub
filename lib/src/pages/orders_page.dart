import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../design/app_colors.dart';
import '../design/app_spacing.dart';
import '../design/app_text_styles.dart';
import '../l10n/l10n.dart';
import '../model/api_order.dart';
import '../services/product_service.dart';
import '../state/auth_state.dart';
import '../themes/theme.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final ProductService _productService = ProductService();
  late Future<List<ApiOrder>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    final authState = context.read<AuthState>();
    final username = authState.user?.username.trim() ?? '';
    _ordersFuture = username.isEmpty
        ? Future.value([])
        : _productService.getOrders(username: username);
  }

  Future<void> _onRefresh() async {
    setState(() {
      _loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.ordersTitle)),
      body: FutureBuilder<List<ApiOrder>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Failed to load orders',
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    snapshot.error.toString(),
                    style: AppTextStyles.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ElevatedButton(
                    onPressed: _onRefresh,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'No orders yet',
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'You haven\'t placed any orders',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              padding: AppTheme.padding,
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return _buildOrderCard(context, order);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, ApiOrder order) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailsScreen(order: order),
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
                  Expanded(
                    child: Text(
                      order.orderNo,
                      style: AppTextStyles.titleSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Container(
                    padding: AppSpacing.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: order.getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                    child: Text(
                      order.getStatusLabel(),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: order.getStatusColor(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Date: ${DateFormat.yMMMd().format(order.orderDate)}',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total:',
                    style: AppTextStyles.bodySmall,
                  ),
                  Text(
                    '\$${order.netAmount.toStringAsFixed(2)}',
                    style: AppTextStyles.titleMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}


class OrderDetailsScreen extends StatelessWidget {
  final ApiOrder order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: SingleChildScrollView(
        padding: AppTheme.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: AppSpacing.insetsLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Information',
                      style: AppTextStyles.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildInfoRow('Order Number', order.orderNo),
                    _buildInfoRow('Username', order.username),
                    _buildInfoRow(
                      'Order Date',
                      DateFormat.yMMMd().add_jm().format(order.orderDate),
                    ),
                    _buildInfoRow(
                      'Created Date',
                      DateFormat.yMMMd().add_jm().format(order.createdDate),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Card(
              child: Padding(
                padding: AppSpacing.insetsLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Status',
                      style: AppTextStyles.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      padding: AppSpacing.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: order.getStatusColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      ),
                      child: Text(
                        order.getStatusLabel(),
                        style: AppTextStyles.labelLarge.copyWith(
                          color: order.getStatusColor(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Card(
              child: Padding(
                padding: AppSpacing.insetsLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Summary',
                      style: AppTextStyles.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildSummaryRow(
                      'Total Amount',
                      order.totalAmount,
                    ),
                    _buildSummaryRow(
                      'Tax Amount',
                      order.taxAmount,
                    ),
                    if (order.discountAmount > 0)
                      _buildSummaryRow(
                        'Discount Amount',
                        order.discountAmount,
                        isDiscount: true,
                      ),
                    const Divider(height: AppSpacing.xl),
                    _buildSummaryRow(
                      'Net Amount',
                      order.netAmount,
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double value, {
    bool isBold = false,
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isBold ? AppTextStyles.labelLarge : AppTextStyles.bodyMedium,
          ),
          Text(
            '${isDiscount ? '-' : ''}\$${value.toStringAsFixed(2)}',
            style: (isBold ? AppTextStyles.labelLarge : AppTextStyles.bodyMedium)
                .copyWith(
              color: isDiscount ? AppColors.error : null,
            ),
          ),
        ],
      ),
    );
  }
}
