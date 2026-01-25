import 'package:flutter/material.dart';
import '../model/data.dart';
import '../model/address.dart';
import '../themes/light_color.dart';
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
    return Scaffold(
      appBar: AppBar(title: Text('Checkout')),
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
            title: Text('Delivery Address'),
            content: _buildAddressStep(),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: Text('Payment Method'),
            content: _buildPaymentStep(),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: Text('Order Review'),
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
              title: Text(address.name),
              subtitle: Text(address.fullAddress),
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
        SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {
            // Navigate to add address
          },
          icon: Icon(Icons.add),
          label: Text('Add New Address'),
        ),
      ],
    );
  }

  Widget _buildPaymentStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPaymentOption('card', 'Credit/Debit Card', Icons.credit_card),
        SizedBox(height: 12),
        _buildPaymentOption('cod', 'Cash on Delivery', Icons.local_atm),
        SizedBox(height: 12),
        _buildPaymentOption(
          'wallet',
          'Digital Wallet',
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
        title: Text(label),
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
    double shipping = 10.0;
    double discount = 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Summary',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 16),
        ...AppData.cartList.map((item) {
          subtotal += item.finalPrice;
          return ListTile(
            leading: Image.asset(item.images[0]),
            title: Text(item.name),
            subtitle: Text('Qty: 1'),
            trailing: Text('\$${item.finalPrice}'),
          );
        }),
        Divider(),
        _buildSummaryRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
        _buildSummaryRow('Shipping', '\$${shipping.toStringAsFixed(2)}'),
        if (discount > 0)
          _buildSummaryRow(
            'Discount',
            '-\$${discount.toStringAsFixed(2)}',
            color: LightColor.orange,
          ),
        Divider(),
        _buildSummaryRow(
          'Total',
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
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
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

    final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            OrderSuccessScreen(orderId: orderId, totalAmount: total),
      ),
    );
  }
}
