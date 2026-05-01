import 'product_model.dart';
import 'package:flutter/foundation.dart';

class CartItemModel {
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

  const CartItemModel({
    required this.detailId,
    required this.itemId,
    this.itemDetId = 0,
    this.username = '',
    required this.itemQty,
    required this.availableQty ,
    required this.itemName,
    this.itemDesc = '',
    required this.itemPrice,
    this.discount = 0,
    this.itemImgUrl = '',
    this.color = '',
    this.itemSize = '',
    this.brand = '',
  });

  String get displaySize  => itemSize.trim().isEmpty ? 'Default' : itemSize;
  String get displayColor => color.trim().isEmpty    ? 'Default' : color;

  double get finalPrice {
    if (discount <= 0 || discount >= 100) return itemPrice;
    return itemPrice * (1 - discount / 100);
  }

  double get total => finalPrice * itemQty;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      debugPrint('[ApiCartItem.fromJson] keys   : ${json.keys.toList()}');
      debugPrint('[ApiCartItem.fromJson] values : $json');
    }

    final detailId = _asInt(_pick(json, const [
      'detail_id',   'DETAIL_ID',
      'cart_det_id', 'CART_DET_ID',
      'ID',
    ]));

    // FIX: GetItemCart does not return a separate DET_ID / item_det_id field.
    // DETAIL_ID on this backend IS the cart_tab-line key that also serves as the
    // item-detail reference for AddItemToCart.
    // Fall back to detailId so itemDetId is never 0 when we need to re-add.
    final itemDetId = () {
      final raw = _asInt(_pick(json, const [
        'item_det_id', 'ITEM_DET_ID',
        'det_id',      'DET_ID',
      ]));
      return raw > 0 ? raw : detailId;
    }();

    final itemQty = _clampMin(
      _asInt(_pick(json, const [
        'booked_qty',  'BOOKED_QTY',
        'cart_qty',    'CART_QTY',
        'order_qty',   'ORDER_QTY',
        'ordered_qty', 'ORDERED_QTY',
      ])),
      min: 1,
    );

    final availableQty = _asInt(_pick(json, const [
      'available_qty', 'AVAILABLE_QTY',
      'avail_qty',     'AVAIL_QTY',
      'stock_qty',     'STOCK_QTY',
      'item_qty',      'ITEM_QTY',
    ]));

    return CartItemModel(
      detailId:     detailId,
      itemId:       _asInt(_pick(json, const ['item_id', 'ITEM_ID'])),
      itemDetId:    itemDetId,
      username:     _asString(json, const ['username', 'USERNAME']),
      itemQty:      itemQty,
      availableQty: availableQty,
      itemName: _asString(json, const [
        'item_name', 'ITEM_NAME', 'name', 'NAME',
      ]),
      itemDesc: _asString(json, const [
        'item_desc', 'ITEM_DESC', 'description', 'DESCRIPTION',
      ]),
      itemPrice: _asDouble(_pick(json, const [
        'item_price', 'ITEM_PRICE', 'price', 'PRICE',
      ])),
      discount: _asDouble(_pick(json, const ['discount', 'DISCOUNT'])),
      itemImgUrl: _asString(json, const [
        'item_img_url', 'ITEM_IMG_URL', 'images', 'IMAGES', 'img_url', 'IMG_URL',
      ]),
      color:    _asString(json, const ['color',     'COLOR']),
      itemSize: _asString(json, const ['item_size', 'ITEM_SIZE', 'size', 'SIZE']),
      brand:    _asString(json, const ['brand',     'BRAND']),
    );
  }

  CartItemModel copyWith({
    int?    detailId,
    int?    itemId,
    int?    itemDetId,
    String? username,
    int?    itemQty,
    int?    availableQty,
    String? itemName,
    String? itemDesc,
    double? itemPrice,
    double? discount,
    String? itemImgUrl,
    String? color,
    String? itemSize,
    String? brand,
  }) {
    return CartItemModel(
      detailId:     detailId     ?? this.detailId,
      itemId:       itemId       ?? this.itemId,
      itemDetId:    itemDetId    ?? this.itemDetId,
      username:     username     ?? this.username,
      itemQty:      itemQty      ?? this.itemQty,
      availableQty: availableQty ?? this.availableQty,
      itemName:     itemName     ?? this.itemName,
      itemDesc:     itemDesc     ?? this.itemDesc,
      itemPrice:    itemPrice    ?? this.itemPrice,
      discount:     discount     ?? this.discount,
      itemImgUrl:   itemImgUrl   ?? this.itemImgUrl,
      color:        color        ?? this.color,
      itemSize:     itemSize     ?? this.itemSize,
      brand:        brand        ?? this.brand,
    );
  }

  ProductModel toProduct() {
    final images = itemImgUrl.trim().isEmpty
        ? <String>[]
        : itemImgUrl.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

    return ProductModel(
      id:            itemId,
      detId:         itemDetId,
      itemName:      itemName,
      itemDesc:      itemDesc,
      itemPrice:     itemPrice,
      itemQty:       availableQty > 0 ? availableQty : itemQty,
      itemImgUrl:    itemImgUrl,
      images:        images,
      categoryId:    0,
      category:      '',
      createdBy:     username,
      itemOwner:     username,
      isActive:      1,
      discountPrice: discount > 0 ? finalPrice : null,
      sizes:         itemSize.trim().isEmpty ? const ['Default'] : [itemSize],
      colors:        color.trim().isEmpty    ? const ['Default'] : [color],
      details: [
        ApiProductVariant(
          detId:     itemDetId,
          brand:     brand,
          color:     displayColor,
          itemSize:  displaySize,
          discount:  discount,
          itemPrice: itemPrice,
          itemQty:   availableQty > 0 ? availableQty : itemQty,
        ),
      ],
    );
  }

  ProductModel get product => toProduct();
}

class AddItemToCartRequest {
  final int    itemId;
  final int    itemDetId;
  final String username;
  final int    itemQty;

  const AddItemToCartRequest({
    required this.itemId,
    required this.itemDetId,
    required this.username,
    required this.itemQty,
  });

  Map<String, dynamic> toJson() => {
    'items': [
      {
        'item_id':     itemId,
        'item_det_id': itemDetId,
        'username':    username,
        'item_qty':    itemQty,
      },
    ],
  };
}

dynamic _pick(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    if (json.containsKey(key)) return json[key];
  }
  return null;
}

String _asString(Map<String, dynamic> json, List<String> keys) =>
    (_pick(json, keys) ?? '').toString().trim();

double _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse((value ?? '').toString()) ?? 0.0;
}

int _asInt(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse((value ?? '').toString()) ?? 0;
}

int _clampMin(int value, {required int min}) => value < min ? min : value;