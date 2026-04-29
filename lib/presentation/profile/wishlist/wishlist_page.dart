import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../controllers/cart_controller.dart';
import '../../../core/state/wishlist_state.dart';
import '../../../design/app_colors.dart';
import '../../../design/app_spacing.dart';
import '../../../services/product_service.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../l10n/l10n.dart';
import '../../../models/data.dart';
import '../../../models/product_api.dart';
import '../../../core/app/app_theme.dart';
import '../../../widgets/product_card.dart';
import '../../../widgets/widgets/add_to_cart_bottom_sheet.dart';
import '../../../widgets/widgets/app_snackbar.dart';
import '../../../core/state/auth_state.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchWishlistOnLoad();
    });
  }

  Future<void> _fetchWishlistOnLoad() async {
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
    final authState    = context.watch<AuthState>();
    final wishlistState = context.watch<WishlistState>();
    final isLoggedIn   = authState.isLoggedIn && authState.user != null;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.accountWishlist)),
      body: !isLoggedIn
          ? const Center(
          child: Text('Please log in to manage your wishlist'))
          : _WishlistBody(wishlistState: wishlistState),
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

  // FIX: Open the AddToCartBottomSheet and then use CartController to add
  // the item — exactly the same path as the home tab ProductCard.
  Future<void> _openAddToCartSheet(
      BuildContext context, ApiProduct product) async {
    final authState = context.read<AuthState>();
    await authState.ensureInitialized();
    if (!context.mounted) return;

    final username = authState.user?.username.trim() ?? '';
    if (username.isEmpty) {
      AppSnackBar.show(
        context,
        message: 'Please log in to add items to your cart',
        type: AppSnackBarType.error,
      );
      return;
    }

    // Show the same bottom drawer used everywhere else.
    final selection = await showModalBottomSheet<AddToCartSelection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddToCartBottomSheet(
        product:      product,
        initialDetId: product.detId,
      ),
    );

    if (!context.mounted || selection == null) return;

    final variant   = selection.variant;
    final itemDetId = variant.detId > 0
        ? variant.detId
        : product.resolveDetId(
      size:     variant.itemSize,
      color:    variant.color,
      fallback: product.detId,
    );

    if (itemDetId <= 0) {
      AppSnackBar.show(
        context,
        message: 'Unable to determine product variant.',
        type: AppSnackBarType.error,
      );
      return;
    }

    try {
      final cartController = Get.find<CartController>();
      await cartController.addItem(
        itemId:    product.id,
        itemDetId: itemDetId,
        username:  username,
        chosenQty: selection.qty,
      );

      if (!context.mounted) return;

      // Keep AppData cache in sync.
      AppData.addToCart(
        product:  product,
        quantity: selection.qty,
        size:  variant.itemSize.trim().isEmpty ? 'Default' : variant.itemSize,
        color: variant.color.trim().isEmpty    ? 'Default' : variant.color,
        detId: itemDetId,
      );

      AppSnackBar.show(
        context,
        message: '${product.name} added to cart',
        type: AppSnackBarType.success,
      );
    } on ProductException catch (e) {
      if (!context.mounted) return;
      AppSnackBar.show(context, message: e.message,
          type: AppSnackBarType.error);
    } catch (_) {
      if (!context.mounted) return;
      AppSnackBar.show(
        context,
        message: 'Failed to add to cart',
        type: AppSnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!wishlistState.hasLoadedForUser && !wishlistState.isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (wishlistState.isLoading && !wishlistState.hasLoadedForUser) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    final errorMessage = wishlistState.errorMessage?.trim() ?? '';
    if (errorMessage.isNotEmpty && wishlistState.items.isEmpty) {
      return Center(
        child: Padding(
          padding: AppSpacing.insetsMd,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: AppSpacing.iconLg, color: AppColors.error),
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
                subtitle:
                'Tap the heart icon on a product to save it here',
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
        padding: AppSpacing.insetsMd,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.82,
          mainAxisSpacing: AppSpacing.lg,
          crossAxisSpacing: AppSpacing.lg,
        ),
        itemCount: wishlistState.items.length,
        itemBuilder: (context, index) {
          final product = wishlistState.items[index];
          // FIX: Pass onCartTap so the card's cart button opens the
          // bottom drawer via our _openAddToCartSheet instead of the
          // card's own logic (which would use a different context/flow).
          return ProductCard(
            product:    product,
            onCartTap: () => _openAddToCartSheet(context, product),
          );
        },
      ),
    );
  }
}