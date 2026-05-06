import 'package:flutter/material.dart';
import 'package:sinwar_shoping/presentation/products/comments/widgets/product_comment_card.dart';

import '../../../design/app_spacing.dart';
import '../../../design/app_text_styles.dart';
import '../../../models/item_comment_model.dart';
import '../../../widgets/custom_empty_state/custom_empty_state.dart';

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({
    super.key,
    required this.productId,
    required this.productName,
    required this.comments,
  });

  final int productId;
  final String productName;
  final List<ItemCommentModel> comments;

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  bool _isLoading = false;
  late List<ItemCommentModel> _comments;

  @override
  void initState() {
    super.initState();
    // Initialize with the comments passed from the previous screen
    _comments = List.from(widget.comments);

    // Only trigger a load if the list is currently empty
    if (_comments.isEmpty) {
      _loadComments();
    }
  }

  Future<void> _loadComments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      /// Simulation of API call
      await Future.delayed(const Duration(milliseconds: 800));

      // Note: If you want to actually fetch from an API,
      // replace the line below with your repository call:
      // _comments = await CommentRepository().getProductComments(widget.productId);

      // For now, we ensure we don't just set it to an empty list if
      // we already have data from the constructor.
      if (_comments.isEmpty) {
        _comments = [];
      }
    } catch (e) {
      debugPrint('Error loading comments: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productName),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_comments.isEmpty) {
      return const CustomEmptyState(
        icon: Icons.rate_review_outlined,
        title: 'No reviews yet',
        subtitle: 'Be the first to review this product.',
      );
    }

    return ListView.separated(
      padding: AppSpacing.insetsLg,
      itemCount: _comments.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        return ProductCommentCard(
          comment: _comments[index],
          collapsedMaxLines: 8,
        );
      },
    );
  }
}