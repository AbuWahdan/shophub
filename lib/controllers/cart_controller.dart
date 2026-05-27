import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/cart_item_model.dart';
import '../models/product/product_model.dart';
import '../repositories/cart_repository.dart';
import '../services/app_notification_service.dart';

class CartController extends GetxController {
  final CartRepository _repo;
  CartController(this._repo);

  // ── Reactive state ──────────────────────────────────────────────────────────

  final RxList<CartItemModel> items = <CartItemModel>[].obs;
  final RxBool isLoading = false.obs;

  /// Per-item loading state keyed by detailId
  final RxMap<int, bool> _itemBusy = <int, bool>{}.obs;

  /// Debounce tracker — prevents rapid taps on the same item
  final Map<int, DateTime> _lastTapTime = {};

  // ── Constants ───────────────────────────────────────────────────────────────

  static const Duration _tapDebounce = Duration(milliseconds: 600);

  // ── Computed getters ────────────────────────────────────────────────────────

  int get totalItemCount => items.length;

  int get totalQuantity => items.fold(0, (sum, i) => sum + i.bookedQty);

  double get totalPrice => items.fold(0.0, (sum, i) => sum + i.lineTotal);

  bool isItemBusy(int detailId) => _itemBusy[detailId] == true;

  bool canIncrement(CartItemModel item) => item.bookedQty < item.availableQty;

  bool canDecrement(CartItemModel item) => item.bookedQty > 1;

  double get originalTotalPrice =>
      items.fold(0.0, (sum, i) => sum + i.originalLineTotal);
  // ── Private helpers ─────────────────────────────────────────────────────────
// State
  final RxList<CartItemModel> cartItems = <CartItemModel>[].obs;
  final RxInt cartCount = 0.obs;

  void setCartItems(List<CartItemModel> items) {
    cartItems.assignAll(items);
    _syncCount();
  }

  void addToCart({
    required ProductModel product,
    required int quantity,
    required String size,
    required String color,
    required int detId,
    String username = '',
  }) {
    if (quantity <= 0) return;

    final normalizedSize = size.trim().isEmpty ? 'Default' : size.trim();
    final normalizedColor = color.trim().isEmpty ? 'Default' : color.trim();
    final resolvedDetId = detId > 0 ? detId : product.detId;

    final matchingVariant = product.variantFor(
      size: normalizedSize,
      color: normalizedColor,
    );
    final sourceVariant = matchingVariant ??
        (product.variants.isNotEmpty ? product.variants.first : null);

    final itemPrice = sourceVariant != null && sourceVariant.price > 0
        ? sourceVariant.price
        : product.finalPrice;
    final itemDiscount = sourceVariant?.discount ?? product.discountPercentage.toDouble();
    final availableQty = sourceVariant != null && sourceVariant.stock > 0
        ? sourceVariant.stock
        : product.baseStock;

    final existingIndex = cartItems.indexWhere((item) {
      if (resolvedDetId > 0 && item.itemDetId == resolvedDetId) return true;
      return item.itemId == product.id &&
          item.displaySize == normalizedSize &&
          item.displayColor == normalizedColor;
    });

    if (existingIndex != -1) {
      final existing = cartItems[existingIndex];
      cartItems[existingIndex] = existing.copyWith(
        bookedQty: existing.bookedQty + quantity,
        availableQty: availableQty,
      );
      _syncCount();
      return;
    }

    cartItems.add(CartItemModel(
      detailId: resolvedDetId,
      itemId: product.id,
      itemDetId: resolvedDetId,
      username: username,
      bookedQty: quantity,
      availableQty: availableQty,
      name: product.name,
      description: product.description,
      price: itemPrice,
      discount: itemDiscount,
      imageUrl: product.primaryImageUrl,
      color: normalizedColor,
      size: normalizedSize,
      brand: matchingVariant?.brand ??
          (product.variants.isNotEmpty ? product.variants.first.brand : ''),
    ));
    _syncCount();
  }

  void _syncCount() {
    cartCount.value = cartItems.fold(0, (sum, item) => sum + item.bookedQty);
  }

  void _setBusy(int detailId, {required bool busy}) {
    if (busy) {
      _itemBusy[detailId] = true;
    } else {
      _itemBusy.remove(detailId);
    }
  }

  bool _isDebounced(int detailId) {
    final last = _lastTapTime[detailId];
    if (last == null) return false;
    return DateTime.now().difference(last) < _tapDebounce;
  }

  void _recordTap(int detailId) => _lastTapTime[detailId] = DateTime.now();

  int _indexOf(int detailId) {
    for (int i = 0; i < items.length; i++) {
      if (items[i].detailId == detailId) return i;
    }
    return -1;
  }

  void _showError(String message) =>
      AppNotificationService.instance.showError(null, message);

  void _showWarning(String message) =>
      AppNotificationService.instance.showWarning(null, message);

  void _showSuccess(String message) =>
      AppNotificationService.instance.showSuccess(null, message);


  Future<void> loadCart({required String username}) async {
    final normalized = username.trim();
    if (normalized.isEmpty) {
      items.clear();
      return;
    }

    isLoading.value = true;
    try {
      final result = await _repo.fetchCart(username: normalized);
      items.assignAll(result);

      if (kDebugMode) {
        debugPrint(
          '[CartController.loadCart] ${result.length} items for $normalized',
        );
      }
    } catch (e) {
      debugPrint('[CartController.loadCart] error: $e');
      _showError('Failed to load cart. Please try again.');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> addItem({
    required int itemId,
    required int itemDetId,
    required String username,
    required int requestedQty,
  }) async {
    if (requestedQty <= 0) return;

    final normalized = username.trim();
    if (normalized.isEmpty) {
      _showError('Please log in to manage your cart.');
      return;
    }

    try {
      // Check if item already in cart → cap delta to remaining stock
      final existing = items.firstWhereOrNull((i) => i.itemDetId == itemDetId);
      int deltaQty = requestedQty;

      if (existing != null) {
        final remaining = existing.availableQty - existing.bookedQty;
        if (remaining <= 0) {
          _showWarning(
            'Maximum quantity reached (${existing.availableQty} in stock).',
          );
          return;
        }
        if (deltaQty > remaining) {
          deltaQty = remaining;
          _showWarning('Only $remaining more available. Added maximum.');
        }
      }

      await _repo.addItem(
        AddToCartRequest(
          itemId: itemId,
          itemDetId: itemDetId,
          username: normalized,
          deltaQty: deltaQty,
        ),
      );

      await loadCart(username: normalized);
      _showSuccess('Item added to cart');
    } catch (e) {
      debugPrint('[CartController.addItem] error: $e');
      _showError('Failed to add item to cart.');
    }
  }

  // ─────────────────────────────
  // REMOVE ITEM
  // ─────────────────────────────

  Future<bool> removeItem({
    required CartItemModel item,
    required String username,
  }) async {
    final normalized = username.trim();
    if (normalized.isEmpty) {
      _showError('Please log in to manage your cart.');
      return false;
    }

    final detailId = item.detailId;
    if (_itemBusy[detailId] == true) return false;

    // Optimistic removal
    final originalIndex = _indexOf(detailId);
    final snapshot = originalIndex >= 0 ? items[originalIndex] : null;
    if (originalIndex >= 0) items.removeAt(originalIndex);

    _setBusy(detailId, busy: true);
    try {
      await _repo.removeItem(detailId: detailId, username: normalized);
      _showSuccess('Item removed');
      return true;
    } catch (e) {
      // Rollback
      if (snapshot != null && originalIndex >= 0) {
        items.insert(originalIndex, snapshot);
      }
      _showError('Failed to remove item.');
      return false;
    } finally {
      _setBusy(detailId, busy: false);
    }
  }

  // ─────────────────────────────
  // INCREMENT (+1)
  // ─────────────────────────────

  Future<void> incrementItem({
    required CartItemModel item,
    required String username,
  }) async {
    if (!canIncrement(item)) {
      _showWarning(
        'Maximum quantity reached (${item.availableQty} in stock).',
      );
      return;
    }

    final detailId = item.detailId;

    if (_isDebounced(detailId)) return;
    if (_itemBusy[detailId] == true) return;

    _recordTap(detailId);

    // Optimistic update
    final index = _indexOf(detailId);
    if (index == -1) return;
    final snapshot = items[index];
    items[index] = snapshot.copyWith(bookedQty: snapshot.bookedQty + 1);

    _setBusy(detailId, busy: true);
    try {
      // ✅ DELTA ONLY: Send +1. API accumulates, so this is correct.
      await _repo.incrementItemQty(
        itemId: item.itemId,
        itemDetId: item.itemDetId,
        username: username.trim(),
        tax: item.tax,
      );
      // Refresh to get server-confirmed state
      await loadCart(username: username.trim());
    } catch (e) {
      // Rollback
      final rollbackIndex = _indexOf(detailId);
      if (rollbackIndex >= 0) items[rollbackIndex] = snapshot;
      _showError('Failed to update quantity.');
    } finally {
      _setBusy(detailId, busy: false);
    }
  }

  // ─────────────────────────────
  // DECREMENT (-1)
  // ─────────────────────────────

  Future<void> decrementItem({
    required CartItemModel item,
    required String username,
  }) async {
    final detailId = item.detailId;
    final normalized = username.trim();

    if (_isDebounced(detailId)) return;
    if (_itemBusy[detailId] == true) return;

    _recordTap(detailId);

    // Decrement to 0 → remove entirely
    if (item.bookedQty <= 1) {
      await removeItem(item: item, username: normalized);
      return;
    }

    // Optimistic update
    final index = _indexOf(detailId);
    if (index == -1) return;
    final snapshot = items[index];
    items[index] = snapshot.copyWith(bookedQty: snapshot.bookedQty - 1);

    _setBusy(detailId, busy: true);
    try {
      // ✅ SIMPLE: Just send delta=-1. API subtracts natively.
      // No delete+re-add. No race conditions. No available_qty corruption.
      await _repo.decrementItemQty(
        itemId: item.itemId,
        itemDetId: item.itemDetId,
        username: normalized,
        tax: item.tax,
      );
      await loadCart(username: normalized);
    } catch (e) {
      // Rollback
      final rollbackIndex = _indexOf(detailId);
      if (rollbackIndex >= 0) items[rollbackIndex] = snapshot;
      _showError('Failed to update quantity.');
    } finally {
      _setBusy(detailId, busy: false);
    }
  }

}