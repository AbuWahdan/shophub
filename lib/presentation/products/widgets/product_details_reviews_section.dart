import 'package:flutter/material.dart';
import 'package:sinwar_shoping/presentation/products/widgets/rating_stars.dart';

import '../../../core/config/route.dart';
import '../../../design/app_colors.dart';
import '../../../design/app_radius.dart';
import '../../../design/app_spacing.dart';
import '../../../design/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/item_comment_model.dart';
import '../../../models/product/product_model.dart';
import '../../../widgets/custom_empty_state/custom_empty_state.dart';
import '../comments/widgets/product_comment_card.dart';

class ProductDetailsReviewsSection extends StatelessWidget {
  final ProductModel product;
  final Future<List<ItemCommentModel>> commentsFuture;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;
  final VoidCallback onRetryComments;

  const ProductDetailsReviewsSection({
    super.key,
    required this.product,
    required this.commentsFuture,
    required this.isExpanded,
    required this.onToggleExpanded,
    required this.onRetryComments,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RatingRow(product: product),
        const SizedBox(height: AppSpacing.xxl),
        _DescriptionSection(
          description: product.description,
          isExpanded: isExpanded,
          onToggle: onToggleExpanded,
        ),
        const SizedBox(height: AppSpacing.xxl),
        _ReviewsList(
          product: product,
          commentsFuture: commentsFuture,
          onRetry: onRetryComments,
        ),
      ],
    );
  }
}

class _RatingRow extends StatelessWidget {
  final ProductModel product;

  const _RatingRow({required this.product});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        RatingStars(rating: product.rating, size: AppSpacing.iconSm),
        Text(product.rating.toStringAsFixed(1), style: AppTextStyles.labelLarge),
        Text(
          AppLocalizations.of(context).productReviews(product.reviewCount),
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }
}

class _DescriptionSection extends StatelessWidget {
  final String description;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _DescriptionSection({
    required this.description,
    required this.isExpanded,
    required this.onToggle,
  });

  static const int _previewLength = 100;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.productDescription,
                style: AppTextStyles.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(
              onPressed: onToggle,
              child: Text(isExpanded ? l10n.productShowLess : l10n.productShowMore),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        AnimatedCrossFade(
          firstChild: Text(
            description.length > _previewLength
                ? '${description.substring(0, _previewLength)}...'
                : description,
            style: AppTextStyles.bodySmall,
          ),
          secondChild: Text(description, style: AppTextStyles.bodySmall),
          crossFadeState:
          isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }
}

class _ReviewsList extends StatelessWidget {
  final ProductModel product;
  final Future<List<ItemCommentModel>> commentsFuture;
  final VoidCallback onRetry;

  const _ReviewsList({
    required this.product,
    required this.commentsFuture,
    required this.onRetry,
  });

  static const int _previewCount = 3;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ItemCommentModel>>(
      future: commentsFuture,
      builder: (context, snapshot) {
        final comments = snapshot.data ?? const <ItemCommentModel>[];
        final preview = comments.take(_previewCount).toList(growable: false);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ReviewsHeader(
              count: comments.length,
              canViewAll: comments.isNotEmpty,
              product: product,
              comments: comments,
            ),
            const SizedBox(height: AppSpacing.md),
            if (snapshot.connectionState == ConnectionState.waiting)
              const _ReviewsSkeletonLoader()
            else if (snapshot.hasError)
              _ReviewsError(
                error: snapshot.error.toString(),
                onRetry: onRetry,
              )
            else if (comments.isEmpty)
                const CustomEmptyState(
                  icon: Icons.rate_review_outlined,
                  title: 'No reviews yet',
                  subtitle: 'Be the first to share your experience.',
                )
              else
                Column(
                  children: preview
                      .map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: ProductCommentCard(comment: c),
                  ))
                      .toList(),
                ),
          ],
        );
      },
    );
  }
}

class _ReviewsHeader extends StatelessWidget {
  final int count;
  final bool canViewAll;
  final ProductModel product;
  final List<ItemCommentModel> comments;

  const _ReviewsHeader({
    required this.count,
    required this.canViewAll,
    required this.product,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text('Reviews ($count)', style: AppTextStyles.titleMedium),
        ),
        if (canViewAll)
          TextButton(
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.productComments,
              arguments: {
                'productId': product.id,
                'productName': product.name,
                'comments': comments,
              },
            ),
            child: Text(AppLocalizations.of(context).viewAll),
          ),
      ],
    );
  }
}

class _ReviewsSkeletonLoader extends StatelessWidget {
  const _ReviewsSkeletonLoader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
            (_) => Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: AppSpacing.insetsLg,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 120, height: 14, color: AppColors.surfaceVariant),
              const SizedBox(height: AppSpacing.sm),
              Container(width: 80, height: 12, color: AppColors.surfaceVariant),
              const SizedBox(height: AppSpacing.md),
              Container(width: double.infinity, height: 12, color: AppColors.surfaceVariant),
              const SizedBox(height: AppSpacing.xs),
              Container(
                width: MediaQuery.of(context).size.width * 0.5,
                height: 12,
                color: AppColors.surfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewsError extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ReviewsError({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(error, style: AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: onRetry,
          child: Text(AppLocalizations.of(context).retry),
        ),
      ],
    );
  }
}