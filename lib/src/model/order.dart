class Order {
  String id;
  List<OrderItem> items;
  double subtotal;
  double shipping;
  double discount;
  double total;
  OrderStatus status;
  DateTime date;
  String? addressId;
  String estimatedDelivery;

  Order({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.shipping,
    required this.discount,
    required this.total,
    required this.status,
    required this.date,
    this.addressId,
    required this.estimatedDelivery,
  });
}

class OrderItem {
  int productId;
  String productName;
  String image;
  double price;
  int quantity;
  String? selectedSize;
  String? selectedColor;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.image,
    required this.price,
    required this.quantity,
    this.selectedSize,
    this.selectedColor,
  });
}

enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled;
}
