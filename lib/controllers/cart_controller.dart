import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../data/repositories/cart_repository.dart';
import '../models/cart_api.dart';

class CartController extends GetxController {
  final CartRepository _repo;
  CartController(this._repo);

  final RxList<ApiCartItem> items       = <ApiCartItem>[].obs;
  final RxBool              isLoading   = false.obs;
  // FIX: use RxMap with explicit bool values.
  // Removing a key directly (itemLoading.remove(key)) does NOT always trigger
  // Obx to rebuild because GetX tracks the map reference, not key deletions.
  // Pattern: always set to false THEN remove — the false-write triggers Obx,
  // the subsequent remove keeps the map clean.
  final RxMap<int, bool> itemLoading = <int, bool>{}.obs;

  // ── Computed ──────────────────────────────────────────────────────────────

  /// Total number of distinct items in the cart — used for the nav badge.
  int get totalItemCount => items.length;

  /// Total quantity across all items — alternative badge value.
  int get totalQuantity =>
      items.fold(0, (sum, item) => sum + item.itemQty);

  int itemKey(ApiCartItem item) {
    if (item.detailId > 0) return item.detailId;
    return item.itemDetId;
  }

  // ── Internal: mark loading state ──────────────────────────────────────────

  void _setLoading(int key, bool value) {
    if (value) {
      itemLoading[key] = true;
    } else {
      // Write false first so Obx sees the change, then clean up the key.
      itemLoading[key] = false;
      itemLoading.remove(key);
    }
  }

  // ── Add ───────────────────────────────────────────────────────────────────

  Future<void> addItem({
    required int    itemId,
    required int    itemDetId,
    required String username,
    required int    chosenQty,
  }) async {
    final existing    = items.firstWhereOrNull((i) => i.itemDetId == itemDetId);
    final existingKey = existing != null ? itemKey(existing) : 0;

    if (existing != null && existingKey > 0) {
      try {
        await _repo.deleteFromCart(
          detailId:   existingKey,
          modifiedBy: username,
        );
        items.removeWhere((i) => itemKey(i) == existingKey);
      } on Exception catch (e) {
        debugPrint('[CartController] addItem pre-delete error: $e');
      }
    }

    await _repo.addToCart(AddItemToCartRequest(
      itemId:    itemId,
      itemDetId: itemDetId,
      username:  username,
      itemQty:   chosenQty,
    ));

    // Reload so the new item (with its real detailId) appears immediately.
    await loadCart(username: username);
  }

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> loadCart({required String username}) async {
    isLoading.value = true;
    try {
      final fetched = await _repo.getCart(username: username);
      final corrected = fetched.map((item) {
        if (item.availableQty > 0 && item.itemQty > item.availableQty) {
          debugPrint(
            '[CartController] Clamping ${item.itemName}: '
                '${item.itemQty} → ${item.availableQty}',
          );
          return item.copyWith(itemQty: item.availableQty);
        }
        return item;
      }).toList();
      items.assignAll(corrected);
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
    required String      username,
  }) async {
    final key = itemKey(item);
    if (key <= 0) {
      Get.snackbar('Error', 'Cannot delete: cart row ID not found.',
          snackPosition: SnackPosition.TOP);
      return false;
    }
    if (itemLoading[key] == true) return false;

    _setLoading(key, true);
    try {
      await _repo.deleteFromCart(detailId: key, modifiedBy: username);
      items.removeWhere((i) => itemKey(i) == key);
      return true;
    } on Exception catch (e) {
      debugPrint('[CartController] removeItem error: $e');
      Get.snackbar('Error', 'Server failed to delete item: $e');
      return false;
    } finally {
      _setLoading(key, false);
    }
  }

  // ── Increment ─────────────────────────────────────────────────────────────

  Future<void> incrementItem({
    required ApiCartItem item,
    required String      username,
  }) async {
    final key = itemKey(item);
    if (itemLoading[key] == true) return;

    final idx = items.indexWhere((i) => itemKey(i) == key);
    if (idx == -1) return;

    final current = items[idx];

    if (current.availableQty > 0 && current.itemQty >= current.availableQty) {
      Get.snackbar(
        'Out of Stock',
        'Only ${current.availableQty} unit(s) available for ${current.itemName}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    _setLoading(key, true);
    final oldQty = current.itemQty;

    // Optimistic update
    items[idx] = current.copyWith(itemQty: oldQty + 1);

    try {
      await _repo.addToCart(AddItemToCartRequest(
        itemId:    item.itemId,
        itemDetId: item.itemDetId,
        username:  username,
        itemQty:   1,
      ));
      // FIX: release lock BEFORE reload — prevents spinner freeze if
      // loadCart is slow, because _setLoading(key, false) triggers Obx
      // immediately, removing the spinner, then the list refreshes.
      _setLoading(key, false);
      await loadCart(username: username);
    } on Exception catch (e) {
      // Rollback optimistic update
      final revertIdx = items.indexWhere((i) => itemKey(i) == key);
      if (revertIdx != -1) {
        items[revertIdx] = items[revertIdx].copyWith(itemQty: oldQty);
      }
      debugPrint('[CartController] incrementItem error: $e');
      Get.snackbar('Error', 'Failed to update quantity: $e');
      _setLoading(key, false);
    }
    // NOTE: no finally here — _setLoading is called explicitly in both
    // success and error paths BEFORE the reload, so the spinner stops
    // immediately rather than waiting for loadCart to complete.
  }

  // ── Decrement ─────────────────────────────────────────────────────────────

  Future<void> decrementItem({
    required ApiCartItem item,
    required String      username,
  }) async {
    if (item.itemQty <= 1) {
      await removeItem(item: item, username: username);
      return;
    }

    final key = itemKey(item);
    if (itemLoading[key] == true) return;

    final idx = items.indexWhere((i) => itemKey(i) == key);
    if (idx == -1) return;

    // Capture all values needed for re-add BEFORE any await.
    final capturedItemId    = item.itemId;
    final capturedItemDetId = item.itemDetId;
    final capturedOldQty    = item.itemQty;
    final capturedNewQty    = capturedOldQty - 1;

    _setLoading(key, true);

    // Optimistic update
    items[idx] = items[idx].copyWith(itemQty: capturedNewQty);

    try {
      await _repo.deleteFromCart(detailId: key, modifiedBy: username);
      await _repo.addToCart(AddItemToCartRequest(
        itemId:    capturedItemId,
        itemDetId: capturedItemDetId,
        username:  username,
        itemQty:   capturedNewQty,
      ));
      // Release lock BEFORE reload — same pattern as incrementItem.
      _setLoading(key, false);
      await loadCart(username: username);
    } on Exception catch (e) {
      final revertIdx = items.indexWhere((i) => itemKey(i) == key);
      if (revertIdx != -1) {
        items[revertIdx] = items[revertIdx].copyWith(itemQty: capturedOldQty);
      }
      debugPrint('[CartController] decrementItem error: $e');
      Get.snackbar('Error', 'Failed to update quantity: $e');
      _setLoading(key, false);
    }
  }
}