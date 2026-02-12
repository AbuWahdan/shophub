import 'package:flutter/material.dart';

import '../config/route.dart';
import '../design/app_spacing.dart';
import '../l10n/l10n.dart';
import '../model/data.dart';
import '../shared/widgets/empty_state.dart';
import '../themes/theme.dart';
import '../widgets/product_card.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  @override
  Widget build(BuildContext context) {
    final wishlist = AppData.wishlistProducts;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.accountWishlist)),
      body: wishlist.isEmpty
          ? EmptyState(
              icon: Icons.favorite_border,
              title: context.l10n.accountWishlist,
              message: context.l10n.accountWishlistComingSoon,
            )
          : GridView.builder(
              padding: AppTheme.padding,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                mainAxisSpacing: AppSpacing.lg,
                crossAxisSpacing: AppSpacing.lg,
              ),
              itemCount: wishlist.length,
              itemBuilder: (context, index) {
                return ProductCard(
                  product: wishlist[index],
                  onSelected: (_) => setState(() {}),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, AppRoutes.main);
        },
        child: const Icon(Icons.storefront),
      ),
    );
  }
}
