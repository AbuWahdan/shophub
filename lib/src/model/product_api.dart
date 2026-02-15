class ApiProduct {
  final int id;
  final String itemName;
  final String itemDesc;
  final double itemPrice;
  final int itemQty;
  final String itemImgUrl;
  final int categoryId;
  final String category;
  final String createdBy;
  final int isActive;
  final double? discountPrice;
  final List<String> images;
  final List<String> sizes;
  final List<String> colors;
  final Map<String, List<String>>? imagesByColor;
  final Map<String, Map<String, int>>? stockByVariant;
  final double rating;
  final int reviewCount;
  final int soldCount;
  bool isFavorite;
  bool isSelected;

  ApiProduct({
    required this.id,
    required this.itemName,
    required this.itemDesc,
    required this.itemPrice,
    required this.itemQty,
    required this.itemImgUrl,
    required this.categoryId,
    required this.category,
    required this.createdBy,
    required this.isActive,
    this.discountPrice,
    List<String>? images,
    this.sizes = const ['Default'],
    this.colors = const ['Default'],
    this.imagesByColor,
    this.stockByVariant,
    this.rating = 4.0,
    this.reviewCount = 0,
    this.soldCount = 0,
    this.isFavorite = false,
    this.isSelected = false,
  }) : images = images ?? (itemImgUrl.isEmpty ? [] : [itemImgUrl]);

  // Getters for ProductCard compatibility
  String get name => itemName;
  String get description => itemDesc;
  double get price => itemPrice;
  int get quantity => itemQty;
  double get finalPrice => discountPrice ?? itemPrice;

  int get discountPercentage {
    if (discountPrice == null || itemPrice == 0) return 0;
    return (((itemPrice - discountPrice!) / itemPrice) * 100).toInt();
  }

  List<String> imagesForColor(String? color) {
    if (color == null) return images;
    final mapped = imagesByColor?[color];
    if (mapped != null && mapped.isNotEmpty) {
      return mapped;
    }
    return images;
  }

  int stockFor(String size, String color) {
    final mapped = stockByVariant?[size]?[color];
    if (mapped != null) return mapped;
    final sizeIndex = sizes.indexOf(size);
    final colorIndex = colors.indexOf(color);
    if (sizeIndex == -1 || colorIndex == -1) return itemQty;
    return ((id + sizeIndex * 3 + colorIndex * 5) % 9) + 1;
  }
factory ApiProduct.fromJson(Map<String, dynamic> json) {
  final imgUrl = _asString(json, const ['item_img_url', 'ITEM_IMG_URL']);
  
  return ApiProduct(
    id: _asInt(_pick(json, const ['id', 'ID'])),
    itemName: _asString(json, const ['item_name', 'ITEM_NAME']),
    itemDesc: _asString(json, const ['item_desc', 'ITEM_DESC']),
    itemPrice: _asDouble(_pick(json, const ['item_price', 'ITEM_PRICE'])),
    itemQty: _asInt(_pick(json, const ['item_qty', 'ITEM_QTY'])),
    itemImgUrl: imgUrl,
    categoryId: _asInt(_pick(json, const ['category_id', 'CAT_ID', 'CATEGORY_ID', 'item_cat', 'ITEM_CAT'])),
    category: _asString(json, const ['category', 'CATEGORY', 'item_cat', 'ITEM_CAT']),
    createdBy: _asString(json, const ['created_by', 'CREATED_BY', 'creatd_by', 'CREATD_BY', 'item_owner', 'ITEM_OWNER']),
    isActive: _asInt(_pick(json, const ['is_active', 'IS_ACTIVE'])),
    discountPrice: _asNullableDouble(
      _pick(json, const ['item_old_price', 'ITEM_OLD_PRICE', 'discount_price', 'DISCOUNT_PRICE']),
    ),
    images: imgUrl.isEmpty ? [] : [imgUrl],
    rating: _asDouble(_pick(json, const ['rating', 'RATING']), fallback: 4.0),
    reviewCount: _asInt(_pick(json, const ['reviews', 'REVIEWS', 'review_count', 'REVIEW_COUNT'])),
    sizes: const ['Default'],
    colors: const ['Default'],
  );
}
  static dynamic _pick(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      if (json.containsKey(key)) return json[key];
    }
    return null;
  }

  static String _asString(Map<String, dynamic> json, List<String> keys) {
    final value = _pick(json, keys);
    return (value ?? '').toString();
  }

  static double _asDouble(dynamic value, {double fallback = 0.0}) {
    if (value is num) return value.toDouble();
    return double.tryParse((value ?? '').toString()) ?? fallback;
  }

  static double? _asNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static int _asInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse((value ?? '').toString()) ?? 0;
  }
}

class CreateProductRequest {
  final String itemName;
  final String itemDesc;
  final double itemPrice;
  final int itemQty;
  final String itemImgUrl;
  final int categoryId;
  final String createdBy;
  final int isActive;

  const CreateProductRequest({
    required this.itemName,
    required this.itemDesc,
    required this.itemPrice,
    required this.itemQty,
    required this.itemImgUrl,
    required this.categoryId,
    required this.createdBy,
    required this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      'item_name': itemName,
      'item_desc': itemDesc,
      'item_price': itemPrice,
      'item_qty': itemQty,
      'item_img_url': itemImgUrl,
      'category_id': categoryId,
      'created_by': createdBy,
      'is_active': isActive,
    };
  }
}
