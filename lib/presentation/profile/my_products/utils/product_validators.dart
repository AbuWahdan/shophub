import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

/// Stateless, context-aware field validators.
/// Pass [context] so the validators can pull localized error strings.
class ProductValidators {
  const ProductValidators._(this._context);

  factory ProductValidators.of(BuildContext context) =>
      ProductValidators._(context);

  final BuildContext _context;

  AppLocalizations get _l10n => AppLocalizations.of(_context);

  String? required(String? value) {
    if ((value ?? '').trim().isEmpty) return _l10n.productRequiredField;
    return null;
  }

  String? positiveDouble(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return _l10n.productRequiredField;
    final parsed = double.tryParse(text);
    if (parsed == null || parsed <= 0) return _l10n.productInvalidValue;
    return null;
  }

  String? positiveInt(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return _l10n.productRequiredField;
    final parsed = int.tryParse(text);
    if (parsed == null || parsed < 1) return _l10n.productInvalidValue;
    return null;
  }

  /// Allows empty (treated as 0 discount). Range 0–100.
  String? optionalDiscount(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;
    final parsed = double.tryParse(text);
    if (parsed == null || parsed < 0 || parsed > 100) {
      return _l10n.productDiscountInvalidRange;
    }
    return null;
  }
}