import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../design/app_colors.dart';
import '../design/app_spacing.dart';
import '../design/app_text_styles.dart';
import '../l10n/l10n.dart';
import '../model/product_api.dart';
import '../services/product_service.dart';
import '../shared/widgets/app_snackbar.dart';
import '../state/auth_state.dart';
import '../themes/theme.dart';
import '../widgets/product_card.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final ProductService _productService = ProductService();
  List<ApiProduct> _favorites = [];
  bool _isLoading = false;
  int? _togglingItemId;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final auth = context.read<AuthState>();
    final username = auth.user?.username.trim() ?? '';

    if (username.isEmpty) {
      if (mounted) {
        setState(() {
          _favorites = [];
          _isLoading = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final favorites =
          await _productService.getUserFavorites(username: username);
      if (mounted) {
        setState(() {
          _favorites = favorites;
          _isLoading = false;
        });
      }
    } on ProductException catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppSnackBar.show(
        context,
        message: error.message,
        type: AppSnackBarType.error,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppSnackBar.show(
        context,
        message: 'Failed to load favorites',
        type: AppSnackBarType.error,
      );
    }
  }

  Future<void> _handleToggleFavorite(ApiProduct product) async {
    final auth = context.read<AuthState>();
    final username = auth.user?.username.trim() ?? '';

    if (username.isEmpty) return;

    setState(() => _togglingItemId = product.id);

    try {
      await _productService.toggleFavorite(
        itemId: product.id,
        username: username,
      );

      if (!mounted) return;

      // Remove from the favorites list
      setState(() {
        _favorites.removeWhere((item) => item.id == product.id);
        _togglingItemId = null;
      });

      AppSnackBar.show(
        context,
        message: 'Removed from favorites',
        type: AppSnackBarType.success,
      );
    } on ProductException catch (error) {
      if (!mounted) return;
      setState(() => _togglingItemId = null);
      AppSnackBar.show(
        context,
        message: error.message,
        type: AppSnackBarType.error,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _togglingItemId = null);
      AppSnackBar.show(
        context,
        message: 'Failed to update favorite',
        type: AppSnackBarType.error,
      );
    }
  }

  Future<void> _onRefresh() async {
    await _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'No favorites yet',
                        style: AppTextStyles.titleLarge
                            .copyWith(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Start adding your favorite products',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: Colors.grey.shade500),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: GridView.builder(
                    padding: AppTheme.padding,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      mainAxisSpacing: AppSpacing.lg,
                      crossAxisSpacing: AppSpacing.lg,
                    ),
                    itemCount: _favorites.length,
                    itemBuilder: (context, index) {
                      final product = _favorites[index];
                      final isToggling = _togglingItemId == product.id;

                      return Stack(
                        children: [
                          ProductCard(
                            product: product,
                            onSelected: (_) => setState(() {}),
                          ),
                          // Favorite heart button
                          Positioned(
                            top: AppSpacing.sm,
                            right: AppSpacing.sm,
                            child: GestureDetector(
                              onTap: isToggling
                                  ? null
                                  : () => _handleToggleFavorite(product),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(25),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(8),
                                child: isToggling
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.favorite,
                                        color: AppColors.error,
                                        size: 20,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
    );
  }
}

