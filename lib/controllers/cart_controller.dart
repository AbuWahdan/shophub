import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../data/repositories/cart_repository.dart';
import '../src/model/cart_api.dart';

class CartController extends GetxController {
  final CartRepository _repo;
  CartController(this._repo);

  final RxList<ApiCartItem> items      = <ApiCartItem>[].obs;
  final RxBool              isLoading  = false.obs;
  final RxMap<int, bool>    itemLoading = <int, bool>{}.obs;

  int itemKey(ApiCartItem item) {
    if (item.detailId  > 0) return item.detailId;
    return item.itemDetId;
  }

  // ── Add (called from ProductCard) ─────────────────────────────────────────
  // If item already exists: delete old row first so BOOKED_QTY resets to 0,
  // then insert with exact chosenQty.
  // If item is new: insert directly.
  Future<void> addItem({
    required int    itemId,
    required int    itemDetId,
    required String username,
    required int    chosenQty,
  }) async {
    // Capture existing row details BEFORE any await.
    final existing = items.firstWhereOrNull((i) => i.itemDetId == itemDetId);
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
        // Continue — insert will accumulate but that beats blocking the add.
      }
    }

    // Insert with the exact qty the user chose.
    await _repo.addToCart(AddItemToCartRequest(
      itemId:    itemId,
      itemDetId: itemDetId,   // always the original itemDetId, never 0
      username:  username,
      itemQty:   chosenQty,
    ));
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
    itemLoading[key] = true;
    try {
      await _repo.deleteFromCart(detailId: key, modifiedBy: username);
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

    itemLoading[key] = true;
    final oldQty = current.itemQty;
    items[idx] = current.copyWith(itemQty: oldQty + 1);

    try {
      // Send delta 1 — backend accumulates correctly here.
      await _repo.addToCart(AddItemToCartRequest(
        itemId:    item.itemId,
        itemDetId: item.itemDetId,
        username:  username,
        itemQty:   1,
      ));
    } on Exception catch (e) {
      items[idx] = items[idx].copyWith(itemQty: oldQty);
      debugPrint('[CartController] incrementItem error: $e');
      Get.snackbar('Error', 'Failed to update quantity: $e');
    } finally {
      itemLoading.remove(key);
    }
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

    // ── FIX: capture ALL values needed for re-add BEFORE any await ──────────
    // After deleteFromCart + loadCart, the `item` parameter and `items[idx]`
    // are stale — itemDetId becomes 0 and qty becomes wrong.
    // Capturing here guarantees the re-add uses the correct values.
    final capturedItemId    = item.itemId;
    final capturedItemDetId = item.itemDetId;   // never 0 at this point
    final capturedOldQty    = item.itemQty;
    final capturedNewQty    = capturedOldQty - 1;
    // ─────────────────────────────────────────────────────────────────────────

    itemLoading[key] = true;

    // Optimistic update
    items[idx] = items[idx].copyWith(itemQty: capturedNewQty);

    try {
      // Step 1 — delete the existing row
      await _repo.deleteFromCart(detailId: key, modifiedBy: username);

      // Step 2 — re-insert with exact new qty using captured values
      await _repo.addToCart(AddItemToCartRequest(
        itemId:    capturedItemId,
        itemDetId: capturedItemDetId,   // guaranteed non-zero
        username:  username,
        itemQty:   capturedNewQty,      // exact qty, not a delta
      ));

      // Step 3 — release lock BEFORE reload so UI is not frozen
      itemLoading.remove(key);
      await loadCart(username: username);
    } on Exception catch (e) {
      final revertIdx = items.indexWhere((i) => itemKey(i) == key);
      if (revertIdx != -1) {
        items[revertIdx] = items[revertIdx].copyWith(itemQty: capturedOldQty);
      }
      debugPrint('[CartController] decrementItem error: $e');
      Get.snackbar('Error', 'Failed to update quantity: $e');
    } finally {
      itemLoading.remove(key);
    }
  }
}