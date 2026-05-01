import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../controllers/my_products_controller.dart';
import '../../../../models/product_image_model.dart';
import '../../../../models/product_model.dart';
import '../../../core/config/route.dart';
import '../../../design/app_colors.dart';
import '../../../design/app_radius.dart';
import '../../../design/app_spacing.dart';
import '../../../design/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/state/auth_state.dart';
import '../../../services/product_service.dart';
import '../../../widgets/widgets/empty_state.dart';
import 'edit_product_page.dart';
import 'insert_product_page.dart';

/// Single entry-point for all seller product management.
/// A FAB opens the [InsertProductPage] as a full-screen modal route.
class MyProductsPage extends StatefulWidget {
  const MyProductsPage({super.key});

  @override
  State<MyProductsPage> createState() => _MyProductsPageState();
}

class _MyProductsPageState extends State<MyProductsPage> {
  bool _isNavigating = false;

  // ── Auth + Controller setup ───────────────────────────────────────────────

  void _configureController(AuthState auth) {
    final ctrl = Get.find<MyProductsController>();
    final isLoggedIn = auth.isLoggedIn && auth.user != null;

    if (isLoggedIn) {
      ctrl.username = auth.user!.username.trim();
      ctrl.userId = auth.user!.userId;
    } else {
      ctrl.username = '';
      ctrl.userId = 0;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isLoggedIn && ctrl.products.isEmpty && !ctrl.isLoading.value) {
        ctrl.loadProducts();
      }
    });
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  Future<void> _openInsertProduct(String currentUsername) async {
    if (_isNavigating) return;
    _isNavigating = true;

    try {
      final updated = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => InsertProductPage(currentUser: currentUsername),
        ),
      );
      if (updated == true && mounted) {
        Get.find<MyProductsController>().loadProducts(forceRefresh: true);
      }
    } finally {
      if (mounted) setState(() => _isNavigating = false);
    }
  }

  Future<void> _openEditProduct(
      ProductModel product,
      String currentUsername,
      ) async {
    if (_isNavigating) return;
    _isNavigating = true;

    final productService = ProductService();

    try {
      final detailsRows = await productService.getItemDetailsRows(
        itemId: product.id,
      );

      if (detailsRows.isEmpty) {
        throw Exception('No item details found for this product.');
      }

      var itemImages = <ProductImageModel>[];
      try {
        itemImages = await productService.getItemImagesBase64(
          itemId: product.id,
        );
      } catch (_) {
        // Continue even if image fetch fails.
      }

      if (!mounted) return;

      final updated = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => EditProductPage(
            product: product,
            details: detailsRows.first,
            detailsRows: detailsRows,
            itemImages: itemImages,
            currentUser: currentUsername,
          ),
        ),
      );

      if (updated == true && mounted) {
        Get.find<MyProductsController>().loadProducts(forceRefresh: true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isNavigating = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthState>();
    final l10n = AppLocalizations.of(context);
    final isLoggedIn = auth.isLoggedIn && auth.user != null;

    _configureController(auth);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountMyProducts)),
      floatingActionButton: isLoggedIn
          ? FloatingActionButton.extended(
        onPressed: _isNavigating
            ? null
            : () => _openInsertProduct(auth.user!.username.trim()),
        icon: const Icon(Icons.add),
        label: Text(l10n.insertProductMenu),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      )
          : null,
      body: !isLoggedIn
          ? _NotLoggedInView(l10n: l10n)
          : Obx(() {
        final ctrl = Get.find<MyProductsController>();

        if (ctrl.error.isNotEmpty) {
          return _ErrorView(
            message: ctrl.error.value,
            onRetry: () => ctrl.loadProducts(forceRefresh: true),
          );
        }

        if (ctrl.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        return RefreshIndicator(
          onRefresh: () => ctrl.loadProducts(forceRefresh: true),
          child: ctrl.products.isEmpty
              ? _EmptyProductsView(l10n: l10n)
              : _ProductGrid(
            products: ctrl.products,
            onProductTap: (product) => _openEditProduct(
              product,
              ctrl.username,
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Extracted view sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _NotLoggedInView extends StatelessWidget {
  const _NotLoggedInView({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
        child: Text(l10n.loginSignIn),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRetry(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const SizedBox(height: AppSpacing.xl),
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Error Loading Products',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyProductsView extends StatelessWidget {
  const _EmptyProductsView({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return ListView(
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
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({
    required this.products,
    required this.onProductTap,
  });

  final List<ProductModel> products;
  final ValueChanged<ProductModel> onProductTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        // Extra bottom padding so FAB never covers last row.
        AppSpacing.md + 80,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        mainAxisSpacing: AppSpacing.lg,
        crossAxisSpacing: AppSpacing.lg,
      ),
      itemCount: products.length,
      itemBuilder: (_, index) => _ProductCard(
        product: products[index],
        onTap: () => onProductTap(products[index]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Product card
// ─────────────────────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.onTap});

  final ProductModel product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isInactive = product.isActive != 1;
    final inStock = product.itemQty > 0;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: isInactive
            ? BorderSide(
          color: Theme.of(context).colorScheme.error.withOpacity(0.4),
          width: 1.5,
        )
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.insetsSm,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ProductCardImage(
                  imageUrl: product.itemImgUrl,
                  isInactive: isInactive,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _ProductCardInfo(
                product: product,
                isInactive: isInactive,
                inStock: inStock,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductCardImage extends StatelessWidget {
  const _ProductCardImage({
    required this.imageUrl,
    required this.isInactive,
  });

  final String imageUrl;
  final bool isInactive;

  static const _grayscaleMatrix = <double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0,      0,      0,      1, 0,
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: ColorFiltered(
            colorFilter: isInactive
                ? const ColorFilter.matrix(_grayscaleMatrix)
                : const ColorFilter.mode(
              Colors.transparent,
              BlendMode.multiply,
            ),
            child: Image.network(
              imageUrl,
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
        if (isInactive)
          Positioned(
            top: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
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
    );
  }
}

class _ProductCardInfo extends StatelessWidget {
  const _ProductCardInfo({
    required this.product,
    required this.isInactive,
    required this.inStock,
  });

  final ProductModel product;
  final bool isInactive;
  final bool inStock;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mutedOpacity = isInactive ? 0.5 : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.itemName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodyMedium.copyWith(
            color: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.color
                ?.withOpacity(mutedOpacity),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '\$${product.itemPrice.toStringAsFixed(2)}',
          style: AppTextStyles.labelLarge.copyWith(
            color: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.color
                ?.withOpacity(isInactive ? 0.4 : 1.0),
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          inStock ? l10n.stockIn : l10n.stockOut,
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
    );
  }
}