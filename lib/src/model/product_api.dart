class ApiProduct {
  final int id;
  final int detId;
  final String itemName;
  final String itemDesc;
  final double itemPrice;
  final int itemQty;
  final String itemImgUrl;
  final int categoryId;
  final String category;
  final String createdBy;
  final String itemOwner;
  final int createdByUserId;
  final int isActive;
  final double? discountPrice;
  final List<String> images;
  final List<ApiProductVariant> details;
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
    this.detId = 0,
    required this.itemName,
    required this.itemDesc,
    required this.itemPrice,
    required this.itemQty,
    required this.itemImgUrl,
    required this.categoryId,
    required this.category,
    required this.createdBy,
    this.itemOwner = '',
    this.createdByUserId = 0,
    required this.isActive,
    this.discountPrice,
    List<String>? images,
    this.details = const [],
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
    final variants = _parseVariants(json);
    final topLevelDetId = _asInt(_pick(json, const ['DET_ID', 'det_id']));
    final selectedVariant = variants.firstWhere(
      (variant) => variant.detId == topLevelDetId,
      orElse: () => variants.isNotEmpty
          ? variants.first
          : const ApiProductVariant(
              detId: 0,
              brand: '',
              color: '',
              itemSize: '',
              discount: 0,
              itemPrice: 0,
              itemQty: 0,
            ),
    );
    final parsedPrice = _asDouble(
      _pick(json, const ['item_price', 'ITEM_PRICE']),
    );
    final parsedQty = _asInt(_pick(json, const ['item_qty', 'ITEM_QTY']));
    final variantSizes = variants
        .map((variant) => variant.itemSize.trim())
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

    return ApiProduct(
      id: _asInt(_pick(json, const ['id', 'ID', 'ITEM_ID', 'item_id'])),
      detId: topLevelDetId > 0 ? topLevelDetId : selectedVariant.detId,
      itemName: _asString(json, const ['item_name', 'ITEM_NAME']),
      itemDesc: _asString(json, const ['item_desc', 'ITEM_DESC']),
      itemPrice: parsedPrice > 0 ? parsedPrice : selectedVariant.itemPrice,
      itemQty: parsedQty > 0 ? parsedQty : selectedVariant.itemQty,
      itemImgUrl: primaryImage,
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
      itemOwner: _asString(json, const ['item_owner', 'ITEM_OWNER']),
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
      discountPrice: _asNullableDouble(
        _pick(json, const [
          'item_old_price',
          'ITEM_OLD_PRICE',
          'discount_price',
          'DISCOUNT_PRICE',
        ]),
      ),
      images: imageList,
      details: variants,
      rating: _asDouble(_pick(json, const ['rating', 'RATING']), fallback: 4.0),
      reviewCount: _asInt(
        _pick(json, const [
          'reviews',
          'REVIEWS',
          'review_count',
          'REVIEW_COUNT',
        ]),
      ),
      sizes: variantSizes.isNotEmpty ? variantSizes : const ['Default'],
      colors: variantColors.isNotEmpty ? variantColors : const ['Default'],
    );
  }

  ApiProductVariant? variantFor({required String size, required String color}) {
    if (details.isEmpty) return null;
    for (final detail in details) {
      if (detail.itemSize == size && detail.color == color) {
        return detail;
      }
    }
    return null;
  }

  int resolveDetId({
    required String size,
    required String color,
    int fallback = 0,
  }) {
    final detail = variantFor(size: size, color: color);
    if (detail != null && detail.detId > 0) {
      return detail.detId;
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

  static List<ApiProductVariant> _parseVariants(Map<String, dynamic> json) {
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
                  ApiProductVariant.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();
      }
    }

    final detId = _asInt(_pick(json, const ['DET_ID', 'det_id']));
    final color = _asString(json, const ['COLOR', 'color']);
    final brand = _asString(json, const ['BRAND', 'brand']);
    final itemSize = _asString(json, const ['ITEM_SIZE', 'item_size']);
    final itemPrice = _asDouble(
      _pick(json, const ['ITEM_PRICE', 'item_price']),
    );
    final itemQty = _asInt(_pick(json, const ['ITEM_QTY', 'item_qty']));
    final discount = _asDouble(_pick(json, const ['DISCOUNT', 'discount']));
    if (detId == 0 &&
        color.trim().isEmpty &&
        brand.trim().isEmpty &&
        itemSize.trim().isEmpty &&
        itemPrice <= 0 &&
        itemQty <= 0 &&
        discount <= 0) {
      return const [];
    }
    return [
      ApiProductVariant(
        detId: detId,
        brand: brand,
        color: color,
        itemSize: itemSize,
        discount: discount,
        itemPrice: itemPrice,
        itemQty: itemQty,
      ),
    ];
  }
}

class ApiProductVariant {
  final int detId;
  final String brand;
  final String color;
  final String itemSize;
  final double discount;
  final double itemPrice;
  final int itemQty;

  const ApiProductVariant({
    required this.detId,
    required this.brand,
    required this.color,
    required this.itemSize,
    required this.discount,
    required this.itemPrice,
    required this.itemQty,
  });

  factory ApiProductVariant.fromJson(Map<String, dynamic> json) {
    return ApiProductVariant(
      detId: _asInt(_pick(json, const ['DET_ID', 'det_id', 'item_det_id'])),
      brand: _asString(json, const ['BRAND', 'brand']),
      color: _asString(json, const ['COLOR', 'color']),
      itemSize: _asString(json, const ['ITEM_SIZE', 'item_size']),
      discount: _asDouble(_pick(json, const ['DISCOUNT', 'discount'])),
      itemPrice: _asDouble(_pick(json, const ['ITEM_PRICE', 'item_price'])),
      itemQty: _asInt(_pick(json, const ['ITEM_QTY', 'item_qty'])),
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
    return (value ?? '').toString().trim();
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
  final String itemName;
  final String itemDesc;
  final double itemPrice;
  final int itemQty;
  final double discount;
  final String itemImgUrl;
  final int imageId;
  final String category;
  final int catId;
  final int isActive;
  final String itemOwner;
  final int reviews;
  final double rating;
  final String itemSize;
  final String color;
  final String brand;

  const ApiProductDetails({
    required this.itemId,
    required this.detId,
    required this.itemName,
    required this.itemDesc,
    required this.itemPrice,
    required this.itemQty,
    required this.discount,
    required this.itemImgUrl,
    required this.imageId,
    required this.category,
    required this.catId,
    required this.isActive,
    required this.itemOwner,
    required this.reviews,
    required this.rating,
    required this.itemSize,
    required this.color,
    required this.brand,
  });

  factory ApiProductDetails.fromJson(Map<String, dynamic> json) {
    return ApiProductDetails(
      itemId: _asInt(_pick(json, const ['ITEM_ID', 'item_id', 'ID', 'id'])),
      detId: _asInt(_pick(json, const ['DET_ID', 'det_id'])),
      itemName: _asString(json, const ['ITEM_NAME', 'item_name']),
      itemDesc: _asString(json, const ['ITEM_DESC', 'item_desc']),
      itemPrice: _asDouble(_pick(json, const ['ITEM_PRICE', 'item_price'])),
      itemQty: _asInt(_pick(json, const ['ITEM_QTY', 'item_qty'])),
      discount: _asDouble(_pick(json, const ['DISCOUNT', 'discount'])),
      itemImgUrl: _asString(json, const ['ITEM_IMG_URL', 'item_img_url']),
      imageId: _asInt(_pick(json, const ['IMAGE_ID', 'image_id'])),
      category: _asString(json, const ['CATEGORY', 'category']),
      catId: _asInt(_pick(json, const ['CAT_ID', 'cat_id', 'CATEGORY_ID'])),
      isActive: _asInt(_pick(json, const ['IS_ACTIVE', 'is_active'])),
      itemOwner: _asString(json, const ['ITEM_OWNER', 'item_owner']),
      reviews: _asInt(_pick(json, const ['REVIEWS', 'reviews'])),
      rating: _asDouble(_pick(json, const ['RATING', 'rating'])),
      itemSize: _asString(json, const ['ITEM_SIZE', 'item_size']),
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
  final String itemName;
  final String itemDesc;
  final String? itemImgUrl;
  final String? imagesCsv;
  final List<CreateProductDetail> details;
  final int categoryId;
  final String createdBy;

  const CreateProductRequest({
    required this.itemName,
    required this.itemDesc,
    this.itemImgUrl,
    this.imagesCsv,
    required this.details,
    required this.categoryId,
    required this.createdBy,
  });

  Map<String, dynamic> toJson() {
    final normalizedImages = _normalizeImagesCsv(imagesCsv ?? itemImgUrl ?? '');
    return {
      'item_name': itemName,
      'item_desc': itemDesc,
      'item_img_url': normalizedImages.isEmpty ? itemImgUrl : normalizedImages,
      'details': details.map((detail) => detail.toJson()).toList(),
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
  final String itemSize; // ← MUST be String (SIZE_CODE), NOT int
  final double discount;
  final double itemPrice;
  final int itemQty;
  final int isActive;

  const CreateProductDetail({
    this.detId,
    required this.brand,
    required this.color,
    required this.itemSize,
    required this.discount,
    required this.itemPrice,
    required this.itemQty,
    this.isActive = 1,
  });

  Map<String, dynamic> toJson() => {
    if (detId != null && detId! > 0) 'det_id': detId,
    'brand': brand,
    'color': color,
    'item_size': itemSize, // SIZE_CODE string — no conversion needed
    'discount': discount,
    'item_price': itemPrice,
    'item_qty': itemQty,
    'is_active': isActive,
  };
}

// ─── NEW: matches exact update-item API shape ──────────────────────────────
class UpdateItemDetail {
  final int detailId;
  final double itemPrice;
  final int itemQty;
  final double itemDiscount;
  final String brand;
  final String color;
  final String modifiedBy;
  final String size; // SIZE_CODE string, e.g. "XL", "42", "32/30"
  final int isActive;

  const UpdateItemDetail({
    required this.detailId,
    required this.itemPrice,
    required this.itemQty,
    this.itemDiscount = 0,
    required this.brand,
    required this.color,
    required this.modifiedBy,
    required this.size,
    required this.isActive,
  });

  factory UpdateItemDetail.fromJson(Map<String, dynamic> json) {
    return UpdateItemDetail(
      detailId: _asInt(_pick(json, const ['detail_id', 'DETAIL_ID'])),
      itemPrice: _asDouble(_pick(json, const ['item_price', 'ITEM_PRICE'])),
      itemQty: _asInt(_pick(json, const ['item_qty', 'ITEM_QTY'])),
      itemDiscount: _asDouble(
        _pick(json, const ['item_discount', 'ITEM_DISCOUNT']),
      ),
      brand: _asString(json, const ['brand', 'BRAND']),
      color: _asString(json, const ['color', 'COLOR']),
      modifiedBy: _asString(json, const ['modified_by', 'MODIFIED_BY']),
      size: _asString(json, const ['size', 'SIZE', 'item_size', 'ITEM_SIZE']),
      isActive: _asInt(_pick(json, const ['is_active', 'IS_ACTIVE'])),
    );
  }

  UpdateItemDetail copyWith({
    int? detailId,
    double? itemPrice,
    int? itemQty,
    double? itemDiscount,
    String? brand,
    String? color,
    String? modifiedBy,
    String? size,
    int? isActive,
  }) {
    return UpdateItemDetail(
      detailId: detailId ?? this.detailId,
      itemPrice: itemPrice ?? this.itemPrice,
      itemQty: itemQty ?? this.itemQty,
      itemDiscount: itemDiscount ?? this.itemDiscount,
      brand: brand ?? this.brand,
      color: color ?? this.color,
      modifiedBy: modifiedBy ?? this.modifiedBy,
      size: size ?? this.size,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
    'detail_id': detailId,
    'item_price': itemPrice,
    'item_qty': itemQty,
    'item_discount': itemDiscount,
    'brand': brand,
    'color': color,
    'modified_by': modifiedBy,
    'size': size, // some Oracle procs use this
    'item_size': size, // ← ADDED: others use this (matches ITEM_SIZE column)
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
  final String itemName;
  final String itemDesc;
  final int isActive;
  final List<UpdateItemDetail> itemDetails;
  final int categoryId;
  final String? itemImgUrl;

  const UpdateProductRequest({
    required this.id,
    required this.itemName,
    required this.itemDesc,
    required this.isActive,
    required this.itemDetails,
    required this.categoryId,
    this.itemImgUrl,
  });

  /// Produces the exact shape the API expects inside "items"[0]
  Map<String, dynamic> toJson() => {
    'id': id,
    'item_name': itemName,
    'item_desc': itemDesc,
    'is_active': isActive,
    'category_id': categoryId,
    if (itemImgUrl != null && itemImgUrl!.isNotEmpty)
      'item_img_url': itemImgUrl,
    'item_details': itemDetails.map((d) => d.toJson()).toList(),
  };
}
