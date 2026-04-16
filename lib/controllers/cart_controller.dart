import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../data/repositories/cart_repository.dart';
import '../src/model/cart_api.dart';

class CartController extends GetxController {
  final CartRepository _repo;
  CartController(this._repo);

  // ── State ────────────────────────────────────────────────────────────────
  final RxList<ApiCartItem> items = <ApiCartItem>[].obs;
  final RxBool isLoading = false.obs;

  /// Per-item loading state.
  /// Key is always [itemKey] — one single source of truth.
  final RxMap<int, bool> itemLoading = <int, bool>{}.obs;

  // ── Key Resolution ────────────────────────────────────────────────────────
  /// THE single source of truth for identifying a cart row.
  /// Public so the view uses the exact same logic — no duplication.
  ///
  /// Priority: detailId (cart line PK) → cartItemId → itemDetId (last resort)
  int itemKey(ApiCartItem item) {
    if (item.detailId > 0) return item.detailId;
    return item.itemDetId;
  }

  // ── Load ──────────────────────────────────────────────────────────────────
  Future<void> loadCart({required String username}) async {
    isLoading.value = true;
    try {
      final fetched = await _repo.getCart(username: username);

      // Clamp qty to available stock in case stock dropped since last session
      final clamped = fetched.map((item) {
        if (item.availableQty > 0 && item.itemQty > item.availableQty) {
          debugPrint(
            '[CartController] Clamping ${item.itemName}: '
                '${item.itemQty} → ${item.availableQty}',
          );
          return item.copyWith(itemQty: item.availableQty);
        }
        return item;
      }).toList();

      items.assignAll(clamped);
    } on Exception catch (e) {
      debugPrint('[CartController] loadCart error: $e');
      Get.snackbar('Error', 'Failed to load cart: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Remove ────────────────────────────────────────────────────────────────
  Future<bool> removeItem({
    required ApiCartItem item,
    required String username,
  }) async {
    // itemKey() and deleteId are now the SAME value — no priority mismatch
    final key = itemKey(item);

    if (key <= 0) {
      debugPrint(
        '[CartController] removeItem BLOCKED — no valid ID. '
            'itemDetId=${item.itemDetId}',
      );
      Get.snackbar(
        'Error',
        'Cannot delete: cart row ID not found. '
            'Check that the API returns detail_id.',
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }

    // Guard against double-tap
    if (itemLoading[key] == true) return false;
    itemLoading[key] = true;

    try {
      await _repo.deleteFromCart(detailId: key, modifiedBy: username);

      // removeWhere uses the same key — guaranteed to find the right row
      items.removeWhere((i) => itemKey(i) == key);
      return true;
    } on Exception catch (e) {
      debugPrint('[CartController] removeItem error: $e');
      Get.snackbar('Error', 'Server failed to delete item: $e');
      return false;
    } finally {
      itemLoading.remove(key);
    }
  }

  // ── Increment ─────────────────────────────────────────────────────────────
  Future<void> incrementItem({
    required ApiCartItem item,
    required String username,
  }) async {
    final key = itemKey(item);
    if (itemLoading[key] == true) return;

    // Find index by itemKey — not by itemDetId — to handle duplicate variants
    final idx = items.indexWhere((i) => itemKey(i) == key);
    if (idx == -1) return;

    final current = items[idx];
    final stock = current.availableQty > 0 ? current.availableQty : current.itemQty;

    if (current.itemQty >= stock) {
      Get.snackbar(
        'Out of Stock',
        'Only $stock unit(s) available for ${current.itemName}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    itemLoading[key] = true;

    // Optimistic update
    final oldQty = current.itemQty;
    items[idx] = current.copyWith(itemQty: oldQty + 1);

    try {
      await _repo.addToCart(
        AddItemToCartRequest(
          itemId: item.itemId,
          itemDetId: item.itemDetId,
          username: username,
          itemQty: 1,
        ),
      );
    } on Exception catch (e) {
      // Revert on failure
      items[idx] = items[idx].copyWith(itemQty: oldQty);
      debugPrint('[CartController] incrementItem error: $e');
      Get.snackbar('Error', 'Failed to update quantity: $e');
      rethrow;
    } finally {
      itemLoading.remove(key);
    }
  }

  // ── Decrement ─────────────────────────────────────────────────────────────
  Future<void> decrementItem({
    required ApiCartItem item,
    required String username,
  }) async {
    // If qty is 1, decrementing means delete the row entirely
    if (item.itemQty <= 1) {
      await removeItem(item: item, username: username);
      return;
    }

    final key = itemKey(item);
    if (itemLoading[key] == true) return;

    // Find index by itemKey — consistent with increment
    final idx = items.indexWhere((i) => itemKey(i) == key);
    if (idx == -1) return;

    itemLoading[key] = true;

    // Optimistic update
    final oldQty = items[idx].itemQty;
    items[idx] = items[idx].copyWith(itemQty: oldQty - 1);

    try {
      await _repo.addToCart(
        AddItemToCartRequest(
          itemId: item.itemId,
          itemDetId: item.itemDetId,
          username: username,
          itemQty: -1,
        ),
      );
    } on Exception catch (e) {
      // Revert on failure
      items[idx] = items[idx].copyWith(itemQty: oldQty);
      debugPrint('[CartController] decrementItem error: $e');
      Get.snackbar('Error', 'Failed to update quantity: $e');
      rethrow;
    } finally {
      itemLoading.remove(key);
    }
  }
}