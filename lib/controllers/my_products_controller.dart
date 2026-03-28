import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../data/repositories/product_repository.dart';
import '../src/model/product_api.dart';

class MyProductsController extends GetxController {
  final ProductRepository _repo;
  
  MyProductsController(this._repo);

  final products = <ApiProduct>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;

  // Set ONCE from the UI before calling load
  String username = '';
  int userId = 0;

  /// Load products for the current user (seller)
  /// All products (active and inactive) are shown
  Future<void> loadProducts({bool forceRefresh = false}) async {
    if (kDebugMode) {
      debugPrint(
        '[MyProductsController.loadProducts] START - username="$username", userId=$userId, forceRefresh=$forceRefresh',
      );
    }

    if (username.isEmpty && userId <= 0) {
      if (kDebugMode) {
        debugPrint(
          '[MyProductsController.loadProducts] ⚠️ No valid username/userId - clearing products',
        );
      }
      products.clear();
      error.value = '';
      return;
    }

    isLoading.value = true;
    error.value = '';
    
    try {
      if (kDebugMode) {
        debugPrint(
          '[MyProductsController.loadProducts] Calling repository.getMyProducts()',
        );
      }

      // getMyProducts does NOT filter by isActive — returns all user's products
      final result = await _repo.getMyProducts(
        username: username,
        userId: userId,
        forceRefresh: forceRefresh,
      );
      
      if (kDebugMode) {
        debugPrint(
          '[MyProductsController.loadProducts] Repository returned ${result.length} products',
        );
      }

      products.assignAll(result);
      
      if (kDebugMode) {
        debugPrint(
          '[MyProductsController.loadProducts] ✅ Successfully assigned ${result.length} products to reactive list',
        );
      }
    } on Exception catch (e) {
      error.value = e.toString();
      if (kDebugMode) {
        debugPrint(
          '[MyProductsController.loadProducts] ❌ Exception caught: ${e.runtimeType} - $e',
        );
      }
    } catch (e) {
      // Catch non-Exception types too
      final errorMsg = 'Unexpected error: ${e.runtimeType} - $e';
      error.value = errorMsg;
      if (kDebugMode) {
        debugPrint(
          '[MyProductsController.loadProducts] ❌ Unexpected error: $errorMsg',
        );
      }
    } finally {
      isLoading.value = false;
      if (kDebugMode) {
        debugPrint(
          '[MyProductsController.loadProducts] END - products.length=${products.length}, hasError=${error.isNotEmpty}',
        );
      }
    }
  }

  /// Clear all products and cached data
  void clearProducts() {
    products.clear();
    error.value = '';
    username = '';
    userId = 0;
    if (kDebugMode) {
      debugPrint('[MyProductsController.clearProducts] Cleared all products and credentials');
    }
  }
}
