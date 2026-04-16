import 'package:flutter/material.dart';

import '../../design/app_text_styles.dart';

class AppDialogs {
  const AppDialogs._();

  static Future<void> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmLabel,
    required String cancelLabel,
    VoidCallback? onConfirm,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: AppTextStyles.titleLarge),
        content: Text(message, style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(cancelLabel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm?.call();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  static Future<void> showInfo({
    required BuildContext context,
    required String title,
    required String message,
    required String closeLabel,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: AppTextStyles.titleLarge),
        content: SingleChildScrollView(
          child: Text(message, style: AppTextStyles.bodyMedium),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(closeLabel),
          ),
        ],
      ),
    );
  }

  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    required String message,
    required String closeLabel,
  }) {
    return showInfo(
      context: context,
      title: title,
      message: message,
      closeLabel: closeLabel,
    );
  }

  static Future<void> showError({
    required BuildContext context,
    required String title,
    required String message,
    required String closeLabel,
  }) {
    return showInfo(
      context: context,
      title: title,
      message: message,
      closeLabel: closeLabel,
    );
  }

  static Future<void> showLoading({
    required BuildContext context,
    required String message,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const SizedBox(
              width: AppSpacing.iconLg,
              height: AppSpacing.iconLg,
              child: CircularProgressIndicator(
                strokeWidth: AppSpacing.borderThick,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(message, style: AppTextStyles.bodyMedium)),
          ],
        ),
      ),
    );
  }

  static void showAbout({
    required BuildContext context,
    required String applicationName,
    required String applicationVersion,
    required String legalese,
    List<Widget>? children,
  }) {
    return showAboutDialog(
      context: context,
      applicationName: applicationName,
      applicationVersion: applicationVersion,
      applicationLegalese: legalese,
      children: children,
    );
  }

  static Future<T?> showCustom<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: builder,
    );
  }
}
