import 'product_api.dart';

class CartItem {
  final ApiProduct product;
  int quantity;
  String selectedSize;
  String selectedColor;

  CartItem({
    required this.product,
    required this.quantity,
    required this.selectedSize,
    required this.selectedColor,
  });

  double get total => product.finalPrice * quantity;
}
