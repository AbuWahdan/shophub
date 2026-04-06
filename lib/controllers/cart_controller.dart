import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../data/repositories/cart_repository.dart';
import '../src/model/cart_api.dart';

class CartController extends GetxController {
  final CartRepository _repo;

  CartController(this._repo);

  final items = <ApiCartItem>[].obs;
  final isLoading = false.obs;

  // Per-item loading: key = cart line id when available, else item detail id.
  final itemLoading = <int, bool>{}.obs;

  int _itemKey(ApiCartItem item) =>
      item.cartItemId > 0
          ? item.cartItemId
          : (item.detailId > 0 ? item.detailId : item.itemDetId);

  /// Load cart for a user
  Future<void> loadCart({required String username}) async {
    isLoading.value = true;

    try {
      if (kDebugMode) {
        debugPrint('[CartController] Loading cart for $username');
      }

      final cartItems = await _repo.getCart(username: username);
      items.assignAll(cartItems);

      if (kDebugMode) {
        debugPrint(
          '[CartController] Cart loaded with ${cartItems.length} items',
        );
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint('[CartController] Error loading cart: $e');
      }
      Get.snackbar('Error', 'Failed to load cart: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Increment item quantity (optimistic update)
  Future<void> incrementItem({
    required ApiCartItem item,
    required String username,
  }) async {
    // Optimistic update
    itemLoading[_itemKey(item)] = true;
    final idx = items.indexWhere((i) => i.itemDetId == item.itemDetId);
    final oldQty = idx != -1 ? items[idx].itemQty : 0;

    if (idx != -1) {
      items[idx] = items[idx].copyWith(itemQty: items[idx].itemQty + 1);
    }

    try {
      await _repo.addToCart(
        AddItemToCartRequest(
          itemId: item.itemId,
          itemDetId: item.itemDetId,
          username: username,
          itemQty: 1,
        ),
      );

      if (kDebugMode) {
        debugPrint('[CartController] Item incremented successfully');
      }
    } catch (e) {
      // Revert optimistic update
      if (idx != -1) {
        items[idx] = items[idx].copyWith(itemQty: oldQty);
      }
      if (kDebugMode) {
        debugPrint('[CartController] Error incrementing item: $e');
      }
      Get.snackbar('Error', 'Failed to update item: $e');
      rethrow;
    } finally {
      itemLoading[_itemKey(item)] = false;
    }
  }

  /// Decrement item quantity (optimistic update)
  /// If quantity would reach 0, delete the item from cart instead
  Future<void> decrementItem({
    required ApiCartItem item,
    required String username,
  }) async {
    // If quantity is 1, delete the item completely
    if (item.itemQty <= 1) {
      await removeItem(item: item, username: username);
      return;
    }

    // Optimistic update
    itemLoading[_itemKey(item)] = true;
    final idx = items.indexWhere((i) => i.itemDetId == item.itemDetId);
    final oldQty = idx != -1 ? items[idx].itemQty : 0;

    if (idx != -1) {
      items[idx] = items[idx].copyWith(itemQty: items[idx].itemQty - 1);
    }

    try {
      await _repo.addToCart(
        AddItemToCartRequest(
          itemId: item.itemId,
          itemDetId: item.itemDetId,
          username: username,
          itemQty: -1, // Decrease by 1 (or API interprets as reduce)
        ),
      );

      if (kDebugMode) {
        debugPrint('[CartController] Item decremented successfully');
      }
    } catch (e) {
      // Revert optimistic update
      if (idx != -1) {
        items[idx] = items[idx].copyWith(itemQty: oldQty);
      }
      if (kDebugMode) {
        debugPrint('[CartController] Error decrementing item: $e');
      }
      Get.snackbar('Error', 'Failed to update item: $e');
      rethrow;
    } finally {
      itemLoading[_itemKey(item)] = false;
    }
  }

  /// Remove item from cart with confirmation
  Future<void> removeItem({
    required ApiCartItem item,
    required String username,
  }) async {
    itemLoading[_itemKey(item)] = true;

    if (item.detailId <= 0) {
      itemLoading[_itemKey(item)] = false;
      Get.snackbar('Error', 'Could not remove item. Please try again.');
      return;
    }

    try {
      await _repo.deleteFromCart(
        detailId: item.detailId,
        modifiedBy: username,
      );

      items.removeWhere(
        (i) =>
            i.detailId == item.detailId ||
            (i.itemDetId == item.itemDetId && i.itemId == item.itemId),
      );

      if (kDebugMode) {
        debugPrint('[CartController] Item removed from cart');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CartController] Error removing item: $e');
      }
      Get.snackbar('Error', 'Failed to remove item: $e');
      rethrow;
    } finally {
      itemLoading[_itemKey(item)] = false;
    }
  }

  /// Clear error state
  void clearError() {
    itemLoading.clear();
  }
}
