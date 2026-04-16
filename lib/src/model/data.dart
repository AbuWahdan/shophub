import 'package:sinwar_shoping/src/config/app_images.dart';
import 'package:flutter/foundation.dart';
import 'package:sinwar_shoping/src/model/cart_api.dart';
import 'package:sinwar_shoping/src/model/product_api.dart';
import 'category.dart';

class AppData {
  static final List<ApiProduct> _products = <ApiProduct>[];

  static List<ApiProduct> get products => List.unmodifiable(_products);

  static void setProducts(List<ApiProduct> products) {
    _products
      ..clear()
      ..addAll(products);

    for (final product in _products) {
      product.isFavorite = _wishlistIds.contains(product.id);
    }

    final keep = <int, ApiProduct>{};
    for (final product in _products) {
      if (_wishlistIds.contains(product.id)) {
        keep[product.id] = product;
      }
    }
    _wishlistProducts
      ..clear()
      ..addAll(keep);
  }


  static final Set<int> _wishlistIds = <int>{};
  static final Map<int, ApiProduct> _wishlistProducts = <int, ApiProduct>{};
  static final List<ApiCartItem> _cartItems = <ApiCartItem>[];
  static final ValueNotifier<int> cartCountNotifier = ValueNotifier<int>(0);

  static List<Categories> categoryList = [
    Categories(id: 0, name: 'All', image: AppImages.all, isSelected: true),
    Categories(
      id: 1,
      name: 'Women',
      image: AppImages.clothing,
      isSelected: false,
    ),
    Categories(
      id: 2,
      name: 'Men',
      image: AppImages.clothing,
      isSelected: false,
    ),
    Categories(
      id: 3,
      name: 'Kids',
      image: AppImages.clothing,
      isSelected: false,
    ),
    Categories(
      id: 4,
      name: 'Jewelry',
      image: AppImages.watch,
      isSelected: false,
    ),
    Categories(
      id: 5,
      name: 'Beauty & Health',
      image: AppImages.placeholder,
      isSelected: false,
    ),
    Categories(
      id: 6,
      name: 'Home',
      image: AppImages.placeholder,
      isSelected: false,
    ),
    Categories(
      id: 7,
      name: 'Kitchen',
      image: AppImages.placeholder,
      isSelected: false,
    ),
    Categories(
      id: 8,
      name: 'Electronics',
      image: AppImages.electronics,
      isSelected: false,
    ),
    Categories(
      id: 9,
      name: 'Shoes',
      image: AppImages.shoeThumb2,
      isSelected: false,
    ),
    Categories(
      id: 10,
      name: 'Bags',
      image: AppImages.placeholder,
      isSelected: false,
    ),
    Categories(
      id: 11,
      name: 'Accessories',
      image: AppImages.placeholder,
      isSelected: false,
    ),
    Categories(
      id: 12,
      name: 'Toys',
      image: AppImages.placeholder,
      isSelected: false,
    ),
    Categories(
      id: 13,
      name: 'Sports & Outdoors',
      image: AppImages.placeholder,
      isSelected: false,
    ),
    Categories(
      id: 14,
      name: 'Pet Supplies',
      image: AppImages.placeholder,
      isSelected: false,
    ),
    Categories(
      id: 15,
      name: 'Automotive',
      image: AppImages.placeholder,
      isSelected: false,
    ),
    Categories(
      id: 16,
      name: 'Tools & Home Improvement',
      image: AppImages.placeholder,
      isSelected: false,
    ),
    Categories(
      id: 17,
      name: 'Office & School Supplies',
      image: AppImages.placeholder,
      isSelected: false,
    ),
    Categories(
      id: 18,
      name: 'Furniture',
      image: AppImages.placeholder,
      isSelected: false,
    ),
    Categories(
      id: 19,
      name: 'Appliances',
      image: AppImages.placeholder,
      isSelected: false,
    ),
    Categories(
      id: 20,
      name: 'Arts, Crafts & Sewing',
      image: AppImages.placeholder,
      isSelected: false,
    ),
    Categories(
      id: 21,
      name: 'Sneakers',
      image: AppImages.shoeThumb2,
      isSelected: false,
    ),
    Categories(
      id: 22,
      name: 'Jackets',
      image: AppImages.jacket,
      isSelected: false,
    ),
    Categories(
      id: 23,
      name: 'Watches',
      image: AppImages.watch,
      isSelected: false,
    ),
    Categories(
      id: 24,
      name: 'Clothing',
      image: AppImages.clothing,
      isSelected: false,
    ),
  ];

  static bool isFavorite(int productId) => _wishlistIds.contains(productId);

  static void syncFavoriteFor(ApiProduct product) {
    product.isFavorite = isFavorite(product.id);
  }

  static void setFavorite(ApiProduct product, bool isFavorite) {
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

  static void setWishlistProducts(List<ApiProduct> products) {
    _wishlistIds
      ..clear()
      ..addAll(products.map((product) => product.id));
    _wishlistProducts
      ..clear()
      ..addEntries(
        products.map((product) {
          product.isFavorite = true;
          return MapEntry(product.id, product);
        }),
      );

    for (final product in _products) {
      product.isFavorite = _wishlistIds.contains(product.id);
    }
  }

  static void toggleFavorite(ApiProduct product) {
    setFavorite(product, !_wishlistIds.contains(product.id));
  }

  static List<ApiProduct> get wishlistProducts =>
      _wishlistProducts.values.toList();

  static List<ApiCartItem> get cartItems => List.unmodifiable(_cartItems);

  static void setCartItems(List<ApiCartItem> items) {
    _cartItems
      ..clear()
      ..addAll(items);
    _syncCartCount();
  }

  static void addToCart({
    required ApiProduct product,
    required int quantity,
    required String size,
    required String color,
    required int detId,
    String username = '',
  }) {
    if (quantity <= 0) {
      return;
    }

    final normalizedSize = size.trim().isEmpty ? 'Default' : size.trim();
    final normalizedColor = color.trim().isEmpty ? 'Default' : color.trim();
    final resolvedDetId = detId > 0 ? detId : product.detId;
    final matchingVariant = product.variantFor(
      size: normalizedSize,
      color: normalizedColor,
    );

    final existingIndex = _cartItems.indexWhere((item) {
      if (resolvedDetId > 0 && item.itemDetId == resolvedDetId) {
        return true;
      }
      return item.itemId == product.id &&
          item.displaySize == normalizedSize &&
          item.displayColor == normalizedColor;
    });

    if (existingIndex != -1) {
      final existing = _cartItems[existingIndex];
      _cartItems[existingIndex] = existing.copyWith(
        itemQty: existing.itemQty + quantity,
        availableQty: product.quantity,
      );
      _syncCartCount();
      return;
    }

    _cartItems.add(
      ApiCartItem(
        detailId: resolvedDetId,
        itemId: product.id,
        itemDetId: resolvedDetId,
        username: username,
        itemQty: quantity,
        availableQty: product.quantity,
        itemName: product.itemName,
        itemDesc: product.itemDesc,
        itemPrice: product.finalPrice,
        discount: product.discountPercentage.toDouble(),
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
