import 'product_api.dart';
import 'package:flutter/foundation.dart';

class ApiCartItem {
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

  const ApiCartItem({
    required this.detailId,
    required this.itemId,
    this.itemDetId = 0,
    this.username = '',
    required this.itemQty,
    this.availableQty = 0,
    required this.itemName,
    this.itemDesc = '',
    required this.itemPrice,
    this.discount = 0,
    this.itemImgUrl = '',
    this.color = '',
    this.itemSize = '',
    this.brand = '',
  });

  // ── Derived helpers ───────────────────────────────────────────────────────

  String get displaySize  => itemSize.trim().isEmpty ? 'Default' : itemSize;
  String get displayColor => color.trim().isEmpty    ? 'Default' : color;

  double get finalPrice {
    if (discount <= 0 || discount >= 100) return itemPrice;
    return itemPrice * (1 - discount / 100);
  }

  double get total => finalPrice * itemQty;

  // ── Factory ───────────────────────────────────────────────────────────────

  factory ApiCartItem.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      debugPrint('[ApiCartItem.fromJson] keys   : ${json.keys.toList()}');
      debugPrint('[ApiCartItem.fromJson] values : $json');
    }

    return ApiCartItem(
      // Cart line PK — 'detail_id' once backend is fixed, 'ID' is current fallback.
      // WARNING: 'ID' currently returns the product ID (wrong value).
      // Delete will work correctly only after backend returns 'detail_id'.
      detailId: _asInt(_pick(json, const [
        'detail_id',   'DETAIL_ID',
        'cart_det_id', 'CART_DET_ID',
        'ID',                          // ← current backend key (temporary fallback)
      ])),

      itemId: _asInt(_pick(json, const [
        'item_id', 'ITEM_ID',
      ])),

      itemDetId: _asInt(_pick(json, const [
        'item_det_id', 'ITEM_DET_ID',
        'det_id',      'DET_ID',
      ])),

      username: _asString(json, const [
        'username', 'USERNAME',
      ]),

      // 'BOOKED_QTY' is what the backend currently returns.
      itemQty: _clampMin(
        _asInt(_pick(json, const [
          'booked_qty',  'BOOKED_QTY',
          'item_qty',    'ITEM_QTY',
          'qty',         'QTY',
          'quantity',    'QUANTITY',
        ])),
        min: 1,
      ),

      availableQty: _asInt(_pick(json, const [
        'available_qty', 'AVAILABLE_QTY',
        'avail_qty',     'AVAIL_QTY',
        'stock_qty',     'STOCK_QTY',
      ])),

      itemName: _asString(json, const [
        'item_name', 'ITEM_NAME',
        'name',      'NAME',
      ]),

      itemDesc: _asString(json, const [
        'item_desc',    'ITEM_DESC',
        'description',  'DESCRIPTION',
      ]),

      itemPrice: _asDouble(_pick(json, const [
        'item_price', 'ITEM_PRICE',
        'price',      'PRICE',
      ])),

      discount: _asDouble(_pick(json, const [
        'discount', 'DISCOUNT',
      ])),

      itemImgUrl: _asString(json, const [
        'item_img_url', 'ITEM_IMG_URL',
        'images',       'IMAGES',
        'img_url',      'IMG_URL',
      ]),

      color:    _asString(json, const ['color',     'COLOR']),
      itemSize: _asString(json, const ['item_size', 'ITEM_SIZE', 'size', 'SIZE']),
      brand:    _asString(json, const ['brand',     'BRAND']),
    );
  }

  // ── copyWith ──────────────────────────────────────────────────────────────

  ApiCartItem copyWith({
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
    return ApiCartItem(
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

  // ── toProduct ─────────────────────────────────────────────────────────────

  ApiProduct toProduct() {
    final images = itemImgUrl.trim().isEmpty
        ? <String>[]
        : itemImgUrl
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    return ApiProduct(
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
          itemQty:   itemQty,
        ),
      ],
    );
  }

  // ── product getter ────────────────────────────────────────────────────────

  ApiProduct get product => toProduct();
}

// ── AddItemToCartRequest ──────────────────────────────────────────────────────

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

// ── Private helpers ───────────────────────────────────────────────────────────

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