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

Color? parseApiColor(String? value) {
  final raw = (value ?? '').trim();
  if (raw.isEmpty) {
    return null;
  }

  final normalized = raw.toLowerCase();
  final namedColor = _namedColors[normalized];
  if (namedColor != null) {
    return namedColor;
  }

  final rgbMatch = RegExp(
    r'rgba?\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})(?:\s*,\s*([0-9]*\.?[0-9]+))?\s*\)',
    caseSensitive: false,
  ).firstMatch(raw);
  if (rgbMatch != null) {
    final red = _clampColorChannel(int.tryParse(rgbMatch.group(1) ?? '0') ?? 0);
    final green = _clampColorChannel(
      int.tryParse(rgbMatch.group(2) ?? '0') ?? 0,
    );
    final blue = _clampColorChannel(
      int.tryParse(rgbMatch.group(3) ?? '0') ?? 0,
    );
    final opacity = double.tryParse(rgbMatch.group(4) ?? '');
    return Color.fromRGBO(
      red,
      green,
      blue,
      opacity == null ? 1.0 : opacity.clamp(0, 1).toDouble(),
    );
  }

  final normalizedHex = _normalizeHex(
    raw
        .replaceFirst(RegExp(r'^0x', caseSensitive: false), '')
        .replaceAll(RegExp(r'^ff', caseSensitive: false), ''),
  );
  if (normalizedHex != null) {
    return Color(int.parse('FF$normalizedHex', radix: 16));
  }

  return null;
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

int _clampColorChannel(int value) {
  if (value < 0) return 0;
  if (value > 255) return 255;
  return value;
}

const Map<String, Color> _namedColors = <String, Color>{
  'black': Colors.black,
  'white': Colors.white,
  'red': Colors.red,
  'green': Colors.green,
  'blue': Colors.blue,
  'yellow': Colors.yellow,
  'orange': Colors.orange,
  'purple': Colors.purple,
  'pink': Colors.pink,
  'brown': Colors.brown,
  'grey': Colors.grey,
  'gray': Colors.grey,
  'silver': Color(0xFFC0C0C0),
  'gold': Color(0xFFFFD700),
  'beige': Color(0xFFF5F5DC),
  'ivory': Color(0xFFFFFFF0),
  'maroon': Color(0xFF800000),
  'navy': Color(0xFF000080),
  'teal': Color(0xFF008080),
  'olive': Color(0xFF808000),
  'lime': Color(0xFF00FF00),
  'cyan': Color(0xFF00BCD4),
  'magenta': Color(0xFFFF00FF),
  'turquoise': Color(0xFF40E0D0),
};
