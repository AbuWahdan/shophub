import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/route.dart';
import '../design/app_colors.dart';
import '../design/app_spacing.dart';
import '../design/app_text_styles.dart';
import '../l10n/l10n.dart';
import '../model/product_api.dart';
import 'products/edit_product_page.dart';
import '../services/product_service.dart';
import '../shared/widgets/empty_state.dart';
import '../state/auth_state.dart';
import '../themes/theme.dart';

class MyProductsPage extends StatefulWidget {
  const MyProductsPage({super.key});

  @override
  State<MyProductsPage> createState() => _MyProductsPageState();
}

class _MyProductsPageState extends State<MyProductsPage> {
  final ProductService _productService = ProductService();
  bool _isLoading = false;
  int? _loadingDetailsItemId;
  List<ApiProduct> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts({bool forceRefresh = false}) async {
    final auth = context.read<AuthState>();
    final username = auth.user?.username.trim();
    final userId = auth.user?.userId ?? auth.userId;

    if ((username == null || username.isEmpty) && userId <= 0) {
      if (mounted) setState(() => _products = []);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final products = await _productService.getMyProducts(
        currentUserId: userId,
        currentUsername: username ?? '',
        forceRefresh: forceRefresh,
      );
      if (!mounted) return;
      setState(() {
        // ── Show ALL products (active + inactive). ────────────────────────
        // Inactive ones get a visual badge in _MyProductCard.
        _products = products;
      });
    } on ProductException catch (error) {
      if (!mounted) return;
      setState(() => _products = []);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.productsLoadFailed(error.message))),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _products = []);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.productsLoadFailedGeneric)),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openEditProduct(ApiProduct product) async {
    setState(() => _loadingDetailsItemId = product.id);

    try {
      final detailsRows =
      await _productService.getItemDetailsRows(itemId: product.id);

      if (detailsRows.isEmpty) {
        throw ProductException('No item details found for this product.');
      }

      final details = detailsRows.first;
      var itemImages = <ApiItemImage>[];
      try {
        itemImages =
        await _productService.getItemImages(itemId: product.id);
      } catch (_) {
        // Keep opening even if images fail.
      }

      if (!mounted) return;

      // ── FIX: pass the actual username, not AutofillHints.username ────────
      final auth = context.read<AuthState>();
      final currentUser = auth.user?.username.trim() ?? '';

      final updated = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => EditProductPage(
            product: product,
            details: details,
            detailsRows: detailsRows,
            itemImages: itemImages,
            currentUser: currentUser, // ← was AutofillHints.username (wrong!)
          ),
        ),
      );

      if (updated == true && context.mounted) {
        _loadProducts(forceRefresh: true);
      }
    } on ProductException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.productsLoadFailed(error.message))),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.productsLoadFailedGeneric)),
      );
    } finally {
      if (mounted) setState(() => _loadingDetailsItemId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final auth = context.watch<AuthState>();
    final isLoggedIn = auth.isLoggedIn && auth.user != null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountMyProducts)),
      body: !isLoggedIn
          ? Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
          child: Text(l10n.loginSignIn),
        ),
      )
          : _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      )
          : RefreshIndicator(
        onRefresh: () => _loadProducts(forceRefresh: true),
        child: _products.isEmpty
            ? ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height:
              MediaQuery.of(context).size.height * 0.65,
              child: EmptyState(
                icon: Icons.inventory_2_outlined,
                title: l10n.accountMyProducts,
                message: l10n.myProductsEmptyMessage,
              ),
            ),
          ],
        )
            : GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: AppTheme.padding,
          gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.72,
            mainAxisSpacing: AppSpacing.lg,
            crossAxisSpacing: AppSpacing.lg,
          ),
          itemCount: _products.length,
          itemBuilder: (context, index) {
            return _MyProductCard(
              product: _products[index],
              isLoading:
              _loadingDetailsItemId == _products[index].id,
              onTap: () => _openEditProduct(_products[index]),
            );
          },
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// _MyProductCard
// ══════════════════════════════════════════════════════════════════════════════
class _MyProductCard extends StatelessWidget {
  const _MyProductCard({
    required this.product,
    required this.onTap,
    required this.isLoading,
  });

  final ApiProduct product;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final inStock = product.itemQty > 0;
    final isInactive = product.isActive != 1;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        // Muted border for inactive products
        side: isInactive
            ? BorderSide(
          color: Theme.of(context).colorScheme.error.withOpacity(0.4),
          width: 1.5,
        )
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        onTap: isLoading ? null : onTap,
        child: Padding(
          padding: AppSpacing.insetsSm,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image with inactive overlay ─────────────────────────────
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius:
                      BorderRadius.circular(AppSpacing.radiusMd),
                      child: ColorFiltered(
                        // Desaturate the image for inactive products
                        colorFilter: isInactive
                            ? const ColorFilter.matrix(<double>[
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0,      0,      0,      1, 0,
                        ])
                            : const ColorFilter.mode(
                          Colors.transparent,
                          BlendMode.multiply,
                        ),
                        child: Image.network(
                          product.itemImgUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) => Container(
                            color: Theme.of(context).colorScheme.surface,
                            alignment: Alignment.center,
                            child: const Icon(Icons.image_outlined),
                          ),
                        ),
                      ),
                    ),

                    // "Inactive" badge — top-left corner
                    if (isInactive)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Inactive',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                    // Loading spinner overlay
                    if (isLoading)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                        alignment: Alignment.center,
                        child: const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // ── Product name ──────────────────────────────────────────
              Text(
                product.itemName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(
                  // Muted text for inactive
                  color: isInactive
                      ? Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.5)
                      : null,
                ),
              ),

              const SizedBox(height: AppSpacing.xs),

              // ── Price ─────────────────────────────────────────────────
              Text(
                '\$${product.itemPrice.toStringAsFixed(2)}',
                style: AppTextStyles.labelLarge.copyWith(
                  color: isInactive
                      ? Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.4)
                      : null,
                ),
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: AppSpacing.xs),

              // ── Stock / loading indicator ─────────────────────────────
              if (isLoading)
                const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Text(
                  inStock
                      ? context.l10n.stockIn
                      : context.l10n.stockOut,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isInactive
                        ? Theme.of(context)
                        .colorScheme
                        .error
                        .withOpacity(0.7)
                        : inStock
                        ? AppColors.success
                        : AppColors.error,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }
}