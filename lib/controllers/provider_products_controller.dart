import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../models/product/product_model.dart';
import '../repositories/product_repository.dart';


class ProviderProductsController extends GetxController {
  ProviderProductsController(this._repo, this.providerUsername);

  final ProductRepository _repo;
  final String providerUsername;

  final products = <ProductModel>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  Future<void> loadProducts({bool forceRefresh = false}) async {
    if (providerUsername.trim().isEmpty) return;

    isLoading.value = true;
    error.value = '';

    try {
      _log('Loading for provider="$providerUsername"');
      final result = await _repo.getProviderProducts(
        username: providerUsername,
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

  void _log(String message) {
    if (kDebugMode) debugPrint('[ProviderProductsController] $message');
  }
}