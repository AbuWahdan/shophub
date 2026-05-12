
import 'package:flutter/foundation.dart';

import '../../models/data.dart';
import '../../services/product_service.dart';
import '../../core/state/auth_state.dart';
import '../models/product/product_model.dart';

/// The result of a wishlist toggle operation.
enum WishlistToggleResult { added, removed }

class WishlistController extends ChangeNotifier {
  WishlistController({ProductService? productService})
    : _service = productService ?? ProductService();

  final ProductService _service;

  // ── Private state ──────────────────────────────────────────────────────────

  final Map<int, ProductModel> _itemsById = {};
  final Set<int> _pendingToggleIds = {};

  /// Optimistic overrides applied before the next server sync.
  final Map<int, bool> _pendingFavoriteState = {};
  final Map<int, ProductModel> _pendingProducts = {};

  String _username = '';
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasLoadedForCurrentUser = false;

  // ── Public read-only state ─────────────────────────────────────────────────

  List<ProductModel> get items => List.unmodifiable(_itemsById.values.toList());

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasLoadedForCurrentUser => _hasLoadedForCurrentUser;
  bool get isEmpty => _itemsById.isEmpty;

  bool isInWishlist(int productId) => _itemsById.containsKey(productId);
  bool isToggling(int productId) => _pendingToggleIds.contains(productId);

  // ── Auth ──────────────────────────────────────────────────────────────────

  /// Called by the auth listener (e.g. via [ProxyProvider]) whenever auth
  /// state changes. Triggers a fetch when a new user logs in.
  void updateAuth(AuthState authState) {
    if (!authState.isInitialized || authState.isInitializing) return;

    final nextUsername = authState.user?.username.trim() ?? '';
    final isLoggedIn = authState.isLoggedIn && nextUsername.isNotEmpty;

    if (!isLoggedIn) {
      _clearAllState();
      return;
    }

    // Same user — fetch if we haven't loaded yet.
    if (_username == nextUsername) {
      if (!_hasLoadedForCurrentUser && !_isLoading) {
        Future<void>.microtask(_fetchSilently);
      }
      return;
    }

    // New user — update username and trigger a fresh fetch.
    // We intentionally keep _itemsById intact during the fetch to avoid a
    // blank flash on slow / cold-start API calls.
    _username = nextUsername;
    _hasLoadedForCurrentUser = false;
    _errorMessage = null;
    _pendingToggleIds.clear();
    _clearPendingOverrides();
    notifyListeners();

    Future<void>.microtask(_fetchSilently);
  }

  // ── Fetch ─────────────────────────────────────────────────────────────────

  Future<void> fetchWishlist() async {
    if (_username.isEmpty) {
      _isLoading = false;
      _errorMessage = null;
      _hasLoadedForCurrentUser = true;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final favorites = await _service.getUserFavorites(username: _username);

      // Only replace local cache when the server returned items.
      // An empty response on cold-start must not wipe an already-loaded list.
      if (favorites.isNotEmpty) {
        _itemsById
          ..clear()
          ..addEntries(
            favorites.where((p) => p.id > 0).map((p) {
              p.isFavorite = true;
              return MapEntry(p.id, p);
            }),
          );
        _applyPendingOverrides();
        AppData.setWishlistProducts(items);
      } else {
        // Keep existing items; re-apply any in-flight toggles.
        _applyPendingOverrides();
      }

      _hasLoadedForCurrentUser = true;
    } catch (error) {
      _errorMessage = error.toString();
      _hasLoadedForCurrentUser = true;
      // Intentionally keep existing _itemsById on error.
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => fetchWishlist();

  // ── Toggle ────────────────────────────────────────────────────────────────

  /// Optimistically toggles [product] in/out of the wishlist.
  /// Rolls back on failure and rethrows so the caller can show a snackbar.
  Future<WishlistToggleResult> toggleWishlist(ProductModel product) async {
    if (_username.isEmpty) {
      throw Exception('Please log in to manage favorites');
    }

    final productId = product.id;

    // Guard against double-tap.
    if (_pendingToggleIds.contains(productId)) {
      return isInWishlist(productId)
          ? WishlistToggleResult.removed
          : WishlistToggleResult.added;
    }

    final wasInWishlist = isInWishlist(productId);

    // ── Optimistic update ──────────────────────────────────────────────────
    _pendingToggleIds.add(productId);
    _errorMessage = null;

    _applyOptimisticToggle(product: product, wasInWishlist: wasInWishlist);
    notifyListeners();

    try {
      await _service.toggleFavorite(itemId: productId, username: _username);

      _pendingFavoriteState[productId] = !wasInWishlist;
      if (!wasInWishlist) {
        _pendingProducts[productId] = product;
      } else {
        _pendingProducts.remove(productId);
      }

      return wasInWishlist
          ? WishlistToggleResult.removed
          : WishlistToggleResult.added;
    } catch (error) {
      // ── Rollback ───────────────────────────────────────────────────────────
      _rollbackToggle(product: product, wasInWishlist: wasInWishlist);
      _pendingFavoriteState.remove(productId);
      _pendingProducts.remove(productId);
      _errorMessage = error.toString();
      rethrow;
    } finally {
      _pendingToggleIds.remove(productId);
      notifyListeners();
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  void _fetchSilently() async {
    try {
      await fetchWishlist();
    } catch (_) {
      // Errors surfaced via _errorMessage, not propagated.
    }
  }

  void _applyOptimisticToggle({
    required ProductModel product,
    required bool wasInWishlist,
  }) {
    if (wasInWishlist) {
      _itemsById.remove(product.id);
      AppData.setFavorite(product, false);
      product.isFavorite = false;
    } else {
      product.isFavorite = true;
      _itemsById[product.id] = product;
      AppData.setFavorite(product, true);
    }
  }

  void _rollbackToggle({
    required ProductModel product,
    required bool wasInWishlist,
  }) {
    if (wasInWishlist) {
      product.isFavorite = true;
      _itemsById[product.id] = product;
      AppData.setFavorite(product, true);
    } else {
      _itemsById.remove(product.id);
      AppData.setFavorite(product, false);
      product.isFavorite = false;
    }
  }

  void _applyPendingOverrides() {
    for (final entry in _pendingFavoriteState.entries) {
      final id = entry.key;
      if (entry.value) {
        if (!_itemsById.containsKey(id)) {
          final product = _pendingProducts[id];
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

  void _clearPendingOverrides() {
    _pendingFavoriteState.clear();
    _pendingProducts.clear();
  }

  void _clearAllState() {
    final hadState =
        _username.isNotEmpty ||
        _itemsById.isNotEmpty ||
        _pendingToggleIds.isNotEmpty ||
        _errorMessage != null ||
        _hasLoadedForCurrentUser;

    if (!hadState) return;

    _username = '';
    _isLoading = false;
    _hasLoadedForCurrentUser = false;
    _errorMessage = null;
    _itemsById.clear();
    _pendingToggleIds.clear();
    _clearPendingOverrides();
    AppData.setWishlistProducts(const []);
    notifyListeners();
  }
}
