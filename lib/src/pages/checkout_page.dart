import 'package:flutter/material.dart';

import '../config/app_constants.dart';
import '../design/app_colors.dart';
import '../design/app_spacing.dart';
import '../design/app_text_styles.dart';
import '../l10n/l10n.dart';
import '../model/address.dart';
import '../model/data.dart';
import '../shared/widgets/app_image.dart';
import 'order_success_screen.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  int _currentStep = 0;
  late Address _selectedAddress;
  String _selectedPaymentMethod = 'card';

  @override
  void initState() {
    super.initState();
    _selectedAddress = AppData.addressList.first;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.checkoutTitle)),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() {
              _currentStep++;
            });
          } else {
            _showOrderConfirmation();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep--;
            });
          }
        },
        steps: [
          Step(
            title: Text(l10n.checkoutDeliveryAddress),
            content: _buildAddressStep(),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: Text(l10n.checkoutPaymentMethod),
            content: _buildPaymentStep(),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: Text(l10n.checkoutOrderReview),
            content: _buildReviewStep(),
            isActive: _currentStep >= 2,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...AppData.addressList.map((address) {
          return Card(
            child: RadioListTile<String>(
              title: Text(address.name, style: AppTextStyles.bodyLarge(context)),
              subtitle:
                  Text(address.fullAddress, style: AppTextStyles.bodySmall(context)),
              value: address.id,
              groupValue: _selectedAddress.id,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedAddress = AppData.addressList.firstWhere(
                      (a) => a.id == value,
                    );
                  });
                }
              },
            ),
          );
        }),
        const SizedBox(height: AppSpacing.lg),
        ElevatedButton.icon(
          onPressed: () {
            // Navigate to add address
          },
          icon: const Icon(Icons.add),
          label: Text(context.l10n.checkoutAddNewAddress),
        ),
      ],
    );
  }

  Widget _buildPaymentStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPaymentOption(
          'card',
          context.l10n.checkoutPaymentCard,
          Icons.credit_card,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildPaymentOption(
          'cod',
          context.l10n.checkoutPaymentCash,
          Icons.local_atm,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildPaymentOption(
          'wallet',
          context.l10n.checkoutPaymentWallet,
          Icons.account_balance_wallet,
          enabled: false,
        ),
      ],
    );
  }

  Widget _buildPaymentOption(
    String value,
    String label,
    IconData icon, {
    bool enabled = true,
  }) {
    return Card(
      child: RadioListTile<String>(
        title: Text(label, style: AppTextStyles.bodyLarge(context)),
        secondary: Icon(icon),
        value: value,
        groupValue: _selectedPaymentMethod,
        onChanged: enabled
            ? (val) {
                if (val != null) {
                  setState(() {
                    _selectedPaymentMethod = val;
                  });
                }
              }
            : null,
      ),
    );
  }

  Widget _buildReviewStep() {
    double subtotal = 0;
    double shipping = AppConstants.checkoutShippingFlat;
    double discount = 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.checkoutOrderSummary,
          style: AppTextStyles.titleMedium(context),
        ),
        const SizedBox(height: AppSpacing.lg),
        ...AppData.cartList.map((item) {
          subtotal += item.finalPrice;
          return ListTile(
            leading: AppImage(
              path: item.images[0],
              width: AppSpacing.imageSm,
              height: AppSpacing.imageSm,
            ),
            title: Text(item.name, style: AppTextStyles.bodyLarge(context)),
            subtitle: Text(
              context.l10n.checkoutQuantity(1),
              style: AppTextStyles.bodySmall(context),
            ),
            trailing: Text(
              '\$${item.finalPrice}',
              style: AppTextStyles.bodyMedium(context),
            ),
          );
        }),
        const Divider(),
        _buildSummaryRow(
          context.l10n.checkoutSubtotal,
          '\$${subtotal.toStringAsFixed(2)}',
        ),
        _buildSummaryRow(
          context.l10n.checkoutShipping,
          '\$${shipping.toStringAsFixed(2)}',
        ),
        if (discount > 0)
          _buildSummaryRow(
            context.l10n.checkoutDiscount,
            '-\$${discount.toStringAsFixed(2)}',
            color: AppColors.accentOrange,
          ),
        const Divider(),
        _buildSummaryRow(
          context.l10n.checkoutTotal,
          '\$${(subtotal + shipping - discount).toStringAsFixed(2)}',
          isBold: true,
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
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
            value,
            style: (isBold
                    ? AppTextStyles.titleSmall(context)
                    : AppTextStyles.bodySmall(context))
                .copyWith(color: color),
          ),
        ],
      ),
    );
  }

  void _showOrderConfirmation() {
    // Calculate total from cart
    double total = 0;
    for (var item in AppData.cartList) {
      total += item.finalPrice;
    }

    final orderId =
        '${context.l10n.orderIdPrefix}${DateTime.now().millisecondsSinceEpoch}';

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            OrderSuccessScreen(orderId: orderId, totalAmount: total),
      ),
    );
  }
}
