import 'package:flutter/foundation.dart';
import '../models/orders_model.dart';
import '../models/order_detail_item_model.dart';
import '../repositories/order_repository.dart';

class OrderController extends ChangeNotifier {
  final OrderRepository _repo;

  OrderController(this._repo);

  List<OrdersModel> _orders = const [];
  bool _isLoading = false;
  String _error = '';

  List<OrdersModel> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;
  String get error => _error;

  /// Load orders for the current user
  Future<void> loadOrders({required String username}) async {
    if (username.isEmpty) {
      _orders = const [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      if (kDebugMode) {
        debugPrint('[OrderController] Loading orders for $username');
      }

      final userOrders = await _repo.getOrders(username: username);
      _orders = userOrders;

      if (kDebugMode) {
        debugPrint(
          '[OrderController] Successfully loaded ${userOrders.length} orders',
        );
      }
    } on Exception catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        debugPrint('[OrderController] Error loading orders: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh orders for the current user
  Future<void> refreshOrders({required String username}) async {
    await loadOrders(username: username);
  }

  Future<List<OrderDetailItemModel>> getOrderDetails(int orderId) {
    return _repo.getOrderDetails(orderId);
  }
}
