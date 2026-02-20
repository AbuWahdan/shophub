import 'product_api.dart';

class ApiCartItem {
  final int itemId;
  final int itemDetId;
  final String username;
  final int itemQty;
  final String itemName;
  final String itemDesc;
  final double itemPrice;
  final double discount;
  final String itemImgUrl;
  final String color;
  final String itemSize;
  final String brand;

  const ApiCartItem({
    required this.itemId,
    required this.itemDetId,
    required this.username,
    required this.itemQty,
    required this.itemName,
    required this.itemDesc,
    required this.itemPrice,
    required this.discount,
    required this.itemImgUrl,
    required this.color,
    required this.itemSize,
    required this.brand,
  });

  factory ApiCartItem.fromJson(Map<String, dynamic> json) {
    return ApiCartItem(
      itemId: _asInt(_pick(json, const ['ITEM_ID', 'item_id', 'ID', 'id'])),
      itemDetId: _asInt(
        _pick(json, const ['ITEM_DET_ID', 'item_det_id', 'DET_ID', 'det_id']),
      ),
      username: _asString(json, const ['USERNAME', 'username']),
      itemQty: _asInt(_pick(json, const ['ITEM_QTY', 'item_qty', 'qty'])),
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
      itemQty: itemQty,
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
          color: color,
          itemSize: itemSize,
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
