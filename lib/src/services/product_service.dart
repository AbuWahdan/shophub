import 'dart:async';
import 'dart:convert';

import '../../data/categories_data.dart';
import '../../models/category.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:http/http.dart' as http;

import '../model/product_api.dart';
import 'api_client.dart';

class ProductService {
  static const String _baseUrl = 'https://oracleapex.com/ords/topg/products';
  static const String _getProductsUrl = '$_baseUrl/getproducts';
  static const Duration _timeout = Duration(seconds: 6);
  static const Duration _cacheTtl = Duration(minutes: 2);
  static List<ApiProduct> _cachedProducts = <ApiProduct>[];
  static DateTime? _lastProductsFetch;

  final http.Client _client;

  ProductService({http.Client? client}) : _client = client ?? ApiClient();

  Future<List<ApiProduct>> getMyProducts({
    required int currentUserId,
    required String currentUsername,
    bool forceRefresh = false,
  }) async {
    final normalizedUsername = currentUsername.trim().toLowerCase();
    final normalizedUserId = currentUserId > 0 ? currentUserId : 0;
    if (normalizedUsername.isEmpty && normalizedUserId == 0) {
      return <ApiProduct>[];
    }

    try {
      final products = await getProducts(forceRefresh: forceRefresh);
      debugPrint('MyProducts total from API: ${products.length}');
      final filtered = products.where((product) {
        final ownerId = int.tryParse(product.itemOwner.trim()) ?? 0;
        final matchesOwnerId =
            normalizedUserId > 0 && ownerId == normalizedUserId;
        final matchesCreatedByUserId =
            normalizedUserId > 0 && product.createdByUserId == normalizedUserId;
        final matchesUsername =
            normalizedUsername.isNotEmpty &&
            product.createdBy.trim().toLowerCase() == normalizedUsername;
        return matchesOwnerId || matchesCreatedByUserId || matchesUsername;
      }).toList();
      debugPrint(
        'MyProducts filtered for userId=$normalizedUserId username=$normalizedUsername => ${filtered.length}',
      );
      return filtered;
    } on ProductException {
      rethrow;
    } catch (error) {
      throw ProductException('Error loading my products: $error');
    }
  }

  Future<List<ApiProduct>> getProducts({
    bool forceRefresh = false,
    String? createdBy,
    int? categoryId,
  }) async {
    final normalizedCreatedBy = createdBy?.trim();
    final hasCreatedByFilter =
        normalizedCreatedBy != null && normalizedCreatedBy.isNotEmpty;
    final hasCategoryFilter = categoryId != null;
    final now = DateTime.now();
    if (!hasCreatedByFilter &&
        !hasCategoryFilter &&
        !forceRefresh &&
        _cachedProducts.isNotEmpty &&
        _lastProductsFetch != null &&
        now.difference(_lastProductsFetch!) < _cacheTtl) {
      return _cachedProducts;
    }

    final endpoints = <String>[
      _getProductsUrl,
      '$_baseUrl/getProducts',
      '$_baseUrl/getproduct',
      '$_baseUrl/getProduct',
      '$_baseUrl/Getproducts',
      '$_baseUrl/Getproduct',
      '$_baseUrl/GetProduct',
    ];

    String? lastError;
    final errors = <String>[];
    var hasRecoverableEmpty = false;

    for (final endpoint in endpoints) {
      final uri = Uri.parse(endpoint);
      final queryBase = {
        ...uri.queryParameters,
        if (hasCategoryFilter) 'CAT_ID': categoryId.toString(),
      };
      final getRequests = <Future<http.Response?>>[
        _safeGetOrNull(uri.replace(queryParameters: queryBase)),
      ];
      if (hasCreatedByFilter) {
        getRequests.add(
          _safeGetOrNull(
            uri.replace(
              queryParameters: {
                ...queryBase,
                'created_by': normalizedCreatedBy,
              },
            ),
          ),
        );
        getRequests.add(
          _safeGetOrNull(
            uri.replace(
              queryParameters: {
                ...queryBase,
                'CREATED_BY': normalizedCreatedBy,
              },
            ),
          ),
        );
      }
      final responses = await Future.wait<http.Response?>([
        ...getRequests,
        _safePostOrNull(
          uri,
          body: hasCreatedByFilter
              ? {
                  'created_by': normalizedCreatedBy,
                  if (hasCategoryFilter) 'CAT_ID': categoryId,
                }
              : {if (hasCategoryFilter) 'CAT_ID': categoryId},
        ),
      ]);

      for (final response in responses) {
        if (response == null) {
          errors.add('$endpoint -> request failed');
          continue;
        }
        final data = _decode(response.body);
        if (response.statusCode == 404 || response.statusCode == 405) {
          hasRecoverableEmpty = true;
          return <ApiProduct>[];
        }
        if (response.statusCode < 200 || response.statusCode >= 300) {
          lastError =
              _extractMessage(data) ??
              'Fetching products failed (HTTP ${response.statusCode}).';
          errors.add('$endpoint -> HTTP ${response.statusCode}');
          continue;
        }

        final items = _extractItems(data);
        if (items.isEmpty) {
          hasRecoverableEmpty = true;
          return <ApiProduct>[];
        }
        var products = items.map(ApiProduct.fromJson).toList();
        if (hasCreatedByFilter) {
          final name = normalizedCreatedBy.toLowerCase().trim();
          products = products
              .where(
                (product) => product.createdBy.toLowerCase().trim() == name,
              )
              .toList();
        }
        if (hasCreatedByFilter) {
          return products;
        }
        if (products.isEmpty) {
          errors.add('$endpoint -> empty');
          continue;
        }
        if (!hasCreatedByFilter && !hasCategoryFilter) {
          _cachedProducts = products;
          _lastProductsFetch = now;
        }
        return products;
      }
    }

    if (hasRecoverableEmpty) {
      return <ApiProduct>[];
    }

    throw ProductException(
      '${lastError ?? 'Fetching products failed.'} (${errors.take(3).join(' | ')})',
    );
  }

  Future<List<ApiProduct>> getProductsByCategory(
    int categoryId, {
    bool forceRefresh = false,
  }) async {
    var category = CategoriesData.getCategoryById(categoryId);
    category ??= await loadCategoryById(categoryId);
    if (category != null && category.isMainCategory) {
      final categoryIds = <int>{
        category.id,
        ...category.children.map((child) => child.id),
      };
      final allProducts = await getProducts(forceRefresh: forceRefresh);
      return allProducts
          .where((product) => categoryIds.contains(product.categoryId))
          .toList();
    }
    return getProducts(forceRefresh: forceRefresh, categoryId: categoryId);
  }

  Future<Category?> loadCategoryById(int id) async {
    final uri = Uri.parse(
      '$_baseUrl/loadCategory',
    ).replace(queryParameters: {'id': id.toString()});
    final response = await _safeGet(uri);
    final data = _decode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ProductException(
        _extractMessage(data) ??
            'Fetching category failed (HTTP ${response.statusCode}).',
      );
    }
    if (data is! Map<String, dynamic>) {
      throw ProductException('Unexpected category response format.');
    }

    final status = (data['status'] ?? '').toString().toLowerCase();
    final raw = data['data'];
    if (status != 'success' || raw is! List || raw.isEmpty) {
      throw ProductException(_extractMessage(data) ?? 'Category not found.');
    }

    final first = raw.first;
    if (first is! Map) {
      throw ProductException('Unexpected category payload.');
    }
    final mapped = Map<String, dynamic>.from(first);
    final level = _asInt(mapped['LEVEL']);
    final category = Category.fromJson(mapped);
    CategoriesData.upsertCategoryFromApi(level: level, category: category);
    return category;
  }

  Future<void> insertProduct(CreateProductRequest request) async {
    final payload = request.toJson();
    final endpoints = <String>[
      '$_baseUrl/insertproduct',
      '$_baseUrl/lnsertproduct',
      '$_baseUrl/insertProduct',
      '$_baseUrl/Insertproduct',
      '$_baseUrl/InsertProduct',
      '$_baseUrl/createproduct',
      '$_baseUrl/addproduct',
    ];

    final payloadVariants = <Map<String, dynamic>>[
      {
        'items': [payload],
      },
      {
        'data': [payload],
      },
      {'product': payload},
      {
        'products': [payload],
      },
      payload,
    ];

    String? lastError;
    final errors = <String>[];

    if (kDebugMode) {
      debugPrint('=== Product Insertion Debug ===');
      debugPrint('payload: $payload');
      debugPrint('===============================');
    }

    for (final endpoint in endpoints) {
      final endpointUri = Uri.parse(endpoint);
      for (final body in payloadVariants) {
        if (kDebugMode) {
          debugPrint('[InsertProduct] POST $endpointUri');
          debugPrint('[InsertProduct] body: $body');
        }
        final response = await _safePost(endpointUri, body: body);
        final data = _decode(response.body);
        if (kDebugMode) {
          debugPrint('[InsertProduct] status: ${response.statusCode}');
          debugPrint('[InsertProduct] response: ${response.body}');
        }
        if (response.statusCode < 200 || response.statusCode >= 300) {
          lastError =
              _extractMessage(data) ??
              'Inserting product failed (HTTP ${response.statusCode}).';
          errors.add('POST $endpoint -> HTTP ${response.statusCode}');
          continue;
        }

        final status = (data is Map<String, dynamic> ? data['status'] : null)
            ?.toString()
            .toLowerCase();
        if (status == 'error') {
          lastError = _extractMessage(data) ?? 'Inserting product failed.';
          errors.add('POST $endpoint -> status error');
          continue;
        }
        _invalidateProductsCache();
        return;
      }

      final getResponse = await _safeGet(
        endpointUri.replace(
          queryParameters: {
            for (final entry in payload.entries)
              entry.key: entry.value.toString(),
          },
        ),
      );
      final getData = _decode(getResponse.body);
      if (kDebugMode) {
        debugPrint('[InsertProduct] GET $endpointUri');
        debugPrint('[InsertProduct] GET status: ${getResponse.statusCode}');
        debugPrint('[InsertProduct] GET response: ${getResponse.body}');
      }
      if (getResponse.statusCode < 200 || getResponse.statusCode >= 300) {
        lastError =
            _extractMessage(getData) ??
            'Inserting product failed (HTTP ${getResponse.statusCode}).';
        errors.add('GET $endpoint -> HTTP ${getResponse.statusCode}');
        continue;
      }

      final getStatus =
          (getData is Map<String, dynamic> ? getData['status'] : null)
              ?.toString()
              .toLowerCase();
      if (getStatus == 'error') {
        lastError = _extractMessage(getData) ?? 'Inserting product failed.';
        errors.add('GET $endpoint -> status error');
        continue;
      }
      _invalidateProductsCache();
      return;
    }

    throw ProductException(
      '${lastError ?? 'Inserting product failed.'} (${errors.take(3).join(' | ')})',
    );
  }

  Future<void> updateProduct(UpdateProductRequest request) async {
    final payload = request.toJson();
    final endpoints = <String>[
      '$_baseUrl/UpdateItem',
      '$_baseUrl/updateitem',
      '$_baseUrl/updateItem',
      '$_baseUrl/updateproduct',
      '$_baseUrl/UpdateProduct',
      '$_baseUrl/updateProduct',
      '$_baseUrl/editproduct',
      '$_baseUrl/EditProduct',
    ];

    final payloadVariants = <Map<String, dynamic>>[
      {
        'items': [payload],
      },
      {
        'data': [payload],
      },
      {'product': payload},
      payload,
    ];

    String? lastError;
    final errors = <String>[];

    for (final endpoint in endpoints) {
      final endpointUri = Uri.parse(endpoint);
      for (final body in payloadVariants) {
        final response = await _safePost(endpointUri, body: body);
        final data = _decode(response.body);
        if (response.statusCode < 200 || response.statusCode >= 300) {
          lastError =
              _extractMessage(data) ??
              'Updating product failed (HTTP ${response.statusCode}).';
          errors.add('POST $endpoint -> HTTP ${response.statusCode}');
          continue;
        }

        final status = (data is Map<String, dynamic> ? data['status'] : null)
            ?.toString()
            .toLowerCase();
        if (status == 'error') {
          lastError = _extractMessage(data) ?? 'Updating product failed.';
          errors.add('POST $endpoint -> status error');
          continue;
        }
        _invalidateProductsCache();
        return;
      }

      final getResponse = await _safeGet(
        endpointUri.replace(
          queryParameters: {
            for (final entry in payload.entries)
              entry.key: entry.value.toString(),
          },
        ),
      );
      final getData = _decode(getResponse.body);
      if (getResponse.statusCode < 200 || getResponse.statusCode >= 300) {
        lastError =
            _extractMessage(getData) ??
            'Updating product failed (HTTP ${getResponse.statusCode}).';
        errors.add('GET $endpoint -> HTTP ${getResponse.statusCode}');
        continue;
      }

      final getStatus =
          (getData is Map<String, dynamic> ? getData['status'] : null)
              ?.toString()
              .toLowerCase();
      if (getStatus == 'error') {
        lastError = _extractMessage(getData) ?? 'Updating product failed.';
        errors.add('GET $endpoint -> status error');
        continue;
      }
      _invalidateProductsCache();
      return;
    }

    throw ProductException(
      '${lastError ?? 'Updating product failed.'} (${errors.take(3).join(' | ')})',
    );
  }

  Future<ApiProductDetails> getItemDetails({required int itemId}) async {
    final uri = Uri.parse(
      '$_baseUrl/GetItemDetails',
    ).replace(queryParameters: {'item_id': itemId.toString()});
    final response = await _safeGet(uri);
    final data = _decode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ProductException(
        _extractMessage(data) ??
            'Fetching item details failed (HTTP ${response.statusCode}).',
      );
    }
    if (data is! Map<String, dynamic>) {
      throw ProductException('Unexpected item details response format.');
    }

    final status = (data['status'] ?? '').toString().toLowerCase();
    final rawDetails = data['data'];
    if (status != 'success' || rawDetails is! List || rawDetails.isEmpty) {
      throw ProductException(
        _extractMessage(data) ?? 'No item details found for this product.',
      );
    }
    final first = rawDetails.first;
    if (first is! Map) {
      throw ProductException('Unexpected item details payload.');
    }
    return ApiProductDetails.fromJson(Map<String, dynamic>.from(first));
  }

  Future<List<ApiItemImage>> loadItemImages({required int itemId}) async {
    final uri = Uri.parse(
      '$_baseUrl/LoadImageByItemID',
    ).replace(queryParameters: {'id': itemId.toString()});
    final response = await _safeGet(uri);
    final data = _decode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ProductException(
        _extractMessage(data) ??
            'Fetching item images failed (HTTP ${response.statusCode}).',
      );
    }

    if (data is! List) {
      throw ProductException('Unexpected item images response format.');
    }

    final images = data
        .whereType<Map>()
        .map((item) => ApiItemImage.fromJson(Map<String, dynamic>.from(item)))
        .where((item) => item.imagePath.trim().isNotEmpty)
        .toList();
    if (images.isEmpty) return const [];

    final defaultIndex = images.indexWhere((item) => item.isDefault == 1);
    if (defaultIndex <= 0) {
      return images;
    }

    final ordered = <ApiItemImage>[images[defaultIndex]];
    for (var i = 0; i < images.length; i++) {
      if (i == defaultIndex) continue;
      ordered.add(images[i]);
    }
    return ordered;
  }

  Future<http.Response> _safePost(
    Uri uri, {
    required Map<String, dynamic> body,
  }) async {
    try {
      return await _client
          .post(uri, headers: _defaultHeaders(), body: jsonEncode(body))
          .timeout(_timeout);
    } on TimeoutException {
      throw ProductException('Request timed out. Please try again.');
    } catch (_) {
      throw ProductException('Network error. Please try again.');
    }
  }

  Future<http.Response> _safeGet(Uri uri) async {
    try {
      return await _client
          .get(uri, headers: _defaultHeaders())
          .timeout(_timeout);
    } on TimeoutException {
      throw ProductException('Request timed out. Please try again.');
    } catch (_) {
      throw ProductException('Network error. Please try again.');
    }
  }

  Future<http.Response?> _safePostOrNull(
    Uri uri, {
    required Map<String, dynamic> body,
  }) async {
    try {
      return await _safePost(uri, body: body);
    } catch (_) {
      return null;
    }
  }

  Future<http.Response?> _safeGetOrNull(Uri uri) async {
    try {
      return await _safeGet(uri);
    } catch (_) {
      return null;
    }
  }

  void _invalidateProductsCache() {
    _cachedProducts = <ApiProduct>[];
    _lastProductsFetch = null;
  }

  Map<String, String> _defaultHeaders() {
    return const {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  dynamic _decode(String body) {
    if (body.isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  List<Map<String, dynamic>> _extractItems(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (data is Map<String, dynamic>) {
      final candidates = [
        data['item'],
        data['ITEM'],
        data['items'],
        data['Items'],
        data['ITEMS'],
        data['product'],
        data['PRODUCT'],
        data['products'],
        data['Products'],
        data['PRODUCTS'],
        data['data'],
        data['Data'],
        data['DATA'],
        data['result'],
        data['RESULT'],
        data['records'],
        data['Records'],
        data['RECORDS'],
      ];
      for (final rawItems in candidates) {
        if (rawItems is Map) {
          return [Map<String, dynamic>.from(rawItems)];
        }
        if (rawItems is List) {
          return rawItems
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        }
      }
    }
    return const [];
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final candidates = [data['message'], data['error'], data['detail']];

      for (final candidate in candidates) {
        if (candidate is String && candidate.trim().isNotEmpty) {
          final normalized = candidate.trim().toLowerCase();
          if (normalized.contains('not found')) {
            return 'Requested endpoint was not found. Please verify API endpoint.';
          }
          return candidate;
        }
      }
    }
    return null;
  }

  int _asInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse((value ?? '').toString()) ?? 0;
  }
}

class ProductException implements Exception {
  final String message;
  ProductException(this.message);

  @override
  String toString() => message;
}
