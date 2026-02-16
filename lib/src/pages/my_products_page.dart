import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/route.dart';
import '../design/app_colors.dart';
import '../design/app_spacing.dart';
import '../design/app_text_styles.dart';
import '../l10n/l10n.dart';
import '../model/product_api.dart';
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
      if (!mounted) return;
      setState(() {
        _products = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final products = await _productService.getMyProducts(
        currentUserId: userId,
        currentUsername: username ?? '',
        forceRefresh: forceRefresh,
      );
      if (!mounted) return;
      setState(() {
        _products = products.where((item) => item.isActive == 1).toList();
      });
    } on ProductException catch (error) {
      if (!mounted) return;
      setState(() {
        _products = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.productsLoadFailed(error.message))),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _products = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.productsLoadFailedGeneric)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.login);
                },
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
                          height: MediaQuery.of(context).size.height * 0.65,
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
                        return _MyProductCard(product: _products[index]);
                      },
                    ),
            ),
    );
  }
}

class _MyProductCard extends StatelessWidget {
  const _MyProductCard({required this.product});

  final ApiProduct product;

  @override
  Widget build(BuildContext context) {
    final inStock = product.itemQty > 0;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.productDetails,
            arguments: {'product': product},
          );
        },
        child: Padding(
          padding: AppSpacing.insetsSm,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  child: Image.network(
                    product.itemImgUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Theme.of(context).colorScheme.surface,
                        alignment: Alignment.center,
                        child: const Icon(Icons.image_outlined),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                product.itemName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium(context),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '\$${product.itemPrice.toStringAsFixed(2)}',
                style: AppTextStyles.labelLarge(context),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                inStock ? context.l10n.stockIn : context.l10n.stockOut,
                style: AppTextStyles.bodySmall(context).copyWith(
                  color: inStock ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
