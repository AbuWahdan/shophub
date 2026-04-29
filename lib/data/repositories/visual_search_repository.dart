import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/api/api_constants.dart';
import '../../core/exceptions/app_exception.dart';
import '../../models/product_api.dart';
import '../../services/api_client.dart';

class VisualSearchRepository {
  final http.Client _client;

  VisualSearchRepository({http.Client? client})
    : _client = client ?? ApiClient();

  Future<List<ApiProduct>> searchByImage(File imageFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.searchByImage}'),
      );
      request.headers['Accept'] = 'application/json';
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      if (kDebugMode) {
        debugPrint('[VisualSearchRepository] POST ${request.url}');
        debugPrint('[VisualSearchRepository] image=${imageFile.path}');
      }

      final streamed = await _client
          .send(request)
          .timeout(ApiConstants.timeout);
      final response = await http.Response.fromStream(streamed);

      if (kDebugMode) {
        debugPrint(
          '[VisualSearchRepository] status=${response.statusCode} body=${response.body}',
        );
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ServerException(
          _extractMessage(_decode(response.body)) ??
              'Visual search failed (HTTP ${response.statusCode}).',
          statusCode: response.statusCode,
        );
      }

      final rawItems = _extractItems(_decode(response.body));
      return rawItems.map(ApiProduct.fromJson).toList();
    } on TimeoutException {
      throw TimeoutException('Visual search timed out. Please try again.');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[VisualSearchRepository] Error searching by image: $e');
      }
      rethrow;
    }
  }

  dynamic _decode(String body) {
    if (body.trim().isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  List<Map<String, dynamic>> _extractItems(dynamic response) {
    if (response == null) return const [];

    if (response is List) {
      return response.whereType<Map>().map(Map<String, dynamic>.from).toList();
    }

    if (response is Map<String, dynamic>) {
      final candidates = <dynamic>[
        response['data'],
        response['DATA'],
        response['items'],
        response['ITEMS'],
        response['products'],
        response['PRODUCTS'],
        response['result'],
        response['RESULT'],
      ];

      for (final candidate in candidates) {
        if (candidate is List) {
          return candidate
              .whereType<Map>()
              .map(Map<String, dynamic>.from)
              .toList();
        }
      }
    }

    return const [];
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      for (final key in ['message', 'error', 'detail', 'MESSAGE', 'ERROR']) {
        final value = data[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
    }
    return null;
  }
}
