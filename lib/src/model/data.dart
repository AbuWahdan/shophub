import 'package:sinwar_shoping/src/config/app_images.dart';
import 'package:sinwar_shoping/src/model/product.dart';
import 'cart_item.dart';
import 'category.dart';
import 'address.dart';
import 'order.dart';
import 'product_comment.dart';

class AppData {
  static Map<String, List<String>> _colorImages(
    List<String> images,
    List<String> colors,
  ) {
    return {for (final color in colors) color: images};
  }

  static Map<String, Map<String, int>> _variantStock(
    List<String> sizes,
    List<String> colors,
    int seed,
  ) {
    return {
      for (var sizeIndex = 0; sizeIndex < sizes.length; sizeIndex++)
        sizes[sizeIndex]: {
          for (var colorIndex = 0; colorIndex < colors.length; colorIndex++)
            colors[colorIndex]:
                ((seed + sizeIndex * 3 + colorIndex * 5) % 9) + 1,
        },
    };
  }

  static List<Product> productList = [
    // Existing ones updated
    Product(
      id: 1,
      name: 'Nike Air Max 200',
      category: 'Sneakers',
      images: [AppImages.shoeTilt1, AppImages.shoeThumb1],
      price: 240.00,
      discountPrice: 200.00,
      description: 'Comfortable running shoes with Air Max technology.',
      sizes: ['7', '8', '9', '10', '11'],
      colors: ['Black', 'White', 'Red'],
      imagesByColor: _colorImages(
        [AppImages.shoeTilt1, AppImages.shoeThumb1],
        ['Black', 'White', 'Red'],
      ),
      stockByVariant: _variantStock(
        ['7', '8', '9', '10', '11'],
        ['Black', 'White', 'Red'],
        1,
      ),
      rating: 4.5,
      reviewCount: 120,
      isFavorite: false,
      isSelected: true,
    ),
    Product(
      id: 2,
      name: 'Nike Air Max 97',
      category: 'Sneakers',
      images: [AppImages.shoeTilt2, AppImages.shoeThumb2],
      price: 220.00,
      description: 'Iconic sneakers with visible Air cushioning.',
      sizes: ['7', '8', '9', '10'],
      colors: ['Silver', 'Black'],
      imagesByColor: _colorImages(
        [AppImages.shoeTilt2, AppImages.shoeThumb2],
        ['Silver', 'Black'],
      ),
      stockByVariant: _variantStock(
        ['7', '8', '9', '10'],
        ['Silver', 'Black'],
        2,
      ),
      rating: 4.7,
      reviewCount: 95,
      isFavorite: false,
    ),
    // Add more products here
    Product(
      id: 3,
      name: 'Adidas Ultraboost',
      category: 'Sneakers',
      images: [AppImages.shoeThumb3],
      price: 180.00,
      discountPrice: 150.00,
      description: 'Boost technology for energy return.',
      sizes: ['6', '7', '8', '9', '10', '11', '12'],
      colors: ['Black', 'White', 'Blue'],
      imagesByColor: _colorImages(
        [AppImages.shoeThumb3],
        ['Black', 'White', 'Blue'],
      ),
      stockByVariant: _variantStock(
        ['6', '7', '8', '9', '10', '11', '12'],
        ['Black', 'White', 'Blue'],
        3,
      ),
      rating: 4.6,
      reviewCount: 200,
    ),
    Product(
      id: 4,
      name: 'Puma RS-X',
      category: 'Sneakers',
      images: [AppImages.shoeThumb4],
      price: 120.00,
      description: 'Retro style with modern comfort.',
      sizes: ['7', '8', '9', '10'],
      colors: ['Pink', 'Black', 'White'],
      imagesByColor: _colorImages(
        [AppImages.shoeThumb4],
        ['Pink', 'Black', 'White'],
      ),
      stockByVariant: _variantStock(
        ['7', '8', '9', '10'],
        ['Pink', 'Black', 'White'],
        4,
      ),
      rating: 4.3,
      reviewCount: 80,
    ),
    Product(
      id: 5,
      name: 'Levi\'s Denim Jacket',
      category: 'Jackets',
      images: [AppImages.jacket],
      price: 89.99,
      discountPrice: 70.00,
      description: 'Classic denim jacket for everyday wear.',
      sizes: ['S', 'M', 'L', 'XL'],
      colors: ['Blue', 'Black'],
      imagesByColor: _colorImages([AppImages.jacket], ['Blue', 'Black']),
      stockByVariant: _variantStock(
        ['S', 'M', 'L', 'XL'],
        ['Blue', 'Black'],
        5,
      ),
      rating: 4.4,
      reviewCount: 150,
    ),
    Product(
      id: 6,
      name: 'Rolex Submariner',
      category: 'Watches',
      images: [AppImages.watch],
      price: 8500.00,
      description: 'Luxury dive watch with Oystersteel.',
      sizes: ['40mm', '41mm'],
      colors: ['Black', 'Green'],
      imagesByColor: _colorImages([AppImages.watch], ['Black', 'Green']),
      stockByVariant: _variantStock(['40mm', '41mm'], ['Black', 'Green'], 6),
      rating: 4.9,
      reviewCount: 50,
    ),
    Product(
      id: 7,
      name: 'Samsung Galaxy Watch',
      category: 'Watches',
      images: [AppImages.watch],
      price: 399.99,
      discountPrice: 349.99,
      description: 'Smartwatch with health tracking.',
      sizes: ['42mm', '46mm'],
      colors: ['Black', 'Silver'],
      imagesByColor: _colorImages([AppImages.watch], ['Black', 'Silver']),
      stockByVariant: _variantStock(['42mm', '46mm'], ['Black', 'Silver'], 7),
      rating: 4.5,
      reviewCount: 300,
    ),
    Product(
      id: 8,
      name: 'MacBook Pro 14"',
      category: 'Electronics',
      images: [AppImages.macbook],
      price: 1999.00,
      description: 'Powerful laptop with M2 chip.',
      sizes: ['14"'],
      colors: ['Space Gray', 'Silver'],
      imagesByColor: _colorImages(
        [AppImages.macbook],
        ['Space Gray', 'Silver'],
      ),
      stockByVariant: _variantStock(['14"'], ['Space Gray', 'Silver'], 8),
      rating: 4.8,
      reviewCount: 500,
    ),
    Product(
      id: 9,
      name: 'iPhone 15 Pro',
      category: 'Electronics',
      images: [AppImages.iphone],
      price: 999.00,
      discountPrice: 949.00,
      description: 'Latest iPhone with Pro camera system.',
      sizes: ['128GB', '256GB', '512GB'],
      colors: ['Natural Titanium', 'Blue Titanium'],
      imagesByColor: _colorImages(
        [AppImages.iphone],
        ['Natural Titanium', 'Blue Titanium'],
      ),
      stockByVariant: _variantStock(
        ['128GB', '256GB', '512GB'],
        ['Natural Titanium', 'Blue Titanium'],
        9,
      ),
      rating: 4.7,
      reviewCount: 1000,
    ),
    Product(
      id: 10,
      name: 'Sony WH-1000XM5',
      category: 'Electronics',
      images: [AppImages.headphones],
      price: 349.99,
      description: 'Noise cancelling wireless headphones.',
      sizes: ['One Size'],
      colors: ['Black', 'Silver'],
      imagesByColor: _colorImages([AppImages.headphones], ['Black', 'Silver']),
      stockByVariant: _variantStock(['One Size'], ['Black', 'Silver'], 10),
      rating: 4.6,
      reviewCount: 400,
    ),
    Product(
      id: 11,
      name: 'Nike T-Shirt',
      category: 'Clothing',
      images: [AppImages.tshirt],
      price: 29.99,
      description: 'Comfortable cotton t-shirt.',
      sizes: ['S', 'M', 'L', 'XL'],
      colors: ['White', 'Black', 'Gray'],
      imagesByColor: _colorImages(
        [AppImages.tshirt],
        ['White', 'Black', 'Gray'],
      ),
      stockByVariant: _variantStock(
        ['S', 'M', 'L', 'XL'],
        ['White', 'Black', 'Gray'],
        11,
      ),
      rating: 4.2,
      reviewCount: 180,
    ),
    Product(
      id: 12,
      name: 'Levi\'s Jeans',
      category: 'Clothing',
      images: [AppImages.clothing],
      price: 59.99,
      discountPrice: 49.99,
      description: 'Classic denim jeans.',
      sizes: ['30x30', '32x30', '34x30', '36x30'],
      colors: ['Blue', 'Black'],
      imagesByColor: _colorImages([AppImages.clothing], ['Blue', 'Black']),
      stockByVariant: _variantStock(
        ['30x30', '32x30', '34x30', '36x30'],
        ['Blue', 'Black'],
        12,
      ),
      rating: 4.3,
      reviewCount: 250,
    ),
    Product(
      id: 13,
      name: 'Samsung Galaxy S23',
      category: 'Electronics',
      images: [AppImages.phone],
      price: 799.99,
      discountPrice: 749.99,
      description: 'Latest Samsung flagship phone.',
      sizes: ['128GB', '256GB'],
      colors: ['Phantom Black', 'Cream'],
      imagesByColor: _colorImages(
        [AppImages.phone],
        ['Phantom Black', 'Cream'],
      ),
      stockByVariant: _variantStock(
        ['128GB', '256GB'],
        ['Phantom Black', 'Cream'],
        13,
      ),
      rating: 4.6,
      reviewCount: 800,
    ),
    Product(
      id: 14,
      name: 'Dell XPS 13',
      category: 'Electronics',
      images: [AppImages.laptop],
      price: 1299.99,
      description: 'Ultra-portable laptop.',
      sizes: ['13"'],
      colors: ['Silver', 'Black'],
      imagesByColor: _colorImages([AppImages.laptop], ['Silver', 'Black']),
      stockByVariant: _variantStock(['13"'], ['Silver', 'Black'], 14),
      rating: 4.5,
      reviewCount: 600,
    ),
    // Continue adding more products with AppImages
    Product(
      id: 15,
      name: 'Apple AirPods Pro',
      category: 'Electronics',
      images: [AppImages.headphones],
      price: 249.99,
      description: 'Wireless earbuds with active noise cancellation.',
      sizes: ['One Size'],
      colors: ['White'],
      imagesByColor: _colorImages([AppImages.headphones], ['White']),
      stockByVariant: _variantStock(['One Size'], ['White'], 15),
      rating: 4.7,
      reviewCount: 1200,
    ),
    Product(
      id: 16,
      name: 'Hoodie',
      category: 'Clothing',
      images: [AppImages.clothing],
      price: 45.00,
      discountPrice: 35.00,
      description: 'Warm and comfortable hoodie.',
      sizes: ['S', 'M', 'L', 'XL'],
      colors: ['Black', 'Gray', 'Navy'],
      imagesByColor: _colorImages(
        [AppImages.clothing],
        ['Black', 'Gray', 'Navy'],
      ),
      stockByVariant: _variantStock(
        ['S', 'M', 'L', 'XL'],
        ['Black', 'Gray', 'Navy'],
        16,
      ),
      rating: 4.4,
      reviewCount: 180,
    ),
  ];

  static final List<CartItem> cartItems = [
    CartItem(
      product: productList[0],
      quantity: 1,
      selectedSize: '10',
      selectedColor: 'Black',
    ),
    CartItem(
      product: productList[1],
      quantity: 1,
      selectedSize: '9',
      selectedColor: 'Silver',
    ),
  ];

  static final Set<int> _wishlistIds = <int>{};
  static final Map<int, Product> _wishlistProducts = <int, Product>{};

  static List<Categories> categoryList = [
    Categories(id: 0, name: "All", image: AppImages.all, isSelected: true),
    Categories(
      id: 1,
      name: "Women",
      image: AppImages.clothing,
      isSelected: false,
    ),
    Categories(
      id: 2,
      name: "Men",
      image: AppImages.clothing,
      isSelected: false,
    ),
    Categories(
      id: 3,
      name: "Kids",
      image: AppImages.clothing,
      isSelected: false,
    ),
    Categories(
      id: 4,
      name: "Jewelry",
      image: AppImages.watch,
      isSelected: false,
    ),
    Categories(
      id: 5,
      name: "Beauty & Health",
      image: AppImages.placeholder,
      isSelected: false,
    ),
    Categories(
      id: 6,
      name: "Home",
      image: AppImages.placeholder,
      isSelected: false,
    ),
    Categories(
      id: 7,
      name: "Kitchen",
      image: AppImages.placeholder,
      isSelected: false,
    ),
    Categories(
      id: 8,
      name: "Electronics",
      image: AppImages.electronics,
      isSelected: false,
    ),
    Categories(
      id: 9,
      name: "Shoes",
      image: AppImages.shoeThumb2,
      isSelected: false,
    ),
    Categories(
      id: 10,
      name: "Bags",
      image: AppImages.placeholder,
      isSelected: false,
    ),
    Categories(
      id: 11,
      name: "Accessories",
      image: AppImages.placeholder,
      isSelected: false,
    ),
    Categories(
      id: 12,
      name: "Toys",
      image: AppImages.placeholder,
      isSelected: false,
    ),
    Categories(
      id: 13,
      name: "Sports & Outdoors",
      image: AppImages.placeholder,
      isSelected: false,
    ),
    Categories(
      id: 14,
      name: "Pet Supplies",
      image: AppImages.placeholder,
      isSelected: false,
    ),
    Categories(
      id: 15,
      name: "Automotive",
      image: AppImages.placeholder,
      isSelected: false,
    ),
    Categories(
      id: 16,
      name: "Tools & Home Improvement",
      image: AppImages.placeholder,
      isSelected: false,
    ),
    Categories(
      id: 17,
      name: "Office & School Supplies",
      image: AppImages.placeholder,
      isSelected: false,
    ),
    Categories(
      id: 18,
      name: "Furniture",
      image: AppImages.placeholder,
      isSelected: false,
    ),
    Categories(
      id: 19,
      name: "Appliances",
      image: AppImages.placeholder,
      isSelected: false,
    ),
    Categories(
      id: 20,
      name: "Arts, Crafts & Sewing",
      image: AppImages.placeholder,
      isSelected: false,
    ),
    Categories(
      id: 21,
      name: "Sneakers",
      image: AppImages.shoeThumb2,
      isSelected: false,
    ),
    Categories(
      id: 22,
      name: "Jackets",
      image: AppImages.jacket,
      isSelected: false,
    ),
    Categories(
      id: 23,
      name: "Watches",
      image: AppImages.watch,
      isSelected: false,
    ),
    Categories(
      id: 24,
      name: "Clothing",
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
        OrderItem(
          productId: 5,
          productName: 'Classic Analog Watch',
          image: AppImages.watch,
          price: 89.99,
          quantity: 1,
          selectedSize: null,
          selectedColor: 'Silver',
        ),
      ],
      subtotal: 289.99,
      shipping: 10.00,
      discount: 0,
      total: 299.99,
      status: OrderStatus.delivered,
      date: DateTime.now().subtract(Duration(days: 15)),
      addressId: '1',
      estimatedDelivery: 'Delivered on Nov 15, 2024',
      paymentMethod: 'Credit/Debit Card',
    ),
    Order(
      id: 'ORD-002',
      items: [
        OrderItem(
          productId: 10,
          productName: 'Premium Winter Jacket',
          image: AppImages.jacket,
          price: 150.00,
          quantity: 1,
          selectedSize: 'M',
          selectedColor: 'Navy',
        ),
      ],
      subtotal: 150.00,
      shipping: 10.00,
      discount: 10.00,
      total: 150.00,
      status: OrderStatus.shipped,
      date: DateTime.now().subtract(Duration(days: 5)),
      addressId: '1',
      estimatedDelivery: 'Arriving on Dec 5, 2024',
      paymentMethod: 'Cash on Delivery',
    ),
    Order(
      id: 'ORD-003',
      items: [
        OrderItem(
          productId: 15,
          productName: 'Sports Running Shoes',
          image: AppImages.shoeThumb3,
          price: 120.00,
          quantity: 2,
          selectedSize: '9',
          selectedColor: 'White',
        ),
      ],
      subtotal: 240.00,
      shipping: 15.00,
      discount: 0,
      total: 255.00,
      status: OrderStatus.processing,
      date: DateTime.now().subtract(Duration(days: 2)),
      addressId: '2',
      estimatedDelivery: 'Arriving on Dec 3, 2024',
      paymentMethod: 'Digital Wallet',
    ),
  ];

  static List<ProductComment> productComments = [
    ProductComment(
      productId: 1,
      userName: 'Ava',
      rating: 5,
      comment: 'Very comfortable and light.',
      date: DateTime.now().subtract(const Duration(days: 4)),
      imageUrls: [AppImages.shoeThumb1, AppImages.shoeTilt1],
    ),
    ProductComment(
      productId: 1,
      userName: 'Noah',
      rating: 4,
      comment: 'Great quality, true to size.',
      date: DateTime.now().subtract(const Duration(days: 9)),
    ),
    ProductComment(
      productId: 2,
      userName: 'Mia',
      rating: 4.5,
      comment: 'Looks premium and feels good.',
      date: DateTime.now().subtract(const Duration(days: 6)),
      imageUrls: [AppImages.shoeThumb2],
    ),
  ];

  static bool isFavorite(int productId) => _wishlistIds.contains(productId);

  static void syncFavoriteFor(Product product) {
    product.isFavorite = isFavorite(product.id);
  }

  static void toggleFavorite(Product product) {
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

  static List<Product> get wishlistProducts =>
      _wishlistProducts.values.toList();

  static void addToCart({
    required Product product,
    required int quantity,
    required String size,
    required String color,
  }) {
    final existingIndex = cartItems.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.selectedSize == size &&
          item.selectedColor == color,
    );

    if (existingIndex >= 0) {
      cartItems[existingIndex].quantity += quantity;
      return;
    }

    cartItems.add(
      CartItem(
        product: product,
        quantity: quantity,
        selectedSize: size,
        selectedColor: color,
      ),
    );
  }

  static void removeFromCartAt(int index) {
    if (index < 0 || index >= cartItems.length) return;
    cartItems.removeAt(index);
  }

  static List<ProductComment> commentsForProduct(int productId) {
    return productComments
        .where((comment) => comment.productId == productId)
        .toList();
  }

  static String description =
      "Clean lines, versatile and timeless—the people shoe returns with the Nike Air Max 90. Featuring the same iconic Waffle sole, stitched overlays and classic TPU accents you come to love, it lets you walk among the pantheon of Air. Nothing as fly, nothing as comfortable, nothing as proven. The Nike Air Max 90 stays true to its OG running roots with the iconic Waffle sole, stitched overlays and classic TPU details. Classic colours celebrate your fresh look while Max Air cushioning adds comfort to the journey.";
}
