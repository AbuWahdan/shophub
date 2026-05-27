import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppShadows {
  const AppShadows._();

  static const BoxShadow cardShadow = BoxShadow(
    color: AppColors.shadowPrimary,
    blurRadius: 20,
    offset: Offset(0, 4),
  );

  static const BoxShadow buttonShadow = BoxShadow(
    color: AppColors.primaryDark,
    blurRadius: 16,
    offset: Offset(0, 6),
  );

  static const BoxShadow subtleShadow = BoxShadow(
    color: AppColors.black,
    blurRadius: 8,
    offset: Offset(0, 2),
  );
}