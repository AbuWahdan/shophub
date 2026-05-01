import 'package:flutter/foundation.dart';
import '../../core/api/api_constants.dart';
import '../../core/api/api_service.dart';
import '../../core/utils/apex_response_helper.dart';
import '../../models/orders_model.dart';
import '../../models/order_detail_item_model.dart';

class OrderRepository {
  final ApiService _apiService;

  OrderRepository(this._apiService);

  /// Get all orders for a specific user
  Future<List<OrdersModel>> getOrders({required String username}) async {
    final normalizedUsername = username.trim();
    if (normalizedUsername.isEmpty) {
      return <OrdersModel>[];
    }

    try {
      if (kDebugMode) {
        debugPrint('[OrderRepository] Fetching orders for $normalizedUsername');
      }

      final response = await _apiService.get(
        ApiConstants.getOrders,
        queryParams: {'l_USERNAME': normalizedUsername},
        isReadOperation: true,
      );
      final rawOrders = ApexResponseHelper.extractData(response, 'GetOrders');
      final orders = _parseOrders(rawOrders);

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

  Future<List<OrderDetailItemModel>> getOrderDetails(int orderId) async {
    if (orderId <= 0) {
      return <OrderDetailItemModel>[];
    }

    try {
      if (kDebugMode) {
        debugPrint(
          '[OrderRepository] Fetching order details for orderId=$orderId',
        );
      }

      final response = await _apiService.get(
        ApiConstants.getOrderDetails,
        queryParams: {'l_ORD_ID': orderId.toString()},
        isReadOperation: true,
      );
      final rawItems = ApexResponseHelper.extractData(
        response,
        'GetOrderDetails',
      );
      return rawItems
          .whereType<Map>()
          .map(
            (item) =>
                OrderDetailItemModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[OrderRepository] Error fetching order details: $e');
      }
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Private parsing and utility methods
  // ═══════════════════════════════════════════════════════════════════════════

  List<OrdersModel> _parseOrders(List<dynamic> response) {
    final groupedOrders = <int, OrdersModel>{};
    for (final item in response) {
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
    return groupedOrders.values.toList();
  }
}
