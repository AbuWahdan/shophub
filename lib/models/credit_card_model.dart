class CreditCardModel {
  const CreditCardModel({
    required this.cardId,
    required this.maskedNumber,
    required this.cardType,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cardholderName,
    required this.isDefault,
  });

  final int cardId;
  final String maskedNumber;
  final String cardType;
  final int expiryMonth;
  final int expiryYear;
  final String cardholderName;
  final bool isDefault;

  String get expiryFormatted {
    final month = expiryMonth.toString().padLeft(2, '0');
    return '$month/$expiryYear';
  }

  bool get isExpired {
    final now = DateTime.now();
    final nextMonth = expiryMonth == 12
        ? DateTime(expiryYear + 1)
        : DateTime(expiryYear, expiryMonth + 1);
    return !now.isBefore(nextMonth);
  }

  factory CreditCardModel.fromJson(Map<String, dynamic> json) {
    return CreditCardModel(
      cardId: _asInt(_pick(json, const ['CARD_ID', 'card_id', 'id', 'ID'])),
      maskedNumber: formatMasked(
        _asString(json, const ['MASKED_NUMBER', 'masked_number']),
      ),
      cardType: _asString(json, const ['CARD_TYPE', 'card_type']).toUpperCase(),
      expiryMonth: _asInt(_pick(json, const ['EXPIRY_MONTH', 'expiry_month'])),
      expiryYear: _asInt(_pick(json, const ['EXPIRY_YEAR', 'expiry_year'])),
      cardholderName: _asString(json, const [
        'CARDHOLDER_NAME',
        'cardholder_name',
      ]).toUpperCase(),
      isDefault: _asBool(_pick(json, const ['IS_DEFAULT', 'is_default'])),
    );
  }

  CreditCardModel copyWith({bool? isDefault}) {
    return CreditCardModel(
      cardId: cardId,
      maskedNumber: maskedNumber,
      cardType: cardType,
      expiryMonth: expiryMonth,
      expiryYear: expiryYear,
      cardholderName: cardholderName,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  static String formatMasked(String raw) {
    final compact = raw.replaceAll(RegExp(r'\s+'), '');
    if (compact.isEmpty) return compact;
    final groups = <String>[];
    for (var index = 0; index < compact.length; index += 4) {
      final end = (index + 4).clamp(0, compact.length).toInt();
      groups.add(compact.substring(index, end));
    }
    return groups.join(' ');
  }

  static dynamic _pick(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      if (json.containsKey(key)) return json[key];
    }
    return null;
  }

  static String _asString(Map<String, dynamic> json, List<String> keys) {
    return (_pick(json, keys) ?? '').toString().trim();
  }

  static int _asInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse((value ?? '').toString()) ?? 0;
  }

  static bool _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value.toInt() == 1;
    final normalized = (value ?? '').toString().trim().toLowerCase();
    return normalized == '1' || normalized == 'true' || normalized == 'y';
  }
}

class AddCardRequest {
  AddCardRequest({
    required String username,
    required this.cardToken,
    required String maskedNumber,
    required String cardType,
    required this.expiryMonth,
    required this.expiryYear,
    required String cardholderName,
    required this.isDefault,
  }) : username = username,
       maskedNumber = CreditCardModel.formatMasked(maskedNumber),
       cardType = cardType.toUpperCase(),
       cardholderName = cardholderName.toUpperCase();

  final String username;
  final String cardToken;
  final String maskedNumber;
  final String cardType;
  final int expiryMonth;
  final int expiryYear;
  final String cardholderName;
  final bool isDefault;

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'card_token': cardToken,
      'masked_number': maskedNumber,
      'card_type': cardType,
      'expiry_month': expiryMonth,
      'expiry_year': expiryYear,
      'cardholder_name': cardholderName,
      'is_default': isDefault ? 1 : 0,
    };
  }
}
