import 'package:flutter/foundation.dart';
import '../../core/api/api_constants.dart';
import '../../core/api/api_service.dart';
import '../../core/utils/apex_response_helper.dart';
import '../../models/item_comment_model.dart';

class CommentRepository {
  final ApiService _apiService;

  CommentRepository(this._apiService);

  Future<List<ItemCommentModel>> getItemComments({required int itemId}) async {
    if (itemId <= 0) {
      return <ItemCommentModel>[];
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
        return <ItemCommentModel>[];
      }

      final rawItems = (response['comments'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map(Map<String, dynamic>.from)
          .toList();
      final comments = rawItems.map(ItemCommentModel.fromJson).toList()
        ..sort((a, b) {
          if (a.hasCreatedAt && b.hasCreatedAt) {
            return b.createdAt.compareTo(a.createdAt);
          }
          if (a.hasCreatedAt != b.hasCreatedAt) {
            return b.hasCreatedAt ? 1 : -1;
          }
          return b.id.compareTo(a.id);
        });
      return comments;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CommentRepository] Error fetching comments: $e');
      }
      rethrow;
    }
  }

  Future<void> addItemComment({
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
}
