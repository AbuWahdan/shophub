import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../design/app_colors.dart';
import '../design/app_radius.dart';
import '../design/app_spacing.dart';
import '../design/app_text_styles.dart';

enum AppNotificationType { success, error, warning, info }

class _NotificationMessage {
  final String message;
  final AppNotificationType type;
  final Duration duration;
  final DateTime timestamp;

  _NotificationMessage({
    required this.message,
    required this.type,
    required this.duration,
    required this.timestamp,
  });

  String get _key => '$type:$message';
}

/// Enterprise-grade, globally-accessible notification service.
///
/// Features:
/// - Single instance (global access via [AppNotificationService.instance])
/// - One snackbar visible at a time (others queued)
/// - Automatic debounce/spam protection (ignores duplicates within 1 second)
/// - Full design system integration (colors, spacing, radius, text styles)
/// - Fully responsive and overflow-safe
/// - Material 3 aligned
///
/// Usage:
/// ```dart
/// AppNotificationService.instance.showSuccess(
///   context,
///   'Item added to cart',
/// );
///
/// AppNotificationService.instance.showError(
///   context,
///   'Failed to load products',
/// );
/// ```
class AppNotificationService {
  static final AppNotificationService _instance =
      AppNotificationService._internal();

  factory AppNotificationService() => _instance;

  AppNotificationService._internal();

  static AppNotificationService get instance => _instance;

  final List<_NotificationMessage> _queue = [];
  _NotificationMessage? _current;
  Timer? _timer;
  BuildContext? _lastContext;

  final Map<String, DateTime> _deduplicateMap = {};
  static const _deduplicateDuration = Duration(seconds: 1);

  /// Shows a success notification.
  ///
  /// If [context] is null, uses [Get.context] (for use in GetX controllers).
  void showSuccess(
    BuildContext? context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    _show(
      context,
      message,
      AppNotificationType.success,
      duration,
    );
  }

  /// Shows an error notification.
  ///
  /// If [context] is null, uses [Get.context] (for use in GetX controllers).
  void showError(
    BuildContext? context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message,
      AppNotificationType.error,
      duration,
    );
  }

  /// Shows a warning notification.
  ///
  /// If [context] is null, uses [Get.context] (for use in GetX controllers).
  void showWarning(
    BuildContext? context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    _show(
      context,
      message,
      AppNotificationType.warning,
      duration,
    );
  }

  /// Shows an info notification.
  ///
  /// If [context] is null, uses [Get.context] (for use in GetX controllers).
  void showInfo(
    BuildContext? context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    _show(
      context,
      message,
      AppNotificationType.info,
      duration,
    );
  }

  void _show(
    BuildContext? context,
    String message,
    AppNotificationType type,
    Duration duration,
  ) {
    final targetContext = context ?? Get.context;
    if (targetContext == null || !targetContext.mounted) return;

    _lastContext = targetContext;

    // Deduplicate: ignore if same message + type shown within 1 second
    final key = '$type:$message';
    final lastTime = _deduplicateMap[key];
    if (lastTime != null &&
        DateTime.now().difference(lastTime) < _deduplicateDuration) {
      return;
    }
    _deduplicateMap[key] = DateTime.now();

    final notification = _NotificationMessage(
      message: message,
      type: type,
      duration: duration,
      timestamp: DateTime.now(),
    );

    _queue.add(notification);
    _processQueue();
  }

  void _processQueue() {
    if (_current != null || _queue.isEmpty || _lastContext == null) return;

    _current = _queue.removeAt(0);
    _displayCurrent();
  }

  void _displayCurrent() {
    if (_current == null || _lastContext == null || !_lastContext!.mounted) {
      _current = null;
      _processQueue();
      return;
    }

    final messenger = ScaffoldMessenger.of(_lastContext!);
    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        content: _NotificationContent(notification: _current!),
        behavior: SnackBarBehavior.floating,
        duration: _current!.duration,
        margin: const EdgeInsets.all(AppSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        backgroundColor: _backgroundColor(_current!.type),
        elevation: 8.0,
      ),
    );

    _timer?.cancel();
    _timer = Timer(_current!.duration, () {
      _current = null;
      _processQueue();
    });
  }

  Color _backgroundColor(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.success:
        return AppColors.success;
      case AppNotificationType.error:
        return AppColors.error;
      case AppNotificationType.warning:
        return AppColors.warning;
      case AppNotificationType.info:
        return AppColors.primary;
    }
  }

  /// Clean up resources on app exit or when needed
  void dispose() {
    _timer?.cancel();
    _queue.clear();
    _current = null;
    _deduplicateMap.clear();
  }
}

/// Internal widget for rendering notification content.
class _NotificationContent extends StatelessWidget {
  final _NotificationMessage notification;

  const _NotificationContent({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIcon(notification.type),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            notification.message,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.white,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildIcon(AppNotificationType type) {
    return Icon(
      _iconData(type),
      color: AppColors.white,
      size: AppSpacing.iconMd,
    );
  }

  IconData _iconData(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.success:
        return Icons.check_circle_outline;
      case AppNotificationType.error:
        return Icons.error_outline;
      case AppNotificationType.warning:
        return Icons.warning_amber_outlined;
      case AppNotificationType.info:
        return Icons.info_outline;
    }
  }
}
