import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/order_repository.dart';
import '../design/app_colors.dart';
import '../design/app_spacing.dart';
import '../design/app_text_styles.dart';
import '../l10n/l10n.dart';
import '../model/api_order.dart';
import '../state/auth_state.dart';
import '../themes/theme.dart';
import 'order_details_screen.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late final OrderRepository _orderRepository;
  late Future<List<ApiOrder>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _orderRepository = Get.find<OrderRepository>();
    _loadOrders();
  }

  void _loadOrders() {
    final authState = context.read<AuthState>();
    final username = authState.user?.username.trim() ?? '';
    _ordersFuture = username.isEmpty
        ? Future.value([])
        : _orderRepository.getOrders(username: username);
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
                  Icon(Icons.error_outline, size: 64, color: AppColors.error),
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
                  Text('No orders yet', style: AppTextStyles.titleMedium),
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
              builder: (context) => OrderDetailsScreen(
                orderId: order.orderId,
                orderNo: order.orderNo,
              ),
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
                  Text('Total:', style: AppTextStyles.bodySmall),
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
