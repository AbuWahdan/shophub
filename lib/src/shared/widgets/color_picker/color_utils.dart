import 'package:flutter/material.dart';

Color? hexToColor(String hex) {
  final normalized = _normalizeHex(hex);
  if (normalized == null) {
    return null;
  }

  return Color(int.parse('FF$normalized', radix: 16));
}

String colorToHex(Color color) {
  final rgb = color.toARGB32() & 0x00FFFFFF;
  return rgb.toRadixString(16).padLeft(6, '0').toUpperCase();
}

bool isValidHex(String hex) {
  return _normalizeHex(hex) != null;
}

String? _normalizeHex(String hex) {
  final normalized = hex.trim().replaceFirst('#', '').toUpperCase();
  if (normalized.length != 6) {
    return null;
  }
  if (!RegExp(r'^[0-9A-F]{6}$').hasMatch(normalized)) {
    return null;
  }
  return normalized;
}
