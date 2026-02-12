import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../config/ui_text.dart';
import '../design/app_colors.dart';
import '../design/app_spacing.dart';
import '../design/app_text_styles.dart';
import '../model/data.dart';
import '../model/product_comment.dart';
import '../shared/widgets/app_image.dart';
import '../shared/widgets/empty_state.dart';
import '../themes/theme.dart';

class ProductCommentsPage extends StatelessWidget {
  final int productId;
  final String productName;

  const ProductCommentsPage({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  Widget build(BuildContext context) {
    final comments = AppData.commentsForProduct(productId);
    return Scaffold(
      appBar: AppBar(
        title: Text('${UiText.commentsScreenTitlePrefix}$productName'),
      ),
      body: comments.isEmpty
          ? const EmptyState(
              icon: Icons.comment_outlined,
              title: UiText.commentsScreenEmptyTitle,
              message: UiText.commentsScreenEmptyMessage,
            )
          : ListView.separated(
              padding: AppTheme.padding,
              itemBuilder: (context, index) {
                final comment = comments[index];
                return _CommentCard(comment: comment);
              },
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.lg),
              itemCount: comments.length,
            ),
    );
  }
}

class _CommentCard extends StatelessWidget {
  final ProductComment comment;

  const _CommentCard({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.insetsMd,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  comment.userName,
                  style: AppTextStyles.titleSmall(context),
                ),
              ),
              Text(
                DateFormat.yMMMd().format(comment.date),
                style: AppTextStyles.bodySmall(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < comment.rating.round() ? Icons.star : Icons.star_border,
                size: AppSpacing.iconSm,
                color: AppColors.accentYellow,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(comment.comment, style: AppTextStyles.bodyMedium(context)),
          if (comment.imageUrls.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: AppSpacing.imageSm,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    child: AppImage(
                      path: comment.imageUrls[index],
                      width: AppSpacing.imageSm,
                      height: AppSpacing.imageSm,
                      fit: BoxFit.cover,
                    ),
                  );
                },
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.sm),
                itemCount: comment.imageUrls.length,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
