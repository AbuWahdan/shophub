// presentation/wishlist/wishlist_page.dart
//
// The wishlist screen. Reads state from FavoritesController (Provider) and
// AuthState (Provider). Never touches a repository directly.
// All text comes from AppLocalizations. No hardcoded sizes, colors, or strings.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sinwar_shoping/presentation/profile/wishlist/widgets/wishlist_widgets.dart';

import '../../../controllers/wishlist_state.dart';
import '../../../core/state/auth_state.dart';
import '../../../l10n/app_localizations.dart';

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

    final controller = context.read<FavoritesController>();
    if (controller.hasLoadedForCurrentUser) return;

    try {
      await controller.fetchWishlist();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = context.watch<AuthState>();
    final controller = context.watch<FavoritesController>();
    final isLoggedIn = authState.isLoggedIn && authState.user != null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountWishlist)),
      body: isLoggedIn
          ? WishlistBody(controller: controller)
          : const WishlistNotLoggedIn(),
    );
  }
}