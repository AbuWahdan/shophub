import 'package:flutter/material.dart';

import '../../../../design/app_colors.dart';
import '../../../../design/app_spacing.dart';
import '../../../../design/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/item_comment_model.dart';
import '../../../../models/product/product_model.dart';

class ProductDetailsReviewsSection extends StatelessWidget {
  final ProductModel product;
  final List<ItemCommentModel>? comments;
  final bool isLoading;
  final String? error;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;
  final VoidCallback onRetry;

  const ProductDetailsReviewsSection({
    super.key,
    required this.product,
    required this.comments,
    required this.isLoading,
    required this.error,
    required this.isExpanded,
    required this.onToggleExpanded,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ReviewsHeader(
          product: product,
          isExpanded: isExpanded,
          onToggle: onToggleExpanded,
        ),
        if (isExpanded) ...[
          const SizedBox(height: AppSpacing.md),
          _ReviewsBody(
            comments: comments,
            isLoading: isLoading,
            error: error,
            onRetry: onRetry,
          ),
        ],
      ],
    );
  }
}

class _ReviewsHeader extends StatelessWidget {
  final ProductModel product;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _ReviewsHeader({
    required this.product,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Flexible(child: Text(l10n.productReviews(product.reviewCount ?? 0), overflow: TextOverflow.ellipsis)),
          const SizedBox(width: AppSpacing.sm),
          _RatingChip(rating: product.rating, reviewCount: product.reviewCount),
          const Spacer(),
          Icon(
            isExpanded ? Icons.expand_less : Icons.expand_more,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _RatingChip extends StatelessWidget {
  final double? rating;
  final int? reviewCount;

  const _RatingChip({this.rating, this.reviewCount});

  @override
  Widget build(BuildContext context) {
    if (rating == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 14, color: AppColors.warning),
          const SizedBox(width: 2),
          Text(
            rating!.toStringAsFixed(1),
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.warning,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (reviewCount != null) ...[
            const SizedBox(width: 4),
            Text(
              '($reviewCount)',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReviewsBody extends StatelessWidget {
  final List<ItemCommentModel>? comments;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;

  const _ReviewsBody({
    required this.comments,
    required this.isLoading,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return _ErrorState(message: error!, onRetry: onRetry);
    }

    final list = comments ?? [];

    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Center(
          child: Text(
            l10n.productNoReviews,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) => _ReviewCard(comment: list[index]),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ItemCommentModel comment;

  const _ReviewCard({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.insetsSm,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowPrimary.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ReviewerAvatar(name: comment.username),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.username,
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (comment.createdAt != null)
                      Text(
                        comment.hasCreatedAt.toString(),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              _StarRow(rating: comment.rating),
            ],
          ),
          if (comment.comment.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              comment.comment,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReviewerAvatar extends StatelessWidget {
  final String name;

  const _ReviewerAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final initial =
    name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

    return CircleAvatar(
      radius: 18,
      backgroundColor: AppColors.primary.withOpacity(0.15),
      child: Text(
        initial,
        style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  final int? rating;

  const _StarRow({this.rating});

  @override
  Widget build(BuildContext context) {
    final filled = (rating ?? 0).clamp(0, 5);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
            (i) => Icon(
          i < filled ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 14,
          color: AppColors.warning,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 36),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.actionRetry),
          ),
        ],
      ),
    );
  }
}