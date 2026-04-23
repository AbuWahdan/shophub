import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controllers/item_review_controller.dart';
import '../../../data/repositories/comment_repository.dart';
import '../../../l10n/l10n.dart';
import '../../../models/api_item_comment.dart';
import '../../design/app_text_styles.dart';
import 'app_button.dart';

class ItemReviewSection extends StatefulWidget {
  const ItemReviewSection({
    required this.itemId,
    required this.currentUsername,
    super.key,
  });

  final int itemId;
  final String currentUsername;

  @override
  State<ItemReviewSection> createState() => _ItemReviewSectionState();
}

class _ItemReviewSectionState extends State<ItemReviewSection> {
  final _formKey = GlobalKey<FormState>();
  late final String _controllerTag;
  late final ItemReviewController _controller;

  @override
  void initState() {
    super.initState();
    _controllerTag = 'item-review-${widget.itemId}-${identityHashCode(this)}';
    Get.lazyPut<ItemReviewController>(
      () => ItemReviewController(Get.find<CommentRepository>()),
      tag: _controllerTag,
    );
    _controller = Get.find<ItemReviewController>(tag: _controllerTag);
    _controller.loadComments(widget.itemId);
  }

  @override
  void dispose() {
    if (Get.isRegistered<ItemReviewController>(tag: _controllerTag)) {
      Get.delete<ItemReviewController>(tag: _controllerTag);
    }
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    await _controller.submitReview(
      context: context,
      itemId: widget.itemId,
      username: widget.currentUsername,
      rating: _controller.selectedRating.value,
      comment: _controller.commentController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentUsername.trim().isEmpty) {
      return Text(
        context.l10n.itemReviewLoginRequired,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
      );
    }

    return Obx(() {
      final userReview = _controller.userReview(widget.currentUsername);
      final errorMessage = _controller.errorMessage.value;

      if (_controller.isLoading.value && _controller.comments.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (errorMessage != null && _controller.comments.isEmpty) {
        final resolvedErrorMessage = errorMessage.isNotEmpty
            ? errorMessage
            : context.l10n.itemReviewLoadFailed;
        return Container(
          width: double.infinity,
          padding: AppSpacing.insetsMd,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                resolvedErrorMessage,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () => _controller.loadComments(widget.itemId),
                child: Text(context.l10n.retry),
              ),
            ],
          ),
        );
      }

      if (userReview != null) {
        return _ReadOnlyReviewCard(review: userReview);
      }

      return Form(
        key: _formKey,
        child: Container(
          width: double.infinity,
          padding: AppSpacing.insetsMd,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppSpacing.xs,
                children: List.generate(5, (index) {
                  final starIndex = index + 1;
                  final isFilled =
                      starIndex <= _controller.selectedRating.value;
                  return InkWell(
                    onTap: _controller.isSubmitting.value
                        ? null
                        : () => _controller.selectedRating.value = starIndex,
                    child: Icon(
                      isFilled ? Icons.star : Icons.star_border,
                      color: isFilled ? AppColors.accentYellow : Colors.grey,
                      size: AppSpacing.iconLg,
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _controller.commentController,
                minLines: 2,
                maxLines: 4,
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return context.l10n.itemReviewCommentRequired;
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: context.l10n.itemReviewCommentLabel,
                  hintText: context.l10n.itemReviewCommentHint,
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: context.l10n.itemReviewSubmitButton,
                onPressed: _controller.isSubmitting.value
                    ? null
                    : _handleSubmit,
                leading: _controller.isSubmitting.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _ReadOnlyReviewCard extends StatelessWidget {
  const _ReadOnlyReviewCard({required this.review});

  final ApiItemComment review;

  @override
  Widget build(BuildContext context) {
    final formattedDate = review.hasCreatedAt
        ? DateFormat('MMMM d, y').format(review.createdAt.toLocal())
        : '';

    return Container(
      width: double.infinity,
      padding: AppSpacing.insetsMd,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.itemReviewYourReview,
            style: AppTextStyles.titleSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < review.rate ? Icons.star : Icons.star_border,
                color: index < review.rate
                    ? AppColors.accentYellow
                    : Colors.grey,
                size: AppSpacing.iconMd,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(review.commentText, style: AppTextStyles.bodyMedium),
          if (formattedDate.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(formattedDate, style: AppTextStyles.bodySmall),
          ],
        ],
      ),
    );
  }
}
