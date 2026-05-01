import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'app_exception.dart';
import 'api_constants.dart';

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> get _headers => const {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Uri _uri(String endpoint, [Map<String, String>? queryParams]) {
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    return queryParams != null
        ? uri.replace(queryParameters: queryParams)
        : uri;
  }

  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParams,
    bool isReadOperation = true,
  }) async {
    try {
      final response = await _client
          .get(_uri(endpoint, queryParams), headers: _headers)
          .timeout(ApiConstants.timeout);
      return _handle(response, isReadOperation: isReadOperation);
    } on TimeoutException {
      throw TimeoutException('Request timed out. Please try again.');
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error: $e');
    }
  }

  Future<dynamic> post(
    String endpoint, {
    required Map<String, dynamic> body,
    bool isReadOperation = false,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('[API] POST ${ApiConstants.baseUrl}$endpoint');
        debugPrint('[API] body: ${jsonEncode(body)}');
      }
      final response = await _client
          .post(_uri(endpoint), headers: _headers, body: jsonEncode(body))
          .timeout(ApiConstants.timeout);
      if (kDebugMode) {
        debugPrint('[API] status: ${response.statusCode}');
        debugPrint('[API] response: ${response.body}');
      }
      return _handle(response, isReadOperation: isReadOperation);
    } on TimeoutException {
      throw TimeoutException('Request timed out. Please try again.');
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error: $e');
    }
  }

  dynamic _handle(http.Response response, {required bool isReadOperation}) {
    final body = response.body;

    // HTTP error → always throw
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ServerException(
        _extractMessage(_decode(body)) ??
            'Server error (HTTP ${response.statusCode})',
        statusCode: response.statusCode,
      );
    }

    final decoded = _decode(body);
    if (decoded != null || body.trim().isEmpty) {
      return decoded;
    }

    final bodyLower = body.toLowerCase();
    if (bodyLower.contains('ora-') || bodyLower.contains('pl/sql')) {
      if (isReadOperation) {
        throw ServerException(body);
      } else {
        return null;
      }
    }

    return isReadOperation ? body : null;
  }

  dynamic _decode(String body) {
    if (body.trim().isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      for (final key in ['message', 'error', 'detail', 'MESSAGE', 'ERROR']) {
        final v = data[key];
        if (v is String && v.trim().isNotEmpty) return v.trim();
      }
    }
    return null;
  }
}
