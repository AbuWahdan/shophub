import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../models/search_history_model.dart';
import '../models/search_result_model.dart';

/// Thrown when the server returns a non-2xx response.
class SearchApiException implements Exception {
  const SearchApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() =>
      'SearchApiException(${statusCode != null ? '$statusCode ' : ''}$message)';
}

/// All network calls for the search feature.
///
/// Replace [_baseUrl] with your actual Oracle APEX base URL.
abstract final class _ApiEndpoints {
  static const String base = 'https://oracleapex.com/ords/topg';

  static const String searchProducts = '$base/products/GetProductBySearch';
  static const String getHistory = '$base/users/GetSearchHistoryByUserName';
  static const String insertHistory = '$base/users/InsertSearchHistory';
  static const String deleteHistory = '$base/users/DeleteSearcHistory';
  static const String deleteAllHistory = '$base/users/DeleteAllSearchHistory';
}

class SearchRepository {
  SearchRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const Duration _timeout = Duration(seconds: 15);

  static const Map<String, String> _headers = {
    HttpHeaders.contentTypeHeader: 'application/json',
    HttpHeaders.acceptHeader: 'application/json',
  };

  // ── Search products ────────────────────────────────────────────────────────

  /// Searches products by [query] text.
  /// Returns an empty list when nothing matches.
  Future<List<SearchResultModel>> searchProducts(String query) async {
    final body = jsonEncode({'search': query});

    final response = await _client
        .post(
      Uri.parse(_ApiEndpoints.searchProducts),
      headers: _headers,
      body: body,
    )
        .timeout(_timeout);

    _assertSuccess(response, context: 'searchProducts');

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final data = json['data'] as List<dynamic>? ?? [];

    return data
        .cast<Map<String, dynamic>>()
        .map(SearchResultModel.fromJson)
        .toList();
  }

  // ── Search history ─────────────────────────────────────────────────────────

  /// Fetches the search history for [username].
  /// Returns the latest [limit] entries (default 10).
  Future<List<SearchHistoryModel>> getSearchHistory(
      String username, {
        int limit = 10,
      }) async {
    final body = jsonEncode({'username': username});

    final response = await _client
        .post(
      Uri.parse(_ApiEndpoints.getHistory),
      headers: _headers,
      body: body,
    )
        .timeout(_timeout);

    _assertSuccess(response, context: 'getSearchHistory');

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final data = json['data'] as List<dynamic>? ?? [];

    final items = data
        .cast<Map<String, dynamic>>()
        .map(SearchHistoryModel.fromJson)
        .toList();

    // Return only the latest [limit] entries.
    if (items.length > limit) return items.sublist(0, limit);
    return items;
  }

  /// Records a search in the server's history log.
  ///
  /// Fire-and-forget in most call sites — failures are swallowed so they
  /// never block the UX; they are only logged.
  Future<void> insertSearchHistory({
    required String username,
    required String searchText,
    String searchType = 'PRODUCT',
    String deviceId = 'UNKNOWN_DEVICE',
    String ipAddress = '0.0.0.0',
  }) async {
    try {
      final body = jsonEncode({
        'username': username,
        'search_text': searchText,
        'search_type': searchType,
        'device_id': deviceId,
        'ip_address': ipAddress,
      });

      await _client
          .post(
        Uri.parse(_ApiEndpoints.insertHistory),
        headers: _headers,
        body: body,
      )
          .timeout(_timeout);
      // We intentionally do not throw here; history recording is best-effort.
    } catch (_) {
      // Silently ignore — history logging must never disrupt search results.
    }
  }

  /// Deletes a single history entry by [id].
  Future<void> deleteSearchHistory(int id) async {
    final body = jsonEncode({'id': id});

    final response = await _client
        .post(
      Uri.parse(_ApiEndpoints.deleteHistory),
      headers: _headers,
      body: body,
    )
        .timeout(_timeout);

    _assertSuccess(response, context: 'deleteSearchHistory');
  }

  /// Clears all history entries for [username].
  Future<void> deleteAllSearchHistory(String username) async {
    final body = jsonEncode({'username': username});

    final response = await _client
        .post(
      Uri.parse(_ApiEndpoints.deleteAllHistory),
      headers: _headers,
      body: body,
    )
        .timeout(_timeout);

    _assertSuccess(response, context: 'deleteAllSearchHistory');
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _assertSuccess(http.Response response, {required String context}) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw SearchApiException(
        'Request failed in $context: ${response.body}',
        statusCode: response.statusCode,
      );
    }
  }
}