import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'storage_service.dart';

class ApiClient extends http.BaseClient {
  final http.Client _inner;
  final StorageService _storageService;

  ApiClient({
    http.Client? inner,
    StorageService? storageService,
  })  : _inner = inner ?? http.Client(),
        _storageService = storageService ?? StorageService();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    request.headers.putIfAbsent('Accept', () => 'application/json');
    request.headers.putIfAbsent('Content-Type', () => 'application/json');

    final token = await _storageService.getAuthToken();
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    if (kDebugMode) {
      debugPrint('[API] ${request.method} ${request.url}');
    }

    final response = await _inner.send(request);
    if (response.statusCode == 401) {
      await _storageService.clearAll();
    }
    return response;
  }
}
