import 'package:flutter/material.dart';

import '../../../../design/app_colors.dart';
import '../../../../design/app_spacing.dart';

class CheckoutTokens {
  const CheckoutTokens._();

  static const double imageSize = AppSpacing.xxxl;
  static const double bottomBarReserve = AppSpacing.xxxl + AppSpacing.xxl;
  static const double iconBoxSize = AppSpacing.xxl;

  static const IconData locationIcon = Icons.location_on_outlined;
  static const IconData promoIcon = Icons.confirmation_number_outlined;
  static const IconData paymentIcon = Icons.credit_card_outlined;
  static const IconData cardIcon = Icons.payments_outlined;
  static const IconData checkIcon = Icons.check_rounded;
  static const IconData truckIcon = Icons.local_shipping_outlined;

  static const List<Color> iconGradient = [
    AppColors.primaryLight,
    AppColors.primary,
  ];
}
