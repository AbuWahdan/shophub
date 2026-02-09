import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/user.dart';
import 'api_client.dart';
import 'storage_service.dart';

class AuthService {
  static const String _baseUrl = 'https://oracleapex.com/ords/topg/users';
  static const String _loginUrl = '$_baseUrl/login';
  static const String _registerUrl = '$_baseUrl/register';
  static const Duration _timeout = Duration(seconds: 20);

  late final StorageService _storageService;
  late final http.Client _client;

  AuthService({
    StorageService? storageService,
    http.Client? client,
  }) {
    _storageService = storageService ?? StorageService();
    _client = client ?? ApiClient(storageService: _storageService);
  }

  // ========================= LOGIN =========================

  Future<AuthSession> login(String username, String password) async {
    final uri = Uri.parse(_loginUrl).replace(
      queryParameters: {
        'username': username,
        'password': password,
      },
    );

    http.Response response;
    try {
      response = await _client
          .get(uri, headers: _defaultHeaders())
          .timeout(_timeout);
    } on TimeoutException {
      throw AuthException('Request timed out. Please try again.');
    } catch (_) {
      throw AuthException('Network error. Please try again.');
    }

    final data = _decode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message =
          _extractMessage(data) ?? 'Login failed (HTTP ${response.statusCode}).';
      throw AuthException(message);
    }

    final payload = _extractPayload(data);
    final status = _extractStatus(data, payload);

    if (status == 'error') {
      throw AuthException(_extractMessage(data) ?? 'Invalid credentials.');
    }
    if (status.isNotEmpty && status != 'success') {
      throw AuthException(_extractMessage(data) ?? 'Invalid credentials.');
    }

    final token = _extractToken(data, payload);
    final userData = _extractUser(data, payload);

    if (userData == null) {
      throw AuthException('Unexpected server response.');
    }

    final user = User(
      username: (userData['username'] ?? '').toString(),
      password: '',
      fullname: (userData['fullname'] ?? '').toString(),
      email: (userData['email'] ?? '').toString(),
      phone: (userData['phone'] ?? '').toString(),
      address: (userData['address'] ?? '').toString(),
      role: (userData['role'] ?? '').toString(),
      country: (userData['country'] ?? '').toString(),
    );

    final userId = (userData['user_id'] ?? '').toString();

    if (token.isNotEmpty) {
      await _storageService.saveAuthToken(token);
    } else {
      await _storageService.saveAuthToken('');
    }

    await _storageService.saveUser(user);

    if (userId.isNotEmpty) {
      await _storageService.saveUserId(userId);
    }

    await _storageService.setLoggedIn(true);

    return AuthSession(
      token: token,
      user: user,
      userId: userId,
    );
  }

  // ========================= REGISTER =========================

  Future<RegisterResult> register(User user) async {
    /// 🔴 FIX: renamed from `payload` to `requestBody`
    final requestBody = jsonEncode({
      'users': [user.toJson()],
    });

    http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse(_registerUrl),
            headers: _defaultHeaders(),
            body: requestBody,
          )
          .timeout(_timeout);
    } on TimeoutException {
      throw AuthException('Request timed out. Please try again.');
    } catch (_) {
      throw AuthException('Network error. Please try again.');
    }

    final data = _decode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = _extractMessage(data) ??
          'Registration failed (HTTP ${response.statusCode}).';
      throw AuthException(message);
    }

    final payload = _extractPayload(data);
    final status = _extractStatus(data, payload);

    if (status == 'error') {
      throw AuthException(_extractMessage(data) ?? 'Registration failed.');
    }
    if (status.isNotEmpty && status != 'success') {
      throw AuthException(_extractMessage(data) ?? 'Registration failed.');
    }

    final message = _extractMessage(data) ?? 'User registered successfully';
    final userId = _extractUserId(data, payload);

    return RegisterResult(
      message: message,
      userId: userId,
    );
  }

  // ========================= LOGOUT =========================

  Future<void> logout() async {
    await _storageService.clearAll();
  }

  // ========================= HELPERS =========================

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

  Map<String, dynamic>? _extractPayload(dynamic data) {
    if (data is Map<String, dynamic>) {
      final items = data['items'];
      if (items is List && items.isNotEmpty && items.first is Map) {
        return Map<String, dynamic>.from(items.first as Map);
      }
      return data;
    }

    if (data is List && data.isNotEmpty && data.first is Map) {
      return Map<String, dynamic>.from(data.first as Map);
    }

    return null;
  }

  String _extractStatus(dynamic data, Map<String, dynamic>? payload) {
    dynamic raw;
    if (data is Map<String, dynamic>) {
      raw = data['status'];
    }
    raw ??= payload?['status'];
    return (raw ?? '').toString().toLowerCase();
  }

  String _extractToken(dynamic data, Map<String, dynamic>? payload) {
    final Map<String, dynamic>? map =
        data is Map<String, dynamic> ? data : null;

    final candidates = [
      map?['token'],
      map?['access_token'],
      map?['session'],
      payload?['token'],
      payload?['access_token'],
      payload?['session'],
    ];

    for (final candidate in candidates) {
      if (candidate is String && candidate.trim().isNotEmpty) {
        return candidate.trim();
      }
    }
    return '';
  }

  Map<String, dynamic>? _extractUser(
    dynamic data,
    Map<String, dynamic>? payload,
  ) {
    if (data is Map<String, dynamic>) {
      final user = data['user'];
      if (user is Map<String, dynamic>) return user;

      final items = data['items'];
      if (items is List && items.isNotEmpty && items.first is Map) {
        final first = Map<String, dynamic>.from(items.first as Map);
        if (first.containsKey('username')) return first;

        final nestedUser = first['user'];
        if (nestedUser is Map<String, dynamic>) return nestedUser;
      }
    }

    if (payload != null) {
      final nestedUser = payload['user'];
      if (nestedUser is Map<String, dynamic>) return nestedUser;
      if (payload.containsKey('username')) return payload;
    }

    return null;
  }

  String _extractUserId(dynamic data, Map<String, dynamic>? payload) {
    final Map<String, dynamic>? map =
        data is Map<String, dynamic> ? data : null;

    final candidates = [
      map?['user_id'],
      payload?['user_id'],
    ];

    for (final candidate in candidates) {
      if (candidate is String && candidate.trim().isNotEmpty) {
        return candidate.trim();
      }
      if (candidate != null) {
        final asString = candidate.toString().trim();
        if (asString.isNotEmpty) return asString;
      }
    }

    return '';
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final candidates = [
        data['message'],
        data['error'],
        data['detail'],
        data['status_message'],
        if (data['items'] is List && (data['items'] as List).isNotEmpty)
          (data['items'] as List).first is Map
              ? ((data['items'] as List).first as Map)['message']
              : null,
      ];

      for (final candidate in candidates) {
        if (candidate is String && candidate.trim().isNotEmpty) {
          return candidate;
        }
      }
    }
    return null;
  }
}

// ========================= MODELS =========================

class AuthSession {
  final String token;
  final User user;
  final String userId;

  const AuthSession({
    required this.token,
    required this.user,
    required this.userId,
  });
}

class RegisterResult {
  final String message;
  final String userId;

  const RegisterResult({
    required this.message,
    required this.userId,
  });
}

class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}
