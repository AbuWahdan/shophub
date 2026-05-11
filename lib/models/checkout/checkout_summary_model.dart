import '../cart_item_model.dart';

class CheckoutSummaryModel {
  const CheckoutSummaryModel({
    required this.subtotal,
    required this.itemDiscount,
    required this.tax,
    required this.promoDiscount,
  });

  factory CheckoutSummaryModel.fromCartItems(
    List<CartItemModel> items, {
    double promoDiscount = 0,
  }) {
    final subtotal = items.fold<double>(
      0,
      (sum, item) => sum + item.lineSubtotal,
    );
    final itemDiscount = items.fold<double>(
      0,
      (sum, item) => sum + item.discount,
    );
    final tax = items.fold<double>(0, (sum, item) => sum + item.tax);

    return CheckoutSummaryModel(
      subtotal: subtotal,
      itemDiscount: itemDiscount,
      tax: tax,
      promoDiscount: promoDiscount,
    );
  }

  final double subtotal;
  final double itemDiscount;
  final double tax;
  final double promoDiscount;

  double get taxableAmount => subtotal - itemDiscount;

  double get totalDiscount => itemDiscount + promoDiscount;

  double get grandTotal {
    final total = taxableAmount + tax - promoDiscount;
    return total < 0 ? 0 : total;
  }
}

class PromoValidationResult {
  const PromoValidationResult({
    required this.isValid,
    required this.discountAmount,
    this.code = '',
    this.message = '',
  });

  factory PromoValidationResult.invalid({String message = ''}) {
    return PromoValidationResult(
      isValid: false,
      discountAmount: 0,
      message: message,
    );
  }

  factory PromoValidationResult.fromJson(Map<String, dynamic> json) {
    final status = _readString(json, const [
      'status',
      'STATUS',
      'valid',
      'VALID',
      'is_valid',
      'IS_VALID',
    ]).toLowerCase();
    final message = _readString(json, const [
      'message',
      'MESSAGE',
      'error',
      'ERROR',
      'description',
      'DESCRIPTION',
    ]);
    final code = _readString(json, const ['code', 'CODE', 'promo_code']);
    final discountAmount = _readDouble(
      _pick(json, const [
        'discount_amount',
        'DISCOUNT_AMOUNT',
        'discount',
        'DISCOUNT',
        'amount',
        'AMOUNT',
        'promo_discount',
        'PROMO_DISCOUNT',
      ]),
    );

    final valid =
        status == 'success' ||
        status == 'valid' ||
        status == 'true' ||
        status == '1' ||
        (discountAmount > 0 && status != 'invalid' && status != 'error');

    return PromoValidationResult(
      isValid: valid,
      discountAmount: valid ? discountAmount : 0,
      code: code,
      message: message,
    );
  }

  final bool isValid;
  final double discountAmount;
  final String code;
  final String message;

  static dynamic _pick(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      if (json.containsKey(key)) return json[key];
    }
    return null;
  }

  static String _readString(Map<String, dynamic> json, List<String> keys) {
    return (_pick(json, keys) ?? '').toString().trim();
  }

  static double _readDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse((value ?? '').toString()) ?? 0;
  }
}
