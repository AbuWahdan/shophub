import 'package:sinwar_shoping/src/config/app_images.dart';
import 'package:flutter/foundation.dart';
import 'package:sinwar_shoping/src/model/product_api.dart';

import 'address.dart';
import 'cart_item.dart';
import 'category.dart';
import 'order.dart';
import 'product_comment.dart';

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

  static final List<CartItem> cartItems = <CartItem>[];
  static final ValueNotifier<int> cartCountNotifier = ValueNotifier<int>(0);

  static void setCartItems(List<CartItem> items) {
    cartItems
      ..clear()
      ..addAll(items);
    _notifyCartCountChanged();
  }

  static final Set<int> _wishlistIds = <int>{};
  static final Map<int, ApiProduct> _wishlistProducts = <int, ApiProduct>{};

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

  static List<String> showThumbnailList = [
    AppImages.shoeThumb5,
    AppImages.shoeThumb1,
    AppImages.shoeThumb4,
    AppImages.shoeThumb3,
  ];

  static List<Address> addressList = [
    Address(
      id: '1',
      name: 'Home',
      phone: '+1 (555) 123-4567',
      street: '123 Main Street',
      city: 'New York',
      state: 'NY',
      zipCode: '10001',
      country: 'USA',
      isDefault: true,
    ),
    Address(
      id: '2',
      name: 'Office',
      phone: '+1 (555) 987-6543',
      street: '456 Business Ave',
      city: 'New York',
      state: 'NY',
      zipCode: '10002',
      country: 'USA',
      isDefault: false,
    ),
  ];

  static List<Order> orderList = [
    Order(
      id: 'ORD-001',
      items: [
        OrderItem(
          productId: 1,
          productName: 'Nike Air Max 200',
          image: AppImages.shoeTilt1,
          price: 200.00,
          quantity: 1,
          selectedSize: '10',
          selectedColor: 'Black',
        ),
      ],
      subtotal: 200.00,
      shipping: 10.00,
      discount: 0,
      total: 210.00,
      status: OrderStatus.delivered,
      date: DateTime.now().subtract(const Duration(days: 15)),
      addressId: '1',
      estimatedDelivery: 'Delivered',
      paymentMethod: 'Credit/Debit Card',
    ),
  ];

  static List<ProductComment> productComments = [];

  static bool isFavorite(int productId) => _wishlistIds.contains(productId);

  static void syncFavoriteFor(ApiProduct product) {
    product.isFavorite = isFavorite(product.id);
  }

  static void toggleFavorite(ApiProduct product) {
    final id = product.id;
    if (_wishlistIds.contains(id)) {
      _wishlistIds.remove(id);
      _wishlistProducts.remove(id);
      product.isFavorite = false;
      return;
    }

    _wishlistIds.add(id);
    _wishlistProducts[id] = product;
    product.isFavorite = true;
  }

  static List<ApiProduct> get wishlistProducts =>
      _wishlistProducts.values.toList();

  static void addToCart({
    required ApiProduct product,
    required int quantity,
    required String size,
    required String color,
    int detId = 0,
  }) {
    final existingIndex = cartItems.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.selectedDetId == detId &&
          item.selectedSize == size &&
          item.selectedColor == color,
    );

    if (existingIndex >= 0) {
      cartItems[existingIndex].quantity += quantity;
      _notifyCartCountChanged();
      return;
    }

    cartItems.add(
      CartItem(
        product: product,
        quantity: quantity,
        selectedSize: size,
        selectedColor: color,
        selectedDetId: detId,
      ),
    );
    _notifyCartCountChanged();
  }

  static void removeFromCartAt(int index) {
    if (index < 0 || index >= cartItems.length) return;
    cartItems.removeAt(index);
    _notifyCartCountChanged();
  }

  static void clearCart() {
    cartItems.clear();
    _notifyCartCountChanged();
  }

  static void _notifyCartCountChanged() {
    cartCountNotifier.value = cartItems.length;
  }

  static List<ProductComment> commentsForProduct(int productId) {
    return productComments
        .where((comment) => comment.productId == productId)
        .toList();
  }

  static String description =
      'Clean lines, versatile and timeless. The Nike Air Max 90 stays true to its OG running roots with the iconic Waffle sole, stitched overlays and classic TPU details.';
}
