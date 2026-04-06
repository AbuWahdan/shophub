import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../core/widgets/empty_state_widget.dart';
import '../../data/repositories/comment_repository.dart';
import '../config/ui_text.dart';
import '../design/app_text_styles.dart';
import '../model/comment_model.dart';
import '../themes/theme.dart';

class ProductCommentsPage extends StatefulWidget {
  final int productId;
  final String productName;

  const ProductCommentsPage({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  State<ProductCommentsPage> createState() => _ProductCommentsPageState();
}

class _ProductCommentsPageState extends State<ProductCommentsPage> {
  late final CommentRepository _commentRepository;
  late Future<List<CommentModel>> _commentsFuture;

  @override
  void initState() {
    super.initState();
    _commentRepository = Get.find<CommentRepository>();
    _commentsFuture = _commentRepository.getItemComments(widget.productId);
  }

  Future<void> _reload() async {
    setState(() {
      _commentsFuture = _commentRepository.getItemComments(widget.productId);
    });
    await _commentsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${UiText.commentsScreenTitlePrefix}${widget.productName}'),
      ),
      body: FutureBuilder<List<CommentModel>>(
        future: _commentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: AppTheme.padding,
                child: EmptyStateWidget(
                  icon: Icons.error_outline,
                  title: 'Unable to load reviews',
                  subtitle: snapshot.error.toString(),
                  action: ElevatedButton.icon(
                    onPressed: _reload,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ),
              ),
            );
          }

          final comments = snapshot.data ?? const <CommentModel>[];
          if (comments.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.comment_outlined,
              title: UiText.commentsScreenEmptyTitle,
              subtitle: UiText.commentsScreenEmptyMessage,
            );
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              padding: AppTheme.padding,
              itemBuilder: (context, index) {
                final comment = comments[index];
                return _CommentCard(comment: comment);
              },
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
              itemCount: comments.length,
            ),
          );
        },
      ),
    );
  }
}

class _CommentCard extends StatelessWidget {
  final CommentModel comment;

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
                  comment.username.isEmpty ? 'Anonymous' : comment.username,
                  style: AppTextStyles.titleSmall,
                ),
              ),
              if (comment.createdAt != null)
                Text(
                  DateFormat.yMMMd().format(comment.createdAt!),
                  style: AppTextStyles.bodySmall,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < comment.rating ? Icons.star : Icons.star_border,
                size: AppSpacing.iconSm,
                color: AppColors.accentYellow,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(comment.commentText, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
