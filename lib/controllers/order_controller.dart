import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../data/repositories/order_repository.dart';
import '../src/model/api_order.dart';

class OrderController extends GetxController {
  final OrderRepository _repo;

  OrderController(this._repo);

  final orders = <ApiOrder>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;

  /// Load orders for the current user
  Future<void> loadOrders({required String username}) async {
    if (username.isEmpty) {
      orders.clear();
      return;
    }

    isLoading.value = true;
    error.value = '';

    try {
      if (kDebugMode) {
        debugPrint('[OrderController] Loading orders for $username');
      }

      final userOrders = await _repo.getOrders(username: username);
      orders.assignAll(userOrders);

      if (kDebugMode) {
        debugPrint('[OrderController] Successfully loaded ${userOrders.length} orders');
      }
    } on Exception catch (e) {
      error.value = e.toString();
      if (kDebugMode) {
        debugPrint('[OrderController] Error loading orders: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh orders for the current user
  Future<void> refreshOrders({required String username}) async {
    await loadOrders(username: username);
  }
}
