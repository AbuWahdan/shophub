import 'package:flutter/material.dart';
import '../../models/data.dart';
import '../../models/product_api.dart';
import '../services/product_service.dart';
import 'auth_state.dart';

enum WishlistToggleAction { added, removed }

class WishlistState extends ChangeNotifier {
  WishlistState({ProductService? productService})
      : _productService = productService ?? ProductService();

  final ProductService _productService;
  final Map<int, ApiProduct> _itemsById   = <int, ApiProduct>{};
  final Set<int>             _togglingIds = <int>{};
  final Map<int, bool>       _favoriteOverrides  = {};
  final Map<int, ApiProduct> _overrideProducts   = {};

  String _username        = '';
  bool   _isLoading       = false;
  String? _errorMessage;
  bool   _hasLoadedForUser = false;

  List<ApiProduct> get items            => _itemsById.values.toList(growable: false);
  bool             get isLoading        => _isLoading;
  String?          get errorMessage     => _errorMessage;
  bool             get hasLoadedForUser => _hasLoadedForUser;

  bool isInWishlist(int productId) => _itemsById.containsKey(productId);
  bool isToggling(int productId)   => _togglingIds.contains(productId);

  // ── Overrides ─────────────────────────────────────────────────────────────

  void _applyOverrides() {
    for (final entry in _favoriteOverrides.entries) {
      final id = entry.key;
      if (entry.value) {
        if (!_itemsById.containsKey(id)) {
          final product = _overrideProducts[id];
          if (product != null) {
            product.isFavorite = true;
            _itemsById[id] = product;
          }
        }
      } else {
        _itemsById.remove(id);
      }
    }
  }

  void _clearOverrides() {
    _favoriteOverrides.clear();
    _overrideProducts.clear();
  }

  // ── Auth ──────────────────────────────────────────────────────────────────

  void updateAuth(AuthState authState) {
    if (!authState.isInitialized || authState.isInitializing) return;

    final nextUsername = authState.user?.username.trim() ?? '';
    final isLoggedIn   = authState.isLoggedIn && nextUsername.isNotEmpty;

    if (!isLoggedIn) {
      final hadState = _username.isNotEmpty ||
          _itemsById.isNotEmpty ||
          _togglingIds.isNotEmpty ||
          _errorMessage != null ||
          _hasLoadedForUser;
      if (hadState) {
        _username        = '';
        _isLoading       = false;
        _hasLoadedForUser = false;
        _errorMessage    = null;
        _itemsById.clear();
        _togglingIds.clear();
        _clearOverrides();
        AppData.setWishlistProducts(const []);
        notifyListeners();
      }
      return;
    }

    if (_username == nextUsername) {
      if (!_hasLoadedForUser && !_isLoading) {
        Future<void>.microtask(_refreshSilently);
      }
      return;
    }

    // Username changed: keep existing items visible while we fetch the new
    // user's list. fetchWishlist will replace them on success.
    // Clearing immediately would cause a blank flash and lose data if the
    // API is slow or times out (APEX cold start).
    _username        = nextUsername;
    _hasLoadedForUser = false;
    _errorMessage    = null;
    _togglingIds.clear();
    _clearOverrides();
    // _itemsById intentionally NOT cleared here — fetchWishlist handles it
    notifyListeners();
    Future<void>.microtask(_refreshSilently);
  }

  Future<void> _refreshSilently() async {
    try {
      await fetchWishlist();
    } catch (_) {
      // Swallow — errors are stored in _errorMessage, not propagated
    }
  }

  // ── Fetch ─────────────────────────────────────────────────────────────────

  Future<void> fetchWishlist() async {
    if (_username.isEmpty) {
      _isLoading        = false;
      _errorMessage     = null;
      _hasLoadedForUser = true;
      // Do NOT clear _itemsById — there is nothing valid to show and nothing
      // wrong to clear.
      notifyListeners();
      return;
    }

    _isLoading    = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final favorites = await _productService.getUserFavorites(
        username: _username,
      );

      // FIX: Only replace local data when the API actually returned items.
      //
      // An empty response on cold start (APEX warmup delay, network hiccup,
      // or the user genuinely having no favorites) must NOT wipe a wishlist
      // the user built in a previous session.
      //
      // Side-effect: if a user removes ALL favorites from another device, the
      // list will look stale until they pull-to-refresh. This is an acceptable
      // trade-off compared to losing the entire wishlist on every cold restart.
      if (favorites.isNotEmpty) {
        _itemsById
          ..clear()
          ..addEntries(
            favorites.where((p) => p.id > 0).map((p) {
              p.isFavorite = true;
              return MapEntry(p.id, p);
            }),
          );
        _applyOverrides();
        AppData.setWishlistProducts(items);
      } else {
        // Empty response: keep whatever is already in _itemsById.
        // Re-apply overrides in case a recent toggle hasn't propagated yet.
        _applyOverrides();
      }

      _hasLoadedForUser = true;
    } catch (error) {
      // FIX: Do NOT rethrow. Keeping existing items is better than crashing
      // or showing an empty screen because of a transient network error.
      _errorMessage     = error.toString();
      _hasLoadedForUser = true;
      // _itemsById is intentionally left as-is on error.
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => fetchWishlist();

  // ── Toggle ────────────────────────────────────────────────────────────────

  Future<WishlistToggleAction> toggleWishlist(ApiProduct product) async {
    if (_username.isEmpty) {
      throw ProductException('Please log in to manage favorites');
    }

    final productId = product.id;
    if (_togglingIds.contains(productId)) {
      return isInWishlist(productId)
          ? WishlistToggleAction.removed
          : WishlistToggleAction.added;
    }

    final wasInWishlist = isInWishlist(productId);

    _togglingIds.add(productId);
    _errorMessage = null;

    if (wasInWishlist) {
      _itemsById.remove(productId);
      AppData.setFavorite(product, false);
      product.isFavorite = false;
    } else {
      product.isFavorite = true;
      _itemsById[productId] = product;
      AppData.setFavorite(product, true);
    }
    notifyListeners();

    try {
      await _productService.toggleFavorite(
        itemId:   productId,
        username: _username,
      );

      _favoriteOverrides[productId] = !wasInWishlist;
      if (!wasInWishlist) {
        _overrideProducts[productId] = product;
      } else {
        _overrideProducts.remove(productId);
      }

      return wasInWishlist
          ? WishlistToggleAction.removed
          : WishlistToggleAction.added;
    } catch (error) {
      // Rollback
      if (wasInWishlist) {
        product.isFavorite       = true;
        _itemsById[productId]    = product;
        AppData.setFavorite(product, true);
      } else {
        _itemsById.remove(productId);
        AppData.setFavorite(product, false);
        product.isFavorite = false;
      }
      _favoriteOverrides.remove(productId);
      _overrideProducts.remove(productId);
      _errorMessage = error.toString();
      rethrow;
    } finally {
      _togglingIds.remove(productId);
      notifyListeners();
    }
  }
}