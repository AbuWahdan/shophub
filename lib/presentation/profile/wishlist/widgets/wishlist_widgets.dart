// presentation/wishlist/wishlist_widgets.dart
//
// All sub-widgets used by WishlistPage.
// Each widget has a single responsibility and receives only what it needs.
// • No hardcoded strings  — all text from AppLocalizations.
// • No hardcoded sizes    — all dimensions from AppSpacing.
// • No hardcoded colors   — all colors from AppColors / Theme.
// • Responsive            — adapts to any screen size, never overflows.
// • Pull-to-refresh       — present on every state, including empty and error.
// • No direct repo calls  — everything goes through FavoritesController.

import 'package:flutter/material.dart';

import '../../../../controllers/wishlist_controller.dart';
import '../../../../design/app_colors.dart';
import '../../../../design/app_spacing.dart';
import '../../../../design/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/product/product_model.dart';
import '../../../../widgets/custom_empty_state/custom_empty_state.dart';
import '../../orders/widgets/add_to_cart_action.dart';
import '../../../../widgets/product_card/product_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Not-logged-in placeholder
// ─────────────────────────────────────────────────────────────────────────────

class WishlistNotLoggedIn extends StatelessWidget {
  const WishlistNotLoggedIn({super.key, required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            child: Center(
              child: Padding(
                padding: AppSpacing.insetsMd,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: AppSpacing.xl,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.wishlistLoginRequired,
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Body — routes to the correct state widget
// ─────────────────────────────────────────────────────────────────────────────

class WishlistBody extends StatelessWidget {
  const WishlistBody({super.key, required this.controller});

  final WishlistController controller;

  Future<void> _refresh() async {
    try {
      await controller.refresh();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    // Show loader while the first fetch is in progress.
    if (!controller.hasLoadedForCurrentUser || controller.isLoading) {
      return WishlistLoader(onRefresh: _refresh);
    }

    final errorMessage = controller.errorMessage?.trim() ?? '';

    // Show error only when there are no cached items to fall back on.
    if (errorMessage.isNotEmpty && controller.isEmpty) {
      return WishlistError(message: errorMessage, onRetry: _refresh);
    }

    // Empty state — still allows pull-to-refresh.
    if (controller.isEmpty) {
      return WishlistEmpty(onRefresh: _refresh);
    }

    return WishlistGrid(items: controller.items, onRefresh: _refresh);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading indicator
// ─────────────────────────────────────────────────────────────────────────────

class WishlistLoader extends StatelessWidget {
  const WishlistLoader({super.key, required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: const CustomScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error state — with pull-to-refresh so the user is never stuck
// ─────────────────────────────────────────────────────────────────────────────

class WishlistError extends StatelessWidget {
  const WishlistError({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return RefreshIndicator(
      onRefresh: onRetry,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Center(
              child: Padding(
                padding: AppSpacing.insetsMd,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: AppSpacing.xl,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      message,
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    FilledButton.icon(
                      onPressed: () => onRetry(),
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(l10n.retry),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.secondary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                          vertical: AppSpacing.sm,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state — with pull-to-refresh
// ─────────────────────────────────────────────────────────────────────────────

class WishlistEmpty extends StatelessWidget {
  const WishlistEmpty({super.key, required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: CustomEmptyState(
              icon: Icons.favorite_border_rounded,
              title: l10n.wishlistEmptyTitle,
              subtitle: l10n.wishlistEmptySubtitle,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Product grid — with pull-to-refresh
// ─────────────────────────────────────────────────────────────────────────────

class WishlistGrid extends StatelessWidget {
  const WishlistGrid({super.key, required this.items, required this.onRefresh});

  final List<ProductModel> items;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive column count: 1 column on very narrow screens,
          // 2 on normal phones, 3 on tablets/wide layouts.
          final crossAxisCount = _crossAxisCount(constraints.maxWidth);
          final childAspectRatio = _childAspectRatio(constraints.maxWidth);

          return GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: AppSpacing.insetsMd,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
            ),
            itemCount: items.length,
            // Each cell gets its own BuildContext so showModalBottomSheet
            // always has a valid Scaffold ancestor.
            itemBuilder: (itemContext, index) {
              final product = items[index];
              return ProductCard(
                product: product,
                onCartTap: () => AddToCartAction.execute(
                  context: context, // use WishlistGrid's stable BuildContext
                  product: product,
                ),
              );
            },
          );
        },
      ),
    );
  }

  int _crossAxisCount(double width) {
    if (width < 360) return 1;
    if (width < 720) return 2;
    return 3;
  }

  double _childAspectRatio(double width) {
    if (width < 360) return 1.1;
    if (width < 720) return 0.82;
    return 0.78;
  }
}
