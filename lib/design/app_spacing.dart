import 'package:flutter/material.dart';

class AppSpacing {
  const AppSpacing._();

  // Base Scale
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 56.0;
  static const double iconXl        = 32.0;   // wishlist button diameter
  static const double iconXs        = 12.0;   // spinner inside cart button
  static const double cartButtonSize = 36.0;  // cart button diameter
  static const double ribbonWidth   = 28.0;   // discount ribbon width
  static const double ribbonTail    = 10.0;   // ribbon pointed tail height

  static const double tabHeight = 72.0;

  // Icon & Element Sizes
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;

  static const double buttonMd = 56.0;
  static const double buttonSm = 24.0;

  static const double borderThick = 12.0;
  static const double borderThin = 8.0;

  static const double imageSm = 60.0;
  static const double imageMd = 160.0;
  static const double imageLg = 240.0;

  static const double cardAspectRatio = 1.58;
  static const double cardCompactHeight = 152.0;
  static const double bottomSheetMaxHeightFactor = 0.82;
  static const int cardExpiryYearCount = 11;

  // EdgeInsets Helpers
  static const EdgeInsets insetsSm = EdgeInsets.all(sm);
  static const EdgeInsets insetsMd = EdgeInsets.all(md);
  static const EdgeInsets insetsLg = EdgeInsets.all(lg);

  static const double navHeight = 90.0;

  static EdgeInsets horizontal(double value) =>
      EdgeInsets.symmetric(horizontal: value);
  static EdgeInsets vertical(double value) =>
      EdgeInsets.symmetric(vertical: value);

  static EdgeInsets symmetric({double h = 0, double v = 0}) =>
      EdgeInsets.symmetric(horizontal: h, vertical: v);
}
