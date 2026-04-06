import 'package:flutter/foundation.dart';

import '../../core/api/api_constants.dart';
import '../../core/api/api_service.dart';
import '../../core/utils/apex_response_helper.dart';
import '../../src/model/comment_model.dart';

class CommentRepository {
  final ApiService _apiService;

  CommentRepository(this._apiService);

  Future<List<CommentModel>> getItemComments(int itemId) async {
    if (itemId <= 0) {
      return <CommentModel>[];
    }

    try {
      if (kDebugMode) {
        debugPrint('[CommentRepository] Fetching comments for itemId=$itemId');
      }

      final response = await _apiService.get(
        ApiConstants.getItemComment,
        queryParams: {'ITEM_id': itemId.toString()},
        isReadOperation: true,
      );

      if (response is! Map<String, dynamic>) {
        return <CommentModel>[];
      }

      final rawItems = (response['comments'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map(Map<String, dynamic>.from)
          .toList();
      return rawItems.map(CommentModel.fromJson).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CommentRepository] Error fetching comments: $e');
      }
      rethrow;
    }
  }

  Future<bool> checkUserItemOrder({
    required String username,
    required int orderId,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '[CommentRepository] Checking order access for username=$username orderId=$orderId',
        );
      }

      final response = await _apiService.post(
        ApiConstants.checkUserItemOrder,
        body: {'username': username, 'order_id': orderId},
        isReadOperation: true,
      );

      final payload = ApexResponseHelper.unwrapResponse(
        response,
        'CheckUserItemOrder',
      );
      if (payload is List && payload.length == 1) {
        return _parseBool(payload.first);
      }
      return _parseBool(payload);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CommentRepository] Error checking ordered item: $e');
      }
      rethrow;
    }
  }

  Future<void> postComment({
    required int itemId,
    required String username,
    required int rating,
    required String comment,
  }) async {
    final normalizedUsername = username.trim();
    final normalizedComment = comment.trim();
    if (itemId <= 0) {
      throw Exception('Invalid item id.');
    }
    if (normalizedUsername.isEmpty) {
      throw Exception('User not authenticated.');
    }
    if (rating < 1 || rating > 5) {
      throw Exception('Please select a valid rating.');
    }
    if (normalizedComment.isEmpty) {
      throw Exception('Please write a review.');
    }

    try {
      if (kDebugMode) {
        debugPrint('[CommentRepository] Posting comment for itemId=$itemId');
      }

      final response = await _apiService.post(
        ApiConstants.addItemComment,
        body: {
          'item_id': itemId,
          'username': normalizedUsername,
          'rating': rating,
          'comment': normalizedComment,
        },
        isReadOperation: false,
      );
      ApexResponseHelper.unwrapResponse(response, 'AddItemComment');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CommentRepository] Error posting comment: $e');
      }
      rethrow;
    }
  }

  bool _parseBool(dynamic response) {
    if (response is bool) return response;
    if (response is num) return response != 0;
    if (response is String) {
      final value = response.trim().toLowerCase();
      return value == 'true' ||
          value == '1' ||
          value == 'yes' ||
          value == 'success';
    }
    if (response is List) {
      return response.isNotEmpty;
    }
    if (response is Map<String, dynamic>) {
      for (final key in [
        'ordered',
        'ORDERED',
        'is_ordered',
        'IS_ORDERED',
        'has_order',
        'HAS_ORDER',
        'result',
        'RESULT',
        'data',
        'DATA',
        'success',
        'SUCCESS',
        'status',
        'STATUS',
      ]) {
        if (!response.containsKey(key)) continue;
        final value = response[key];
        if (value is bool) return value;
        if (value is num) return value != 0;
        if (value is String) {
          final normalized = value.trim().toLowerCase();
          if (normalized == 'true' ||
              normalized == '1' ||
              normalized == 'ordered' ||
              normalized == 'success' ||
              normalized == 'yes') {
            return true;
          }
          if (normalized == 'false' ||
              normalized == '0' ||
              normalized == 'not_ordered' ||
              normalized == 'no' ||
              normalized == 'error') {
            return false;
          }
        }
      }
    }
    return false;
  }
}
