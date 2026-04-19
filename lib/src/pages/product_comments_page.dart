import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/widgets/empty_state_widget.dart';
import '../../data/repositories/comment_repository.dart';
import '../config/ui_text.dart';
import '../model/api_item_comment.dart';
import '../shared/widgets/product_comment_card.dart';
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
  late Future<List<ApiItemComment>> _commentsFuture;

  @override
  void initState() {
    super.initState();
    _commentRepository = Get.find<CommentRepository>();
    _commentsFuture = _commentRepository.getItemComments(
      itemId: widget.productId,
    );
  }

  Future<void> _reload() async {
    setState(() {
      _commentsFuture = _commentRepository.getItemComments(
        itemId: widget.productId,
      );
    });
    await _commentsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${UiText.commentsScreenTitlePrefix}${widget.productName}'),
      ),
      body: FutureBuilder<List<ApiItemComment>>(
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

          final comments = snapshot.data ?? const <ApiItemComment>[];
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
                return ProductCommentCard(comment: comment);
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
