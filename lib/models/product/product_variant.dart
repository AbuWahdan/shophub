class ProductVariant {
  final int detId;
  final String brand;
  final String color;
  final String size;
  final double discount;
  final double tax;
  final double price;
  final int stock;

  const ProductVariant({
    required this.detId,
    required this.brand,
    required this.color,
    required this.size,
    required this.discount,
    this.tax = 0,
    required this.price,
    required this.stock,
  });




  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductVariant &&
          runtimeType == other.runtimeType &&
          detId == other.detId;

  @override
  int get hashCode => detId.hashCode;

  // ── Serialisation ──────────────────────────────────────────────────────────

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      detId: _int(_pick(json, const ['DET_ID', 'det_id', 'item_det_id'])),
      brand: _str(json, const ['BRAND', 'brand']),
      color: _str(json, const ['COLOR', 'color']),
      size: _str(json, const ['ITEM_SIZE', 'item_size']),
      discount: _dbl(
        _pick(json, const [
          'ITEM_DISCOUNT',
          'item_discount',
          'DISCOUNT',
          'discount',
        ]),
      ),
      tax: _dbl(_pick(json, const ['TAX', 'tax', 'ITEM_TAX', 'item_tax'])),
      price: _dbl(_pick(json, const ['ITEM_PRICE', 'item_price'])),
      stock: _int(_pick(json, const ['ITEM_QTY', 'item_qty'])),
    );
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  static dynamic _pick(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      if (json.containsKey(key)) return json[key];
    }
    return null;
  }

  static String _str(Map<String, dynamic> json, List<String> keys) =>
      (_pick(json, keys) ?? '').toString().trim();

  static double _dbl(dynamic v, {double fallback = 0.0}) {
    if (v is num) return v.toDouble();
    return double.tryParse((v ?? '').toString()) ?? fallback;
  }

  static int _int(dynamic v) {
    if (v is num) return v.toInt();
    return int.tryParse((v ?? '').toString()) ?? 0;
  }
}
