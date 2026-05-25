import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/api/api_constants.dart';
import '../core/api/api_service.dart';
import '../models/notification_model.dart';


class NotificationRepository {
  final ApiService _api;

  NotificationRepository({ApiService? api, http.Client? client})
      : _api = api ?? ApiService(client: client);

  Future<List<NotificationModel>> getNotifications(String username) async {
    final dynamic raw = await _api.post(
      ApiConstants.getNotifications,
      body: {'username': username},
      isReadOperation: true,
    );

    if (raw == null) return [];

    List<dynamic> items;

    if (raw is List) {
      items = raw;
    } else if (raw is Map<String, dynamic>) {
      final data = raw['data'] ?? raw['items'] ?? raw['notifications'];
      if (data is List) {
        items = data;
      } else {
        items = [raw];
      }
    } else {
      return [];
    }

    final result = <NotificationModel>[];
    for (final item in items) {
      if (item is! Map<String, dynamic>) continue;
      try {
        result.add(NotificationModel.fromJson(item));
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[NotificationRepository] skipping bad item: $e | $item');
        }
      }
    }

    return result;
  }

  Future<void> markAsRead({
    required int notificationId,
    required String username,
  }) async {
    await _api.post(
      ApiConstants.markAsRead,
      body: {'id': notificationId, 'username': username},
      isReadOperation: false,
    );
  }
}