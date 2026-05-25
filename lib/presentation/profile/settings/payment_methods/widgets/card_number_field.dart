import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'payment_methods_tokens.dart';
import 'payment_text_field.dart';

class CardNumberField extends StatelessWidget {
  const CardNumberField({
    super.key,
    required this.controller,
    required this.label,
    required this.inputFormatters,
    required this.validator,
  });

  final TextEditingController controller;
  final String label;
  final List<TextInputFormatter> inputFormatters;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return PaymentTextField(
      controller: controller,
      label: label,
      keyboardType: TextInputType.number,
      inputFormatters: inputFormatters,
      validator: validator,
      prefixIcon: PaymentMethodsTokens.cardIcon,
      suffixIcon: PaymentMethodsTokens.scanIcon,
    );
  }
}
