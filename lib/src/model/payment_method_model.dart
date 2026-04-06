import 'package:flutter/material.dart';

class PaymentMethodModel {
  final int id;
  final String label;
  final IconData icon;

  const PaymentMethodModel({
    required this.id,
    required this.label,
    required this.icon,
  });
}
