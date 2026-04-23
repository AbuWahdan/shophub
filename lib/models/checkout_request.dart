class CheckoutRequest {
  final String username;
  final int shippingAddress;
  final int paymentMethod;

  const CheckoutRequest({
    required this.username,
    required this.shippingAddress,
    required this.paymentMethod,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'shipping_address': shippingAddress,
      'payment_method': paymentMethod,
    };
  }
}
