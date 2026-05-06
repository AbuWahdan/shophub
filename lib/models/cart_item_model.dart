import 'product_model.dart';
import 'package:flutter/foundation.dart';

class CartItemModel {
  final int detailId;
  final int itemId;
  final int itemDetId;
  final String username;
  final int bookedQty;
  final int availableQty;
  final String itemName;
  final String itemDesc;
  final double itemPrice;
  final double discount;
  final double tax;
  final String itemImgUrl;
  final String color;
  final String itemSize;
  final String brand;

  const CartItemModel({
    required this.detailId,
    required this.itemId,
    this.itemDetId = 0,
    this.username = '',
    required this.bookedQty,
    required this.availableQty,
    required this.itemName,
    this.itemDesc = '',
    required this.itemPrice,
    this.discount = 0,
    this.tax = 0,
    this.itemImgUrl = '',
    this.color = '',
    this.itemSize = '',
    this.brand = '',
  });

  // ─────────────────────────────
  // UI HELPERS
  // ─────────────────────────────

  String get displaySize => itemSize.trim().isEmpty ? 'Default' : itemSize;

  String get displayColor => color.trim().isEmpty ? 'Default' : color;

  double get finalPrice {
    if (discount <= 0 || discount >= 100) return itemPrice;
    return itemPrice * (1 - discount / 100);
  }

  double get total => finalPrice * bookedQty;

  /// Remaining stock after subtracting what's already in cart
  int get remainingAvailableQty {
    final remaining = availableQty - bookedQty;
    return remaining < 0 ? 0 : remaining;
  }

  double get lineSubtotal => itemPrice * bookedQty;

  double get lineDiscount {
    if (discount <= 0) return 0;
    return lineSubtotal * (discount.clamp(0, 100) / 100);
  }

  double get lineTax {
    if (tax <= 0) return 0;
    return (lineSubtotal - lineDiscount) * (tax.clamp(0, 100) / 100);
  }

  // ─────────────────────────────
  // JSON
  // ─────────────────────────────

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      debugPrint('[CartItemModel.fromJson] keys   : ${json.keys.toList()}');
      debugPrint('[CartItemModel.fromJson] values : $json');
    }

    final detailId = _asInt(_pick(json, const [
      'detail_id', 'DETAIL_ID', 'cart_det_id', 'CART_DET_ID', 'ID',
    ]));

    final itemDetId = () {
      final raw = _asInt(_pick(json, const [
        'item_det_id', 'ITEM_DET_ID', 'det_id', 'DET_ID',
      ]));
      return raw > 0 ? raw : detailId;
    }();

    final bookedQty = _clampMin(
      _asInt(_pick(json, const [
        'booked_qty', 'BOOKED_QTY', 'qty', 'QTY', 'quantity', 'QUANTITY',
      ])),
      min: 1,
    );

    final parsedAvailableQty = _asInt(_pick(json, const [
      'available_qty', 'AVAILABLE_QTY',
      'avail_qty',     'AVAIL_QTY',
      'stock_qty',     'STOCK_QTY',
      'item_qty',      'ITEM_QTY',
    ]));

    // Never default to 0 — use bookedQty so the user can at least
    // keep what they already have in the cart.
    final availableQty = parsedAvailableQty > 0 ? parsedAvailableQty : bookedQty;

    if (parsedAvailableQty <= 0 && kDebugMode) {
      debugPrint(
        '[CartItemModel.fromJson] ⚠️ availableQty missing in API response. '
            'Falling back to bookedQty=$bookedQty.',
      );
    }

    return CartItemModel(
      detailId: detailId,
      itemId: _asInt(_pick(json, const ['item_id', 'ITEM_ID'])),
      itemDetId: itemDetId,
      username: _asString(json, const ['username', 'USERNAME']),
      bookedQty: bookedQty,
      availableQty: availableQty,
      itemName: _asString(json, const ['item_name', 'ITEM_NAME', 'name', 'NAME']),
      itemDesc: _asString(json, const ['item_desc', 'ITEM_DESC', 'description', 'DESCRIPTION']),
      itemPrice: _asDouble(_pick(json, const ['item_price', 'ITEM_PRICE', 'price', 'PRICE'])),
      discount: _asDouble(_pick(json, const ['discount', 'DISCOUNT'])),
      tax: _asDouble(_pick(json, const ['tax', 'TAX', 'item_tax', 'ITEM_TAX', 'tax_percent', 'TAX_PERCENT'])),
      itemImgUrl: _asString(json, const ['item_img_url', 'ITEM_IMG_URL', 'images', 'IMAGES', 'img_url', 'IMG_URL']),
      color: _asString(json, const ['color', 'COLOR']),
      itemSize: _asString(json, const ['item_size', 'ITEM_SIZE', 'size', 'SIZE']),
      brand: _asString(json, const ['brand', 'BRAND']),
    );
  }

  // ─────────────────────────────
  // COPY WITH
  // ─────────────────────────────

  CartItemModel copyWith({
    int? detailId,
    int? itemId,
    int? itemDetId,
    String? username,
    int? bookedQty,
    int? availableQty,
    String? itemName,
    String? itemDesc,
    double? itemPrice,
    double? discount,
    double? tax,
    String? itemImgUrl,
    String? color,
    String? itemSize,
    String? brand,
  }) {
    return CartItemModel(
      detailId: detailId ?? this.detailId,
      itemId: itemId ?? this.itemId,
      itemDetId: itemDetId ?? this.itemDetId,
      username: username ?? this.username,
      bookedQty: bookedQty ?? this.bookedQty,
      availableQty: availableQty ?? this.availableQty,
      itemName: itemName ?? this.itemName,
      itemDesc: itemDesc ?? this.itemDesc,
      itemPrice: itemPrice ?? this.itemPrice,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      itemImgUrl: itemImgUrl ?? this.itemImgUrl,
      color: color ?? this.color,
      itemSize: itemSize ?? this.itemSize,
      brand: brand ?? this.brand,
    );
  }

  // ─────────────────────────────
  // PRODUCT CONVERSION
  // ─────────────────────────────

  ProductModel toProduct() {
    final images = itemImgUrl.trim().isEmpty
        ? <String>[]
        : itemImgUrl
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    return ProductModel(
      id: itemId,
      detId: itemDetId,
      itemName: itemName,
      itemDesc: itemDesc,
      itemPrice: itemPrice,
      itemQty: availableQty > 0 ? availableQty : bookedQty,
      itemImgUrl: itemImgUrl,
      images: images,
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
          tax: tax,
          itemPrice: itemPrice,
          itemQty: availableQty > 0 ? availableQty : bookedQty,
        ),
      ],
    );
  }

  ProductModel get product => toProduct();
}

// ─────────────────────────────
// ADD TO CART REQUEST
// ─────────────────────────────

class AddItemToCartRequest {
  final int itemId;
  final int itemDetId;
  final String username;
  final int bookedQty;
  final double tax;

  const AddItemToCartRequest({
    required this.itemId,
    required this.itemDetId,
    required this.username,
    required this.bookedQty,
    this.tax = 0,
  });

  Map<String, dynamic> toJson() => {
    'items': [
      {
        'item_id': itemId,
        'item_det_id': itemDetId,
        'username': username,
        'item_qty': bookedQty,
        if (tax > 0) 'tax': tax,
      },
    ],
  };
}

// ─────────────────────────────
// HELPERS
// ─────────────────────────────

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