import 'package:flutter/foundation.dart';
import '../../core/api/api_constants.dart';
import '../../core/api/api_service.dart';
import '../../core/utils/apex_response_helper.dart';
import '../../models/cart_item_model.dart';


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

  Future<void> removeItem({required int detailId, required String username,}) async {
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