import 'package:flutter/foundation.dart';
import '../../core/api/api_constants.dart';
import '../../core/api/api_service.dart';
import '../../src/model/cart_api.dart';

class CartRepository {
  final ApiService _apiService;

  CartRepository(this._apiService);

  /// Get shopping cart items for a user
  Future<List<ApiCartItem>> getCart({required String username}) async {
    try {
      if (kDebugMode) {
        debugPrint('[CartRepository] Fetching cart for $username');
      }

      final response = await _apiService.post(
        ApiConstants.getItemCart,
        body: {'username': username},
        isReadOperation: true,
      );

      if (response == null) {
        return <ApiCartItem>[];
      }

      final cartItems = _parseCartItems(response);
      
      if (kDebugMode) {
        debugPrint('[CartRepository] Cart loaded with ${cartItems.length} items');
      }

      return cartItems;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CartRepository] Error fetching cart: $e');
      }
      rethrow;
    }
  }

  /// Add an item to the shopping cart
  Future<void> addToCart(AddItemToCartRequest request) async {
    try {
      if (kDebugMode) {
        debugPrint('[CartRepository] Adding item to cart');
      }

      await _apiService.post(
        ApiConstants.addItemToCart,
        body: request.toJson(),
        isReadOperation: false,
      );

      if (kDebugMode) {
        debugPrint('[CartRepository] Item added to cart successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CartRepository] Error adding to cart: $e');
      }
      rethrow;
    }
  }

  /// Delete an item from the shopping cart
  Future<void> deleteFromCart({
    required int detailId,
    required String modifiedBy,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('[CartRepository] Deleting item from cart (detailId=$detailId)');
      }

      // Send exactly { "detail_id": detailId, "modified_by": modifiedBy }
      await _apiService.post(
        ApiConstants.deleteItemCart,
        body: {
          'detail_id': detailId,
          'modified_by': modifiedBy,
        },
        isReadOperation: false,
      );

      if (kDebugMode) {
        debugPrint('[CartRepository] Item deleted from cart successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CartRepository] Error deleting from cart: $e');
      }
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Private parsing methods
  // ═══════════════════════════════════════════════════════════════════════════

  List<ApiCartItem> _parseCartItems(dynamic response) {
    if (response is List) {
      return [
        for (final item in response)
          if (item is Map<String, dynamic>) ApiCartItem.fromJson(item),
      ];
    }
    return <ApiCartItem>[];
  }
}
