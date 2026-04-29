import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../core/exceptions/color_parsing_extension.dart';
import '../../../design/app_colors.dart';
import '../../../design/app_radius.dart';
import '../../../design/app_spacing.dart';
import '../../../design/app_text_styles.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../../models/order_detail_item_model.dart';
import '../../../core/app/app_theme.dart';
import '../../../core/state/auth_state.dart';
import 'single_ordered_item_screen.dart'; // The new detail screen

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
    final currentUsername = context.watch<AuthState>().user?.username.trim() ?? '';

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
                padding: AppSpacing.insetsMd,
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
                padding: AppSpacing.insetsMd,
                child: EmptyStateWidget(
                  icon: Icons.receipt_long_outlined,
                  title: 'No order items found',
                  subtitle: 'There are no line items available for this order yet.',
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
              padding: AppSpacing.insetsMd,
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) => _OrderProductListItem(
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

class _OrderProductListItem extends StatelessWidget {
  const _OrderProductListItem({required this.item, required this.currentUsername});

  final OrderDetailItemModel item;
  final String currentUsername;

  @override
  Widget build(BuildContext context) {
    final isDelivered = item.deliveryStatus == 1;
    final itemColor = item.color.toColor(); // Utilizes the extension

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SingleOrderedItemScreen(
                item: item,
                currentUsername: currentUsername,
              ),
            ),
          );
        },
        child: Padding(
          padding: AppSpacing.insetsLg,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.itemName, style: AppTextStyles.titleSmall),
                    const SizedBox(height: AppSpacing.xs),

                    // Conditionally render attributes
                    if (item.brand.isNotEmpty)
                      Text('Brand: ${item.brand}', style: AppTextStyles.bodySmall),

                    if (item.itemSize != null && item.itemSize != '0')
                      Text('Size: ${item.itemSize}', style: AppTextStyles.bodySmall),

                    const SizedBox(height: AppSpacing.xs),

                    // Render Visual Color instead of Hex Text
                    if (itemColor != null)
                      Row(
                        children: [
                          Text('Color: ', style: AppTextStyles.bodySmall),
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: itemColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.neutral300, width: 1),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // Status & Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: AppSpacing.insetsMd,
                    decoration: BoxDecoration(
                      color: (isDelivered ? Colors.green : Colors.amber).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Text(
                      isDelivered ? 'Delivered' : 'Pending',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isDelivered ? Colors.green : Colors.amber.shade800,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    item.totalPrice.toStringAsFixed(2),
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