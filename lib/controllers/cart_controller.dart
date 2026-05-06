import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/cart_item_model.dart';
import '../repositories/cart_repository.dart';

class CartController extends GetxController {
  final CartRepository _repo;
  CartController(this._repo);

  final RxList<CartItemModel> items = <CartItemModel>[].obs;
  final RxBool isLoading = false.obs;

  final RxMap<int, bool> itemLoading = <int, bool>{}.obs;
  final RxMap<int, DateTime> _lastUpdateTime = <int, DateTime>{}.obs;

  static const String _errLoadCart    = 'Failed to load cart. Please try again.';
  static const String _errAddItem     = 'Failed to add item to cart.';
  static const String _errRemoveItem  = 'Failed to remove item from cart.';
  static const String _errUpdateQty   = 'Failed to update quantity.';
  static const String _errInvalidQty  = 'Invalid quantity selected.';
  static const String _errExceedsStock= 'Quantity exceeds available stock.';
  static const String _errAuth        = 'Please log in to manage your cart.';
  static const String _errRapidTap    = 'Please wait before tapping again.';
  static const String _sucAdded       = 'Item added to cart';
  static const String _sucRemoved     = 'Item removed from cart';

  int itemKey(CartItemModel item) =>
      item.detailId > 0 ? item.detailId : item.itemDetId;

  CartItemModel? _findByKey(int key) =>
      items.firstWhereOrNull((i) => itemKey(i) == key);

  int _findIndexByKey(int key) {
    for (int i = 0; i < items.length; i++) {
      if (itemKey(items[i]) == key) return i;
    }
    return -1;
  }

  int get totalItemCount => items.length;

  int get totalQuantity =>
      items.fold(0, (sum, item) => sum + item.bookedQty);

  double get totalPrice =>
      items.fold(0.0, (sum, item) => sum + item.total);

  bool canIncrement(CartItemModel item) => item.bookedQty < item.availableQty;

  bool canDecrement(CartItemModel item) => item.bookedQty > 1;

  void _lock(int key)   => itemLoading[key] = true;
  void _unlock(int key) => itemLoading.remove(key);
  bool _isLocked(int key) => itemLoading[key] == true;

  static const Duration _minTimeBetweenTaps = Duration(milliseconds: 500);

  bool _canProcessTap(int key) {
    final lastUpdate = _lastUpdateTime[key];
    if (lastUpdate == null) return true;
    return DateTime.now().difference(lastUpdate) >= _minTimeBetweenTaps;
  }

  void _recordTap(int key) => _lastUpdateTime[key] = DateTime.now();

  Future<void> loadCart({required String username}) async {
    final normalized = username.trim();
    if (normalized.isEmpty) {
      items.clear();
      return;
    }

    isLoading.value = true;
    try {
      final result = await _repo.getCart(username: normalized);
      items.assignAll(result);

      if (kDebugMode) {
        debugPrint('[CartController] loadCart → ${result.length} items for $normalized');
      }
    } catch (e) {
      debugPrint('[CartController] loadCart error: $e');
      Get.snackbar('Error', _errLoadCart, snackPosition: SnackPosition.BOTTOM);
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────
  // FIXED: ADD ITEM
  // ─────────────────────────────────────────────
  Future<void> addItem({
    required int itemId,
    required int itemDetId,
    required String username,
    required int chosenQty,
  }) async {
    if (chosenQty <= 0) return;

    final normalized = username.trim();
    if (normalized.isEmpty) {
      Get.snackbar('Error', _errAuth);
      return;
    }

    try {
      final existing = items.firstWhereOrNull((i) => i.itemDetId == itemDetId);
      int payloadQty = chosenQty;

      if (existing != null) {
        int remainingStock = existing.availableQty - existing.bookedQty;

        // ✅ CRITICAL FIX 1: Abort completely if max stock is reached.
        if (remainingStock <= 0) {
          Get.snackbar('Warning', '$_errExceedsStock (Max: ${existing.availableQty})', snackPosition: SnackPosition.BOTTOM);
          return;
        }

        // Cap the delta if they try to add more than remaining stock
        if (payloadQty > remainingStock) {
          payloadQty = remainingStock;
          Get.snackbar('Warning', 'Only $remainingStock more items available. Added maximum to cart.', snackPosition: SnackPosition.BOTTOM);
        }
      }

      // ✅ CRITICAL FIX 2: Send ONLY the delta (payloadQty) to the API.
      // Do NOT send (existing + chosen) since the backend accumulates.
      await _repo.addToCart(
        AddItemToCartRequest(
          itemId: itemId,
          itemDetId: itemDetId,
          username: normalized,
          bookedQty: payloadQty,
        ),
      );

      await loadCart(username: normalized);
      Get.snackbar(_sucAdded, '', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', _errAddItem, snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<bool> removeItem({
    required CartItemModel item,
    required String username,
  }) async {
    final normalized = username.trim();
    if (normalized.isEmpty) {
      Get.snackbar('Error', _errAuth);
      return false;
    }

    final key = itemKey(item);
    final originalIndex = _findIndexByKey(key);
    final snapshot = originalIndex >= 0 ? items[originalIndex] : null;

    if (_isLocked(key)) return false;

    _lock(key);

    try {
      items.removeWhere((i) => itemKey(i) == key);
      await _repo.deleteFromCart(detailId: key, modifiedBy: normalized);
      Get.snackbar(_sucRemoved, '', snackPosition: SnackPosition.BOTTOM);
      return true;
    } catch (e) {
      if (snapshot != null && originalIndex >= 0) {
        items.insert(originalIndex, snapshot);
      }
      Get.snackbar('Error', _errRemoveItem, snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      _unlock(key);
    }
  }

  // ─────────────────────────────────────────────
  // STRICT BOUNDS ENFORCEMENT
  // ─────────────────────────────────────────────
  Future<void> _updateQty({required CartItemModel item, required String username, required int newQty,}) async {
    final normalized = username.trim();
    if (normalized.isEmpty) {
      Get.snackbar('Error', _errAuth);
      return;
    }

    final key = itemKey(item);
    if (!_canProcessTap(key)) {
      Get.snackbar('Info', _errRapidTap, snackPosition: SnackPosition.BOTTOM);
      return;
    }
    _recordTap(key);

    final index = _findIndexByKey(key);
    if (index == -1) return;

    final snapshot = items[index];

    if (_isLocked(key)) return;

    if (newQty <= 0) {
      await removeItem(item: snapshot, username: normalized);
      return;
    }

    // ✅ STRICT BOUNDS CHECK: Do not allow optimistic updates or API calls to proceed.
    if (newQty < 1) {
      Get.snackbar('Error', _errInvalidQty);
      return;
    }

    if (newQty > snapshot.availableQty) {
      Get.snackbar('Warning', '$_errExceedsStock (Max: ${snapshot.availableQty})', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    _lock(key);
    items[index] = snapshot.copyWith(bookedQty: newQty);

    try {
      await _repo.updateCartItemQty(
        currentDetailId: key,
        itemId: snapshot.itemId,
        itemDetId: snapshot.itemDetId,
        username: normalized,
        newQty: newQty,
        availableQty: snapshot.availableQty,
        tax: snapshot.tax,
      );

      await loadCart(username: normalized);

    } catch (e) {
      final rollbackIndex = _findIndexByKey(key);
      if (rollbackIndex >= 0) {
        items[rollbackIndex] = snapshot;
      } else if (index < items.length) {
        items[index] = snapshot;
      }
      Get.snackbar('Error', _errUpdateQty, snackPosition: SnackPosition.BOTTOM);
    } finally {
      _unlock(key);
    }
  }

  Future<void> incrementItem({
    required CartItemModel item,
    required String username,
  }) async {
    if (!canIncrement(item)) {
      Get.snackbar('Warning', '$_errExceedsStock (Max: ${item.availableQty})', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    await _updateQty(item: item, username: username, newQty: item.bookedQty + 1);
  }

  Future<void> decrementItem({
    required CartItemModel item,
    required String username,
  }) async {
    await _updateQty(item: item, username: username, newQty: item.bookedQty - 1);
  }

  Map<String, dynamic> validateCartState() {
    final errors = <String>[];
    final warnings = <String>[];

    final detailIds = items.map((i) => i.detailId).toList();
    final uniqueDetailIds = detailIds.toSet();
    if (detailIds.length != uniqueDetailIds.length) {
      errors.add('Duplicate DETAIL_IDs detected');
    }

    for (final item in items) {
      if (item.bookedQty < 1) {
        errors.add('Item ${item.itemDetId}: bookedQty=${item.bookedQty} < 1');
      }
      if (item.bookedQty > item.availableQty) {
        errors.add('Item ${item.itemDetId}: bookedQty=${item.bookedQty} > availableQty=${item.availableQty}');
      }
    }

    final calcQuantity = items.fold(0, (sum, item) => sum + item.bookedQty);
    if (calcQuantity != totalQuantity) {
      errors.add('Quantity mismatch: calculated=$calcQuantity, totalQuantity=$totalQuantity');
    }

    final calcPrice = items.fold(0.0, (sum, item) => sum + item.total);
    if ((calcPrice - totalPrice).abs() > 0.01) {
      warnings.add('Price mismatch: calculated=${calcPrice.toStringAsFixed(2)}, totalPrice=$totalPrice');
    }

    return {
      'isValid': errors.isEmpty,
      'errors': errors,
      'warnings': warnings,
    };
  }
}