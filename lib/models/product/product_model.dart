import 'product_variant.dart';
export 'product_variant.dart';

class ProductModel {
  final int id;
  final int detId;
  final String name;
  final String description;
  final double basePrice;
  final int baseStock;
  final String primaryImageUrl;
  final int categoryId;
  final String category;
  final String createdBy;
  final String? itemOwner;
  final int createdByUserId;
  final int isActive;
  final double? discountPrice;
  final List<String> images;
  final List<ProductVariant> variants;
  final List<String> sizes;
  final List<String> colors;
  final Map<String, List<String>>? imagesByColor;
  final Map<String, Map<String, int>>? stockByVariant;
  final double rating;
  final int reviewCount;
  final int soldCount;
  bool isFavorite;
  final double finalPrice;

  ProductModel({
    required this.id,
    this.detId = 0,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.baseStock,
    required this.primaryImageUrl,
    required this.categoryId,
    required this.category,
    required this.createdBy,
    this.itemOwner,
    this.createdByUserId = 0,
    required this.isActive,
    this.discountPrice,
    List<String>? images,
    this.variants = const [],
    this.sizes = const [],
    this.colors = const [],
    this.imagesByColor,
    this.stockByVariant,
    this.rating = 0,
    this.reviewCount = 0,
    this.soldCount = 0,
    this.isFavorite = false,
    required this.finalPrice,
  }) : images = images ?? (primaryImageUrl.isEmpty ? [] : [primaryImageUrl]);


  int get quantity => baseStock;


  int get discountPercentage {
    if (discountPrice == null || basePrice == 0) return 0;
    return (((basePrice - discountPrice!) / basePrice) * 100).toInt();
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
    if (sizeIndex == -1 || colorIndex == -1) return baseStock;
    return ((id + sizeIndex * 3 + colorIndex * 5) % 9) + 1;
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final variants = _parseVariants(json);
    final topLevelDetId = _asInt(_pick(json, const ['DET_ID', 'det_id']));
    final selectedVariant = variants.firstWhere(
      (variant) => variant.detId == topLevelDetId,
      orElse: () => variants.isNotEmpty
          ? variants.first
          : const ProductVariant(
              detId: 0,
              brand: '',
              color: '',
              size: '',
              discount: 0,
              tax: 0,
              price: 0,
              stock: 0,
            ),
    );
    final parsedPrice = _asDouble(
      _pick(json, const ['item_price', 'ITEM_PRICE']),
    );
    final parsedFinalPrice = _asNullableDouble(
      _pick(json, const ['FINAL_PRICE', 'final_price']),
    );

    final parsedAlternatePrice = _asNullableDouble(
      _pick(json, const [
        'discount_price',
        'DISCOUNT_PRICE',
        'item_old_price',
        'ITEM_OLD_PRICE',
      ]),
    );
    final parsedStock = _asInt(_pick(json, const ['item_qty', 'ITEM_QTY']));
    final variantSizes = variants
        .map((variant) => variant.size.trim())
        .where((size) => size.isNotEmpty)
        .toSet()
        .toList();
    final variantColors = variants
        .map((variant) => variant.color.trim())
        .where((color) => color.isNotEmpty)
        .toSet()
        .toList();
    final rawImageValue = _asString(json, const [
      'item_img_url',
      'ITEM_IMG_URL',
      'images',
      'IMAGES',
    ]);
    final imageList = _parseImageList(rawImageValue);
    final primaryImage = imageList.isNotEmpty ? imageList.first : '';

    return ProductModel(
      id: _asInt(_pick(json, const ['id', 'ID', 'ITEM_ID', 'item_id'])),
      detId: topLevelDetId > 0 ? topLevelDetId : selectedVariant.detId,
      name: _asString(json, const ['item_name', 'ITEM_NAME']),
      description: _asString(json, const ['item_desc', 'ITEM_DESC']),
      finalPrice: parsedFinalPrice ?? parsedPrice,
      basePrice: _resolveOriginalPrice(
        rawPrice: parsedPrice,
        explicitAltPrice: parsedAlternatePrice,
        variant: selectedVariant,
      ),
      baseStock: parsedStock > 0 ? parsedStock : selectedVariant.stock,
      primaryImageUrl: primaryImage,
      categoryId: _asInt(
        _pick(json, const [
          'category_id',
          'CAT_ID',
          'CATEGORY_ID',
          'item_cat',
          'ITEM_CAT',
        ]),
      ),
      category: _asString(json, const [
        'category',
        'CATEGORY',
        'item_cat',
        'ITEM_CAT',
      ]),
      createdBy: _asString(json, const [
        'created_by',
        'CREATED_BY',
        'creatd_by',
        'CREATD_BY',
        'item_owner',
        'ITEM_OWNER',
      ]),
      itemOwner: _asNullableString(json, const ['item_owner', 'ITEM_OWNER']),
      createdByUserId: _asInt(
        _pick(json, const [
          'created_by_user_id',
          'CREATED_BY_USER_ID',
          'user_id',
          'USER_ID',
          'owner_id',
          'OWNER_ID',
        ]),
      ),
      isActive: _asInt(_pick(json, const ['is_active', 'IS_ACTIVE'])),
      discountPrice: _resolveDiscountedPrice(
        rawPrice: parsedPrice,
        finalPrice: parsedFinalPrice,        // ← new param
        explicitAltPrice: parsedAlternatePrice,
        variant: selectedVariant,
      ),
      images: imageList,
      variants: variants,
      rating: _asDouble(
        _pick(json, const [
          'average_rating',
          'AVERAGE_RATING',
          'avg_rating',
          'AVG_RATING',
          'rating',
          'RATING',
        ]),
      ),
      reviewCount: _asInt(
        _pick(json, const [
          'comments_count',
          'COMMENTS_COUNT',
          'reviews',
          'REVIEWS',
          'review_count',
          'REVIEW_COUNT',
        ]),
      ),
      soldCount: _asInt(
        _pick(json, const ['sold_count', 'SOLD_COUNT', 'sold_qty', 'SOLD_QTY']),
      ),
      sizes: variantSizes,
      colors: variantColors,
    );
  }

  ProductVariant? variantFor({required String size, required String color}) {
    if (variants.isEmpty) return null;
    for (final variant in variants) {
      if (variant.size == size && variant.color == color) {
        return variant;
      }
    }
    return null;
  }

  int resolveDetId({
    required String size,
    required String color,
    int fallback = 0,
  }) {
    final variant = variantFor(size: size, color: color);
    if (variant != null && variant.detId > 0) {
      return variant.detId;
    }
    if (detId > 0) return detId;
    return fallback;
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

  static String? _asNullableString(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    final value = _pick(json, keys);
    if (value == null) return null;
    final normalized = value.toString().trim();
    return normalized.isEmpty ? null : normalized;
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

  static List<String> _parseImageList(String value) {
    if (value.trim().isEmpty) return const [];
    return value
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
  }

  static List<ProductVariant> _parseVariants(Map<String, dynamic> json) {
    final candidates = <dynamic>[
      _pick(json, const ['details', 'DETAILS']),
      _pick(json, const ['variants', 'VARIANTS']),
    ];

    for (final raw in candidates) {
      if (raw is List) {
        return raw
            .whereType<Map>()
            .map(
              (item) =>
                  ProductVariant.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();
      }
    }

    final detId = _asInt(_pick(json, const ['DET_ID', 'det_id']));
    final color = _asString(json, const ['COLOR', 'color']);
    final brand = _asString(json, const ['BRAND', 'brand']);
    final size = _asString(json, const ['ITEM_SIZE', 'item_size']);
    final price = _asDouble(_pick(json, const ['ITEM_PRICE', 'item_price']));
    final stock = _asInt(_pick(json, const ['ITEM_QTY', 'item_qty']));
    final discount = _asDouble(
      _pick(json, const [
        'ITEM_DISCOUNT',
        'item_discount',
        'DISCOUNT',
        'discount',
      ]),
    );
    if (detId == 0 &&
        color.trim().isEmpty &&
        brand.trim().isEmpty &&
        size.trim().isEmpty &&
        price <= 0 &&
        stock <= 0 &&
        discount <= 0) {
      return const [];
    }
    return [
      ProductVariant(
        detId: detId,
        brand: brand,
        color: color,
        size: size,
        discount: discount,
        tax: _asDouble(
          _pick(json, const ['TAX', 'tax', 'ITEM_TAX', 'item_tax']),
        ),
        price: price,
        stock: stock,
      ),
    ];
  }

  static double _resolveOriginalPrice({
    required double rawPrice,
    required double? explicitAltPrice,
    required ProductVariant variant,
  }) {
    // rawPrice (ITEM_PRICE) is always the original/base price
    final variantPrice = variant.price > 0 ? variant.price : rawPrice;
    return variantPrice > 0 ? variantPrice : (explicitAltPrice ?? 0.0);
  }

  static double? _resolveDiscountedPrice({
    required double rawPrice,
    required double? finalPrice,
    required double? explicitAltPrice,
    required ProductVariant variant,
  }) {
    final variantPrice = variant.price > 0 ? variant.price : rawPrice;

    if (finalPrice != null && finalPrice > 0 && finalPrice < variantPrice) {
      return finalPrice;
    }

    if (explicitAltPrice != null &&
        explicitAltPrice > 0 &&
        explicitAltPrice < variantPrice) {
      return explicitAltPrice;
    }

    if (variant.discount > 0 && variant.discount < 100 && variantPrice > 0) {
      return variantPrice * (1 - (variant.discount / 100));
    }

    return null;
  }
}
class GetProductsRequest {
  final String? createdBy;
  final int? categoryId;
  final int? detId;

  const GetProductsRequest({this.createdBy, this.categoryId, this.detId});

  Map<String, String> toQueryParameters() {
    final normalizedCreatedBy = createdBy?.trim();
    return {
      if (categoryId != null) 'CAT_ID': categoryId.toString(),
      if (detId != null) 'DET_ID': detId.toString(),
      if (normalizedCreatedBy != null && normalizedCreatedBy.isNotEmpty)
        'created_by': normalizedCreatedBy,
    };
  }

  Map<String, dynamic> toBody() {
    final normalizedCreatedBy = createdBy?.trim();
    return {
      if (categoryId != null) 'CAT_ID': categoryId,
      if (detId != null) 'DET_ID': detId,
      if (normalizedCreatedBy != null && normalizedCreatedBy.isNotEmpty)
        'created_by': normalizedCreatedBy,
    };
  }
}

class ApiProductDetails {
  final int itemId;
  final int detId;
  final String name;
  final String description;
  final double price;
  final int stock;
  final double discount;
  final double tax;
  final String primaryImageUrl;
  final int imageId;
  final String category;
  final int catId;
  final int isActive;
  final String itemOwner;
  final int reviews;
  final double rating;
  final String size;
  final String color;
  final String brand;

  const ApiProductDetails({
    required this.itemId,
    required this.detId,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.discount,
    this.tax = 0,
    required this.primaryImageUrl,
    required this.imageId,
    required this.category,
    required this.catId,
    required this.isActive,
    required this.itemOwner,
    required this.reviews,
    required this.rating,
    required this.size,
    required this.color,
    required this.brand,
  });

  factory ApiProductDetails.fromJson(Map<String, dynamic> json) {
    return ApiProductDetails(
      itemId: _asInt(_pick(json, const ['ITEM_ID', 'item_id', 'ID', 'id'])),
      detId: _asInt(_pick(json, const ['DET_ID', 'det_id'])),
      name: _asString(json, const ['ITEM_NAME', 'item_name']),
      description: _asString(json, const ['ITEM_DESC', 'item_desc']),
      price: _asDouble(_pick(json, const ['ITEM_PRICE', 'item_price'])),
      stock: _asInt(_pick(json, const ['ITEM_QTY', 'item_qty'])),
      discount: _asDouble(
        _pick(json, const [
          'ITEM_DISCOUNT',
          'item_discount',
          'DISCOUNT',
          'discount',
        ]),
      ),
      tax: _asDouble(_pick(json, const ['TAX', 'tax', 'ITEM_TAX', 'item_tax'])),
      primaryImageUrl: _asString(json, const ['ITEM_IMG_URL', 'item_img_url']),
      imageId: _asInt(_pick(json, const ['IMAGE_ID', 'image_id'])),
      category: _asString(json, const ['CATEGORY', 'category']),
      catId: _asInt(_pick(json, const ['CAT_ID', 'cat_id', 'CATEGORY_ID'])),
      isActive: _asInt(_pick(json, const ['IS_ACTIVE', 'is_active'])),
      itemOwner: _asString(json, const ['ITEM_OWNER', 'item_owner']),
      reviews: _asInt(_pick(json, const ['REVIEWS', 'reviews'])),
      rating: _asDouble(_pick(json, const ['RATING', 'rating'])),
      size: _asString(json, const ['ITEM_SIZE', 'item_size']),
      color: _asString(json, const ['COLOR', 'color']),
      brand: _asString(json, const ['BRAND', 'brand']),
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

  static int _asInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse((value ?? '').toString()) ?? 0;
  }
}

class ApiItemImage {
  final int imageId;
  final String imagePath;
  final int isDefault;

  const ApiItemImage({
    required this.imageId,
    required this.imagePath,
    required this.isDefault,
  });

  factory ApiItemImage.fromJson(Map<String, dynamic> json) {
    return ApiItemImage(
      imageId: _asInt(_pick(json, const ['IMAGE_ID', 'image_id', 'id', 'ID'])),
      imagePath: _asString(json, const ['IMAGE_PATH', 'image_path', 'path']),
      isDefault: _asInt(_pick(json, const ['IS_DEFAULT', 'is_default'])),
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

  static int _asInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse((value ?? '').toString()) ?? 0;
  }
}

class CreateProductRequest {
  final String name;
  final String description;
  final String? primaryImageUrl;
  final String? imagesCsv;
  final List<CreateProductDetail> variants;
  final int categoryId;
  final String createdBy;

  const CreateProductRequest({
    required this.name,
    required this.description,
    this.primaryImageUrl,
    this.imagesCsv,
    required this.variants,
    required this.categoryId,
    required this.createdBy,
  });

  Map<String, dynamic> toJson() {
    final normalizedImages = _normalizeImagesCsv(
      imagesCsv ?? primaryImageUrl ?? '',
    );
    return {
      'item_name': name,
      'item_desc': description,
      'item_img_url': normalizedImages.isEmpty
          ? primaryImageUrl
          : normalizedImages,
      'details': variants.map((detail) => detail.toJson()).toList(),
      'category_id': categoryId,
      'created_by': createdBy,
    };
  }

  String _normalizeImagesCsv(String raw) {
    return raw
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .join(',');
  }
}

class CreateProductDetail {
  final int? detId;
  final String brand;
  final String color;
  final String size; // ← MUST be String (SIZE_CODE), NOT int
  final double discount;
  final double tax;
  final double price;
  final int stock;
  final int isActive;

  const CreateProductDetail({
    this.detId,
    required this.brand,
    required this.color,
    required this.size,
    required this.discount,
    this.tax = 0,
    required this.price,
    required this.stock,
    this.isActive = 1,
  });

  Map<String, dynamic> toJson() => {
    if (detId != null && detId! > 0) 'det_id': detId,
    'brand': brand,
    'color': color,
    'item_size': size, // SIZE_CODE string — no conversion needed
    'discount': discount,
    'tax': tax,
    'item_price': price,
    'item_qty': stock,
    'is_active': isActive,
  };
}

// ─── NEW: matches exact update-item API shape ──────────────────────────────
class UpdateItemDetail {
  final int detailId;
  final double price;
  final int stock;
  final double discount;
  final String brand;
  final String color;
  final String modifiedBy;
  final String size; // SIZE_CODE string, e.g. "XL", "42", "32/30"
  final int isActive;
  final double tax;

  const UpdateItemDetail({
    required this.detailId,
    required this.price,
    required this.stock,
    this.discount = 0,
    required this.brand,
    required this.color,
    required this.modifiedBy,
    required this.size,
    required this.isActive,
    this.tax = 0,
  });

  factory UpdateItemDetail.fromJson(Map<String, dynamic> json) {
    return UpdateItemDetail(
      detailId: _asInt(_pick(json, const ['detail_id', 'DETAIL_ID'])),
      price: _asDouble(_pick(json, const ['item_price', 'ITEM_PRICE'])),
      stock: _asInt(_pick(json, const ['item_qty', 'ITEM_QTY'])),
      discount: _asDouble(
        _pick(json, const ['item_discount', 'ITEM_DISCOUNT']),
      ),
      brand: _asString(json, const ['brand', 'BRAND']),
      color: _asString(json, const ['color', 'COLOR']),
      modifiedBy: _asString(json, const ['modified_by', 'MODIFIED_BY']),
      size: _asString(json, const ['size', 'SIZE', 'item_size', 'ITEM_SIZE']),
      isActive: _asInt(_pick(json, const ['is_active', 'IS_ACTIVE'])),
      tax: _asDouble(_pick(json, const ['item_tax', 'ITEM_TAX'])),
    );
  }

  UpdateItemDetail copyWith({
    int? detailId,
    double? price,
    int? stock,
    double? discount,
    String? brand,
    String? color,
    String? modifiedBy,
    String? size,
    int? isActive,
    double? tax,
  }) {
    return UpdateItemDetail(
      detailId: detailId ?? this.detailId,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      discount: discount ?? this.discount,
      brand: brand ?? this.brand,
      color: color ?? this.color,
      modifiedBy: modifiedBy ?? this.modifiedBy,
      size: size ?? this.size,
      isActive: isActive ?? this.isActive,
      tax: tax ?? this.tax,
    );
  }

  Map<String, dynamic> toJson() => {
    'detail_id': detailId,
    'item_price': price,
    'item_qty': stock,
    'item_discount': discount,
    'item_tax': tax,
    'brand': brand,
    'color': color,
    'modified_by': modifiedBy,
    'size': size,
    'item_size': size,
    'is_active': isActive,
  };

  static dynamic _pick(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      if (json.containsKey(key)) {
        return json[key];
      }
    }
    return null;
  }

  static String _asString(Map<String, dynamic> json, List<String> keys) {
    final value = _pick(json, keys);
    return (value ?? '').toString().trim();
  }

  static double _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse((value ?? '').toString()) ?? 0.0;
  }

  static int _asInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse((value ?? '').toString()) ?? 0;
  }
}

// ─── REPLACED: old UpdateProductRequest was sending wrong keys ────────────
class UpdateProductRequest {
  final int id;
  final String name;
  final String description;
  final int isActive;
  final List<UpdateItemDetail> itemDetails;
  final int categoryId;
  final String? primaryImageUrl;

  const UpdateProductRequest({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
    required this.itemDetails,
    required this.categoryId,
    this.primaryImageUrl,
  });

  /// Produces the exact shape the API expects inside "items"[0]
  Map<String, dynamic> toJson() => {
    'id': id,
    'item_name': name,
    'item_desc': description,
    'is_active': isActive,
    'category_id': categoryId,
    if (primaryImageUrl != null && primaryImageUrl!.isNotEmpty)
      'item_img_url': primaryImageUrl,
    'item_details': itemDetails.map((d) => d.toJson()).toList(),
  };
}
