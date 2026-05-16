import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../controllers/order_controller.dart';
import '../../../../core/state/auth_state.dart';
import '../../../../models/orders_model.dart';
import '../../../design/app_colors.dart';
import '../../../design/app_radius.dart';
import '../../../design/app_spacing.dart';
import '../../../design/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import 'order_details_screen.dart';
import 'widgets/order_status_badge.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOrders());
  }

  Future<void> _loadOrders() async {
    final authState = context.read<AuthState>();
    await authState.ensureInitialized();
    if (!mounted) return;
    final username = authState.user?.username.trim() ?? '';
    await context.read<OrderController>().loadOrders(username: username);
  }

  Future<void> _onRefresh() async {
    await _loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = context.watch<OrderController>();
    final orders = controller.orders;
    final error = controller.error.trim();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ordersTitle)),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: _buildOrdersBody(
          context: context,
          controller: controller,
          orders: orders,
          error: error,
          l10n: l10n,
        ),
      ),
    );
  }

  Widget _buildOrdersBody({
    required BuildContext context,
    required OrderController controller,
    required List<OrdersModel> orders,
    required String error,
    required AppLocalizations l10n,
  }) {
    if (controller.isLoading && orders.isEmpty) {
      return const CustomScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

    if (error.isNotEmpty && orders.isEmpty) {
      return _OrdersStateMessage(
        icon: Icons.error_outline,
        iconColor: AppColors.error,
        title: l10n.errorLoadingOrders,
        subtitle: error,
        onRetry: _onRefresh,
      );
    }

    if (orders.isEmpty) {
      return _OrdersStateMessage(
        icon: Icons.shopping_bag_outlined,
        iconColor: AppColors.neutral400,
        title: l10n.noOrdersYet,
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: AppSpacing.insetsMd,
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(context, orders[index]);
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, OrdersModel order) {
    final l10n = AppLocalizations.of(context);
    final currency = NumberFormat.simpleCurrency(
      locale: Localizations.localeOf(context).toLanguageTag(),
    );
    final promoCode = order.promoCode?.trim() ?? '';

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
                order: order,
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
                      title: l10n.orderIdLabel,
                      value: order.orderId.toString(),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    _buildInfoRow(
                      title: l10n.orderDateLabel,
                      value: DateFormat.yMMMd().format(order.orderDate),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    _buildInfoRow(
                      title: l10n.orderCreatedDateLabel,
                      value: DateFormat.yMMMd().format(order.createdDate),
                    ),

                    const Divider(height: AppSpacing.xl),

                    if (promoCode.isNotEmpty) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Chip(
                          label: Text(l10n.orderPromoApplied(promoCode)),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],

                    _buildPriceRow(
                      title: l10n.orderSubtotal,
                      value: currency.format(order.totalAmount),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    _buildPriceRow(
                      title: l10n.orderTax,
                      value: currency.format(order.taxAmount),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    _buildPriceRow(
                      title: l10n.orderDiscount,
                      value: currency.format(order.discountAmount),
                      valueColor: AppColors.error,
                    ),

                    if (order.promoDiscountAmount > 0) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _buildPriceRow(
                        title: l10n.orderPromoDiscount,
                        value: currency.format(order.promoDiscountAmount),
                        valueColor: AppColors.error,
                      ),
                    ],

                    const Divider(height: AppSpacing.xl),

                    _buildPriceRow(
                      title: l10n.orderTotal,
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
                  l10n.orderItemsCount(order.items.length),
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
                                        ? l10n.unknownProduct
                                        : item.productName,

                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),

                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  const SizedBox(height: AppSpacing.xs),

                                  Text(
                                    '${l10n.orderIdLabel}: ${item.itemId}',
                                    style: AppTextStyles.bodySmall,
                                  ),

                                  const SizedBox(height: AppSpacing.xs),

                                  Text(
                                    '${l10n.quantityShortLabel}: ${item.quantity}',
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
                      l10n.orderMoreItems(order.items.length - 3),

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
    for (final item in order.items) {
      if (item.deliveryStatusCode > 0) {
        return OrderStatusBadge.labelFromDeliveryStatus(item.deliveryStatusCode);
      }
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

class _OrdersStateMessage extends StatelessWidget {
  const _OrdersStateMessage({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.onRetry,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
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
            Icon(icon, size: AppSpacing.xxl, color: iconColor),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTextStyles.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null && subtitle!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle!,
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
