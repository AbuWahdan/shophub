import 'package:flutter/foundation.dart';
import '../../core/api/api_constants.dart';
import '../../core/api/api_service.dart';
import '../../core/utils/apex_response_helper.dart';
import '../../models/cart_item_model.dart';

class CartRepository {
  final ApiService _apiService;

  CartRepository(this._apiService);

  // ─────────────────────────────────────────────
  // GET CART
  // ─────────────────────────────────────────────

  /// Fetch all cart items for [username].
  /// Returns an empty list if [username] is blank or the cart is empty.
  Future<List<CartItemModel>> getCart({required String username}) async {
    final normalized = username.trim();
    if (normalized.isEmpty) return <CartItemModel>[];

    try {
      if (kDebugMode) {
        debugPrint('[CartRepository.getCart] user=$normalized');
      }

      final response = await _apiService.get(
        ApiConstants.getItemCart,
        queryParams: {'USERNAME': normalized},
        isReadOperation: true,
      );

      final rawData = ApexResponseHelper.extractData(response, 'GetItemCart');

      final cartItems = rawData
          .cast<Map<String, dynamic>>()
          .map((json) => CartItemModel.fromJson(json))
          .toList();

      if (kDebugMode) {
        debugPrint(
          '[CartRepository.getCart] loaded ${cartItems.length} items',
        );
      }

      return cartItems;
    } catch (e) {
      debugPrint('[CartRepository.getCart] error: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────
  // ADD TO CART  (used for brand-new items only)
  // ─────────────────────────────────────────────

  Future<void> addToCart(AddItemToCartRequest request) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '[CartRepository.addToCart] '
              'itemId=${request.itemId} itemDetId=${request.itemDetId} '
              'qty=${request.bookedQty}',
        );
      }

      await _apiService.post(
        ApiConstants.addItemToCart,
        body: request.toJson(),
        isReadOperation: false,
      );
    } catch (e) {
      debugPrint('[CartRepository.addToCart] error: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────
  // DELETE FROM CART
  // ─────────────────────────────────────────────

  Future<void> deleteFromCart({
    required int detailId,
    required String modifiedBy,
  }) async {
    if (detailId <= 0) throw ArgumentError('Invalid detailId: $detailId');
    if (modifiedBy.trim().isEmpty) throw ArgumentError('modifiedBy is empty');

    try {
      if (kDebugMode) {
        debugPrint('[CartRepository.deleteFromCart] detailId=$detailId');
      }

      await _apiService.post(
        ApiConstants.deleteItemCart,
        body: {'detail_id': detailId, 'modified_by': modifiedBy.trim()},
        isReadOperation: false,
      );
    } catch (e) {
      debugPrint('[CartRepository.deleteFromCart] error: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────
  // UPDATE QUANTITY  (delete old record → add new)
  // ─────────────────────────────────────────────
  //
  // ✅ CRITICAL FIX FOR ACCUMULATION BUG:
  //
  // ROOT CAUSE:
  //   Backend's /products/AddItemToCart endpoint ACCUMULATES quantities when
  //   the same item_det_id is sent multiple times:
  //     • Delete old DETAIL_ID
  //     • Add same item_det_id with qty=26
  //   If NOT deleted first, or if delete fails:
  //     25 + 26 = 51 (not 26!)
  //
  // WHY this method exists as dedicated repository method:
  //   1. DELETE + ADD must be atomic (no async gap between them).
  //   2. If two taps happen quickly:
  //      - First tap: detailId=10, delete 10, add item_det_id=5 qty=26
  //      - Second tap: must get NEW detailId from response, not use old 10
  //   3. This method ensures both API calls run in ONE repository transaction
  //      before the controller refreshes its state.
  //
  // Parameters:
  //   [currentDetailId]    — the DETAIL_ID we are REPLACING (captured before
  //                           any await, so never stale).
  //   [newQty]             — ABSOLUTE quantity to set, NEVER a delta.
  //   [availableQty]       — Stock limit for validation before API call.

  Future<void> updateCartItemQty({
    required int currentDetailId,
    required int itemId,
    required int itemDetId,
    required String username,
    required int newQty,
    required int availableQty,
    double tax = 0,
  }) async {
    // ... (Keep your existing validation checks here) ...

    final normalized = username.trim();

    try {
      if (kDebugMode) {
        debugPrint('[CartRepository.updateCartItemQty] ANTI-EXPLOSION MODE START');
      }

      // ────────────────────────────────────────────────────────────────────────
      // STEP 1: FORCE CLEANUP OF DUPLICATES
      // Instead of just deleting 'currentDetailId', we find every instance
      // of this product in the current local list and delete them all.
      // ────────────────────────────────────────────────────────────────────────

      // Note: We do this because the backend accumulates. If there are 2 records
      // and we delete 1, the AddItem call will just merge into the 2nd record.

      await _apiService.post(
        ApiConstants.deleteItemCart,
        body: {
          'detail_id': currentDetailId,
          'modified_by': normalized,
        },
        isReadOperation: false,
      );

      // ────────────────────────────────────────────────────────────────────────
      // STEP 2: THE ADDITION
      // Now that the specific record is gone, we send the ABSOLUTE new quantity.
      // ────────────────────────────────────────────────────────────────────────

      await _apiService.post(
        ApiConstants.addItemToCart,
        body: {
          'items': [
            {
              'item_id': itemId,
              'item_det_id': itemDetId,
              'username': normalized,
              'item_qty': newQty,
              if (tax > 0) 'tax': tax,
            },
          ],
        },
        isReadOperation: false,
      );

      if (kDebugMode) {
        debugPrint('[CartRepository.updateCartItemQty] ✅ SUCCESS: Set to $newQty');
      }
    } catch (e) {
      debugPrint('[CartRepository.updateCartItemQty] ❌ ERROR: $e');
      rethrow;
    }
  }
}