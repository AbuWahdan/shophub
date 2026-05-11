import 'package:flutter/foundation.dart';
import '../../core/api/api_constants.dart';
import '../../core/api/api_service.dart';
import '../../core/utils/apex_response_helper.dart';
import '../../models/cart_item_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CART REPOSITORY
//
// API BEHAVIOR CONTRACT (confirmed by testing):
//   • GET  /GetItemCart          → returns current cart items with BOOKED_QTY
//   • POST /AddItemToCart        → ACCUMULATES qty with signed delta:
//                                    +N  →  adds N to current qty
//                                    -N  →  subtracts N from current qty
//   • POST /DeleteItemCart       → removes the record entirely by DETAIL_ID
//
// CRITICAL: NEVER send an absolute quantity. Always send the signed delta.
//   Increment → deltaQty = +1
//   Decrement → deltaQty = -1   (API handles subtraction natively)
//   Remove    → use DeleteItemCart (when qty would reach 0)
// ─────────────────────────────────────────────────────────────────────────────

class CartRepository {
  final ApiService _apiService;

  CartRepository(this._apiService);

  // ─────────────────────────────
  // FETCH CART
  // ─────────────────────────────

  Future<List<CartItemModel>> fetchCart({required String username}) async {
    final normalized = username.trim();
    if (normalized.isEmpty) return const [];

    try {
      if (kDebugMode) {
        debugPrint('[CartRepository.fetchCart] username=$normalized');
      }

      final response = await _apiService.get(
        ApiConstants.getItemCart,
        queryParams: {'USERNAME': normalized},
        isReadOperation: true,
      );

      final rawData = ApexResponseHelper.extractData(response, 'GetItemCart');

      final items = rawData
          .cast<Map<String, dynamic>>()
          .map(CartItemModel.fromJson)
          .toList();

      if (kDebugMode) {
        debugPrint('[CartRepository.fetchCart] loaded ${items.length} items');
        for (final item in items) {
          debugPrint('  → $item');
        }
      }

      return items;
    } catch (e, st) {
      debugPrint('[CartRepository.fetchCart] ERROR: $e\n$st');
      rethrow;
    }
  }

  // ─────────────────────────────
  // ADD ITEM  (delta qty only)
  // ─────────────────────────────
  //
  // Only call this when adding a brand-new item OR sending a delta of 1.
  // NEVER pass an absolute target quantity here.

  Future<void> addItem(AddToCartRequest request) async {
    assert(request.deltaQty != 0, 'deltaQty must not be zero');

    try {
      if (kDebugMode) {
        final sign = request.deltaQty > 0 ? '+' : '';
        debugPrint(
          '[CartRepository.addItem] '
              'itemId=${request.itemId} detId=${request.itemDetId} '
              'delta=$sign${request.deltaQty}',
        );
      }

      await _apiService.post(
        ApiConstants.addItemToCart,
        body: request.toJson(),
        isReadOperation: false,
      );
    } catch (e, st) {
      debugPrint('[CartRepository.addItem] ERROR: $e\n$st');
      rethrow;
    }
  }

  // ─────────────────────────────
  // REMOVE ITEM
  // ─────────────────────────────

  Future<void> removeItem({
    required int detailId,
    required String username,
  }) async {
    if (detailId <= 0) throw ArgumentError('detailId must be > 0');
    if (username.trim().isEmpty) throw ArgumentError('username is empty');

    try {
      if (kDebugMode) {
        debugPrint('[CartRepository.removeItem] detailId=$detailId');
      }

      await _apiService.post(
        ApiConstants.deleteItemCart,
        body: {
          'detail_id': detailId,
          'modified_by': username.trim(),
        },
        isReadOperation: false,
      );
    } catch (e, st) {
      debugPrint('[CartRepository.removeItem] ERROR: $e\n$st');
      rethrow;
    }
  }

  // ─────────────────────────────
  // INCREMENT QTY  (+1 only)
  // ─────────────────────────────
  //
  // Because the API accumulates, incrementing is just adding delta=1.
  // No delete needed. No absolute value sent. Safe from explosion bug.

  Future<void> incrementItemQty({
    required int itemId,
    required int itemDetId,
    required String username,
    double tax = 0,
  }) async {
    if (kDebugMode) {
      debugPrint('[CartRepository.incrementItemQty] itemDetId=$itemDetId +1');
    }

    await addItem(
      AddToCartRequest(
        itemId: itemId,
        itemDetId: itemDetId,
        username: username.trim(),
        deltaQty: 1,
        tax: tax,
      ),
    );
  }

  // ─────────────────────────────
  // DECREMENT QTY  (-1 only)
  // ─────────────────────────────
  //
  // The API supports negative deltas natively.
  // Simply POST item_qty=-1 — no delete needed, no race conditions.
  // The controller must call removeItem() separately when qty reaches 0.

  Future<void> decrementItemQty({
    required int itemId,
    required int itemDetId,
    required String username,
    double tax = 0,
  }) async {
    if (kDebugMode) {
      debugPrint('[CartRepository.decrementItemQty] itemDetId=$itemDetId -1');
    }

    await addItem(
      AddToCartRequest(
        itemId: itemId,
        itemDetId: itemDetId,
        username: username.trim(),
        deltaQty: -1,
        tax: tax,
      ),
    );
  }
}