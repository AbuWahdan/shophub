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

  void updateAuth(AuthState authState) {
    if (!authState.isInitialized || authState.isInitializing) {
      return;
    }

    final nextUsername = authState.user?.username.trim() ?? '';
    final isLoggedIn = authState.isLoggedIn && nextUsername.isNotEmpty;

    if (!isLoggedIn) {
      if (_username.isNotEmpty ||
          _itemsById.isNotEmpty ||
          _togglingIds.isNotEmpty ||
          _errorMessage != null ||
          _hasLoadedForUser) {
        _username = '';
        _itemsById.clear();
        _togglingIds.clear();
        _errorMessage = null;
        _hasLoadedForUser = false;
        AppData.setWishlistProducts(const <ApiProduct>[]);
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
    AppData.setWishlistProducts(const <ApiProduct>[]);
    notifyListeners();
    Future<void>.microtask(_refreshSilently);
  }

  Future<void> _refreshSilently() async {
    try {
      await refresh();
    } catch (_) {
      // The consumers render the stored error state.
    }
  }

  Future<void> refresh() async {
    if (_username.isEmpty) {
      _itemsById.clear();
      _errorMessage = null;
      _hasLoadedForUser = true;
      AppData.setWishlistProducts(const <ApiProduct>[]);
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
          favorites.map((product) {
            product.isFavorite = true;
            return MapEntry(product.id, product);
          }),
        );
      _hasLoadedForUser = true;
      AppData.setWishlistProducts(items);
    } catch (error) {
      _errorMessage = error.toString();
      _hasLoadedForUser = true;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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

    _togglingIds.add(productId);
    _errorMessage = null;
    notifyListeners();

    final wasInWishlist = isInWishlist(productId);

    try {
      await _productService.toggleFavorite(
        itemId: productId,
        username: _username,
      );

      if (wasInWishlist) {
        _itemsById.remove(productId);
      } else {
        product.isFavorite = true;
        _itemsById[productId] = product;
      }

      product.isFavorite = !wasInWishlist;
      AppData.setFavorite(product, !wasInWishlist);

      return wasInWishlist
          ? WishlistToggleAction.removed
          : WishlistToggleAction.added;
    } catch (error) {
      _errorMessage = error.toString();
      rethrow;
    } finally {
      _togglingIds.remove(productId);
      notifyListeners();
    }
  }
}
