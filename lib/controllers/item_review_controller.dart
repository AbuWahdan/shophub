import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/repositories/comment_repository.dart';
import '../l10n/l10n.dart';
import '../models/api_item_comment.dart';
import '../src/shared/widgets/app_snackbar.dart';
import '../src/state/review_refresh_notifier.dart';

class ItemReviewController extends GetxController {
  ItemReviewController(this._commentRepository);

  final CommentRepository _commentRepository;

  final comments = <ApiItemComment>[].obs;
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

  ApiItemComment? userReview(String username) {
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
      AppSnackBar.show(
        context,
        message: context.l10n.itemReviewLoginRequired,
        type: AppSnackBarType.error,
      );
      return;
    }

    if (userReview(normalizedUsername) != null) {
      AppSnackBar.show(
        context,
        message: context.l10n.itemReviewAlreadyRated,
        type: AppSnackBarType.warning,
      );
      return;
    }

    if (rating < 1 || rating > 5) {
      AppSnackBar.show(
        context,
        message: context.l10n.itemReviewRatingRequired,
        type: AppSnackBarType.warning,
      );
      return;
    }

    if (normalizedComment.isEmpty) {
      AppSnackBar.show(
        context,
        message: context.l10n.itemReviewCommentRequired,
        type: AppSnackBarType.warning,
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
      AppSnackBar.show(
        context,
        message: context.l10n.itemReviewSubmittedSuccess,
        type: AppSnackBarType.success,
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      AppSnackBar.show(
        context,
        message: _resolveErrorMessage(error).isEmpty
            ? context.l10n.itemReviewLoadFailed
            : _resolveErrorMessage(error),
        type: AppSnackBarType.error,
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
