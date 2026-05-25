import 'package:flutter/material.dart';

import 'payment_methods_tokens.dart';
import 'payment_text_field.dart';

class HolderNameField extends StatelessWidget {
  const HolderNameField({
    super.key,
    required this.controller,
    required this.label,
    required this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return PaymentTextField(
      controller: controller,
      label: label,
      validator: validator,
      prefixIcon: PaymentMethodsTokens.personIcon,
      textCapitalization: TextCapitalization.characters,
    );
  }
}
