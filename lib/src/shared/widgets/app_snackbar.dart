import 'package:flutter/material.dart';

import '../../design/app_colors.dart';

enum AppSnackBarType { success, error, info, warning }

class AppSnackBar {
  const AppSnackBar._();

  static void show(
    BuildContext context, {
    required String message,
    AppSnackBarType type = AppSnackBarType.info,
    Duration duration = const Duration(seconds: 2),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: duration,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: _background(type),
        content: Text(
          message,
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static Color _background(AppSnackBarType type) {
    switch (type) {
      case AppSnackBarType.success:
        return AppColors.success;
      case AppSnackBarType.error:
        return AppColors.error;
      case AppSnackBarType.warning:
        return AppColors.warning;
      case AppSnackBarType.info:
        return AppColors.primary;
    }
  }
}
