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
          (sum, item) =>
      sum + ((item.price - item.discountedPrice) * item.bookedQty),
    );

    final tax = items.fold<double>(
      0,
          (sum, item) => sum + item.tax,
    );

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

/// =====================================================
/// PROMO VALIDATION MODEL (FIXED FOR YOUR API)
/// =====================================================
class PromoValidationResult {
  const PromoValidationResult({
    required this.isValid,
    required this.discountValue,
    required this.discountType,
    this.maxDiscount = 0,
    this.code = '',
    this.message = '',
  });

  factory PromoValidationResult.invalid({String message = ''}) {
    return PromoValidationResult(
      isValid: false,
      discountValue: 0,
      discountType: '',
      maxDiscount: 0,
      message: message,
    );
  }

  factory PromoValidationResult.fromJson(Map<String, dynamic> json) {
    final isValidRaw = _pick(json, [
      'is_valid',
      'IS_VALID',
      'valid',
      'VALID',
    ]);

    final discountType = _readString(json, [
      'discount_type',
      'DISCOUNT_TYPE',
    ]).toUpperCase();

    final discountValue = _readDouble(_pick(json, [
      'discount_value',
      'DISCOUNT_VALUE',
    ]));

    final maxDiscount = _readDouble(_pick(json, [
      'max_discount',
      'MAX_DISCOUNT',
    ]));

    final code = _readString(json, ['code', 'CODE']);
    final message = _readString(json, [
      'message',
      'MESSAGE',
      'error',
      'ERROR',
    ]);

    final isValid =
        isValidRaw == 1 ||
            isValidRaw == true ||
            isValidRaw == '1' ||
            isValidRaw == 'true';

    return PromoValidationResult(
      isValid: isValid,
      discountValue: isValid ? discountValue : 0,
      discountType: discountType,
      maxDiscount: maxDiscount,
      code: code,
      message: message,
    );
  }

  final bool isValid;
  final double discountValue;   // raw value from API
  final String discountType;     // PERCENT or FIXED
  final double maxDiscount;
  final String code;
  final String message;

  /// ✅ CLIENT CALCULATION (IMPORTANT FIX)
  double calculateDiscount(double subtotal) {
    if (!isValid) return 0;

    if (discountType == 'PERCENT') {
      final raw = subtotal * (discountValue / 100);
      if (maxDiscount > 0 && raw > maxDiscount) {
        return maxDiscount;
      }
      return raw;
    }

    return discountValue;
  }

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