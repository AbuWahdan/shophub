import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../data/repositories/product_repository.dart';
import '../models/product_api.dart';

class ProductController extends GetxController {
  final ProductRepository _repo;

  ProductController(this._repo);

  final allProducts = <ApiProduct>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;

  /// Load all products (public catalog)
  Future<void> loadAllProducts({bool forceRefresh = false}) async {
    isLoading.value = true;
    error.value = '';

    try {
      if (kDebugMode) {
        debugPrint('[ProductController] Loading all products');
      }

      final products = await _repo.getProducts(forceRefresh: forceRefresh);
      allProducts.assignAll(products);

      if (kDebugMode) {
        debugPrint('[ProductController] Successfully loaded ${products.length} products');
      }
    } on Exception catch (e) {
      error.value = e.toString();
      if (kDebugMode) {
        debugPrint('[ProductController] Error loading products: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Clear all products and cached data
  void clearCache() {
    allProducts.clear();
    error.value = '';
  }
}
