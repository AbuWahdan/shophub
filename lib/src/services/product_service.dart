import 'dart:async';
import 'dart:convert';

import '../../data/categories_data.dart';
import '../../models/category.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:http/http.dart' as http;

import '../config/size_options.dart';
import '../model/api_order.dart';
import '../model/cart_api.dart';
import '../model/product_api.dart';
import 'api_client.dart';

class ProductService {
  static const String _baseUrl = 'https://oracleapex.com/ords/topg/products';
  static const String _getProductsUrl = '$_baseUrl/GetProducts';
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
    int? detId,
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

    final request = GetProductsRequest(
      createdBy: normalizedCreatedBy,
      categoryId: categoryId,
      detId: detId,
    );
    final endpoints = <String>[_getProductsUrl];

    String? lastError;
    final errors = <String>[];
    var hasRecoverableEmpty = false;

    for (final endpoint in endpoints) {
      final uri = Uri.parse(endpoint);
      final queryBase = {
        ...uri.queryParameters,
        ...request.toQueryParameters(),
      };
      final getRequests = <Future<http.Response?>>[
        _safeGetOrNull(
          uri.replace(
            queryParameters: {
              ...queryBase,
              if (hasCreatedByFilter) 'created_by': normalizedCreatedBy,
            },
          ),
        ),
      ];
      if (hasCreatedByFilter) {
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
              ? {...request.toBody(), 'created_by': normalizedCreatedBy}
              : request.toBody(),
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
        var products = _groupProductsByItemId(
          items.map(ApiProduct.fromJson).toList(),
        );
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
    final endpoints = <String>['$_baseUrl/InsertProduct'];
    final body = <String, dynamic>{
      'items': [payload],
    };

    String? lastError;
    final errors = <String>[];

    if (kDebugMode) {
      debugPrint('=== Product Insertion Debug ===');
      debugPrint('payload: $payload');
      debugPrint('body: $body');
      debugPrint('===============================');
    }

    for (final endpoint in endpoints) {
      final endpointUri = Uri.parse(endpoint);
      if (kDebugMode) {
        debugPrint('[InsertProduct] POST $endpointUri');
        debugPrint('[InsertProduct] body: $body');
        debugPrint(
          '[InsertProduct] body(json): ${jsonEncode(body)}',
        );
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

      if (kDebugMode) {
        debugPrint(
          '[InsertProduct] raw response before success check: ${response.body}',
        );
      }
      if (_hasExplicitInsertError(data, response.body)) {
        lastError =
            _extractMessage(data) ??
            'Inserting product failed due to backend error response.';
        errors.add('POST $endpoint -> explicit backend error');
        continue;
      }
      final insertedItemId = _extractInsertedItemId(data);
      if (insertedItemId > 0) {
        _logInsertedItemSize(itemId: insertedItemId);
      } else if (kDebugMode) {
        debugPrint(
          '[InsertProduct] Could not resolve inserted item id from response, skipping GetItemDetails size verification.',
        );
      }
      _invalidateProductsCache();
      return;
    }

    throw ProductException(
      '${lastError ?? 'Inserting product failed.'} (${errors.take(3).join(' | ')})',
    );
  }

  bool _hasExplicitInsertError(dynamic data, String rawBody) {
    final raw = rawBody.toLowerCase();
    if (raw.contains('ora-')) return true;
    if (raw.contains('pl/sql')) return true;

    if (data is Map<String, dynamic>) {
      final status = (data['status'] ?? '').toString().toLowerCase().trim();
      final result = (data['result'] ?? '').toString().toLowerCase().trim();
      final error = (data['error'] ?? '').toString().trim();
      final message = (data['message'] ?? '').toString().toLowerCase().trim();
      if (status == 'error' || status == 'failed' || status == 'fail') {
        return true;
      }
      if (result == 'error' || result == 'failed' || result == 'fail') {
        return true;
      }
      if (error.isNotEmpty) return true;
      if (message.contains('ora-') || message.contains('pl/sql')) {
        return true;
      }
    }

    return false;
  }

  void _debugLogUpdatePayloadTypes(Map<String, dynamic> payload) {
    if (!kDebugMode) return;
    debugPrint(
      '[UpdateProduct][Types] item_qty: ${payload['item_qty']} (${payload['item_qty']?.runtimeType})',
    );
    debugPrint(
      '[UpdateProduct][Types] is_active: ${payload['is_active']} (${payload['is_active']?.runtimeType})',
    );
    final details = payload['details'];
    if (details is List && details.isNotEmpty && details.first is Map) {
      final firstDetail = Map<String, dynamic>.from(details.first as Map);
      debugPrint(
        '[UpdateProduct][Types] details.item_price: ${firstDetail['item_price']} (${firstDetail['item_price']?.runtimeType})',
      );
      debugPrint(
        '[UpdateProduct][Types] details.discount: ${firstDetail['discount']} (${firstDetail['discount']?.runtimeType})',
      );
      debugPrint(
        '[UpdateProduct][Types] details.item_qty: ${firstDetail['item_qty']} (${firstDetail['item_qty']?.runtimeType})',
      );
    }
  }

  Future<UpdateProductResult> updateProduct(UpdateProductRequest request) async {
    // toJson() now produces the correct shape with "item_details" / "detail_id" / "size"
    final payload = request.toJson();
    final body = <String, dynamic>{'items': [payload]};
    final endpointUri = Uri.parse('$_baseUrl/UpdateItem');

    if (kDebugMode) {
      debugPrint('=== Product Update Debug ===');
      debugPrint('[UpdateProduct] endpoint : $endpointUri');
      debugPrint('[UpdateProduct] body(json): ${jsonEncode(body)}');
      debugPrint('============================');
    }

    final response = await _safePost(endpointUri, body: body);
    final data = _decode(response.body);

    debugPrint('[UpdateProduct] status  : ${response.statusCode}');
    debugPrint('[UpdateProduct] response: ${response.body}');

    final rawLower = response.body.toLowerCase();
    if (rawLower.contains('ora-') || rawLower.contains('pl/sql')) {
      throw ProductException(response.body);
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ProductException(
        response.body.trim().isNotEmpty
            ? response.body
            : (_extractMessage(data) ??
            'Updating product failed (HTTP ${response.statusCode}).'),
      );
    }

    _invalidateProductsCache();
    return UpdateProductResult(
      statusCode: response.statusCode,
      rawBody: response.body,
      data: data,
    );
  }

  /// Calls the delete-check endpoint for a single variant detail.
  ///
  /// • Returns **true**  → item has no orders; the API has already hard-deleted
  ///   the record — remove it from the UI list.
  /// • Returns **false** → item has existing orders; deletion was blocked —
  ///   keep the row, just set is_active = 0 in the update payload.
  Future<bool> deleteVariantDetail(int itemDetId) async {
    final uri = Uri.parse('$_baseUrl/DeleteItemDetails');
    final response = await _safePost(uri, body: {'item_det_id': itemDetId});

    debugPrint('[DeleteVariant] item_det_id: $itemDetId');
    debugPrint('[DeleteVariant] response   : ${response.body}');

    try {
      final raw = response.body.trim();
      final data = jsonDecode(raw);

      // Handle common response shapes: bare int, {"result":1}, [1]
      if (data is int) return data == 1;
      if (data is List && data.isNotEmpty) {
        final first = data.first;
        if (first is int) return first == 1;
        if (first is Map) {
          final v = first.values.first;
          return _asInt(v) == 1;
        }
      }
      if (data is Map) {
        final v = data['result'] ?? data['status'] ?? data['value'] ??
            data['RESULT'] ?? data['STATUS'] ?? data.values.first;
        return _asInt(v) == 1;
      }
    } catch (_) {
      // Bare string like "1" or "[1]"
      final raw = response.body.trim();
      return raw == '1' || raw == '[1]' || raw.contains('"1"');
    }
    return false;
  }

// Helper — keeps DRY with existing _asInt usages in the file
//   static int _asInt(dynamic v) {
//     if (v is num) return v.toInt();
//     return int.tryParse((v ?? '').toString()) ?? 0;
//   }

  String _resolveSizeLabel(int sizeId) {
    if (sizeId <= 0) return '';
    final option = findSizeOptionById(sizeId);
    return option?.name ?? sizeId.toString();
  }

  Future<void> insertProductDetails({
    required int itemId,
    required List<CreateProductDetail> details,
  }) async {
    if (itemId <= 0 || details.isEmpty) {
      throw ProductException('Invalid product details payload.');
    }
    final endpoint = Uri.parse('$_baseUrl/InsertProductDetails');
    final body = <String, dynamic>{
      'items': details
          .map(
            (detail) {
              final detailMap = {
                'item_id': itemId,
                'ITEM_ID': itemId,
                ...detail.toJson(),
              };
              // Override item_size with resolved string label
              final sizeLabel = _resolveSizeLabel(detail.itemSize);
              if (sizeLabel.isNotEmpty) {
                detailMap['item_size'] = sizeLabel;
                detailMap['ITEM_SIZE'] = sizeLabel;
              }
              return detailMap;
            },
          )
          .toList(),
    };
    if (kDebugMode) {
      debugPrint('[InsertProductDetails] POST $endpoint');
      debugPrint('[InsertProductDetails] body: $body');
      debugPrint(
        '[InsertProductDetails] body(json): ${jsonEncode(body)}',
      );
    }
    final response = await _safePost(endpoint, body: body);
    final data = _decode(response.body);
    if (kDebugMode) {
      debugPrint('[InsertProductDetails] status: ${response.statusCode}');
      debugPrint('[InsertProductDetails] response: ${response.body}');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ProductException(
        _extractMessage(data) ??
            'Inserting product details failed (HTTP ${response.statusCode}).',
      );
    }
    final status = (data is Map<String, dynamic> ? data['status'] : null)
        ?.toString()
        .toLowerCase();
    if (status == 'error' || status == 'failed' || status == 'fail') {
      throw ProductException(
        _extractMessage(data) ?? 'Inserting product details failed.',
      );
    }
  }

  Future<List<ApiCartItem>> getItemCart({required String username}) async {
    final normalizedUsername = username.trim();
    if (normalizedUsername.isEmpty) {
      throw ProductException('Unable to load cart: username is missing.');
    }

    final uri = Uri.parse(
      '$_baseUrl/GetItemCart',
    ).replace(queryParameters: {'USERNAME': normalizedUsername});
    final response = await _safeGet(uri);
    final data = _decode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ProductException(
        _extractMessage(data) ??
            'Fetching cart failed (HTTP ${response.statusCode}).',
      );
    }

    final items = _extractItems(data);
    if (items.isEmpty) return const [];
    return items.map(ApiCartItem.fromJson).toList();
  }

  Future<void> addItemToCart(AddItemToCartRequest request) async {
    final endpoint = Uri.parse('$_baseUrl/AddItemToCart');
    final payload = request.toJson();
    if (kDebugMode) {
      debugPrint('[AddItemToCart] POST $endpoint');
      debugPrint('[AddItemToCart] body: $payload');
    }
    final response = await _safePost(endpoint, body: payload);
    final data = _decode(response.body);
    if (kDebugMode) {
      debugPrint('[AddItemToCart] status: ${response.statusCode}');
      debugPrint('[AddItemToCart] response: ${response.body}');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ProductException(
        _extractMessage(data) ??
            'Adding item to cart failed (HTTP ${response.statusCode}).',
      );
    }
    final status = (data is Map<String, dynamic> ? data['status'] : null)
        ?.toString()
        .toLowerCase();
    if (status == 'error') {
      throw ProductException(
        _extractMessage(data) ?? 'Adding item to cart failed.',
      );
    }
  }

  Future<ApiProductDetails> getItemDetails({required int itemId}) async {
    final rows = await getItemDetailsRows(itemId: itemId);
    if (rows.isEmpty) {
      throw ProductException('No item details found for this product.');
    }
    return rows.first;
  }

  Future<List<ApiProductDetails>> getItemDetailsRows({
    required int itemId,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/GetItemDetails',
    ).replace(queryParameters: {'item_id': itemId.toString()});
    debugPrint('[GetItemDetails] GET $uri');
    final response = await _safeGet(uri);
    final data = _decode(response.body);
    debugPrint('[GetItemDetails] status: ${response.statusCode}');
    debugPrint('[GetItemDetails] response: ${response.body}');
    final detailsRawLower = response.body.toLowerCase();
    if (detailsRawLower.contains('ora-') ||
        detailsRawLower.contains('pl/sql')) {
      throw ProductException(response.body);
    }
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
    return rawDetails
        .whereType<Map>()
        .map(
          (row) => ApiProductDetails.fromJson(Map<String, dynamic>.from(row)),
        )
        .toList();
  }

  Future<List<ApiItemImage>> getItemImages({required int itemId}) async {
    final uri = Uri.parse(
      '$_baseUrl/GetItemImages',
    ).replace(queryParameters: {'id': itemId.toString()});
    final response = await _safeGet(uri);
    final data = _decode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ProductException(
        _extractMessage(data) ??
            'Fetching item images failed (HTTP ${response.statusCode}).',
      );
    }

    final rawImages = _extractImageRows(data);
    final images = <ApiItemImage>[];
    for (final item in rawImages) {
      try {
        final parsed = ApiItemImage.fromJson(item);
        if (parsed.imagePath.trim().isNotEmpty) {
          images.add(parsed);
        }
      } catch (_) {
        // Ignore malformed image rows and continue loading the product.
      }
    }
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

  Future<List<ApiItemImage>> loadItemImages({required int itemId}) {
    return getItemImages(itemId: itemId);
  }

  Future<void> updateItemImage({
    required int imageId,
    required String imagePath,
  }) async {
    final normalizedPath = imagePath.trim();
    if (imageId <= 0 || normalizedPath.isEmpty) {
      throw ProductException('Invalid image update payload.');
    }
    final endpoint = Uri.parse('$_baseUrl/UpdateItemImages');
    final body = <String, dynamic>{
      'items': [
        {
          'image_id': imageId,
          'IMAGE_ID': imageId,
          'image_path': normalizedPath,
          'IMAGE_PATH': normalizedPath,
        },
      ],
    };
    final response = await _safePost(endpoint, body: body);
    final data = _decode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ProductException(
        _extractMessage(data) ??
            'Updating item image failed (HTTP ${response.statusCode}).',
      );
    }
    final status = (data is Map<String, dynamic> ? data['status'] : null)
        ?.toString()
        .toLowerCase();
    if (status == 'error') {
      throw ProductException(_extractMessage(data) ?? 'Updating image failed.');
    }
  }

  List<Map<String, dynamic>> _extractImageRows(dynamic data) {
    if (data == null) return const [];
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    if (data is Map<String, dynamic>) {
      final candidates = [
        data['data'],
        data['items'],
        data['images'],
        data['result'],
      ];
      for (final candidate in candidates) {
        if (candidate is List) {
          return candidate
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        }
      }
    }
    return const [];
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

  int _extractInsertedItemId(dynamic data) {
    if (data is Map<String, dynamic>) {
      final direct = _asInt(data['item_id'] ?? data['ITEM_ID']);
      if (direct > 0) return direct;
      final items = data['items'];
      if (items is List && items.isNotEmpty && items.first is Map) {
        final first = Map<String, dynamic>.from(items.first as Map);
        final fromItems = _asInt(first['item_id'] ?? first['ITEM_ID']);
        if (fromItems > 0) return fromItems;
      }
      final rows = data['data'];
      if (rows is List && rows.isNotEmpty && rows.first is Map) {
        final first = Map<String, dynamic>.from(rows.first as Map);
        final fromData = _asInt(first['item_id'] ?? first['ITEM_ID']);
        if (fromData > 0) return fromData;
      }
    }
    return 0;
  }

  Future<void> _logInsertedItemSize({required int itemId}) async {
    if (!kDebugMode) return;
    try {
      final rows = await getItemDetailsRows(itemId: itemId);
      final itemSizes = rows.map((row) => row.itemSize).toList();
      debugPrint(
        '[InsertProduct] GetItemDetails item_id=$itemId ITEM_SIZE values after insert: $itemSizes',
      );
    } catch (error) {
      debugPrint(
        '[InsertProduct] Failed to load GetItemDetails after insert for item_id=$itemId: $error',
      );
    }
  }

  int _asInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse((value ?? '').toString()) ?? 0;
  }

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

      final variants = <ApiProductVariant>[];
      final seenVariantKeys = <String>{};
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
              '${variant.detId}|${variant.brand}|${variant.color}|${variant.itemSize}|${variant.itemPrice}|${variant.itemQty}';
          if (seenVariantKeys.add(key)) {
            variants.add(variant);
          }
        }
      }

      final sizes = variants
          .map((variant) => variant.itemSize.trim())
          .where((size) => size.isNotEmpty)
          .toSet()
          .toList();
      final colors = variants
          .map((variant) => variant.color.trim())
          .where((color) => color.isNotEmpty)
          .toSet()
          .toList();

      ApiProductVariant? displayVariant;
      for (final variant in variants) {
        if (displayVariant == null) {
          displayVariant = variant;
          continue;
        }
        final candidatePrice =
            variant.itemPrice * (1 - (variant.discount / 100));
        final currentPrice =
            displayVariant.itemPrice * (1 - (displayVariant.discount / 100));
        if (candidatePrice < currentPrice) {
          displayVariant = variant;
        }
      }

      final mergedImages = rows
          .expand((row) => row.images)
          .map((image) => image.trim())
          .where((image) => image.isNotEmpty)
          .toSet()
          .toList();

      final displayPrice = displayVariant == null
          ? base.itemPrice
          : (displayVariant.itemPrice * (1 - (displayVariant.discount / 100)));

      result.add(
        ApiProduct(
          id: base.id,
          detId: displayVariant?.detId ?? base.detId,
          itemName: base.itemName,
          itemDesc: base.itemDesc,
          itemPrice: displayPrice > 0 ? displayPrice : base.itemPrice,
          itemQty: displayVariant?.itemQty ?? base.itemQty,
          itemImgUrl: mergedImages.isNotEmpty
              ? mergedImages.first
              : base.itemImgUrl,
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

  Future<List<ApiOrder>> getOrders({required String username}) async {
    final normalizedUsername = username.trim();
    if (normalizedUsername.isEmpty) {
      throw ProductException('Username is required to fetch orders.');
    }

    final uri = Uri.parse(
      '$_baseUrl/GetOrders',
    ).replace(queryParameters: {'l_USERNAME': normalizedUsername});

    if (kDebugMode) {
      debugPrint('[GetOrders] GET $uri');
    }

    try {
      final response = await _safeGet(uri);

      if (kDebugMode) {
        debugPrint('[GetOrders] status: ${response.statusCode}');
        debugPrint('[GetOrders] response: ${response.body}');
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ProductException(
          'Failed to fetch orders (HTTP ${response.statusCode}).',
        );
      }

      final data = _decode(response.body);

      if (data is! Map<String, dynamic>) {
        throw ProductException('Invalid orders response format.');
      }

      final apiResponse = ApiOrderResponse.fromJson(data);

      if (apiResponse.status != 'success') {
        throw ProductException(
          'Failed to fetch orders: ${apiResponse.status}',
        );
      }

      return apiResponse.data;
    } on ProductException {
      rethrow;
    } catch (error) {
      throw ProductException('Error fetching orders: $error');
    }
  }
}

class ProductException implements Exception {
  final String message;
  ProductException(this.message);

  @override
  String toString() => message;
}

class UpdateProductResult {
  final int statusCode;
  final String rawBody;
  final dynamic data;

  const UpdateProductResult({
    required this.statusCode,
    required this.rawBody,
    required this.data,
  });
}
