import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../../data/repositories/comment_repository.dart';
import '../../../../src/state/auth_state.dart';
import '../../../../src/state/review_refresh_notifier.dart';

class RateItemScreen extends StatefulWidget {
  const RateItemScreen({
    super.key,
    required this.itemId,
    required this.orderId,
    required this.itemName,
    required this.brand,
  });

  final int itemId;
  final int orderId;
  final String itemName;
  final String brand;

  @override
  State<RateItemScreen> createState() => _RateItemScreenState();
}

class _RateItemScreenState extends State<RateItemScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _commentController = TextEditingController();
  late final CommentRepository _commentRepository;

  int _selectedRating = 0;
  bool _isSubmitting = false;
  String? _ratingError;

  @override
  void initState() {
    super.initState();
    _commentRepository = Get.find<CommentRepository>();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedRating == 0) {
      setState(() => _ratingError = 'Please select a star rating');
      return;
    }

    setState(() => _ratingError = null);
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final auth = context.read<AuthState>();
    final username = auth.user?.username.trim() ?? '';
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please log in to submit a review'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _commentRepository.postComment(
        itemId: widget.itemId,
        username: username,
        rating: _selectedRating,
        comment: _commentController.text.trim(),
      );

      ReviewRefreshNotifier.notifyItemReviewed(widget.itemId);
      if (!mounted) return;

      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully!')),
      );
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      final message = error.toString().replaceFirst('Exception: ', '');
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('Rate: ${widget.itemName}')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.itemName, style: theme.textTheme.titleLarge),
                if (widget.brand.trim().isNotEmpty)
                  Text(widget.brand, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 24),
                Text('Your rating', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (index) {
                    final star = index + 1;
                    final isSelected = star <= _selectedRating;
                    return IconButton(
                      icon: Icon(
                        isSelected
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: isSelected
                            ? Colors.amber
                            : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                        size: 36,
                      ),
                      onPressed: () => setState(() => _selectedRating = star),
                    );
                  }),
                ),
                if (_ratingError != null)
                  Text(
                    _ratingError!,
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    labelText: 'Your review',
                    hintText: 'Tell others what you think...',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 5,
                  maxLength: 500,
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Please write a review';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Submit Review'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
