import 'package:flutter/foundation.dart';
import '../../core/api/api_constants.dart';
import '../../core/api/api_service.dart';
import '../../core/api/app_exception.dart';
import '../models/product/product_model.dart';

class ProductRepository {
  final ApiService _apiService;
  static List<ProductModel> _cachedProducts = <ProductModel>[];
  static DateTime? _lastProductsFetch;
  static const Duration _cacheTtl = Duration(minutes: 2);

  ProductRepository(this._apiService);

  Future<List<ProductModel>> getMyProducts({required String username, bool forceRefresh = false,}) async {
    final normalizedUsername = username.trim().toLowerCase();

    if (normalizedUsername.isEmpty) return <ProductModel>[];

    if (kDebugMode) {
      debugPrint(
        '[ProductRepository.getMyProducts] Called with username="$normalizedUsername"',
      );
    }

    try {
      // Fetch flat (ungrouped) products directly from API
      final products = await _fetchFlatProducts(forceRefresh: forceRefresh);

      final filtered = products
          .where((p) => p.createdBy.trim().toLowerCase() == normalizedUsername)
          .toList();

      if (kDebugMode) {
        debugPrint(
          '[ProductRepository.getMyProducts] ✅ Got ${filtered.length} products for username="$normalizedUsername"',
        );
      }

      return filtered;
    } on ServerException catch (e) {
      if (e.statusCode == 404 || e.statusCode == 405) return <ProductModel>[];
      _invalidateCache();
      rethrow;
    } catch (e) {
      _invalidateCache();
      rethrow;
    }
  }

  ///
  /// Fetches products for a given provider username directly from the API
  /// using the USERNAME query parameter — no client-side filtering needed.
  Future<List<ProductModel>> getProviderProducts({
    required String username,
    bool forceRefresh = false,
  }) async {
    final normalizedUsername = username.trim();
    if (normalizedUsername.isEmpty) return const [];

    final response = await _apiService.get(
      ApiConstants.getProducts,
      queryParams: {'USERNAME': normalizedUsername},
      isReadOperation: true,
    );

    if (response == null) return const [];

    final rawItems = _extractItems(response);
    if (rawItems.isEmpty) return const [];

    return rawItems.map((item) => ProductModel.fromJson(item)).toList();
  }

  Future<List<ProductModel>> fetchAllProducts({bool forceRefresh = false}) {
    return _fetchFlatProducts(forceRefresh: forceRefresh);
  }
  Future<List<ProductModel>> _fetchFlatProducts({bool forceRefresh = false,}) async {
    dynamic response;

    try {
      response = await _apiService.get(
        ApiConstants.getProducts,
        isReadOperation: true,
      );
    } catch (getError) {
      response = await _apiService.post(
        ApiConstants.getProducts,
        body: const {},
        isReadOperation: true,
      );
    }

    if (response == null) return const [];

    final rawItems = _extractItems(response);
    if (rawItems.isEmpty) return const [];

    return rawItems.map((item) => ProductModel.fromJson(item)).toList();
  }

  void _invalidateCache() {
    _cachedProducts = <ProductModel>[];
    _lastProductsFetch = null;
  }

  /// Extracts the raw list of product maps from whatever shape the API returns.
  /// Handles: bare List, { "data": [...] }, { "items": [...] }, { "result": [...] }, etc.
  List<Map<String, dynamic>> _extractItems(dynamic response) {
    if (response is List) {
      return response
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (response is Map<String, dynamic>) {
      final candidates = [
        response['item'],
        response['ITEM'],
        response['items'],
        response['Items'],
        response['ITEMS'],
        response['product'],
        response['PRODUCT'],
        response['products'],
        response['Products'],
        response['PRODUCTS'],
        response['data'],
        response['Data'],
        response['DATA'],
        response['result'],
        response['RESULT'],
        response['records'],
        response['Records'],
        response['RECORDS'],
      ];

      for (final raw in candidates) {
        if (raw is Map) {
          return [Map<String, dynamic>.from(raw)];
        }
        if (raw is List) {
          return raw
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        }
      }
    }

    return const [];
  }
}
