import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Brand ──────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF4E54C8);
  static const Color primaryLight = Color(0xFF8F94FB);
  static const Color primaryDark = Color(0xFF0018CC);
  static const Color onPrimary = Colors.white;
  static const Color secondary = Color(0xFF4ECDC4);

  /// Hover / lighter surfaces / subtle fills.
  static const Color secondaryLight = Color(0xFFE6FAF8);

  /// Stronger emphasis state.
  static const Color secondaryDark = Color(0xFF2FA99F);

  /// Secondary tinted surface backgrounds.
  static const Color secondarySurface = Color(0xFFF2FFFD);

  /// Warm call-to-action color — used for urgency badges, sale strips, etc.
  /// Distinct from [primary] so the two never clash.
  static const Color accent = Color(0xFFFF6B35);
  static const Color accentLight = Color(0xFFFF9A70);

  /// Informational teal — chips, "new arrival" tags, info surfaces.
  /// Intentionally cool/muted so it never fights the warm accent.
  static const Color info = Color(0xFF00B4D8);
  static const Color infoLight = Color(0xFFE0F7FA);

  // ── Product-specific pigments ──────────────────────────────────────────────
  /// Currency / "you save" text — Material green that reads as money.
  static const Color priceGreen = Color(0xFF2E7D32);

  /// Savings / original-price surface tint.
  static const Color savingsSurface = Color(0xFFE8F5E9);

  /// Discount ribbon / sale badge background.
  static const Color saleBadge = Color(0xFFE53935);

  /// Star rating fill.
  static const Color star = Color(0xFFFFB800);

  // ── Cart / wishlist actions ────────────────────────────────────────────────
  /// Cart CTA uses [primary] so the button hierarchy is consistent —
  /// primary blue = the main conversion action everywhere.
  static const Color cartAction = primary;

  /// Wishlist heart active fill.
  static const Color wishlistActive = Color(0xFFFF4D4F);

  // ── Semantic status ────────────────────────────────────────────────────────
  static const Color success = Color(0xFF00C48C);
  static const Color successSurface = Color(0xFFE9FFF7);
  static const Color warning = Color(0xFFFFB800);
  static const Color warningSurface = Color(0xFFFFF8E1);
  static const Color error = Color(0xFFFF4D4F);
  static const Color errorSurface = Color(0xFFFFEBEE);

  // ── Neutrals ───────────────────────────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF1A1D26);
  static const Color transparent = Colors.transparent;

  static const Color neutral100 = Color(0xFFF6F8FC);
  static const Color neutral200 = Color(0xFFEFF2F8);
  static const Color neutral300 = Color(0xFFDCE3F0);
  static const Color neutral400 = Color(0xFFB6C0D4);
  static const Color neutral500 = Color(0xFF8A96AE);
  static const Color neutral600 = Color(0xFF65718A);

  // ── Light-theme surface tokens ─────────────────────────────────────────────
  static const Color background = Color(0xFFE9ECEF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F2FF);
  static const Color textPrimary = Color(0xFF1A1D26);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFFB0B7C3);
  static const Color border = Color(0xFFDFE6F0);
  static const Color divider = Color(0xFFF0F2F5);

  /// Colored shadow tinted with [primary] for elevated cards.
  static const Color shadowPrimary = Color(0x1A4E54C8);

  // ── Dark-theme surface tokens ──────────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF10111A);
  static const Color surfaceDark = Color(0xFF191C28);
  static const Color cardDark = Color(0xFF212537);
  static const Color dividerDark = Color(0xFF303651);
  static const Color textPrimaryDark = Color(0xFFF5F7FF);
  static const Color textSecondaryDark = Color(0xFFC0C7DD);
  static const Color textMutedDark = Color(0xFF8D96B0);
  static const Color iconDark = Color(0xFFD4DBEC);
  static const Color borderDark = Color(0xFF2A2D40);
  static const Color grey = Color(0xFF9CA3AF);

  // ── Payment-card gradients ─────────────────────────────────────────────────
  static const Color cardVisaStart = Color(0xFF0B1F66);
  static const Color cardVisaEnd = Color(0xFF4E54C8);
  static const Color cardMastercardStart = Color(0xFFB42318);
  static const Color cardMastercardEnd = Color(0xFFFF6B35);
  static const Color cardDefaultStart = Color(0xFF1A1D26);
  static const Color cardDefaultEnd = Color(0xFF65718A);
}