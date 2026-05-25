import 'package:flutter/material.dart';

import '../../../../../design/app_colors.dart';
import '../../../../../design/app_spacing.dart';


class PaymentMethodsTokens {
  const PaymentMethodsTokens._();

  static const double cardPreviewAspectRatio = 1.58;
  static const double cardIconSize = AppSpacing.xxl;
  static const double chipWidth = AppSpacing.xl;
  static const double chipHeight = AppSpacing.lg;
  static const double circleLarge = 156.0;
  static const double circleSmall = 92.0;

  static const IconData backIcon = Icons.arrow_back_ios_new_rounded;
  static const IconData addCardIcon = Icons.add_card_rounded;
  static const IconData cardIcon = Icons.credit_card_rounded;
  static const IconData scanIcon = Icons.document_scanner_outlined;
  static const IconData personIcon = Icons.person_outline_rounded;
  static const IconData lockIcon = Icons.lock_outline_rounded;
  static const IconData calendarIcon = Icons.calendar_month_outlined;
  static const IconData checkIcon = Icons.check_rounded;
  static const IconData moreIcon = Icons.more_vert_rounded;

  static const List<Color> visaGradient = [
    AppColors.cardVisaStart,
    AppColors.cardVisaEnd,
  ];
  static const List<Color> mastercardGradient = [
    AppColors.cardMastercardStart,
    AppColors.cardMastercardEnd,
  ];
  static const List<Color> defaultGradient = [
    AppColors.cardDefaultStart,
    AppColors.cardDefaultEnd,
  ];
}
