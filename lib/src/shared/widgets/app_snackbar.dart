import 'package:flutter/material.dart';

import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../design/app_text_styles.dart';

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
        margin: const EdgeInsets.all(AppSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        backgroundColor: _background(type),
        content: Row(
          children: [
            Icon(_icon(type), color: AppColors.textOnPrimary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textOnPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static IconData _icon(AppSnackBarType type) {
    switch (type) {
      case AppSnackBarType.success:
        return Icons.check_circle_outline;
      case AppSnackBarType.error:
        return Icons.error_outline;
      case AppSnackBarType.warning:
        return Icons.warning_amber_outlined;
      case AppSnackBarType.info:
        return Icons.info_outline;
    }
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
