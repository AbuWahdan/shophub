import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/empty_state_widget.dart';
import '../l10n/l10n.dart';
import '../state/auth_state.dart';
import '../state/wishlist_state.dart';
import '../themes/theme.dart';
import '../widgets/product_card.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthState>();
    final wishlistState = context.watch<WishlistState>();
    final isLoggedIn = authState.isLoggedIn && authState.user != null;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.accountWishlist)),
      body: !isLoggedIn
          ? const Center(child: Text('Please log in to manage your wishlist'))
          : _WishlistBody(wishlistState: wishlistState),
    );
  }
}

class _WishlistBody extends StatelessWidget {
  const _WishlistBody({required this.wishlistState});

  final WishlistState wishlistState;

  Future<void> _refresh() async {
    try {
      await wishlistState.refresh();
    } catch (_) {
      // The screen renders the provider error state.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!wishlistState.hasLoadedForUser && !wishlistState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (wishlistState.isLoading && !wishlistState.hasLoadedForUser) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    final errorMessage = wishlistState.errorMessage?.trim() ?? '';
    if (errorMessage.isNotEmpty && wishlistState.items.isEmpty) {
      return Center(
        child: Padding(
          padding: AppTheme.padding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: AppSpacing.iconXl,
                color: AppColors.error,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(errorMessage, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton.icon(
                onPressed: _refresh,
                icon: const Icon(Icons.refresh),
                label: Text(context.l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (wishlistState.items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(
              height: 520,
              child: EmptyStateWidget(
                icon: Icons.favorite_border,
                title: 'No saved items',
                subtitle: 'Tap the heart icon on a product to save it here',
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: AppTheme.padding,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          mainAxisSpacing: AppSpacing.lg,
          crossAxisSpacing: AppSpacing.lg,
        ),
        itemCount: wishlistState.items.length,
        itemBuilder: (context, index) {
          return ProductCard(product: wishlistState.items[index]);
        },
      ),
    );
  }
}
