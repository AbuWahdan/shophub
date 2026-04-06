import 'product_api.dart';

class ApiCartItem {
  final int cartItemId;
  final int detailId;
  final int itemId;
  final int itemDetId;
  final String username;
  final int itemQty;
  final int availableQty;
  final String itemName;
  final String itemDesc;
  final double itemPrice;
  final double discount;
  final String itemImgUrl;
  final String color;
  final String itemSize;
  final String brand;
  final ApiProduct? _product;

  const ApiCartItem({
    this.cartItemId = 0,
    this.detailId = 0,
    required this.itemId,
    required this.itemDetId,
    required this.username,
    required this.itemQty,
    this.availableQty = 0,
    required this.itemName,
    required this.itemDesc,
    required this.itemPrice,
    required this.discount,
    required this.itemImgUrl,
    required this.color,
    required this.itemSize,
    required this.brand,
    ApiProduct? product,
  }) : _product = product;

  ApiProduct get product => _product ?? toProduct();

  String get displaySize => itemSize.trim().isEmpty ? 'Default' : itemSize;

  String get displayColor => color.trim().isEmpty ? 'Default' : color;

  double get total => product.finalPrice * itemQty;

  ApiCartItem copyWith({
    int? cartItemId,
    int? detailId,
    int? itemId,
    int? itemDetId,
    String? username,
    int? itemQty,
    int? availableQty,
    String? itemName,
    String? itemDesc,
    double? itemPrice,
    double? discount,
    String? itemImgUrl,
    String? color,
    String? itemSize,
    String? brand,
    ApiProduct? product,
  }) {
    return ApiCartItem(
      cartItemId: cartItemId ?? this.cartItemId,
      detailId: detailId ?? this.detailId,
      itemId: itemId ?? this.itemId,
      itemDetId: itemDetId ?? this.itemDetId,
      username: username ?? this.username,
      itemQty: itemQty ?? this.itemQty,
      availableQty: availableQty ?? this.availableQty,
      itemName: itemName ?? this.itemName,
      itemDesc: itemDesc ?? this.itemDesc,
      itemPrice: itemPrice ?? this.itemPrice,
      discount: discount ?? this.discount,
      itemImgUrl: itemImgUrl ?? this.itemImgUrl,
      color: color ?? this.color,
      itemSize: itemSize ?? this.itemSize,
      brand: brand ?? this.brand,
      product: product ?? _product,
    );
  }

  factory ApiCartItem.fromJson(Map<String, dynamic> json) {
    final parsedDetailId = _asInt(
      _pick(json, const [
        'DETAIL_ID',
        'detail_id',
        'CART_DET_ID',
        'cart_det_id',
        'CART_DETAIL_ID',
        'cart_detail_id',
      ]),
    );
    final parsedCartItemId = _asInt(
      _pick(json, const [
        'CART_ITEM_ID',
        'cart_item_id',
        'CART_ID',
        'cart_id',
      ]),
    );
    final parsedItemDetId = _asInt(
      _pick(json, const ['ITEM_DET_ID', 'item_det_id', 'DET_ID', 'det_id']),
    );
    return ApiCartItem(
      cartItemId: parsedCartItemId > 0
          ? parsedCartItemId
          : (parsedDetailId > 0 ? parsedDetailId : parsedItemDetId),
      detailId: parsedDetailId > 0
          ? parsedDetailId
          : (parsedItemDetId > 0 ? parsedItemDetId : parsedCartItemId),
      itemId: _asInt(_pick(json, const ['ITEM_ID', 'item_id', 'ID', 'id'])),
      itemDetId: parsedItemDetId,
      username: _asString(json, const ['USERNAME', 'username']),
      itemQty: _asInt(_pick(json, const ['ITEM_QTY', 'item_qty', 'qty'])),
      availableQty: _asInt(
        _pick(json, const [
          'AVAILABLE_QTY',
          'available_qty',
          'AVAILABLE_QUANTITY',
          'available_quantity',
        ]),
      ),
      itemName: _asString(json, const ['ITEM_NAME', 'item_name', 'name']),
      itemDesc: _asString(json, const [
        'ITEM_DESC',
        'item_desc',
        'description',
        'desc',
      ]),
      itemPrice: _asDouble(_pick(json, const ['ITEM_PRICE', 'item_price'])),
      discount: _asDouble(_pick(json, const ['DISCOUNT', 'discount'])),
      itemImgUrl: _asString(json, const [
        'ITEM_IMG_URL',
        'item_img_url',
        'images',
        'IMAGES',
      ]),
      color: _asString(json, const ['COLOR', 'color']),
      itemSize: _asString(json, const ['ITEM_SIZE', 'item_size']),
      brand: _asString(json, const ['BRAND', 'brand']),
    );
  }

  ApiProduct toProduct() {
    final finalPrice = itemPrice;
    final originalPrice = discount > 0
        ? finalPrice / (1 - (discount / 100))
        : finalPrice;
    return ApiProduct(
      id: itemId,
      detId: itemDetId,
      itemName: itemName,
      itemDesc: itemDesc,
      itemPrice: originalPrice.isFinite ? originalPrice : finalPrice,
      itemQty: availableQty > 0 ? availableQty : itemQty,
      itemImgUrl: itemImgUrl,
      images: itemImgUrl.trim().isEmpty
          ? const []
          : itemImgUrl
                .split(',')
                .map((path) => path.trim())
                .where((path) => path.isNotEmpty)
                .toList(),
      categoryId: 0,
      category: '',
      createdBy: username,
      itemOwner: username,
      isActive: 1,
      discountPrice: discount > 0 ? finalPrice : null,
      sizes: itemSize.trim().isEmpty ? const ['Default'] : [itemSize],
      colors: color.trim().isEmpty ? const ['Default'] : [color],
      details: [
        ApiProductVariant(
          detId: itemDetId,
          brand: brand,
          color: displayColor,
          itemSize: displaySize,
          discount: discount,
          itemPrice: finalPrice,
          itemQty: itemQty,
        ),
      ],
    );
  }
}

class AddItemToCartRequest {
  final int itemId;
  final int itemDetId;
  final String username;
  final int itemQty;

  const AddItemToCartRequest({
    required this.itemId,
    required this.itemDetId,
    required this.username,
    required this.itemQty,
  });

  Map<String, dynamic> toJson() {
    return {
      'items': [
        {
          'item_id': itemId,
          'item_det_id': itemDetId,
          'username': username,
          'item_qty': itemQty,
        },
      ],
    };
  }
}

dynamic _pick(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    if (json.containsKey(key)) return json[key];
  }
  return null;
}

String _asString(Map<String, dynamic> json, List<String> keys) {
  final value = _pick(json, keys);
  return (value ?? '').toString().trim();
}

double _asDouble(dynamic value, {double fallback = 0.0}) {
  if (value is num) return value.toDouble();
  return double.tryParse((value ?? '').toString()) ?? fallback;
}

int _asInt(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse((value ?? '').toString()) ?? 0;
}
