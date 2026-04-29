import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/api_item_comment.dart';
import '../../design/app_colors.dart';
import '../../design/app_radius.dart';
import '../../design/app_spacing.dart';
import '../../design/app_text_styles.dart';
import 'rating_stars.dart';

class ProductCommentCard extends StatefulWidget {
  const ProductCommentCard({
    super.key,
    required this.comment,
    this.collapsedMaxLines = 3,
  });

  final ApiItemComment comment;
  final int collapsedMaxLines;

  @override
  State<ProductCommentCard> createState() => _ProductCommentCardState();
}

class _ProductCommentCardState extends State<ProductCommentCard> {
  bool _isExpanded = false;

  String get _initials {
    final parts = widget.comment.username
        .split(' ')
        .where((part) => part.trim().isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return '';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final commentText = widget.comment.comment.trim();
    final textStyle = AppTextStyles.bodyMedium;

    return Container(
      width: double.infinity,
      padding: AppSpacing.insetsLg,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: theme.dividerColor),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final painter = TextPainter(
            text: TextSpan(text: commentText, style: textStyle),
            maxLines: widget.collapsedMaxLines,
            textDirection: Directionality.of(context),
          )..layout(maxWidth: constraints.maxWidth);
          final hasOverflow = painter.didExceedMaxLines;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                    foregroundColor: AppColors.primary,
                    child: _initials.isEmpty
                        ? const Icon(Icons.person_outline)
                        : Text(_initials),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.comment.username.trim().isNotEmpty)
                          Text(
                            widget.comment.username,
                            style: AppTextStyles.titleSmall,
                          ),
                        const SizedBox(height: AppSpacing.xs),
                        RatingStars(
                          rating: widget.comment.rating.toDouble(),
                          size: AppSpacing.iconSm,
                        ),
                      ],
                    ),
                  ),
                  if (widget.comment.hasCreatedAt)
                    Text(
                      DateFormat.yMMMd().format(
                        widget.comment.createdAt.toLocal(),
                      ),
                      style: AppTextStyles.bodySmall,
                    ),
                ],
              ),
              if (commentText.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  commentText,
                  style: textStyle,
                  maxLines: _isExpanded ? null : widget.collapsedMaxLines,
                  overflow: _isExpanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                ),
                if (hasOverflow)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      child: Text(_isExpanded ? 'Show less' : 'Show more'),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}
