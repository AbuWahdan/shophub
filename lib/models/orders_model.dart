import 'package:flutter/material.dart';

class OrdersModel {
  final int orderId;
  final String orderNo;
  final String username;
  final DateTime orderDate;
  final double totalAmount;
  final double taxAmount;
  final double discountAmount;
  final double netAmount;
  final String statusRaw; // Store raw status value
  final DateTime createdDate;
  final List<ApiOrderItem> items;

  OrdersModel({
    required this.orderId,
    required this.orderNo,
    required this.username,
    required this.orderDate,
    required this.totalAmount,
    required this.taxAmount,
    required this.discountAmount,
    required this.netAmount,
    required this.statusRaw,
    required this.createdDate,
    this.items = const [],
  });

  factory OrdersModel.fromJson(Map<String, dynamic> json) {
    // Check for status field with multiple possible names
    final statusValue =
        json['STATUS'] ??
        json['status'] ??
        json['ORDER_STATUS'] ??
        json['order_status'] ??
        json['ITEM_STATUS'] ??
        json['item_status'] ??
        '';

    return OrdersModel(
      orderId: json['ORDER_ID'] as int? ?? 0,
      orderNo: json['ORDER_NO'] as String? ?? '',
      username: json['USERNAME'] as String? ?? '',
      orderDate: _parseDateTime(json['ORDER_DATE']),
      totalAmount: _parseDouble(json['TOTAL_AMOUNT']),
      taxAmount: _parseDouble(json['TAX_AMOUNT']),
      discountAmount: _parseDouble(json['DISCOUNT_AMOUNT']),
      netAmount: _parseDouble(json['NET_AMOUNT']),
      statusRaw: statusValue.toString().trim(),
      createdDate: _parseDateTime(json['CREATED_DATE']),
      items: _parseItems(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ORDER_ID': orderId,
      'ORDER_NO': orderNo,
      'USERNAME': username,
      'ORDER_DATE': orderDate.toIso8601String(),
      'TOTAL_AMOUNT': totalAmount,
      'TAX_AMOUNT': taxAmount,
      'DISCOUNT_AMOUNT': discountAmount,
      'NET_AMOUNT': netAmount,
      'STATUS': statusRaw,
      'CREATED_DATE': createdDate.toIso8601String(),
      'ITEMS': items.map((item) => item.toJson()).toList(),
    };
  }

  OrdersModel copyWith({
    int? orderId,
    String? orderNo,
    String? username,
    DateTime? orderDate,
    double? totalAmount,
    double? taxAmount,
    double? discountAmount,
    double? netAmount,
    String? statusRaw,
    DateTime? createdDate,
    List<ApiOrderItem>? items,
  }) {
    return OrdersModel(
      orderId: orderId ?? this.orderId,
      orderNo: orderNo ?? this.orderNo,
      username: username ?? this.username,
      orderDate: orderDate ?? this.orderDate,
      totalAmount: totalAmount ?? this.totalAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      netAmount: netAmount ?? this.netAmount,
      statusRaw: statusRaw ?? this.statusRaw,
      createdDate: createdDate ?? this.createdDate,
      items: items ?? this.items,
    );
  }

  static List<ApiOrderItem> _parseItems(Map<String, dynamic> json) {
    final parsedItems = <ApiOrderItem>[];
    final candidates = <dynamic>[
      json['ITEMS'],
      json['items'],
      json['ORDER_ITEMS'],
      json['order_items'],
      json['DETAILS'],
      json['details'],
    ];

    for (final candidate in candidates) {
      if (candidate is List) {
        for (final item in candidate) {
          if (item is Map<String, dynamic>) {
            parsedItems.add(ApiOrderItem.fromJson(item));
          }
        }
        if (parsedItems.isNotEmpty) {
          return parsedItems;
        }
      }
    }

    final topLevelItem = ApiOrderItem.fromJson(json);
    if (topLevelItem.itemId > 0 || topLevelItem.productName.isNotEmpty) {
      return [topLevelItem];
    }

    return const [];
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {
        return 0.0;
      }
    }
    return 0.0;
  }

  /// Maps the raw status value to a human-readable label
  String getStatusLabel() {
    final normalized = statusRaw.trim().toLowerCase();

    switch (normalized) {
      case 'p':
      case 'pending':
        return 'Pending';
      case 'c':
      case 'confirmed':
        return 'Confirmed';
      case 'shipped':
      case 's':
        return 'Shipped';
      case 'd':
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
      case 'x':
        return 'Cancelled';
      default:
        return normalized.isNotEmpty ? normalized : 'Processing';
    }
  }

  /// Returns the color associated with the status for UI display
  Color getStatusColor() {
    final normalized = statusRaw.trim().toLowerCase();

    switch (normalized) {
      case 'p':
      case 'pending':
        return const Color(0xFFFFA500); // Orange
      case 'c':
      case 'confirmed':
        return const Color(0xFF2196F3); // Blue
      case 'shipped':
      case 's':
        return const Color(0xFF9C27B0); // Purple
      case 'd':
      case 'delivered':
        return const Color(0xFF4CAF50); // Green
      case 'cancelled':
      case 'x':
        return const Color(0xFFF44336); // Red
      default:
        return const Color(0xFF757575); // Grey
    }
  }
}

class ApiOrderResponse {
  final String status;
  final List<OrdersModel> data;

  ApiOrderResponse({required this.status, required this.data});

  factory ApiOrderResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>? ?? [];
    final groupedOrders = <int, OrdersModel>{};

    for (final item in data) {
      if (item is! Map<String, dynamic>) continue;
      final order = OrdersModel.fromJson(item);
      final existing = groupedOrders[order.orderId];

      if (existing == null) {
        groupedOrders[order.orderId] = order;
        continue;
      }

      groupedOrders[order.orderId] = existing.copyWith(
        items: [
          ...existing.items,
          ...order.items.where(
            (candidate) => existing.items.every(
              (existingItem) =>
                  existingItem.itemId != candidate.itemId ||
                  existingItem.itemDetId != candidate.itemDetId,
            ),
          ),
        ],
      );
    }

    return ApiOrderResponse(
      status: json['status'] as String? ?? 'error',
      data: groupedOrders.values.toList(),
    );
  }
}

class ApiOrderItem {
  final int itemId;
  final int itemDetId;
  final String productName;
  final String productImage;
  final int quantity;
  final double price;

  const ApiOrderItem({
    required this.itemId,
    required this.itemDetId,
    required this.productName,
    required this.productImage,
    required this.quantity,
    required this.price,
  });

  factory ApiOrderItem.fromJson(Map<String, dynamic> json) {
    return ApiOrderItem(
      itemId: _parseInt(
        json['ITEM_ID'] ??
            json['item_id'] ??
            json['PRODUCT_ID'] ??
            json['product_id'],
      ),
      itemDetId: _parseInt(
        json['ITEM_DET_ID'] ??
            json['item_det_id'] ??
            json['DET_ID'] ??
            json['det_id'],
      ),
      productName:
          (json['ITEM_NAME'] ??
                  json['item_name'] ??
                  json['PRODUCT_NAME'] ??
                  json['product_name'] ??
                  '')
              .toString(),
      productImage:
          (json['ITEM_IMG_URL'] ??
                  json['item_img_url'] ??
                  json['PRODUCT_IMAGE'] ??
                  json['product_image'] ??
                  '')
              .toString(),
      quantity: _parseInt(
        json['ITEM_QTY'] ?? json['item_qty'] ?? json['QTY'] ?? json['qty'] ?? 1,
      ),
      price: _parseDouble(
        json['ITEM_PRICE'] ??
            json['item_price'] ??
            json['PRICE'] ??
            json['price'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ITEM_ID': itemId,
      'ITEM_DET_ID': itemDetId,
      'ITEM_NAME': productName,
      'ITEM_IMG_URL': productImage,
      'ITEM_QTY': quantity,
      'ITEM_PRICE': price,
    };
  }
}

int _parseInt(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse((value ?? '').toString()) ?? 0;
}

double _parseDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse((value ?? '').toString()) ?? 0;
}
