import 'product_api.dart';

class CartItem {
  final ApiProduct product;
  int quantity;
  String selectedSize;
  String selectedColor;
  int selectedDetId;

  CartItem({
    required this.product,
    required this.quantity,
    required this.selectedSize,
    required this.selectedColor,
    this.selectedDetId = 0,
  });

  double get total => product.finalPrice * quantity;
}
