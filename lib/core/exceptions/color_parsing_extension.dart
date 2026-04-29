import 'package:flutter/material.dart';

extension ColorParsingExt on String {
  /// Converts a hex string (e.g., "#FF0000" or "FF0000") to a Flutter Color.
  /// Returns null if the string is invalid.
  Color? toColor() {
    final hexCode = replaceAll('#', '').trim();
    if (hexCode.isEmpty) return null;

    try {
      if (hexCode.length == 6) {
        return Color(int.parse('FF$hexCode', radix: 16));
      } else if (hexCode.length == 8) {
        return Color(int.parse(hexCode, radix: 16));
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}