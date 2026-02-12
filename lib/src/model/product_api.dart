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

  const ApiProduct({
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
  });

  factory ApiProduct.fromJson(Map<String, dynamic> json) {
    return ApiProduct(
      id: _asInt(_pick(json, const ['id', 'ID'])),
      itemName: _asString(json, const ['item_name', 'ITEM_NAME']),
      itemDesc: _asString(json, const ['item_desc', 'ITEM_DESC']),
      itemPrice: _asDouble(_pick(json, const ['item_price', 'ITEM_PRICE'])),
      itemQty: _asInt(_pick(json, const ['item_qty', 'ITEM_QTY'])),
      itemImgUrl: _asString(json, const ['item_img_url', 'ITEM_IMG_URL']),
      categoryId: _asInt(_pick(json, const ['category_id', 'CAT_ID'])),
      category: _asString(json, const ['category', 'CATEGORY']),
      createdBy: _asString(json, const ['created_by', 'CREATED_BY']),
      isActive: _asInt(_pick(json, const ['is_active', 'IS_ACTIVE'])),
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

  static double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse((value ?? '').toString()) ?? 0;
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
