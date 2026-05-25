import 'package:flutter/material.dart';

import '../../../design/app_colors.dart';
import '../../../design/app_spacing.dart';

class CategoryTokens {
  const CategoryTokens._();

  static const double minTileWidth = 150;
  static const double tileAspectRatio = 1.08;
  static const double iconBoxSize = AppSpacing.xxl;
  static const double productMinWidth = 280;
  static const double bottomReserve = AppSpacing.navHeight + AppSpacing.lg;

  static const IconData backIcon = Icons.arrow_back_ios_new_rounded;
  static const IconData searchIcon = Icons.search_rounded;
  static const IconData categoryIcon = Icons.category_rounded;
  static const IconData cartIcon = Icons.add_shopping_cart_rounded;

  static const List<Color> tileGradient = [
    AppColors.primaryLight,
    AppColors.primary,
  ];
}
