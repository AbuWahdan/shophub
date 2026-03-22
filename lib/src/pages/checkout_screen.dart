import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../config/route.dart';
import '../design/app_colors.dart';
import '../design/app_spacing.dart';
import '../design/app_text_styles.dart';
import '../l10n/l10n.dart';
import '../model/cart_item.dart';
import '../model/delivery_location.dart';
import '../services/api_client.dart';
import '../shared/widgets/app_button.dart';
import '../shared/widgets/app_snackbar.dart';
import '../themes/theme.dart';
import '../state/auth_state.dart';
import 'order_confirmation_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({
    super.key,
    required this.cartItems,
  });

  final List<CartItem> cartItems;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const String _baseUrl = 'https://oracleapex.com/ords/topg/products';
  final http.Client _client = ApiClient();
  bool _isSubmitting = false;
  DeliveryLocation? _selectedDeliveryLocation;

  double get _totalPrice {
    return widget.cartItems.fold(0, (sum, item) => sum + item.total);
  }

  Map<String, dynamic> _buildOrderPayload() {
    final authState = context.read<AuthState>();
    final username = authState.user?.username.trim() ?? '';
    final userId = authState.userId;

    return {
      'username': username,
      'user_id': userId,
      'total': _totalPrice,
      'delivery_address': _selectedDeliveryLocation?.label ?? '',
      'delivery_lat': _selectedDeliveryLocation?.lat,
      'delivery_lng': _selectedDeliveryLocation?.lng,
      'items': widget.cartItems
          .map(
            (item) => {
              'item_id': item.product.id,
              'item_det_id':
                  item.selectedDetId > 0 ? item.selectedDetId : item.product.detId,
              'item_qty': item.quantity,
              'item_price': item.product.finalPrice,
              'item_name': item.product.name,
              'color': item.selectedColor,
              'item_size': item.selectedSize,
            },
          )
          .toList(),
    };
  }

  Future<void> _openDeliveryLocationScreen() async {
    final location = await Navigator.pushNamed<DeliveryLocation>(
      context,
      AppRoutes.deliveryLocation,
      arguments: {
        'savedAddresses': _selectedDeliveryLocation != null
            ? [_selectedDeliveryLocation!]
            : []
      },
    );

    if (location != null) {
      setState(() => _selectedDeliveryLocation = location);
      AppSnackBar.show(
        context,
        message: 'Delivery address updated',
        type: AppSnackBarType.success,
      );
    }
  }

  Future<void> _placeOrder() async {
    if (_isSubmitting) return;
    if (widget.cartItems.isEmpty) {
      AppSnackBar.show(
        context,
        message: 'Your cart is empty.',
        type: AppSnackBarType.warning,
      );
      return;
    }

    if (_selectedDeliveryLocation == null) {
      AppSnackBar.show(
        context,
        message: 'Please select a delivery address',
        type: AppSnackBarType.warning,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/CheckOut'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(_buildOrderPayload()),
      );
      final body = response.body.trim();
      final decoded = body.isEmpty ? null : jsonDecode(body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          decoded is Map<String, dynamic>
              ? decoded['message']?.toString() ?? body
              : body,
        );
      }
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OrderConfirmationScreen(
            receipt: decoded is Map<String, dynamic> ? decoded : const {},
            total: _totalPrice,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: error.toString(),
        type: AppSnackBarType.error,
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.checkoutTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppTheme.padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.checkoutOrderSummary, style: AppTextStyles.headingMedium),
              const SizedBox(height: AppSpacing.md),
              if (widget.cartItems.isEmpty)
                Text(
                  l10n.cartEmptyMessage,
                  style: AppTextStyles.bodyMedium,
                )
              else
                ...widget.cartItems.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _OrderSummaryRow(item: item),
                  ),
                ),
              const Divider(height: AppSpacing.xl),
              const SizedBox(height: AppSpacing.md),
              // Delivery Address Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Delivery Address',
                    style: AppTextStyles.titleSmall,
                  ),
                  GestureDetector(
                    onTap: _openDeliveryLocationScreen,
                    child: const Icon(Icons.edit, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              GestureDetector(
                onTap: _openDeliveryLocationScreen,
                child: Container(
                  padding: AppSpacing.insetsMd,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _selectedDeliveryLocation != null
                          ? AppColors.primary
                          : Colors.grey[300]!,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: _selectedDeliveryLocation != null
                        ? AppColors.primary.withOpacity(0.05)
                        : Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 20,
                        color: _selectedDeliveryLocation != null
                            ? AppColors.primary
                            : Colors.grey,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedDeliveryLocation?.label ??
                                  'Select delivery address',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: _selectedDeliveryLocation != null
                                    ? null
                                    : Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.checkoutTotal, style: AppTextStyles.titleMedium),
                  Text(
                    '\$${_totalPrice.toStringAsFixed(2)}',
                    style: AppTextStyles.priceMedium,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: 'Place Order',
                leading: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
                onPressed: (_isSubmitting || _selectedDeliveryLocation == null)
                    ? null
                    : _placeOrder,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderSummaryRow extends StatelessWidget {
  const _OrderSummaryRow({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final total = item.total;
    return Container(
      padding: AppSpacing.insetsMd,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: AppTextStyles.labelLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Qty: ${item.quantity}',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '\$${item.product.finalPrice.toStringAsFixed(2)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${total.toStringAsFixed(2)}',
            style: AppTextStyles.labelLarge,
          ),
        ],
      ),
    );
  }
}
