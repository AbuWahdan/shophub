import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../../controllers/my_products_controller.dart';
import '../../../../models/product_image_model.dart';
import '../../../../models/product_api.dart';
import '../../../l10n/l10n.dart';
import '../../../src/config/route.dart';
import '../../../src/core/theme/app_theme.dart';
import '../../../src/services/product_service.dart';
import '../../../src/shared/widgets/empty_state.dart';
import '../../../src/state/auth_state.dart';
import 'edit_product_page.dart';

class MyProductsPage extends StatefulWidget {
  const MyProductsPage({super.key});

  @override
  State<MyProductsPage> createState() => _MyProductsPageState();
}

class _MyProductsPageState extends State<MyProductsPage> {
  bool _isOpeningProduct = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthState>(); // Get auth first
    final l10n = context.l10n;
    final isLoggedIn = auth.isLoggedIn && auth.user != null;

    // Initialize controller with user credentials EARLY
    final ctrl = Get.find<MyProductsController>();

    // ✅ FIX: Set credentials FIRST
    if (isLoggedIn) {
      ctrl.username = auth.user!.username.trim();
      ctrl.userId = auth.user!.userId;
      if (kDebugMode) {
        debugPrint(
          '[MyProductsPage] Initialized controller with username="${ctrl.username}", userId=${ctrl.userId}',
        );
      }
    } else {
      ctrl.username = '';
      ctrl.userId = 0;
      if (kDebugMode) {
        debugPrint('[MyProductsPage] User not logged in - cleared credentials');
      }
    }

    // ✅ FIX: Schedule load AFTER credentials are set
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isLoggedIn && ctrl.products.isEmpty && !ctrl.isLoading.value) {
        if (kDebugMode) {
          debugPrint(
            '[MyProductsPage] Post-frame callback: triggering loadProducts()',
          );
        }
        ctrl.loadProducts();
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountMyProducts)),
      body: !isLoggedIn
          ? Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                child: Text(l10n.loginSignIn),
              ),
            )
          : Obx(() {
              // ✅ FIX: Show error state first
              if (ctrl.error.isNotEmpty) {
                return RefreshIndicator(
                  onRefresh: () => ctrl.loadProducts(forceRefresh: true),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error Loading Products',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ctrl.error.value,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () =>
                                  ctrl.loadProducts(forceRefresh: true),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Show loading state
              if (ctrl.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              // Show empty state
              if (ctrl.products.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () => ctrl.loadProducts(forceRefresh: true),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.65,
                        child: EmptyState(
                          icon: Icons.inventory_2_outlined,
                          title: l10n.accountMyProducts,
                          message: l10n.myProductsEmptyMessage,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Show products grid
              return RefreshIndicator(
                onRefresh: () => ctrl.loadProducts(forceRefresh: true),
                child: GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: AppTheme.padding,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    mainAxisSpacing: AppSpacing.lg,
                    crossAxisSpacing: AppSpacing.lg,
                  ),
                  itemCount: ctrl.products.length,
                  itemBuilder: (context, index) {
                    return _MyProductCard(
                      product: ctrl.products[index],
                      onTap: () => _openEditProduct(
                        context,
                        ctrl.products[index],
                        ctrl.username,
                      ),
                    );
                  },
                ),
              );
            }),
    );
  }

  Future<void> _openEditProduct(
    BuildContext context,
    ApiProduct product,
    String currentUsername,
  ) async {
    if (_isOpeningProduct) return;
    _isOpeningProduct = true;

    final productService = ProductService();

    try {
      final detailsRows = await productService.getItemDetailsRows(
        itemId: product.id,
      );

      if (detailsRows.isEmpty) {
        throw Exception('No item details found for this product.');
      }

      final details = detailsRows.first;
      var itemImages = <ProductImageModel>[];
      try {
        itemImages = await productService.getItemImagesBase64(
          itemId: product.id,
        );
      } catch (_) {
        // Keep opening even if images fail.
      }

      if (!context.mounted) return;

      final updated = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => EditProductPage(
            product: product,
            details: details,
            detailsRows: detailsRows,
            itemImages: itemImages,
            currentUser: currentUsername,
          ),
        ),
      );

      if (updated == true && context.mounted) {
        Get.find<MyProductsController>().loadProducts(forceRefresh: true);
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() => _isOpeningProduct = false);
      }
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// _MyProductCard
// ══════════════════════════════════════════════════════════════════════════════
class _MyProductCard extends StatelessWidget {
  const _MyProductCard({required this.product, required this.onTap});

  final ApiProduct product;
  final VoidCallback onTap;

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
        onTap: onTap,
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
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      child: ColorFiltered(
                        // Desaturate the image for inactive products
                        colorFilter: isInactive
                            ? const ColorFilter.matrix(<double>[
                                0.2126,
                                0.7152,
                                0.0722,
                                0,
                                0,
                                0.2126,
                                0.7152,
                                0.0722,
                                0,
                                0,
                                0.2126,
                                0.7152,
                                0.0722,
                                0,
                                0,
                                0,
                                0,
                                0,
                                1,
                                0,
                              ])
                            : const ColorFilter.mode(
                                Colors.transparent,
                                BlendMode.multiply,
                              ),
                        child: Image.network(
                          product.itemImgUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, _, _) => Container(
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
                            horizontal: 6,
                            vertical: 3,
                          ),
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
                      ? Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withOpacity(0.5)
                      : null,
                ),
              ),

              const SizedBox(height: AppSpacing.xs),

              // ── Price ─────────────────────────────────────────────────
              Text(
                '\$${product.itemPrice.toStringAsFixed(2)}',
                style: AppTextStyles.labelLarge.copyWith(
                  color: isInactive
                      ? Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withOpacity(0.4)
                      : null,
                ),
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: AppSpacing.xs),

              // ── Stock indicator ─────────────────────────────────
              Text(
                inStock ? context.l10n.stockIn : context.l10n.stockOut,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isInactive
                      ? Theme.of(context).colorScheme.error.withOpacity(0.7)
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
