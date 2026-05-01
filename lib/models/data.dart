import 'package:sinwar_shoping/models/product_model.dart';
import 'package:flutter/foundation.dart';
import 'package:sinwar_shoping/models/cart_item_model.dart';

class AppData {
  static final List<ProductModel> _products = <ProductModel>[];
  static final Set<int> _wishlistIds = <int>{};
  static final Map<int, ProductModel> _wishlistProducts = <int, ProductModel>{};
  static final List<CartItemModel> _cartItems = <CartItemModel>[];
  static final ValueNotifier<int> cartCountNotifier = ValueNotifier<int>(0);

  // ── Products ──────────────────────────────────────────────────────────────

  static List<ProductModel> get products => List.unmodifiable(_products);

  static void setProducts(List<ProductModel> products) {
    _products
      ..clear()
      ..addAll(products);

    // Re-sync isFavorite for every loaded product based on the current
    // wishlist IDs (which may have been seeded from SharedPreferences before
    // this call — see seedWishlistIds).
    for (final product in _products) {
      product.isFavorite = _wishlistIds.contains(product.id);
    }

    // Rebuild the wishlist product map from the updated product list.
    // Products that are favorited but not yet in _products stay in
    // _wishlistProducts from the previous setWishlistProducts call.
    for (final product in _products) {
      if (_wishlistIds.contains(product.id)) {
        _wishlistProducts[product.id] = product;
      }
    }
  }

  // ── Wishlist ──────────────────────────────────────────────────────────────

  static List<ProductModel> get wishlistProducts =>
      _wishlistProducts.values.toList();

  static bool isFavorite(int productId) => _wishlistIds.contains(productId);

  static void syncFavoriteFor(ProductModel product) {
    product.isFavorite = isFavorite(product.id);
  }

  /// Pre-seeds wishlist IDs from local storage before the API fetch completes.
  ///
  /// This ensures that:
  ///  1. Products loaded by the home tab immediately show the correct
  ///     heart icon without waiting for getUserFavorites().
  ///  2. The wishlist screen is never blank on a cold start — products already
  ///     in the all-products cache are promoted into _wishlistProducts right away.
  static void seedWishlistIds(Set<int> ids) {
    if (ids.isEmpty) return;

    _wishlistIds.addAll(ids);

    // Promote any already-loaded products into the wishlist map.
    for (final product in _products) {
      if (ids.contains(product.id)) {
        product.isFavorite = true;
        _wishlistProducts[product.id] = product;
      }
    }
  }

  /// Called after a successful getUserFavorites() with the full product list.
  /// Replaces the wishlist state entirely.
  static void setWishlistProducts(List<ProductModel> products) {
    _wishlistIds
      ..clear()
      ..addAll(products.map((p) => p.id));

    _wishlistProducts
      ..clear()
      ..addEntries(products.map((p) {
        p.isFavorite = true;
        return MapEntry(p.id, p);
      }));

    // Sync isFavorite flag on all loaded products.
    for (final product in _products) {
      product.isFavorite = _wishlistIds.contains(product.id);
    }
  }

  /// Adds or removes a single product from the in-memory wishlist.
  static void setFavorite(ProductModel product, bool isFavorite) {
    final id = product.id;
    if (isFavorite) {
      _wishlistIds.add(id);
      _wishlistProducts[id] = product;
    } else {
      _wishlistIds.remove(id);
      _wishlistProducts.remove(id);
    }

    product.isFavorite = isFavorite;
    for (final item in _products) {
      if (item.id == id) {
        item.isFavorite = isFavorite;
      }
    }
  }

  static void toggleFavorite(ProductModel product) {
    setFavorite(product, !_wishlistIds.contains(product.id));
  }

  // ── Cart ──────────────────────────────────────────────────────────────────

  static List<CartItemModel> get cartItems => List.unmodifiable(_cartItems);

  static void setCartItems(List<CartItemModel> items) {
    _cartItems
      ..clear()
      ..addAll(items);
    _syncCartCount();
  }

  static void addToCart({
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
    final sourceVariant =
        matchingVariant ??
            (product.details.isNotEmpty ? product.details.first : null);
    final sourceItemPrice = sourceVariant != null && sourceVariant.itemPrice > 0
        ? sourceVariant.itemPrice
        : product.price;
    final sourceDiscount = sourceVariant != null
        ? sourceVariant.discount
        : product.discountPercentage.toDouble();
    final sourceAvailableQty =
    sourceVariant != null && sourceVariant.itemQty > 0
        ? sourceVariant.itemQty
        : product.quantity;

    final existingIndex = _cartItems.indexWhere((item) {
      if (resolvedDetId > 0 && item.itemDetId == resolvedDetId) return true;
      return item.itemId == product.id &&
          item.displaySize == normalizedSize &&
          item.displayColor == normalizedColor;
    });

    if (existingIndex != -1) {
      final existing = _cartItems[existingIndex];
      _cartItems[existingIndex] = existing.copyWith(
        itemQty: existing.itemQty + quantity,
        availableQty: sourceAvailableQty,
      );
      _syncCartCount();
      return;
    }

    _cartItems.add(
      CartItemModel(
        detailId: resolvedDetId,
        itemId: product.id,
        itemDetId: resolvedDetId,
        username: username,
        itemQty: quantity,
        availableQty: sourceAvailableQty,
        itemName: product.itemName,
        itemDesc: product.itemDesc,
        itemPrice: sourceItemPrice,
        discount: sourceDiscount,
        itemImgUrl: product.itemImgUrl,
        color: normalizedColor,
        itemSize: normalizedSize,
        brand: matchingVariant?.brand ??
            (product.details.isNotEmpty ? product.details.first.brand : ''),
      ),
    );
    _syncCartCount();
  }

  static void _syncCartCount() {
    cartCountNotifier.value =
        _cartItems.fold<int>(0, (sum, item) => sum + item.itemQty);
  }



}