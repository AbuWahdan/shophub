import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/state/auth_state.dart';
import '../../../widgets/product_card/add_to_cart_bottom_sheet/widgets/add_to_cart_action.dart';
import '../../../widgets/product_card/product_card.dart';
import 'wishlist_state.dart';
import '../../../design/app_colors.dart';
import '../../../design/app_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/product_model.dart';
import '../../../widgets/custom_empty_state/custom_empty_state.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOnInit());
  }

  Future<void> _loadOnInit() async {
    final authState = context.read<AuthState>();
    await authState.ensureInitialized();
    if (!mounted || !authState.isLoggedIn || authState.user == null) return;

    final wishlistState = context.read<WishlistState>();
    if (wishlistState.hasLoadedForUser) return;

    try {
      await wishlistState.fetchWishlist();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final authState     = context.watch<AuthState>();
    final wishlistState = context.watch<WishlistState>();
    final isLoggedIn    = authState.isLoggedIn && authState.user != null;
    final l10n          = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountWishlist)),
      body: isLoggedIn
          ? _WishlistBody(wishlistState: wishlistState)
          : const _NotLoggedInPlaceholder(),
    );
  }
}

// ── Private sub-widgets ────────────────────────────────────────────────────────

class _NotLoggedInPlaceholder extends StatelessWidget {
  const _NotLoggedInPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Please log in to manage your wishlist'),
    );
  }
}

class _WishlistBody extends StatelessWidget {
  const _WishlistBody({required this.wishlistState});

  final WishlistState wishlistState;

  Future<void> _refresh() async {
    try {
      await wishlistState.fetchWishlist();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (!wishlistState.hasLoadedForUser || wishlistState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    final errorMessage = wishlistState.errorMessage?.trim() ?? '';
    if (errorMessage.isNotEmpty && wishlistState.items.isEmpty) {
      return _ErrorView(message: errorMessage, onRetry: _refresh);
    }

    if (wishlistState.items.isEmpty) {
      return _EmptyWishlistView(onRefresh: _refresh);
    }

    return _WishlistGrid(
      items:     wishlistState.items,
      onRefresh: _refresh,
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.insetsMd,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: AppSpacing.iconLg,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon:  const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context).retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyWishlistView extends StatelessWidget {
  const _EmptyWishlistView({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(
            height: 520,
            child: CustomEmptyState(
              icon:     Icons.favorite_border,
              title:    'No saved items',
              subtitle: 'Tap the heart icon on a product to save it here',
            ),
          ),
        ],
      ),
    );
  }
}

class _WishlistGrid extends StatelessWidget {
  const _WishlistGrid({
    required this.items,
    required this.onRefresh,
  });

  final List<ProductModel> items;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: AppSpacing.insetsMd,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:   2,
          childAspectRatio: 0.82,
          mainAxisSpacing:  AppSpacing.lg,
          crossAxisSpacing: AppSpacing.lg,
        ),
        itemCount: items.length,
        // itemBuilder provides a fresh BuildContext on every cell — use it
        // directly so showModalBottomSheet always has a valid scaffold ancestor.
        itemBuilder: (itemContext, index) {
          final product = items[index];
          return ProductCard(
            product:   product,
            onCartTap: () => AddToCartAction.execute(
              context: itemContext,
              product: product,
            ),
          );
        },
      ),
    );
  }
}