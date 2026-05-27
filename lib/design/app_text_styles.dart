import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  const AppTextStyles._();

  static const String fontFamily = 'Poppins';

  // --- Display Styles (Large hero text) ---
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -1.0,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  // --- Heading Styles (Section titles) ---
  static const TextStyle headingLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle headingSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // --- Body Styles (General content) ---
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // --- Label & Utility Styles (Buttons, Chips, Captions) ---
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
  );

  // --- Specialized Styles ---
  static const TextStyle priceLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  static const TextStyle priceMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  static const TextStyle buttonLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  static const TextStyle discountRibbon = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w700,
    fontSize: 9,
    height: 1.1,
  );

  static const TextStyle savingsBadge = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w600,
    fontSize: 11,
  );

  static const TextStyle priceLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle originalPrice = TextStyle(fontSize: 10);

  static TextStyle get titleLarge =>
      const TextStyle(fontSize: 18, fontWeight: FontWeight.w700);

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
  );
  // --- Helper Methods ---

  static TextStyle strong(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.w700);
  }
}
