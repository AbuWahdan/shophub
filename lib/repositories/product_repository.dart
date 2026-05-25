import 'package:flutter/foundation.dart';
import '../../core/api/api_constants.dart';
import '../../core/api/api_service.dart';
import '../../core/api/app_exception.dart';
import '../../core/utils/apex_response_helper.dart';
import '../models/product/product_model.dart';

class ProductRepository {
  final ApiService _apiService;
  static List<ProductModel> _cachedProducts = <ProductModel>[];
  static DateTime? _lastProductsFetch;
  static const Duration _cacheTtl = Duration(minutes: 2);

  ProductRepository(this._apiService);

  // ═══════════════════════════════════════════════════════════════════════════
  // Public API
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get all products with optional caching (cache for 2 minutes)
  Future<List<ProductModel>> getProducts({bool forceRefresh = false, String? username,}) async {
    final now = DateTime.now();
    final isUserSpecific = username != null && username.isNotEmpty;

    // Only use cache for non-user-specific calls
    if (!isUserSpecific &&
        !forceRefresh &&
        _cachedProducts.isNotEmpty &&
        _lastProductsFetch != null &&
        now.difference(_lastProductsFetch!) < _cacheTtl) {
      if (kDebugMode) {
        debugPrint(
          '[ProductRepository.getProducts] Cache HIT: ${_cachedProducts.length} products',
        );
      }
      return _cachedProducts;
    }

    try {
      if (kDebugMode) {
        debugPrint(
          '[ProductRepository.getProducts] Cache MISS - fetching from API...',
        );
      }

      final queryParams = username != null && username.isNotEmpty
          ? {'username': username}
          : null;

      dynamic response;

      try {
        if (kDebugMode) {
          debugPrint('[ProductRepository.getProducts] Attempting GET request');
        }
        response = await _apiService.get(
          ApiConstants.getProducts,
          queryParams: queryParams,
          isReadOperation: true,
        );
      } catch (getError) {
        if (kDebugMode) {
          debugPrint(
            '[ProductRepository.getProducts] GET failed: $getError, trying POST as fallback',
          );
        }
        // Fallback to POST if GET fails
        try {
          response = await _apiService.post(
            ApiConstants.getProducts,
            body: const {},
            isReadOperation: true,
          );
        } catch (postError) {
          // Both failed - check if it's a 405 (Method Not Allowed) and handle gracefully
          if (kDebugMode) {
            debugPrint(
              '[ProductRepository.getProducts] Both GET and POST failed. GET: $getError, POST: $postError',
            );
          }

          // If POST also fails, re-throw the POST error (or GET if both failed)
          rethrow;
        }
      }

      if (kDebugMode) {
        debugPrint(
          '[ProductRepository.getProducts] API response received: ${response.runtimeType}',
        );
      }

      if (response == null) {
        if (kDebugMode) {
          debugPrint('[ProductRepository.getProducts] ⚠️ API returned null');
        }
        _cachedProducts = const [];
        _lastProductsFetch = now;
        return _cachedProducts;
      }

      // Extract items from response (handles various response formats)
      final rawItems = _extractItems(response);
      if (kDebugMode) {
        debugPrint(
          '[ProductRepository.getProducts] ✅ Extracted ${rawItems.length} raw items',
        );
      }

      if (rawItems.isEmpty) {
        if (kDebugMode) {
          debugPrint(
            '[ProductRepository.getProducts] Response was empty - no items found',
          );
        }
        _cachedProducts = const [];
        _lastProductsFetch = now;
        return _cachedProducts;
      }

      // Parse items to models
      final parsed = rawItems.map((item) {
        try {
          return ProductModel.fromJson(item);
        } catch (parseError) {
          if (kDebugMode) {
            debugPrint(
              '[ProductRepository.getProducts] ⚠️ Error parsing item: $parseError',
            );
          }
          rethrow;
        }
      }).toList();

      if (kDebugMode) {
        debugPrint(
          '[ProductRepository.getProducts] Parsed ${parsed.length} products successfully',
        );
      }

      // Group variants by product ID
      final products = _groupProductsByItemId(parsed);

      // Only cache non-user-specific results
      if (!isUserSpecific) {
        _cachedProducts = products;
        _lastProductsFetch = now;
      }

      if (kDebugMode) {
        debugPrint(
          '[ProductRepository.getProducts] ✅ Final count after grouping: ${products.length} products',
        );
      }

      return products;
    } on ServerException catch (e) {
      // Handle API errors specifically
      if (kDebugMode) {
        debugPrint(
          '[ProductRepository.getProducts] ❌ ServerException: ${e.message} (statusCode: ${e.statusCode})',
        );
      }

      // On 404/405 (not found / method not allowed), return empty list gracefully
      if (e.statusCode == 404 || e.statusCode == 405) {
        if (kDebugMode) {
          debugPrint(
            '[ProductRepository.getProducts] Endpoint not available or method not supported - returning empty list',
          );
        }
        _cachedProducts = const [];
        _lastProductsFetch = now;
        return _cachedProducts;
      }

      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[ProductRepository.getProducts] ❌ Unexpected error: ${e.runtimeType} - $e',
        );
      }
      rethrow;
    }
  }

  /// Get products belonging to the current user (seller).
  /// Returns all products (active and inactive) for the user.
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




  /// Groups flat product rows (one row per variant) into one ApiProduct per
  /// item ID — identical to ProductService._groupProductsByItemId.
  List<ProductModel> _groupProductsByItemId(List<ProductModel> flatProducts) {
    if (flatProducts.isEmpty) return const [];

    final grouped = <int, List<ProductModel>>{};
    for (final product in flatProducts) {
      grouped.putIfAbsent(product.id, () => <ProductModel>[]).add(product);
    }

    final result = <ProductModel>[];

    for (final entry in grouped.entries) {
      final rows = entry.value;
      final base = rows.first;

      // Collect all variants across rows, deduplicating by a stable key.
      final variants = <ProductVariant>[];
      final seenKeys = <String>{};

      for (final row in rows) {
        final sourceVariants = row.variants.isNotEmpty
            ? row.variants
            : <ProductVariant>[
                ProductVariant(
                  detId: row.detId,
                  brand: '',
                  color: row.colors.isNotEmpty ? row.colors.first : '',
                  size: row.sizes.isNotEmpty ? row.sizes.first : '',
                  discount: 0,
                  price: row.basePrice,
                  stock: row.baseStock,
                ),
              ];

        for (final variant in sourceVariants) {
          final key =
              '${variant.detId}|${variant.brand}|${variant.color}'
              '|${variant.size}|${variant.price}|${variant.stock}';
          if (seenKeys.add(key)) {
            variants.add(variant);
          }
        }
      }

      final sizes = variants
          .map((v) => v.size.trim())
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList();

      final colors = variants
          .map((v) => v.color.trim())
          .where((c) => c.isNotEmpty)
          .toSet()
          .toList();

      // Pick the variant with the lowest effective price for display.
      ProductVariant? displayVariant;
      for (final v in variants) {
        if (displayVariant == null) {
          displayVariant = v;
          continue;
        }
        final candidate = v.price * (1 - v.discount / 100);
        final current =
            displayVariant.price * (1 - displayVariant.discount / 100);
        if (candidate < current) displayVariant = v;
      }

      final mergedImages = rows
          .expand((row) => row.images)
          .map((img) => img.trim())
          .where((img) => img.isNotEmpty)
          .toSet()
          .toList();

      final displayPrice = displayVariant == null
          ? base.price
          : displayVariant.price * (1 - displayVariant.discount / 100);

      result.add(
        ProductModel(
          id: base.id,
          detId: displayVariant?.detId ?? base.detId,
          name: base.name,
          description: base.description,
          basePrice: displayPrice > 0 ? displayPrice : base.basePrice,
          baseStock: displayVariant?.stock ?? base.baseStock,
          primaryImageUrl: mergedImages.isNotEmpty
              ? mergedImages.first
              : base.primaryImageUrl,
          images: mergedImages.isNotEmpty ? mergedImages : base.images,
          categoryId: base.categoryId,
          category: base.category,
          createdBy: base.createdBy,
          itemOwner: base.itemOwner,
          createdByUserId: base.createdByUserId,
          isActive: rows.every((r) => r.isActive == 1) ? 1 : 0,
          discountPrice: null,
          variants: variants,
          sizes: sizes.isNotEmpty ? sizes : base.sizes,
          colors: colors.isNotEmpty ? colors : base.colors,
          imagesByColor: base.imagesByColor,
          stockByVariant: base.stockByVariant,
          rating: base.rating,
          reviewCount: base.reviewCount,
          soldCount: base.soldCount,
          isFavorite: base.isFavorite,
        ),
      );
    }

    return result;
  }
}
