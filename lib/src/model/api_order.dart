class ApiOrder {
  final int orderId;
  final String orderNo;
  final String username;
  final DateTime orderDate;
  final double totalAmount;
  final double taxAmount;
  final double discountAmount;
  final double netAmount;
  final int status;
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
    required this.status,
    required this.createdDate,
  });

  factory ApiOrder.fromJson(Map<String, dynamic> json) {
    return ApiOrder(
      orderId: json['ORDER_ID'] as int? ?? 0,
      orderNo: json['ORDER_NO'] as String? ?? '',
      username: json['USERNAME'] as String? ?? '',
      orderDate: _parseDateTime(json['ORDER_DATE']),
      totalAmount: _parseDouble(json['TOTAL_AMOUNT']),
      taxAmount: _parseDouble(json['TAX_AMOUNT']),
      discountAmount: _parseDouble(json['DISCOUNT_AMOUNT']),
      netAmount: _parseDouble(json['NET_AMOUNT']),
      status: json['STATUS'] as int? ?? 0,
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
      'STATUS': status,
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

  String getStatusLabel() {
    switch (status) {
      case 1:
        return 'Completed';
      case 2:
        return 'Processing';
      case 3:
        return 'Shipped';
      case 4:
        return 'Pending';
      case 5:
        return 'Cancelled';
      default:
        return 'Unknown';
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
