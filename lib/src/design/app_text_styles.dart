import 'package:flutter/material.dart';
import 'app_spacing.dart';

class AppTextStyles {
  const AppTextStyles._();

  static TextStyle _scaled(BuildContext context, TextStyle style) {
    final scaler = MediaQuery.textScalerOf(context);
    return style.apply(fontSizeFactor: scaler.scale(1));
  }

  static TextStyle displayLarge(BuildContext context) =>
      _scaled(context, Theme.of(context).textTheme.displayLarge!);
  static TextStyle displayMedium(BuildContext context) =>
      _scaled(context, Theme.of(context).textTheme.displayMedium!);
  static TextStyle displaySmall(BuildContext context) =>
      _scaled(context, Theme.of(context).textTheme.displaySmall!);

  static TextStyle headlineLarge(BuildContext context) =>
      _scaled(context, Theme.of(context).textTheme.headlineLarge!);
  static TextStyle headlineMedium(BuildContext context) =>
      _scaled(context, Theme.of(context).textTheme.headlineMedium!);
  static TextStyle headlineSmall(BuildContext context) =>
      _scaled(context, Theme.of(context).textTheme.headlineSmall!);

  static TextStyle titleLarge(BuildContext context) =>
      _scaled(context, Theme.of(context).textTheme.titleLarge!);
  static TextStyle titleMedium(BuildContext context) =>
      _scaled(context, Theme.of(context).textTheme.titleMedium!);
  static TextStyle titleSmall(BuildContext context) =>
      _scaled(context, Theme.of(context).textTheme.titleSmall!);

  static TextStyle bodyLarge(BuildContext context) =>
      _scaled(context, Theme.of(context).textTheme.bodyLarge!);
  static TextStyle bodyMedium(BuildContext context) =>
      _scaled(context, Theme.of(context).textTheme.bodyMedium!);
  static TextStyle bodySmall(BuildContext context) =>
      _scaled(context, Theme.of(context).textTheme.bodySmall!);

  static TextStyle labelLarge(BuildContext context) =>
      _scaled(context, Theme.of(context).textTheme.labelLarge!);
  static TextStyle labelMedium(BuildContext context) =>
      _scaled(context, Theme.of(context).textTheme.labelMedium!);
  static TextStyle labelSmall(BuildContext context) =>
      _scaled(context, Theme.of(context).textTheme.labelSmall!);

  static TextStyle emphasized(BuildContext context, TextStyle base) =>
      _scaled(context, base.copyWith(fontWeight: FontWeight.w600));

  static TextStyle strong(BuildContext context, TextStyle base) =>
      _scaled(context, base.copyWith(fontWeight: FontWeight.w700));

  static TextStyle subtle(BuildContext context, TextStyle base) =>
      _scaled(context, base.copyWith(letterSpacing: AppSpacing.xs));
}
