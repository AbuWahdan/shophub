import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../models/order_detail_item_model.dart';
import '../../../../models/orders_model.dart';
import '../../../models/product/product_model.dart';
import '../../../repositories/order_repository.dart';
import '../../../widgets/product_card/add_to_cart_bottom_sheet/widgets/add_to_cart_action.dart';
import '../my_products/color_picker/color_parsing_extension.dart';
import '../../../core/state/auth_state.dart';
import '../../../design/app_colors.dart';
import '../../../design/app_radius.dart';
import '../../../design/app_spacing.dart';
import '../../../design/app_text_styles.dart';
import '../../../widgets/custom_empty_state/custom_empty_state.dart';
import 'single_ordered_item_screen.dart';

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
    _detailsFuture = _fetchDetails();
  }

  Future<List<OrderDetailItemModel>> _fetchDetails() =>
      _orderRepository.getOrderDetails(widget.orderId);

  void _reload() {
    setState(() => _detailsFuture = _fetchDetails());
  }

  Future<void> _refreshDetails() async {
    _reload();
    await _detailsFuture;
  }

  @override
  Widget build(BuildContext context) {
    final username = context.watch<AuthState>().user?.username.trim() ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(widget.orderNo)),
      body: FutureBuilder<List<OrderDetailItemModel>>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return RefreshIndicator(
              onRefresh: _refreshDetails,
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

          if (snapshot.hasError) {
            return RefreshIndicator(
              onRefresh: _refreshDetails,
              child: _ErrorView(
                subtitle: snapshot.error.toString(),
                onRetry: _reload,
              ),
            );
          }

          final items = snapshot.data ?? const [];
          if (items.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshDetails,
              child: _EmptyOrderView(onRetry: _reload),
            );
          }

          final order = _buildOrderSummary(items, username);

          return RefreshIndicator(
            onRefresh: _refreshDetails,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: AppSpacing.insetsMd,
              children: [
                _OrderSummaryCard(order: order),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Order Items (${items.length})',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ...items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _OrderProductListItem(
                      item: item,
                      currentUsername: username,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  OrdersModel _buildOrderSummary(
    List<OrderDetailItemModel> items,
    String username,
  ) {
    final totalAmount = items.fold<double>(0, (s, i) => s + i.totalPrice);
    final isDelivered = items.any((e) => e.deliveryStatus == 1);

    return OrdersModel(
      orderId: widget.orderId,
      orderNo: widget.orderNo,
      username: username,
      orderDate: DateTime.now(),
      totalAmount: totalAmount,
      taxAmount: 0,
      discountAmount: 0,
      netAmount: totalAmount,
      statusRaw: isDelivered ? 'Delivered' : 'Pending',
      createdDate: DateTime.now(),
      items: items
          .map(
            (e) => ApiOrderItem(
              itemId: e.itemId,
              itemDetId: e.itemDetId,
              productName: e.itemName,
              quantity: e.qty,
              price: e.totalPrice,
            ),
          )
          .toList(),
    );
  }
}

// ── Error / Empty states ───────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.subtitle, required this.onRetry});

  final String subtitle;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.insetsMd,
        child: CustomEmptyState(
          icon: Icons.error_outline,
          title: 'Unable to load order details',
          subtitle: subtitle,
          action: ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ),
      ),
    );
  }
}

class _EmptyOrderView extends StatelessWidget {
  const _EmptyOrderView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.insetsMd,
        child: CustomEmptyState(
          icon: Icons.receipt_long_outlined,
          title: 'No order items found',
          subtitle: 'There are no line items available for this order yet.',
          action: ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ),
      ),
    );
  }
}

// ── Order summary card ─────────────────────────────────────────────────────────

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({required this.order});

  final OrdersModel order;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'JOD ', decimalDigits: 2);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: AppSpacing.insetsLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.orderNo,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(order.username, style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Info rows ─────────────────────────────────────────────────────
            _InfoRow(label: 'Order ID', value: order.orderId.toString()),
            const SizedBox(height: AppSpacing.sm),
            _InfoRow(
              label: 'Order Date',
              value: DateFormat.yMMMd().format(order.orderDate),
            ),
            const SizedBox(height: AppSpacing.sm),
            _InfoRow(
              label: 'Created Date',
              value: DateFormat.yMMMd().format(order.createdDate),
            ),
            const Divider(height: AppSpacing.xl),

            // ── Amounts ───────────────────────────────────────────────────────
            _PriceRow(
              label: 'Total Amount',
              value: currency.format(order.totalAmount),
            ),
            const SizedBox(height: AppSpacing.sm),
            _PriceRow(
              label: 'Tax Amount',
              value: currency.format(order.taxAmount),
            ),
            const SizedBox(height: AppSpacing.sm),
            _PriceRow(
              label: 'Discount Amount',
              value: currency.format(order.discountAmount),
              valueColor: Colors.red,
            ),
            const Divider(height: AppSpacing.xl),
            _PriceRow(
              label: 'Net Amount',
              value: currency.format(order.netAmount),
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
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
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final labelStyle = isBold
        ? AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold)
        : AppTextStyles.bodyMedium;
    final valueStyle =
        (isBold ? AppTextStyles.titleSmall : AppTextStyles.bodyMedium).copyWith(
          fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          color: valueColor,
        );

    return Row(
      children: [
        Expanded(child: Text(label, style: labelStyle)),
        Text(value, style: valueStyle),
      ],
    );
  }
}

// ── Order product list item ────────────────────────────────────────────────────

class _OrderProductListItem extends StatelessWidget {
  const _OrderProductListItem({
    required this.item,
    required this.currentUsername,
  });

  final OrderDetailItemModel item;
  final String currentUsername;

  /// Builds a minimal [ProductModel] from the order item fields so that
  /// [AddToCartAction] — which expects a [ProductModel] — can be reused
  /// without duplicating any cart logic.
  /// Maps [OrderDetailItemModel] → [ProductModel] using the exact field names
  /// from [ProductModel]'s constructor. Required fields are filled with safe
  /// defaults so the cart bottom sheet has everything it needs.
  ProductModel _toProductModel() {
    return ProductModel(
      id: item.itemId,
      detId: item.itemDetId,
      itemName: item.itemName,
      itemDesc: '',
      itemPrice: item.unitPrice,
      itemQty: item.qty,
      itemImgUrl: '',
      categoryId: 0,
      category: '',
      createdBy: '',
      isActive: 1,
      details: [
        ApiProductVariant(
          detId: item.itemDetId,
          brand: item.brand,
          color: item.color,
          itemSize: item.itemSize ?? '',
          discount: item.itemDiscount,
          itemPrice: item.unitPrice,
          itemQty: item.qty,
        ),
      ],
    );
  }

  Future<void> _addToCart(BuildContext context) async {
    await AddToCartAction.execute(context: context, product: _toProductModel());
  }

  @override
  Widget build(BuildContext context) {
    final itemColor = item.color.toColor();
    final discountedTotal =
        item.unitPrice * item.qty -
        (item.itemDiscount / 100) * item.unitPrice * item.qty;
    final currency = NumberFormat.currency(symbol: 'JOD ', decimalDigits: 2);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => SingleOrderedItemScreen(
              item: item,
              currentUsername: currentUsername,
            ),
          ),
        ),
        child: Padding(
          padding: AppSpacing.insetsLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Product info ─────────────────────────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.itemName,
                          style: AppTextStyles.titleSmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xs),

                        if (item.brand.isNotEmpty)
                          _ItemDetail(label: 'Brand', value: item.brand),

                        if (item.itemSize != null && item.itemSize != '0')
                          _ItemDetail(label: 'Size', value: item.itemSize!),

                        _ItemDetail(label: 'Qty', value: item.qty.toString()),

                        if (itemColor != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          _ColorIndicator(color: itemColor),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),

                  // ── Price ────────────────────────────────────────────────
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currency.format(discountedTotal),
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Add to cart button ───────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _addToCart(context),
                  icon: const Icon(Icons.add_shopping_cart_outlined),
                  label: const Text('Add to Cart'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Small reusable sub-widgets inside the list item ───────────────────────────

class _ItemDetail extends StatelessWidget {
  const _ItemDetail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text('$label: $value', style: AppTextStyles.bodySmall);
  }
}

class _ColorIndicator extends StatelessWidget {
  const _ColorIndicator({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Color: ', style: AppTextStyles.bodySmall),
        Container(
          width: AppSpacing.iconSm,
          height: AppSpacing.iconSm,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.neutral300),
          ),
        ),
      ],
    );
  }
}
