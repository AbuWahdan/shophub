import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../data/repositories/cart_repository.dart';
import '../src/model/cart_api.dart';

class CartController extends GetxController {
  final CartRepository _repo;

  CartController(this._repo);

  final items = <ApiCartItem>[].obs;
  final isLoading = false.obs;
  
  // Per-item loading: key = detail_id (itemDetId), value = true while API in flight
  final itemLoading = <int, bool>{}.obs;

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
        debugPrint('[CartController] Cart loaded with ${cartItems.length} items');
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
    itemLoading[item.itemDetId] = true;
    final idx = items.indexWhere((i) => i.itemDetId == item.itemDetId);
    final oldQty = idx != -1 ? items[idx].itemQty : 0;
    
    if (idx != -1) {
      // Create new instance with incremented quantity
      items[idx] = ApiCartItem(
        itemId: items[idx].itemId,
        itemDetId: items[idx].itemDetId,
        username: items[idx].username,
        itemQty: items[idx].itemQty + 1,
        availableQty: items[idx].availableQty,
        itemName: items[idx].itemName,
        itemDesc: items[idx].itemDesc,
        itemPrice: items[idx].itemPrice,
        discount: items[idx].discount,
        itemImgUrl: items[idx].itemImgUrl,
        color: items[idx].color,
        itemSize: items[idx].itemSize,
        brand: items[idx].brand,
      );
    }

    try {
      await _repo.addToCart(AddItemToCartRequest(
        itemId: item.itemId,
        itemDetId: item.itemDetId,
        username: username,
        itemQty: 1,
      ));
      
      if (kDebugMode) {
        debugPrint('[CartController] Item incremented successfully');
      }
    } catch (e) {
      // Revert optimistic update
      if (idx != -1) {
        items[idx] = ApiCartItem(
          itemId: items[idx].itemId,
          itemDetId: items[idx].itemDetId,
          username: items[idx].username,
          itemQty: oldQty,
          availableQty: items[idx].availableQty,
          itemName: items[idx].itemName,
          itemDesc: items[idx].itemDesc,
          itemPrice: items[idx].itemPrice,
          discount: items[idx].discount,
          itemImgUrl: items[idx].itemImgUrl,
          color: items[idx].color,
          itemSize: items[idx].itemSize,
          brand: items[idx].brand,
        );
      }
      if (kDebugMode) {
        debugPrint('[CartController] Error incrementing item: $e');
      }
      Get.snackbar('Error', 'Failed to update item: $e');
      rethrow;
    } finally {
      itemLoading[item.itemDetId] = false;
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
    itemLoading[item.itemDetId] = true;
    final idx = items.indexWhere((i) => i.itemDetId == item.itemDetId);
    final oldQty = idx != -1 ? items[idx].itemQty : 0;
    
    if (idx != -1) {
      items[idx] = ApiCartItem(
        itemId: items[idx].itemId,
        itemDetId: items[idx].itemDetId,
        username: items[idx].username,
        itemQty: items[idx].itemQty - 1,
        availableQty: items[idx].availableQty,
        itemName: items[idx].itemName,
        itemDesc: items[idx].itemDesc,
        itemPrice: items[idx].itemPrice,
        discount: items[idx].discount,
        itemImgUrl: items[idx].itemImgUrl,
        color: items[idx].color,
        itemSize: items[idx].itemSize,
        brand: items[idx].brand,
      );
    }

    try {
      await _repo.addToCart(AddItemToCartRequest(
        itemId: item.itemId,
        itemDetId: item.itemDetId,
        username: username,
        itemQty: -1, // Decrease by 1 (or API interprets as reduce)
      ));

      if (kDebugMode) {
        debugPrint('[CartController] Item decremented successfully');
      }
    } catch (e) {
      // Revert optimistic update
      if (idx != -1) {
        items[idx] = ApiCartItem(
          itemId: items[idx].itemId,
          itemDetId: items[idx].itemDetId,
          username: items[idx].username,
          itemQty: oldQty,
          availableQty: items[idx].availableQty,
          itemName: items[idx].itemName,
          itemDesc: items[idx].itemDesc,
          itemPrice: items[idx].itemPrice,
          discount: items[idx].discount,
          itemImgUrl: items[idx].itemImgUrl,
          color: items[idx].color,
          itemSize: items[idx].itemSize,
          brand: items[idx].brand,
        );
      }
      if (kDebugMode) {
        debugPrint('[CartController] Error decrementing item: $e');
      }
      Get.snackbar('Error', 'Failed to update item: $e');
      rethrow;
    } finally {
      itemLoading[item.itemDetId] = false;
    }
  }

  /// Remove item from cart with confirmation
  Future<void> removeItem({
    required ApiCartItem item,
    required String username,
  }) async {
    itemLoading[item.itemDetId] = true;
    
    try {
      await _repo.deleteFromCart(
        detailId: item.itemDetId,
        modifiedBy: username,
      );
      
      items.removeWhere((i) => i.itemDetId == item.itemDetId);
      
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
      itemLoading[item.itemDetId] = false;
    }
  }

  /// Clear error state
  void clearError() {
    itemLoading.clear();
  }
}
