import 'package:flutter/material.dart';

import '../model/data.dart';
import '../model/product_api.dart';
import '../services/product_service.dart';
import 'auth_state.dart';

enum WishlistToggleAction { added, removed }

class WishlistState extends ChangeNotifier {
  WishlistState({ProductService? productService})
    : _productService = productService ?? ProductService();

  final ProductService _productService;
  final Map<int, ApiProduct> _itemsById = <int, ApiProduct>{};
  final Set<int> _togglingIds = <int>{};

  // ── Override maps ──────────────────────────────────────────────────────────
  // Local truth that gets re-applied on top of every API fetch.
  // This protects optimistic changes from being wiped by API eventual-consistency lag.
  // Cleared only on logout / username change.
  final Map<int, bool> _favoriteOverrides = {}; // id → isFavorite
  final Map<int, ApiProduct> _overrideProducts =
      {}; // id → product (to re-insert)
  // ──────────────────────────────────────────────────────────────────────────

  String _username = '';
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasLoadedForUser = false;

  List<ApiProduct> get items => _itemsById.values.toList(growable: false);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasLoadedForUser => _hasLoadedForUser;

  bool isInWishlist(int productId) => _itemsById.containsKey(productId);
  bool isToggling(int productId) => _togglingIds.contains(productId);

  // ── Override helpers ───────────────────────────────────────────────────────

  void _applyOverrides() {
    for (final entry in _favoriteOverrides.entries) {
      final id = entry.key;
      if (entry.value) {
        // Should be in wishlist — re-insert if API response didn't include it
        if (!_itemsById.containsKey(id)) {
          final product = _overrideProducts[id];
          if (product != null) {
            product.isFavorite = true;
            _itemsById[id] = product;
          }
        }
      } else {
        // Should NOT be in wishlist — remove even if API returned it
        _itemsById.remove(id);
      }
    }
  }

  void _clearOverrides() {
    _favoriteOverrides.clear();
    _overrideProducts.clear();
  }

  // ── Auth ───────────────────────────────────────────────────────────────────

  void updateAuth(AuthState authState) {
    if (!authState.isInitialized || authState.isInitializing) return;

    final nextUsername = authState.user?.username.trim() ?? '';
    final isLoggedIn = authState.isLoggedIn && nextUsername.isNotEmpty;

    if (!isLoggedIn) {
      if (_username.isNotEmpty ||
          _itemsById.isNotEmpty ||
          _togglingIds.isNotEmpty ||
          _errorMessage != null ||
          _hasLoadedForUser) {
        _username = '';
        _isLoading = false;
        _itemsById.clear();
        _togglingIds.clear();
        _errorMessage = null;
        _hasLoadedForUser = false;
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

    _username = nextUsername;
    _itemsById.clear();
    _togglingIds.clear();
    _errorMessage = null;
    _hasLoadedForUser = false;
    _clearOverrides(); // new user = fresh state
    notifyListeners();
    Future<void>.microtask(_refreshSilently);
  }

  Future<void> _refreshSilently() async {
    try {
      await fetchWishlist();
    } catch (_) {}
  }

  // ── Fetch ──────────────────────────────────────────────────────────────────

  Future<void> fetchWishlist() async {
    if (_username.isEmpty) {
      _isLoading = false;
      _itemsById.clear();
      _errorMessage = null;
      _hasLoadedForUser = true;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final favorites = await _productService.getUserFavorites(
        username: _username,
      );

      _itemsById
        ..clear()
        ..addEntries(
          favorites.where((p) => p.id > 0).map((p) {
            p.isFavorite = true;
            return MapEntry(p.id, p);
          }),
        );

      // Re-apply local overrides on top of the API result.
      // This handles the case where the API hasn't yet reflected a recent toggle.
      _applyOverrides();

      AppData.setWishlistProducts(items);
      _hasLoadedForUser = true;
    } catch (error) {
      _errorMessage = error.toString();
      _hasLoadedForUser = true;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => fetchWishlist();

  // ── Toggle ─────────────────────────────────────────────────────────────────

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

    // ── Optimistic update ──────────────────────────────────────────────────
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
    // ──────────────────────────────────────────────────────────────────────

    try {
      await _productService.toggleFavorite(
        itemId: productId,
        username: _username,
      );

      // Record the override so future fetchWishlist calls don't undo this.
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
      // ── Rollback ─────────────────────────────────────────────────────────
      if (wasInWishlist) {
        product.isFavorite = true;
        _itemsById[productId] = product;
        AppData.setFavorite(product, true);
      } else {
        _itemsById.remove(productId);
        AppData.setFavorite(product, false);
        product.isFavorite = false;
      }
      // Remove override — we rolled back so local state matches pre-toggle
      _favoriteOverrides.remove(productId);
      _overrideProducts.remove(productId);
      // ─────────────────────────────────────────────────────────────────────

      _errorMessage = error.toString();
      rethrow;
    } finally {
      _togglingIds.remove(productId);
      notifyListeners();
    }
  }
}
