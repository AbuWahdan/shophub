import 'package:flutter/foundation.dart';
import '../../core/api/api_constants.dart';
import '../../core/api/api_service.dart';
import '../../core/utils/apex_response_helper.dart';
import '../../models/cart_api.dart';

class CartRepository {
  final ApiService _apiService;

  CartRepository(this._apiService);

  /// Get shopping cart_tab items for a user
  Future<List<ApiCartItem>> getCart({required String username}) async {
    try {
      final normalizedUsername = username.trim();
      if (normalizedUsername.isEmpty) {
        return <ApiCartItem>[];
      }

      if (kDebugMode) {
        debugPrint('[CartRepository] Fetching cart_tab for $normalizedUsername');
      }

      final response = await _apiService.get(
        ApiConstants.getItemCart,
        queryParams: {'USERNAME': normalizedUsername},
        isReadOperation: true,
      );
      if (kDebugMode) {
        for (final row in ApexResponseHelper.extractData(response, 'GetItemCart')) {
          debugPrint('>>> CART ROW KEYS: ${(row as Map).keys.toList()}');
          debugPrint('>>> CART ROW VALUES: $row');
        }
      }
      final cartItems = _parseCartItems(
        ApexResponseHelper.extractData(response, 'GetItemCart'),
      );

      if (kDebugMode) {
        debugPrint(
          '[CartRepository] Cart loaded with ${cartItems.length} items',
        );
      }

      return cartItems;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CartRepository] Error fetching cart_tab: $e');
      }
      rethrow;
    }
  }

  /// Add an item to the shopping cart_tab
  Future<void> addToCart(AddItemToCartRequest request) async {
    try {
      if (kDebugMode) {
        debugPrint('[CartRepository] Adding item to cart_tab');
      }

      await _apiService.post(
        ApiConstants.addItemToCart,
        body: request.toJson(),
        isReadOperation: false,
      );

      if (kDebugMode) {
        debugPrint('[CartRepository] Item added to cart_tab successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CartRepository] Error adding to cart_tab: $e');
      }
      rethrow;
    }
  }

  /// Delete an item from the shopping cart_tab
  Future<void> deleteFromCart({
    required int detailId,
    required String modifiedBy,
  }) async {
    final normalizedModifiedBy = modifiedBy.trim();
    if (detailId <= 0) {
      throw Exception('Invalid cart_tab detail id: $detailId');
    }
    if (normalizedModifiedBy.isEmpty) {
      throw Exception('User not authenticated.');
    }

    try {
      if (kDebugMode) {
        debugPrint(
          '[CartRepository] Deleting item from cart_tab (detailId=$detailId)',
        );
      }

      // 👈 THE FIX: Just await the post call. No need to assign to 'final response'
      await _apiService.post(
        ApiConstants.deleteItemCart,
        body: {'detail_id': detailId, 'modified_by': normalizedModifiedBy},
        isReadOperation: false,
      );

      if (kDebugMode) {
        debugPrint('[CartRepository] Item deleted from cart_tab successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CartRepository] Error deleting from cart_tab: $e');
      }
      rethrow;
    }
  }
  // ═══════════════════════════════════════════════════════════════════════════
  // Private parsing methods
  // ═══════════════════════════════════════════════════════════════════════════

  List<ApiCartItem> _parseCartItems(List<dynamic> response) {
    return [
      for (final item in response)
        if (item is Map<String, dynamic>) ApiCartItem.fromJson(item),
    ];
  }
}
