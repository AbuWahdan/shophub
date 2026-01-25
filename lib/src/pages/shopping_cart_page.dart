import 'package:flutter/material.dart';

import '../model/data.dart';
import '../model/product.dart';
import '../themes/light_color.dart';
import '../themes/theme.dart';

class ShoppingCartPage extends StatefulWidget {
  final Function(int)? onCartUpdated;
  const ShoppingCartPage({super.key, this.onCartUpdated});

  @override
  _ShoppingCartPageState createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  late List<Map<String, dynamic>> cartItems;

  @override
  void initState() {
    super.initState();
    _initializeCart();
  }

  void _initializeCart() {
    cartItems = AppData.cartList
        .map((product) => {'product': product, 'quantity': 1})
        .toList();
    // Use postFrame callback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyCartUpdate();
    });
  }

  void _notifyCartUpdate() {
    if (mounted) {
      widget.onCartUpdated?.call(cartItems.length);
    }
  }

  void _removeItem(int index) {
    if (!mounted) return;
    setState(() {
      cartItems.removeAt(index);
    });
    // Notify parent after state update completes in a separate frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyCartUpdate();
    });
  }

  void _updateQuantity(int index, int quantity) {
    if (!mounted) return;
    if (quantity < 1) return; // Prevent invalid quantities
    setState(() {
      cartItems[index]['quantity'] = quantity;
    });
  }

  double get totalPrice {
    return cartItems.fold(
      0,
      (sum, item) => sum + (item['product'].finalPrice * item['quantity']),
    );
  }

  double get originalPrice {
    return cartItems.fold(
      0,
      (sum, item) => sum + (item['product'].price * item['quantity']),
    );
  }

  double get totalDiscount {
    return originalPrice - totalPrice;
  }

  void _showRemoveConfirmation(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Item'),
        content: const Text('Remove this item from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removeItem(index);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Item removed from cart'),
                  duration: const Duration(seconds: 2),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () {
                      // Could implement undo here
                    },
                  ),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(int index, Map<String, dynamic> item) {
    Product product = item['product'];
    int quantity = item['quantity'];
    double itemTotal = product.finalPrice * quantity;
    bool hasDiscount = product.discountPrice != null;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  child: Image.asset(product.images[0], fit: BoxFit.cover),
                ),
                const SizedBox(width: 12),
                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Price Display
                      Row(
                        children: [
                          Text(
                            '\$${product.finalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: LightColor.skyBlue,
                              fontSize: 14,
                            ),
                          ),
                          if (hasDiscount) ...[
                            const SizedBox(width: 8),
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Delete Button
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => _showRemoveConfirmation(index),
                  color: Colors.grey,
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const Divider(height: 16),
            // Quantity Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Quantity'),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 18),
                        onPressed: quantity > 1
                            ? () => _updateQuantity(index, quantity - 1)
                            : null,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      SizedBox(
                        width: 40,
                        child: Center(
                          child: Text(
                            '$quantity',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 18),
                        onPressed: quantity < 10
                            ? () => _updateQuantity(index, quantity + 1)
                            : null,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            // Item Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Item Total', style: TextStyle(color: Colors.grey)),
                Text(
                  '\$${itemTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Your Cart is Empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items to get started',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to home/shopping
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: const Icon(Icons.shopping_bag),
            label: const Text('Start Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _cartItems() {
    if (cartItems.isEmpty) {
      return SizedBox.expand(child: _buildEmptyCart());
    }

    return Column(
      children: cartItems.asMap().entries.map((entry) {
        return _buildCartItemCard(entry.key, entry.value);
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Cart Items
          Expanded(
            child: cartItems.isEmpty
                ? _buildEmptyCart()
                : SingleChildScrollView(
                    padding: AppTheme.padding,
                    child: _cartItems(),
                  ),
          ),
          // Price Summary & Checkout
          if (cartItems.isNotEmpty)
            Container(
              padding: AppTheme.padding,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Price Breakdown
                  _buildPriceSummaryRow(
                    'Subtotal',
                    '\$${originalPrice.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 8),
                  if (totalDiscount > 0)
                    _buildPriceSummaryRow(
                      'Discount',
                      '-\$${totalDiscount.toStringAsFixed(2)}',
                      isDiscount: true,
                    ),
                  if (totalDiscount > 0) const SizedBox(height: 8),
                  _buildPriceSummaryRow('Shipping', 'Free', isHighlight: true),
                  const Divider(height: 16),
                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '\$${totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: LightColor.skyBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Checkout Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/checkout');
                      },
                      child: const Text(
                        'Proceed to Checkout',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPriceSummaryRow(
    String label,
    String value, {
    bool isDiscount = false,
    bool isHighlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isHighlight ? LightColor.skyBlue : Colors.grey[600],
            fontWeight: isHighlight ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isDiscount ? LightColor.skyBlue : Colors.grey[600],
            fontWeight: isDiscount ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
