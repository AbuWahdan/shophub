import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../design/app_text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../repositories/product_repository.dart';
import '../../widgets/product_card/product_card.dart';
import '../../controllers/provider_products_controller.dart';

class ProviderProductsScreen extends StatefulWidget {
  const ProviderProductsScreen({
    super.key,
    required this.providerUsername,
  });

  final String providerUsername;

  @override
  State<ProviderProductsScreen> createState() => _ProviderProductsScreenState();
}

class _ProviderProductsScreenState extends State<ProviderProductsScreen> {
  late final ProviderProductsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(
      ProviderProductsController(
        Get.find<ProductRepository>(),
        widget.providerUsername,
      ),
      tag: widget.providerUsername,
    );
  }

  @override
  void dispose() {
    Get.delete<ProviderProductsController>(tag: widget.providerUsername);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.productsByProvider(widget.providerUsername),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        if (_controller.isLoading.value && _controller.products.isEmpty) {
          return Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          );
        }

        if (_controller.error.isNotEmpty && _controller.products.isEmpty) {
          return _StatusView(
            icon: Icons.error_outline,
            title: l10n.errorLoadingProducts,
            subtitle: _controller.error.value,
            buttonLabel: l10n.retry,
            onButtonTap: () => _controller.loadProducts(forceRefresh: true),
          );
        }

        return RefreshIndicator(
          onRefresh: () => _controller.loadProducts(forceRefresh: true),
          color: colorScheme.primary,
          child: _controller.products.isEmpty
              ? _StatusView(
            icon: Icons.inventory_2_outlined,
            title: l10n.noProductsFound,
            subtitle: l10n.pullToRefresh,
            buttonLabel: l10n.refresh,
            onButtonTap: () => _controller.loadProducts(forceRefresh: true),
          )
              : LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth >= 800
                  ? 4
                  : constraints.maxWidth >= 600
                  ? 3
                  : 2;
              return GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: AppSpacing.insetsMd,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: 0.78,
                ),
                itemCount: _controller.products.length,
                itemBuilder: (_, index) => ProductCard(
                  product: _controller.products[index],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

class _StatusView extends StatelessWidget {
  const _StatusView({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onButtonTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onButtonTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height - kToolbarHeight,
        ),
        child: Padding(
          padding: AppSpacing.insetsMd,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 72, color: colorScheme.onSurfaceVariant),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                style: AppTextStyles.titleMedium.copyWith(
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: onButtonTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
                child: Text(buttonLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}