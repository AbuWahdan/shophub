import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';

class NotificationController extends GetxController {
  final NotificationRepository _repository;

  NotificationController(this._repository);

  // ── Observable state ───────────────────────────────────────────────────────

  final notifications = <NotificationModel>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;

  String username = '';

  // ── Derived ────────────────────────────────────────────────────────────────

  int get unreadCount => notifications.where((n) => !n.isRead).length;
  bool get hasUnread => unreadCount > 0;

  // ── Read ───────────────────────────────────────────────────────────────────

  Future<void> loadNotifications() async {
    if (username.trim().isEmpty) {
      notifications.clear();
      error.value = 'User not authenticated';
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    error.value = '';

    try {
      final result = await _repository.getNotifications(username.trim());
      notifications.assignAll(result);

      if (kDebugMode) {
        debugPrint(
          '[NotificationController] ✅ loaded ${result.length} notifications',
        );
      }
    } catch (e) {
      error.value = _friendlyError(e);
      if (kDebugMode) {
        debugPrint('[NotificationController] ❌ loadNotifications: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ── Write ──────────────────────────────────────────────────────────────────

  Future<void> markAsRead(int notificationId) async {
    if (username.trim().isEmpty) return;

    try {
      await _repository.markAsRead(
        notificationId: notificationId,
        username: username.trim(),
      );

      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        notifications[index] = notifications[index].copyWith(isRead: true);
      }

      if (kDebugMode) {
        debugPrint(
          '[NotificationController] ✅ marked $notificationId as read',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationController] ❌ markAsRead: $e');
      }
    }
  }

  Future<void> markAllAsRead() async {
    final unread = notifications.where((n) => !n.isRead).toList();
    for (final n in unread) {
      await markAsRead(n.id);
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void clear() {
    notifications.clear();
    error.value = '';
    username = '';
    isLoading.value = false;
  }

  // ── Private ────────────────────────────────────────────────────────────────

  String _friendlyError(Object e) {
    final raw = e.toString();
    if (raw.contains('ORA-') ||
        raw.contains('cursor') ||
        raw.contains('PL/SQL')) {
      return 'Something went wrong. Please try again.';
    }
    return raw.replaceFirst('Exception: ', '');
  }
}