import 'package:flutter/foundation.dart';
import 'product/product_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CART ITEM MODEL
// Represents a single item returned from the GET cart API.
// This is a pure data model — no request/mutation logic lives here.
// ─────────────────────────────────────────────────────────────────────────────

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
  // DISPLAY HELPERS
  // ─────────────────────────────

  String get displaySize => itemSize.trim().isEmpty ? 'Default' : itemSize.trim();

  String get displayColor => color.trim().isEmpty ? 'Default' : color.trim();

  /// Price after discount applied (clamped to valid range)
  double get discountedPrice {
    if (discount <= 0 || discount >= 100) return itemPrice;
    return itemPrice * (1 - discount / 100);
  }

  /// Total cost for this line item
  double get lineTotal => discountedPrice * bookedQty;

  /// Subtotal before discount
  double get lineSubtotal => itemPrice * bookedQty;

  /// Discount amount for this line
  double get lineDiscountAmount {
    if (discount <= 0) return 0;
    return lineSubtotal * (discount.clamp(0, 100) / 100);
  }

  /// Tax amount applied after discount
  double get lineTaxAmount {
    if (tax <= 0) return 0;
    return (lineSubtotal - lineDiscountAmount) * (tax.clamp(0, 100) / 100);
  }

  /// How many more of this item can be added (0 means at max)
  int get remainingStock {
    final r = availableQty - bookedQty;
    return r < 0 ? 0 : r;
  }

  bool get hasDiscount => discount > 0 && discount < 100;

  bool get isAtMaxQty => bookedQty >= availableQty;

  bool get isOutOfStock => availableQty <= 0;

  // ─────────────────────────────
  // JSON PARSING
  // ─────────────────────────────

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      debugPrint('[CartItemModel.fromJson] raw=$json');
    }

    final detailId = _parseIntFromKeys(json, const [
      'detail_id', 'DETAIL_ID', 'cart_det_id', 'CART_DET_ID', 'ID',
    ]);

    final itemDetId = () {
      final v = _parseIntFromKeys(json, const [
        'item_det_id', 'ITEM_DET_ID', 'det_id', 'DET_ID',
      ]);
      // Fall back to detailId so the key is never zero
      return v > 0 ? v : detailId;
    }();

    final bookedQty = _clampMin(
      _parseIntFromKeys(json, const [
        'booked_qty', 'BOOKED_QTY', 'qty', 'QTY', 'quantity', 'QUANTITY',
      ]),
      min: 1,
    );

    final rawAvailableQty = _parseIntFromKeys(json, const [
      'available_qty', 'AVAILABLE_QTY',
      'avail_qty',     'AVAIL_QTY',
      'stock_qty',     'STOCK_QTY',
      'item_qty',      'ITEM_QTY',
    ]);

    // Guard: never let availableQty drop below what user already has in cart
    final availableQty = rawAvailableQty > 0 ? rawAvailableQty : bookedQty;

    if (rawAvailableQty <= 0 && kDebugMode) {
      debugPrint(
        '[CartItemModel.fromJson] ⚠️ availableQty missing — '
            'falling back to bookedQty=$bookedQty',
      );
    }

    return CartItemModel(
      detailId: detailId,
      itemId: _parseIntFromKeys(json, const ['item_id', 'ITEM_ID']),
      itemDetId: itemDetId,
      username: _parseStringFromKeys(json, const ['username', 'USERNAME']),
      bookedQty: bookedQty,
      availableQty: availableQty,
      itemName: _parseStringFromKeys(
          json, const ['item_name', 'ITEM_NAME', 'name', 'NAME']),
      itemDesc: _parseStringFromKeys(
          json, const ['item_desc', 'ITEM_DESC', 'description', 'DESCRIPTION']),
      itemPrice: _parseDoubleFromKey(
          _pickFirstKey(json, const ['item_price', 'ITEM_PRICE', 'price', 'PRICE'])),
      discount: _parseDoubleFromKey(
          _pickFirstKey(json, const ['discount', 'DISCOUNT'])),
      tax: _parseDoubleFromKey(
          _pickFirstKey(json, const [
            'tax', 'TAX', 'item_tax', 'ITEM_TAX', 'tax_percent', 'TAX_PERCENT',
          ])),
      itemImgUrl: _parseStringFromKeys(
          json, const [
        'item_img_url', 'ITEM_IMG_URL', 'images', 'IMAGES', 'img_url', 'IMG_URL',
      ]),
      color: _parseStringFromKeys(json, const ['color', 'COLOR']),
      itemSize: _parseStringFromKeys(
          json, const ['item_size', 'ITEM_SIZE', 'size', 'SIZE']),
      brand: _parseStringFromKeys(json, const ['brand', 'BRAND']),
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
      itemQty: availableQty,
      itemImgUrl: itemImgUrl,
      images: images,
      categoryId: 0,
      category: '',
      createdBy: username,
      itemOwner: username,
      isActive: 1,
      discountPrice: hasDiscount ? discountedPrice : null,
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
          itemQty: availableQty,
        ),
      ],
    );
  }

  ProductModel get product => toProduct();

  @override
  String toString() =>
      'CartItemModel(detailId=$detailId, itemDetId=$itemDetId, '
          'name=$itemName, qty=$bookedQty/$availableQty)';
}

// ─────────────────────────────────────────────────────────────────────────────
// ADD TO CART REQUEST  (kept separate — request DTOs are not data models)
// ─────────────────────────────────────────────────────────────────────────────

class AddToCartRequest {
  final int itemId;
  final int itemDetId;
  final String username;

  /// ALWAYS a DELTA — never an absolute total.
  /// The backend accumulates, so we send the exact change:
  ///   • Increment: +1
  ///   • Decrement: -1
  ///   • Add new:   +chosenQty (capped to remaining stock)
  final int deltaQty;

  final double tax;

  const AddToCartRequest({
    required this.itemId,
    required this.itemDetId,
    required this.username,
    required this.deltaQty,
    this.tax = 0,
  }) : assert(deltaQty != 0, 'deltaQty must not be zero');

  Map<String, dynamic> toJson() => {
    'items': [
      {
        'item_id': itemId,
        'item_det_id': itemDetId,
        'username': username,
        'item_qty': deltaQty,
        if (tax > 0) 'tax': tax,
      },
    ],
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// PRIVATE PARSING HELPERS
// ─────────────────────────────────────────────────────────────────────────────

dynamic _pickFirstKey(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    if (json.containsKey(key)) return json[key];
  }
  return null;
}

String _parseStringFromKeys(Map<String, dynamic> json, List<String> keys) =>
    (_pickFirstKey(json, keys) ?? '').toString().trim();

double _parseDoubleFromKey(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse((value ?? '').toString()) ?? 0.0;
}

int _parseIntFromKeys(Map<String, dynamic> json, List<String> keys) {
  final value = _pickFirstKey(json, keys);
  if (value is num) return value.toInt();
  return int.tryParse((value ?? '').toString()) ?? 0;
}

int _clampMin(int value, {required int min}) => value < min ? min : value;