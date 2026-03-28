import 'package:flutter/foundation.dart';
import '../../core/api/api_constants.dart';
import '../../core/api/api_service.dart';
import '../../src/model/api_order.dart';

class OrderRepository {
  final ApiService _apiService;

  OrderRepository(this._apiService);

  /// Get all orders for a specific user
  Future<List<ApiOrder>> getOrders({required String username}) async {
    try {
      if (kDebugMode) {
        debugPrint('[OrderRepository] Fetching orders for $username');
      }

      final response = await _apiService.post(
        ApiConstants.getOrders,
        body: {'username': username},
        isReadOperation: true,
      );

      if (response == null) {
        return <ApiOrder>[];
      }

      final orders = _parseOrders(response);
      
      if (kDebugMode) {
        debugPrint('[OrderRepository] Loaded ${orders.length} orders');
      }

      return orders;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[OrderRepository] Error fetching orders: $e');
      }
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Private parsing and utility methods
  // ═══════════════════════════════════════════════════════════════════════════

  List<ApiOrder> _parseOrders(dynamic response) {
    if (response is List) {
      return [
        for (final item in response)
          if (item is Map<String, dynamic>) ApiOrder.fromJson(item),
      ];
    }
    return <ApiOrder>[];
  }
}
