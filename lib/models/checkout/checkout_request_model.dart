class CheckoutRequestModel {
  final String username;
  final int shippingAddress;
  final int paymentMethod;
  final String? promoCode;
  final int? cardId;

  const CheckoutRequestModel({
    required this.username,
    required this.shippingAddress,
    required this.paymentMethod,
    this.promoCode,
    this.cardId,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'username': username,
      'shipping_address': shippingAddress,
      'payment_method': paymentMethod,
    };

    if (promoCode != null && promoCode!.trim().isNotEmpty) {
      data['promo_code'] = promoCode!.trim().toUpperCase();
    }
    if (cardId != null && cardId! > 0) {
      data['card_id'] = cardId;
    }

    return data;
  }
}
