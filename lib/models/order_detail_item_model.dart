class OrderDetailItemModel {
  final int orderDetId;
  final int orderId;
  final String orderNo;
  final int itemId;
  final int qty;
  final double unitPrice;
  final double totalPrice;
  final int deliveryStatus;
  final String brand;
  final String color;
  final String? size;
  final double itemDiscount;
  final int itemDetId;
  final String name;

  const OrderDetailItemModel({
    required this.orderDetId,
    required this.orderId,
    required this.orderNo,
    required this.itemId,
    required this.qty,
    required this.unitPrice,
    required this.totalPrice,
    required this.deliveryStatus,
    required this.brand,
    required this.color,
    this.size,
    required this.itemDiscount,
    required this.itemDetId,
    required this.name,
  });

  factory OrderDetailItemModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailItemModel(
      orderDetId: _asInt(json['ORDER_DET_ID']),
      orderId: _asInt(json['ORDER_ID']),
      orderNo: _asString(json['ORDER_NO']),
      itemId: _asInt(json['ITEM_ID']),
      qty: _asInt(json['QTY']),
      unitPrice: _asDouble(json['UNIT_PRICE']),
      totalPrice: _asDouble(json['TOTAL_PRICE']),
      deliveryStatus: _asInt(json['DELIVARY_STATUS']),
      brand: _asString(json['BRAND']),
      color: _asString(json['COLOR']),
      size: _asNullableString(json['ITEM_SIZE']),
      itemDiscount: _asDouble(json['ITEM_DISCOUNT']),
      itemDetId: _asInt(json['ITEM_DET_ID']),
      name: _asString(json['ITEM_NAME']),
    );
  }

  static int _asInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse((value ?? '').toString()) ?? 0;
  }

  static double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse((value ?? '').toString()) ?? 0.0;
  }

  static String _asString(dynamic value) {
    return (value ?? '').toString().trim();
  }

  static String? _asNullableString(dynamic value) {
    final normalized = (value ?? '').toString().trim();
    return normalized.isEmpty ? null : normalized;
  }
}
