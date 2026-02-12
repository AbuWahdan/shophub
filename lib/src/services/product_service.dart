import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/product_api.dart';
import 'api_client.dart';

class ProductService {
  static const String _baseUrl = 'https://oracleapex.com/ords/topg/products';
  static const String _getProductsUrl = '$_baseUrl/getproduct';
  static const Duration _timeout = Duration(seconds: 20);

  final http.Client _client;

  ProductService({http.Client? client}) : _client = client ?? ApiClient();

  Future<List<ApiProduct>> getProducts() async {
    final endpoints = <String>[
      _getProductsUrl,
      '$_baseUrl/getProduct',
      '$_baseUrl/Getproduct',
      '$_baseUrl/GetProduct',
    ];

    String? lastError;
    final errors = <String>[];

    for (final endpoint in endpoints) {
      final uri = Uri.parse(endpoint);
      final attempts = <Future<http.Response> Function()>[
        () => _safePost(uri, body: const {}),
        () => _safePost(uri, body: const {'items': []}),
        () => _safePost(uri, body: const {'data': []}),
        () => _safeGet(uri),
      ];

      for (final attempt in attempts) {
        final response = await attempt();
        final data = _decode(response.body);
        if (response.statusCode < 200 || response.statusCode >= 300) {
          lastError =
              _extractMessage(data) ??
              'Fetching products failed (HTTP ${response.statusCode}).';
          errors.add('$endpoint -> HTTP ${response.statusCode}');
          continue;
        }

        final items = _extractItems(data);
        if (items.isEmpty) {
          errors.add('$endpoint -> empty');
          continue;
        }
        return items.map(ApiProduct.fromJson).toList();
      }
    }

    throw ProductException(
      '${lastError ?? 'Fetching products failed.'} (${errors.take(3).join(' | ')})',
    );
  }

  Future<void> insertProduct(CreateProductRequest request) async {
    final payload = request.toJson();
    final payloadUpper = <String, dynamic>{
      'ITEM_NAME': payload['item_name'],
      'ITEM_DESC': payload['item_desc'],
      'ITEM_PRICE': payload['item_price'],
      'ITEM_QTY': payload['item_qty'],
      'ITEM_IMG_URL': payload['item_img_url'],
      'CATEGORY_ID': payload['category_id'],
      'CREATED_BY': payload['created_by'],
      'IS_ACTIVE': payload['is_active'],
    };
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
      {
        'items': [payloadUpper],
      },
      {
        'data': [payloadUpper],
      },
      payload,
      payloadUpper,
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
      return;
    }

    throw ProductException(
      '${lastError ?? 'Inserting product failed.'} (${errors.take(3).join(' | ')})',
    );
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
        data['items'],
        data['ITEMS'],
        data['data'],
        data['DATA'],
        data['records'],
        data['RECORDS'],
      ];
      for (final rawItems in candidates) {
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
            return 'Unable to insert product. Please verify API endpoint.';
          }
          return candidate;
        }
      }
    }
    return null;
  }
}

class ProductException implements Exception {
  final String message;
  ProductException(this.message);

  @override
  String toString() => message;
}
