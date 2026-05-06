import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/state/auth_state.dart';
import '../../../../models/orders_model.dart';
import '../../../design/app_colors.dart';
import '../../../design/app_radius.dart';
import '../../../design/app_spacing.dart';
import '../../../design/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../repositories/order_repository.dart';
import 'order_details_screen.dart';
import 'widgets/order_status_badge.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late final OrderRepository _orderRepository;
  late Future<List<OrdersModel>> _ordersFuture;

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
    await _ordersFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).ordersTitle)),

      body: FutureBuilder<List<OrdersModel>>(
        future: _ordersFuture,

        builder: (context, snapshot) {
          /// =========================
          /// LOADING
          /// =========================

          if (snapshot.connectionState == ConnectionState.waiting) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: const CustomScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              ),
            );
          }

          /// =========================
          /// ERROR
          /// =========================

          if (snapshot.hasError) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: AppSpacing.insetsLg,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        MediaQuery.sizeOf(context).height -
                        kToolbarHeight -
                        AppSpacing.xl,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 70,
                        color: AppColors.error,
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      Text(
                        AppLocalizations.of(context).errorLoadingOrders ??
                            'Failed to load orders',
                        style: AppTextStyles.titleMedium,
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      Text(
                        snapshot.error.toString(),
                        style: AppTextStyles.bodySmall,
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      ElevatedButton.icon(
                        onPressed: _onRefresh,
                        icon: const Icon(Icons.refresh),
                        label: Text(AppLocalizations.of(context).retry),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final orders = snapshot.data ?? [];

          /// =========================
          /// EMPTY
          /// =========================

          if (orders.isEmpty) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: AppSpacing.insetsLg,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        MediaQuery.sizeOf(context).height -
                        kToolbarHeight -
                        AppSpacing.xl,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.shopping_bag_outlined,
                        size: 70,
                        color: AppColors.neutral400,
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      Text(
                        AppLocalizations.of(context).noOrdersYet ??
                            'No orders yet',
                        style: AppTextStyles.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          /// =========================
          /// LIST
          /// =========================

          return RefreshIndicator(
            onRefresh: _onRefresh,

            child: ListView.builder(
              padding: AppSpacing.insetsMd,
              itemCount: orders.length,

              itemBuilder: (context, index) {
                return _buildOrderCard(context, orders[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrdersModel order) {
    final currency = NumberFormat.currency(symbol: 'JOD ', decimalDigits: 2);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),

      clipBehavior: Clip.antiAlias,

      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),

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
              /// =========================
              /// HEADER
              /// =========================
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ORDER INFO
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// ORDER NUMBER
                        Text(
                          order.orderNo.isEmpty
                              ? '#${order.orderId}'
                              : order.orderNo,

                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),

                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: AppSpacing.xs),

                        /// USERNAME
                        Text(
                          order.username.isEmpty ? '-' : order.username,

                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.neutral600,
                          ),

                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: AppSpacing.md),

                  OrderStatusBadge(status: _deliveryStatusFor(order)),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              /// =========================
              /// ORDER DETAILS
              /// =========================
              Container(
                padding: AppSpacing.insetsMd,

                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),

                child: Column(
                  children: [
                    _buildInfoRow(
                      title: 'Order ID',
                      value: order.orderId.toString(),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    _buildInfoRow(
                      title: 'Order Date',
                      value: DateFormat.yMMMd().format(order.orderDate),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    _buildInfoRow(
                      title: 'Created Date',
                      value: DateFormat.yMMMd().format(order.createdDate),
                    ),

                    const Divider(height: AppSpacing.xl),

                    _buildPriceRow(
                      title: 'Total Amount',
                      value: currency.format(order.totalAmount),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    _buildPriceRow(
                      title: 'Tax Amount',
                      value: currency.format(order.taxAmount),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    _buildPriceRow(
                      title: 'Discount Amount',
                      value: currency.format(order.discountAmount),
                      valueColor: Colors.red,
                    ),

                    const Divider(height: AppSpacing.xl),

                    _buildPriceRow(
                      title: 'Net Amount',
                      value: currency.format(order.netAmount),

                      isBold: true,
                    ),
                  ],
                ),
              ),

              /// =========================
              /// ITEMS
              /// =========================
              if (order.items.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),

                Text(
                  'Items (${order.items.length})',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                ...order.items
                    .take(3)
                    .map(
                      (item) => Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),

                        padding: AppSpacing.insetsMd,

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.md),

                          border: Border.all(color: AppColors.neutral200),
                        ),

                        child: Row(
                          children: [
                            /// IMAGE
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppRadius.md),

                              // child: SizedBox(
                              //   width: 60,
                              //   height: 60,
                              //
                              //   child: item.productImage.isNotEmpty
                              //       ? Image.network(
                              //     item.productImage,
                              //     fit: BoxFit.cover,
                              //
                              //     errorBuilder:
                              //         (_, __, ___) {
                              //       return Container(
                              //         color: AppColors.neutral100,
                              //         child: const Icon(
                              //           Icons.image_not_supported_outlined,
                              //         ),
                              //       );
                              //     },
                              //   )
                              //       : Container(
                              //     color: AppColors.neutral100,
                              //     child: const Icon(
                              //       Icons.inventory_2_outlined,
                              //     ),
                              //   ),
                              // ),
                            ),

                            const SizedBox(width: AppSpacing.md),

                            /// PRODUCT INFO
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName.isEmpty
                                        ? 'Unknown Product'
                                        : item.productName,

                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),

                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  const SizedBox(height: AppSpacing.xs),

                                  Text(
                                    'Item ID: ${item.itemId}',
                                    style: AppTextStyles.bodySmall,
                                  ),

                                  const SizedBox(height: AppSpacing.xs),

                                  Text(
                                    'Quantity: ${item.quantity}',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: AppSpacing.md),

                            /// PRICE
                            Text(
                              currency.format(item.price),

                              style: AppTextStyles.titleSmall.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                /// MORE ITEMS
                if (order.items.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),

                    child: Text(
                      '+${order.items.length - 3} more items',

                      style: AppTextStyles.bodySmall.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _deliveryStatusFor(OrdersModel order) {
    final deliveredItem = order.items.firstWhereOrNull(
      (item) => item.deliveryStatus > 0,
    );
    if (deliveredItem != null) {
      return OrderStatusBadge.labelFromDeliveryStatus(
        deliveredItem.deliveryStatus,
      );
    }
    return order.statusRaw;
  }

  Widget _buildInfoRow({required String title, required String value}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.neutral600,
            ),
          ),
        ),

        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildPriceRow({
    required String title,
    required String value,
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,

            style: isBold
                ? AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold)
                : AppTextStyles.bodyMedium,
          ),
        ),

        Text(
          value,

          style: (isBold ? AppTextStyles.titleSmall : AppTextStyles.bodyMedium)
              .copyWith(
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,

                color: valueColor,
              ),
        ),
      ],
    );
  }
}
