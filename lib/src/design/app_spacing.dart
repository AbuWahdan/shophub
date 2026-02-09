import 'package:flutter/material.dart';

class AppSpacing {
  const AppSpacing._();

  // Core scale
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;

  // Extended scale
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double jumbo = 40;
  static const double giant = 48;
  static const double massive = 64;
  static const double hero = 80;

  // Radius
  static const double radiusSm = 6;
  static const double radiusMd = 8;
  static const double radiusLg = 12;
  static const double radiusXl = 16;
  static const double radiusPill = 999;

  // Borders
  static const double borderThin = 1;
  static const double borderThick = 2;
  static const double borderHeavy = 3;

  // Icon sizes
  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 24;
  static const double iconXl = 32;
  static const double iconHero = 80;

  // Button heights
  static const double buttonSm = 40;
  static const double buttonMd = 48;
  static const double buttonLg = 56;

  // Image sizes
  static const double imageSm = 48;
  static const double imageMd = 80;
  static const double imageLg = 120;
  static const double imageHero = 300;

  // Navigation
  static const double navHeight = 60;
  static const double navMaxWidth = 400;

  // Insets helpers
  static const EdgeInsets insetsXs = EdgeInsets.all(xs);
  static const EdgeInsets insetsSm = EdgeInsets.all(sm);
  static const EdgeInsets insetsMd = EdgeInsets.all(md);
  static const EdgeInsets insetsLg = EdgeInsets.all(lg);
  static const EdgeInsets insetsXl = EdgeInsets.all(xl);
  static const EdgeInsets insetsXxl = EdgeInsets.all(xxl);

  // EdgeInsets factory methods
  static EdgeInsets all(double value) => EdgeInsets.all(value);

  static EdgeInsets horizontal(double value) =>
      EdgeInsets.symmetric(horizontal: value);

  static EdgeInsets vertical(double value) =>
      EdgeInsets.symmetric(vertical: value);

  static EdgeInsets symmetric({
    double horizontal = 0,
    double vertical = 0,
  }) =>
      EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);

  static EdgeInsets only({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) =>
      EdgeInsets.only(left: left, top: top, right: right, bottom: bottom);
}