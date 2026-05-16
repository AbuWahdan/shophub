import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/state/review_refresh_notifier.dart';
import '../l10n/app_localizations.dart';
import '../models/item_comment_model.dart';
import '../repositories/comment_repository.dart';
import '../services/app_notification_service.dart';

class ItemReviewController extends GetxController {
  ItemReviewController(this._commentRepository);

  final CommentRepository _commentRepository;

  final comments = <ItemCommentModel>[].obs;
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final errorMessage = RxnString();
  final selectedRating = 0.obs;
  final commentController = TextEditingController();

  Future<void> loadComments(int itemId) async {
    if (itemId <= 0) {
      comments.clear();
      errorMessage.value = null;
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;
    try {
      final loadedComments = await _commentRepository.getItemComments(
        itemId: itemId,
      );
      comments.assignAll(loadedComments);
    } catch (error) {
      errorMessage.value = _resolveErrorMessage(error);
    } finally {
      isLoading.value = false;
    }
  }

  ItemCommentModel? userReview(String username) {
    final normalizedUsername = username.trim().toLowerCase();
    if (normalizedUsername.isEmpty) {
      return null;
    }

    for (final review in comments) {
      if (review.username.trim().toLowerCase() == normalizedUsername) {
        return review;
      }
    }
    return null;
  }

  Future<void> submitReview({
    required BuildContext context,
    required int itemId,
    required String username,
    required int rating,
    required String comment,
  }) async {
    final normalizedUsername = username.trim();
    final normalizedComment = comment.trim();

    if (normalizedUsername.isEmpty) {
      AppNotificationService.instance.showError(
        context,
        AppLocalizations.of(context).itemReviewLoginRequired,
      );
      return;
    }

    if (userReview(normalizedUsername) != null) {
      AppNotificationService.instance.showWarning(
        context,
        AppLocalizations.of(context).itemReviewAlreadyRated,
      );
      return;
    }

    if (rating < 1 || rating > 5) {
      AppNotificationService.instance.showWarning(
        context,
        AppLocalizations.of(context).itemReviewRatingRequired,
      );
      return;
    }

    if (normalizedComment.isEmpty) {
      AppNotificationService.instance.showWarning(
        context,
        AppLocalizations.of(context).itemReviewCommentRequired,
      );
      return;
    }

    if (isSubmitting.value) {
      return;
    }

    isSubmitting.value = true;
    try {
      await _commentRepository.addItemComment(
        itemId: itemId,
        username: normalizedUsername,
        rating: rating,
        comment: normalizedComment,
      );
      ReviewRefreshNotifier.notifyItemReviewed(itemId);
      selectedRating.value = 0;
      commentController.clear();
      await loadComments(itemId);
      if (!context.mounted) {
        return;
      }
      AppNotificationService.instance.showSuccess(
        context,
        AppLocalizations.of(context).itemReviewSubmittedSuccess,
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      AppNotificationService.instance.showError(
        context,
        _resolveErrorMessage(error).isEmpty
            ? AppLocalizations.of(context).itemReviewLoadFailed
            : _resolveErrorMessage(error),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  String _resolveErrorMessage(Object error) {
    return error.toString().replaceFirst('Exception: ', '').trim();
  }

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }
}
