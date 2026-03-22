import 'package:flutter/material.dart';

class ApiOrder {
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

  ApiOrder({
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
  });

  factory ApiOrder.fromJson(Map<String, dynamic> json) {
    // Check for status field with multiple possible names
    final statusValue = json['STATUS'] ??
        json['status'] ??
        json['ORDER_STATUS'] ??
        json['order_status'] ??
        json['ITEM_STATUS'] ??
        json['item_status'] ??
        '';

    return ApiOrder(
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
    };
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
  final List<ApiOrder> data;

  ApiOrderResponse({
    required this.status,
    required this.data,
  });

  factory ApiOrderResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>? ?? [];
    return ApiOrderResponse(
      status: json['status'] as String? ?? 'error',
      data: data
          .map((item) => ApiOrder.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
