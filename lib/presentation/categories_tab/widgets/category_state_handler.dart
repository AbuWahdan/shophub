import 'package:flutter/material.dart';

import '../../../design/app_colors.dart';
import '../../../design/app_spacing.dart';
import '../../../design/app_text_styles.dart';

class CategoryStateHandler extends StatelessWidget {
  const CategoryStateHandler({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.hasSelectedCategory,
    required this.hasProducts,
    required this.selectCategoryMessage,
    required this.emptyMessage,
    required this.retryLabel,
    required this.onRetry,
    required this.child,
  });

  final bool isLoading;
  final String? errorMessage;
  final bool hasSelectedCategory;
  final bool hasProducts;
  final String selectCategoryMessage;
  final String emptyMessage;
  final String retryLabel;
  final VoidCallback onRetry;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    final error = errorMessage?.trim() ?? '';
    if (error.isNotEmpty) {
      return _MessageState(
        icon: Icons.error_outline,
        message: error,
        actionLabel: retryLabel,
        onAction: onRetry,
      );
    }

    if (!hasSelectedCategory) {
      return _MessageState(
        icon: Icons.touch_app_outlined,
        message: selectCategoryMessage,
      );
    }

    if (!hasProducts) {
      return _MessageState(
        icon: Icons.inventory_2_outlined,
        message: emptyMessage,
      );
    }

    return child;
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSpacing.xxxl, color: AppColors.textHint),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
