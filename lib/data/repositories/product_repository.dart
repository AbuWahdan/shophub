import 'package:flutter/foundation.dart';
import '../../core/api/api_constants.dart';
import '../../core/api/api_service.dart';
import '../../core/exceptions/app_exception.dart';
import '../../src/model/product_api.dart';

class ProductRepository {
  final ApiService _apiService;
  static List<ApiProduct> _cachedProducts = <ApiProduct>[];
  static DateTime? _lastProductsFetch;
  static const Duration _cacheTtl = Duration(minutes: 2);

  ProductRepository(this._apiService);

  // ═══════════════════════════════════════════════════════════════════════════
  // Public API
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get all products with optional caching (cache for 2 minutes)
  Future<List<ApiProduct>> getProducts({bool forceRefresh = false}) async {
    final now = DateTime.now();

    if (!forceRefresh &&
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
        debugPrint('[ProductRepository.getProducts] Cache MISS - fetching from API...');
      }

      // Try GET first (REST convention for fetching data)
      dynamic response;
      String lastTryMethod = 'GET';
      
      try {
        if (kDebugMode) {
          debugPrint('[ProductRepository.getProducts] Attempting GET request');
        }
        response = await _apiService.get(
          ApiConstants.getProducts,
          isReadOperation: true,
        );
      } catch (getError) {
        if (kDebugMode) {
          debugPrint('[ProductRepository.getProducts] GET failed: $getError, trying POST as fallback');
        }
        // Fallback to POST if GET fails
        lastTryMethod = 'POST';
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
        debugPrint('[ProductRepository.getProducts] API response received (via $lastTryMethod): ${response.runtimeType}');
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
        debugPrint('[ProductRepository.getProducts] ✅ Extracted ${rawItems.length} raw items');
      }

      if (rawItems.isEmpty) {
        if (kDebugMode) {
          debugPrint('[ProductRepository.getProducts] Response was empty - no items found');
        }
        _cachedProducts = const [];
        _lastProductsFetch = now;
        return _cachedProducts;
      }

      // Parse items to models
      final parsed = rawItems
          .map((item) {
            try {
              return ApiProduct.fromJson(item);
            } catch (parseError) {
              if (kDebugMode) {
                debugPrint('[ProductRepository.getProducts] ⚠️ Error parsing item: $parseError');
              }
              rethrow;
            }
          })
          .toList();
      
      if (kDebugMode) {
        debugPrint('[ProductRepository.getProducts] Parsed ${parsed.length} products successfully');
      }

      // Group variants by product ID
      final products = _groupProductsByItemId(parsed);

      // Update cache
      _cachedProducts = products;
      _lastProductsFetch = now;

      if (kDebugMode) {
        debugPrint(
          '[ProductRepository.getProducts] ✅ Final count after grouping: ${products.length} products',
        );
      }

      return products;
    } on ServerException catch (e) {
      // Handle API errors specifically
      if (kDebugMode) {
        debugPrint('[ProductRepository.getProducts] ❌ ServerException: ${e.message} (statusCode: ${e.statusCode})');
      }
      
      // On 404/405 (not found / method not allowed), return empty list gracefully
      if (e.statusCode == 404 || e.statusCode == 405) {
        if (kDebugMode) {
          debugPrint('[ProductRepository.getProducts] Endpoint not available or method not supported - returning empty list');
        }
        _cachedProducts = const [];
        _lastProductsFetch = now;
        return _cachedProducts;
      }
      
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ProductRepository.getProducts] ❌ Unexpected error: ${e.runtimeType} - $e');
      }
      rethrow;
    }
  }

  /// Get products belonging to the current user (seller).
  /// Returns all products (active and inactive) for the user.
  Future<List<ApiProduct>> getMyProducts({
    required String username,
    required int userId,
    bool forceRefresh = false,
  }) async {
    final normalizedUsername = username.trim().toLowerCase();
    final normalizedUserId = userId > 0 ? userId : 0;

    if (kDebugMode) {
      debugPrint(
        '[ProductRepository.getMyProducts] Called with username="$normalizedUsername", userId=$normalizedUserId',
      );
    }

    if (normalizedUsername.isEmpty && normalizedUserId == 0) {
      if (kDebugMode) {
        debugPrint(
          '[ProductRepository.getMyProducts] ⚠️ Both username and userId are invalid - returning empty list',
        );
      }
      return <ApiProduct>[];
    }

    try {
      // Fetch all products first
      final products = await getProducts(forceRefresh: forceRefresh);

      if (kDebugMode) {
        debugPrint(
          '[ProductRepository.getMyProducts] Got ${products.length} total products from cache/API',
        );
      }

      // Filter for current user's products
      final filtered = products.where((product) {
        final ownerId = int.tryParse(product.itemOwner.trim()) ?? 0;
        final matchesOwnerId =
            normalizedUserId > 0 && ownerId == normalizedUserId;
        final matchesCreatedByUserId =
            normalizedUserId > 0 &&
                product.createdByUserId == normalizedUserId;
        final matchesUsername =
            normalizedUsername.isNotEmpty &&
                product.createdBy.trim().toLowerCase() == normalizedUsername;
        
        final matches = matchesOwnerId || matchesCreatedByUserId || matchesUsername;
        
        if (kDebugMode && matches) {
          debugPrint(
            '[ProductRepository.getMyProducts] ✅ Product matched: "${product.itemName}" '
            '(ownerId=$ownerId, createdByUserId=${product.createdByUserId}, createdBy="${product.createdBy}")',
          );
        }
        
        return matches;
      }).toList();

      if (kDebugMode) {
        debugPrint(
          '[ProductRepository.getMyProducts] ✅ Filtered ${filtered.length} products for userId=$normalizedUserId, username=$normalizedUsername',
        );
      }

      return filtered;
    } on ServerException catch (e) {
      // Handle API errors specifically
      if (kDebugMode) {
        debugPrint('[ProductRepository.getMyProducts] ❌ ServerException: ${e.message} (statusCode: ${e.statusCode})');
      }
      
      // On 404/405, return empty list gracefully
      if (e.statusCode == 404 || e.statusCode == 405) {
        if (kDebugMode) {
          debugPrint('[ProductRepository.getMyProducts] Endpoint issue - returning empty list');
        }
        return <ApiProduct>[];
      }
      
      _invalidateCache();
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ProductRepository.getMyProducts] ❌ ERROR: ${e.runtimeType} - $e');
      }
      _invalidateCache();
      rethrow;
    }
  }

  /// Get product details rows for a specific item.
  Future<List<ApiProductDetails>> getItemDetails({required int itemId}) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '[ProductRepository] Fetching item details for itemId=$itemId',
        );
      }

      final response = await _apiService.post(
        ApiConstants.getItemDetails,
        body: {'item_id': itemId},
        isReadOperation: true,
      );

      if (response == null) return <ApiProductDetails>[];

      return _parseItemDetails(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ProductRepository] Error fetching item details: $e');
      }
      _invalidateCache();
      rethrow;
    }
  }

  /// Get images for a specific item.
  Future<List<ApiItemImage>> getItemImages({required int itemId}) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '[ProductRepository] Fetching item images for itemId=$itemId',
        );
      }

      final response = await _apiService.post(
        ApiConstants.getItemImages,
        body: {'item_id': itemId},
        isReadOperation: true,
      );

      if (response == null) return <ApiItemImage>[];

      return _parseItemImages(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ProductRepository] Error fetching item images: $e');
      }
      rethrow;
    }
  }

  /// Insert a new product.
  Future<void> insertProduct(CreateProductRequest request) async {
    try {
      if (kDebugMode) {
        debugPrint('[ProductRepository] Inserting new product');
      }

      await _apiService.post(
        ApiConstants.insertProduct,
        body: request.toJson(),
        isReadOperation: false,
      );

      _invalidateCache();

      if (kDebugMode) {
        debugPrint('[ProductRepository] Product inserted successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ProductRepository] Error inserting product: $e');
      }
      rethrow;
    }
  }

  /// Update an existing product.
  Future<void> updateProduct(UpdateProductRequest request) async {
    try {
      if (kDebugMode) {
        debugPrint('[ProductRepository] Updating product id=${request.id}');
      }

      await _apiService.post(
        ApiConstants.updateItem,
        body: request.toJson(),
        isReadOperation: false,
      );

      _invalidateCache();

      if (kDebugMode) {
        debugPrint('[ProductRepository] Product updated successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ProductRepository] Error updating product: $e');
      }
      rethrow;
    }
  }

  /// Insert product variant details.
  ///
  /// API shape (POST /InsertProductDetails):
  /// ```json
  /// {
  ///   "details": [
  ///     {
  ///       "item_id": 505,
  ///       "brand": "Nike",
  ///       "color": "Black",
  ///       "item_size": "L",
  ///       "discount": 10,
  ///       "item_price": 50,
  ///       "item_qty": 5,
  ///       "is_active": 1
  ///     }
  ///   ]
  /// }
  /// ```
  Future<void> insertProductDetails({
    required int itemId,
    required List<CreateProductDetail> details,
    required String createdBy,
  }) async {
    if (itemId <= 0 || details.isEmpty) {
      throw ServerException(
        'Invalid payload: itemId=$itemId details=${details.length}',
      );
    }

    try {
      if (kDebugMode) {
        debugPrint(
          '[ProductRepository] Inserting product details for itemId=$itemId',
        );
      }

      // FIX 2: "details" is the top-level key. item_id goes INSIDE each row,
      // NOT at the top level. Matches ProductService.insertProductDetails.
      final body = <String, dynamic>{
        'details': details.map((d) {
          return <String, dynamic>{
            'item_id': itemId, // ← inside each detail row
            ...d.toJson(),     // brand, color, item_size, discount, item_price, item_qty, is_active
            if (createdBy.trim().isNotEmpty) 'created_by': createdBy.trim(),
          };
        }).toList(),
      };

      if (kDebugMode) {
        debugPrint('[ProductRepository] insertProductDetails body: $body');
      }

      await _apiService.post(
        ApiConstants.insertProductDetails,
        body: body,
        isReadOperation: false,
      );

      _invalidateCache();

      if (kDebugMode) {
        debugPrint('[ProductRepository] Product details inserted successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ProductRepository] Error inserting product details: $e');
      }
      rethrow;
    }
  }

  /// Delete a product variant detail.
  Future<bool> deleteVariantDetail(int itemDetId) async {
    try {
      if (kDebugMode) {
        debugPrint('[ProductRepository] Deleting variant detail $itemDetId');
      }

      await _apiService.post(
        ApiConstants.deleteItemDetails,
        body: {'item_det_id': itemDetId},
        isReadOperation: false,
      );

      _invalidateCache();

      if (kDebugMode) {
        debugPrint('[ProductRepository] Variant detail deleted successfully');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ProductRepository] Error deleting variant detail: $e');
      }
      rethrow;
    }
  }

  /// Get user favorites.
  Future<List<ApiProduct>> getUserFavorites({required String username}) async {
    try {
      if (kDebugMode) {
        debugPrint('[ProductRepository] Fetching favorites for $username');
      }

      final response = await _apiService.post(
        ApiConstants.getUserFavorites,
        body: {'username': username},
        isReadOperation: true,
      );

      if (response == null) return <ApiProduct>[];

      final rawItems = _extractItems(response);
      return rawItems.map((item) => ApiProduct.fromJson(item)).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ProductRepository] Error fetching favorites: $e');
      }
      rethrow;
    }
  }

  /// Toggle favorite status for a product.
  Future<void> toggleFavorite({
    required int itemId,
    required String username,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '[ProductRepository] Toggling favorite for itemId=$itemId',
        );
      }

      await _apiService.post(
        ApiConstants.toggleFavoriteItem,
        body: {'item_id': itemId, 'username': username},
        isReadOperation: false,
      );

      if (kDebugMode) {
        debugPrint('[ProductRepository] Favorite toggled successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ProductRepository] Error toggling favorite: $e');
      }
      rethrow;
    }
  }

  /// Add a comment/review for a product.
  Future<void> addItemComment({
    required int itemId,
    required String username,
    required int rating,
    required String comment,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('[ProductRepository] Adding comment for itemId=$itemId');
      }

      await _apiService.post(
        ApiConstants.addItemComment,
        body: {
          'item_id': itemId,
          'username': username,
          'rating': rating,
          'comment': comment,
        },
        isReadOperation: false,
      );

      if (kDebugMode) {
        debugPrint('[ProductRepository] Comment added successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ProductRepository] Error adding comment: $e');
      }
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Private helpers
  // ═══════════════════════════════════════════════════════════════════════════

  void _invalidateCache() {
    _cachedProducts = <ApiProduct>[];
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

  List<ApiProductDetails> _parseItemDetails(dynamic response) {
    final items = _extractItems(response);
    return items.map((item) => ApiProductDetails.fromJson(item)).toList();
  }

  List<ApiItemImage> _parseItemImages(dynamic response) {
    final items = _extractItems(response);
    return items.map((item) => ApiItemImage.fromJson(item)).toList();
  }

  /// Groups flat product rows (one row per variant) into one ApiProduct per
  /// item ID — identical to ProductService._groupProductsByItemId.
  List<ApiProduct> _groupProductsByItemId(List<ApiProduct> flatProducts) {
    if (flatProducts.isEmpty) return const [];

    final grouped = <int, List<ApiProduct>>{};
    for (final product in flatProducts) {
      grouped.putIfAbsent(product.id, () => <ApiProduct>[]).add(product);
    }

    final result = <ApiProduct>[];

    for (final entry in grouped.entries) {
      final rows = entry.value;
      final base = rows.first;

      // Collect all variants across rows, deduplicating by a stable key.
      final variants = <ApiProductVariant>[];
      final seenKeys = <String>{};

      for (final row in rows) {
        final sourceVariants = row.details.isNotEmpty
            ? row.details
            : <ApiProductVariant>[
          ApiProductVariant(
            detId: row.detId,
            brand: '',
            color: row.colors.isNotEmpty ? row.colors.first : '',
            itemSize: row.sizes.isNotEmpty ? row.sizes.first : '',
            discount: 0,
            itemPrice: row.itemPrice,
            itemQty: row.itemQty,
          ),
        ];

        for (final variant in sourceVariants) {
          final key =
              '${variant.detId}|${variant.brand}|${variant.color}'
              '|${variant.itemSize}|${variant.itemPrice}|${variant.itemQty}';
          if (seenKeys.add(key)) {
            variants.add(variant);
          }
        }
      }

      final sizes = variants
          .map((v) => v.itemSize.trim())
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList();

      final colors = variants
          .map((v) => v.color.trim())
          .where((c) => c.isNotEmpty)
          .toSet()
          .toList();

      // Pick the variant with the lowest effective price for display.
      ApiProductVariant? displayVariant;
      for (final v in variants) {
        if (displayVariant == null) {
          displayVariant = v;
          continue;
        }
        final candidate = v.itemPrice * (1 - v.discount / 100);
        final current =
            displayVariant.itemPrice * (1 - displayVariant.discount / 100);
        if (candidate < current) displayVariant = v;
      }

      final mergedImages = rows
          .expand((row) => row.images)
          .map((img) => img.trim())
          .where((img) => img.isNotEmpty)
          .toSet()
          .toList();

      final displayPrice = displayVariant == null
          ? base.itemPrice
          : displayVariant.itemPrice * (1 - displayVariant.discount / 100);

      result.add(
        ApiProduct(
          id: base.id,
          detId: displayVariant?.detId ?? base.detId,
          itemName: base.itemName,
          itemDesc: base.itemDesc,
          itemPrice: displayPrice > 0 ? displayPrice : base.itemPrice,
          itemQty: displayVariant?.itemQty ?? base.itemQty,
          itemImgUrl: mergedImages.isNotEmpty ? mergedImages.first : base.itemImgUrl,
          images: mergedImages.isNotEmpty ? mergedImages : base.images,
          categoryId: base.categoryId,
          category: base.category,
          createdBy: base.createdBy,
          itemOwner: base.itemOwner,
          createdByUserId: base.createdByUserId,
          isActive: base.isActive,
          discountPrice: null,
          details: variants,
          sizes: sizes.isNotEmpty ? sizes : base.sizes,
          colors: colors.isNotEmpty ? colors : base.colors,
          imagesByColor: base.imagesByColor,
          stockByVariant: base.stockByVariant,
          rating: base.rating,
          reviewCount: base.reviewCount,
          soldCount: base.soldCount,
          isFavorite: base.isFavorite,
          isSelected: base.isSelected,
        ),
      );
    }

    return result;
  }
}