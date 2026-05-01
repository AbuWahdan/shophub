import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../data/repositories/product_repository.dart';
import '../models/product_model.dart';

/// Manages a **seller's own product listings** — both active and inactive.
///
/// Requires [username] and [userId] to be set before calling [loadProducts].
/// These are set from [MyProductsPage] once the auth state is available.
///
/// Separate from [ProductController] which handles the public catalog.
class MyProductsController extends GetxController {
  MyProductsController(this._repo);

  final ProductRepository _repo;

  final products = <ProductModel>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;

  /// Must be set before calling [loadProducts].
  String username = '';
  int userId = 0;

  // ── Public API ────────────────────────────────────────────────────────────

  Future<void> loadProducts({bool forceRefresh = false}) async {
    if (!_hasValidCredentials) {
      _log('No valid credentials — clearing list');
      products.clear();
      error.value = '';
      return;
    }

    isLoading.value = true;
    error.value = '';

    try {
      _log('Loading for username="$username", userId=$userId');
      final result = await _repo.getMyProducts(
        username: username,
        userId: userId,
        forceRefresh: forceRefresh,
      );
      products.assignAll(result);
      _log('Loaded ${result.length} products');
    } on Exception catch (e) {
      error.value = e.toString();
      _log('Error: $e');
    } catch (e) {
      error.value = 'Unexpected error: $e';
      _log('Unexpected error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void clearProducts() {
    products.clear();
    error.value = '';
    username = '';
    userId = 0;
  }

  // ── Private ───────────────────────────────────────────────────────────────

  bool get _hasValidCredentials => username.isNotEmpty || userId > 0;

  void _log(String message) {
    if (kDebugMode) debugPrint('[MyProductsController] $message');
  }
}