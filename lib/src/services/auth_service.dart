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

  AuthService({StorageService? storageService, http.Client? client}) {
    _storageService = storageService ?? StorageService();
    _client = client ?? ApiClient(storageService: _storageService);
  }

  // ========================= LOGIN =========================

  Future<AuthSession> login(String username, String password) async {
    final usernameValue = username.trim();
    final passwordValue = password.trim();

    String? lastError;
    TimeoutException? timeoutError;
    bool hadNetworkError = false;

    final attempts = <Future<http.Response> Function()>[
      () => _client.get(
        Uri.parse(_loginUrl).replace(
          queryParameters: {
            'username': usernameValue,
            'password': passwordValue,
          },
        ),
        headers: _defaultHeaders(),
      ),
      () => _client.get(
        Uri.parse(_loginUrl).replace(
          queryParameters: {
            'USERNAME': usernameValue,
            'PASSWORD': passwordValue,
          },
        ),
        headers: _defaultHeaders(),
      ),
      () => _client.post(
        Uri.parse(_loginUrl),
        headers: _defaultHeaders(),
        body: jsonEncode({
          'username': usernameValue,
          'password': passwordValue,
        }),
      ),
      () => _client.post(
        Uri.parse(_loginUrl),
        headers: _defaultHeaders(),
        body: jsonEncode({
          'data': [
            {'USERNAME': usernameValue, 'PASSWORD': passwordValue},
          ],
        }),
      ),
    ];

    for (final attempt in attempts) {
      http.Response response;
      try {
        response = await attempt().timeout(_timeout);
      } on TimeoutException catch (error) {
        timeoutError = error;
        continue;
      } catch (_) {
        hadNetworkError = true;
        continue;
      }

      final data = _decode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        lastError =
            _extractMessage(data) ??
            'Login failed (HTTP ${response.statusCode}).';
        continue;
      }

      final payload = _extractPayload(data);
      final status = _extractStatus(data, payload);

      if (status == 'error' || (status.isNotEmpty && status != 'success')) {
        lastError = _extractMessage(data) ?? 'Invalid username or password.';
        continue;
      }

      final userData = _extractUser(data, payload);
      if (userData == null) {
        lastError = 'Unexpected server response.';
        continue;
      }

      final token = _extractToken(data, payload);
      final user = User(
        userId: _readInt(userData, const ['user_id', 'USER_ID']),
        username: _readString(userData, const ['username', 'USERNAME']),
        passwordHash: _readString(userData, const [
          'password_hash',
          'PASSWORD_HASH',
          'password',
          'PASSWORD',
        ]),
        fullname: _readString(userData, const [
          'fullname',
          'full_name',
          'FULL_NAME',
        ]),
        email: _readString(userData, const ['email', 'EMAIL']),
        phone: _readString(userData, const ['phone', 'PHONE']),
        address: _readString(userData, const ['address', 'ADDRESS']),
        role: _readString(userData, const ['role', 'ROLE']),
        country: _readString(userData, const ['country', 'COUNTRY']),
        createdAt: _readString(userData, const [
          'created_at',
          'CREATED_AT',
          'createdAt',
        ]),
        updatedAt: _readString(userData, const [
          'updated_at',
          'UPDATED_AT',
          'updatedAt',
        ]),
        isActive: _readInt(userData, const ['is_active', 'IS_ACTIVE']),
      );
      final extractedUserId = int.tryParse(_extractUserId(data, payload)) ?? 0;
      final userId = user.userId > 0 ? user.userId : extractedUserId;

      await _storageService.saveAuthToken(token);
      await _storageService.saveUser(user);
      if (userId > 0) {
        await _storageService.saveUserId(userId);
      }
      await _storageService.setLoggedIn(true);

      return AuthSession(token: token, user: user, userId: userId);
    }

    if (timeoutError != null) {
      throw AuthException('Request timed out. Please try again.');
    }
    if (hadNetworkError && lastError == null) {
      throw AuthException('Network error. Please try again.');
    }
    throw AuthException(lastError ?? 'Invalid username or password.');
  }

  // ========================= REGISTER =========================

  Future<RegisterResult> register(User user) async {
    final normalizedRole = _normalizeRoleForApi(user.role);
    final registerPayload = {
      'username': user.username,
      'password': user.passwordHash,
      'fullname': user.fullname,
      'email': user.email,
      'phone': user.phone,
      'address': user.address,
      'role': normalizedRole,
      'country': user.country,
      'USERNAME': user.username,
      'PASSWORD': user.passwordHash,
      'FULL_NAME': user.fullname,
      'EMAIL': user.email,
      'PHONE': user.phone,
      'ADDRESS': user.address,
      'ROLE': normalizedRole,
      'COUNTRY': user.country,
    };

    final requestMap = {
      'users': [registerPayload],
      'items': [registerPayload],
      'data': [registerPayload],
    };
    final requestBody = jsonEncode(requestMap);

    final registerAttempts = <Future<http.Response> Function()>[
      () => _client.post(
        Uri.parse(_registerUrl),
        headers: _defaultHeaders(),
        body: requestBody,
      ),
      () => _client.post(
        Uri.parse(_registerUrl),
        headers: _defaultHeaders(),
        body: jsonEncode({
          'users': [registerPayload],
        }),
      ),
      () => _client.get(
        Uri.parse(_registerUrl).replace(
          queryParameters: {
            'username': user.username,
            'password': user.passwordHash,
            'fullname': user.fullname,
            'email': user.email,
            'phone': user.phone,
            'address': user.address,
            'role': normalizedRole,
            'country': user.country,
          },
        ),
        headers: _defaultHeaders(),
      ),
    ];

    String? lastError;
    TimeoutException? timeoutError;
    bool hadNetworkError = false;

    for (final attempt in registerAttempts) {
      http.Response response;
      try {
        response = await attempt().timeout(_timeout);
      } on TimeoutException catch (error) {
        timeoutError = error;
        continue;
      } catch (_) {
        hadNetworkError = true;
        continue;
      }

      final data = _decode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        lastError =
            _extractMessage(data) ??
            'Registration failed (HTTP ${response.statusCode}).';
        continue;
      }

      final payload = _extractPayload(data);
      final status = _extractStatus(data, payload);
      if (status == 'error' || (status.isNotEmpty && status != 'success')) {
        lastError = _extractMessage(data) ?? 'Registration failed.';
        continue;
      }

      final message = _extractMessage(data) ?? 'User registered successfully';
      final userId = _extractUserId(data, payload);
      return RegisterResult(message: message, userId: userId);
    }

    if (timeoutError != null) {
      throw AuthException('Request timed out. Please try again.');
    }
    if (hadNetworkError && lastError == null) {
      throw AuthException('Network error. Please try again.');
    }
    throw AuthException(lastError ?? 'Registration failed.');
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
      final usersData = data['data'];
      if (usersData is List && usersData.isNotEmpty && usersData.first is Map) {
        return Map<String, dynamic>.from(usersData.first as Map);
      }

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
    final Map<String, dynamic>? map = data is Map<String, dynamic>
        ? data
        : null;

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
        if (_hasAnyKey(first, const ['username', 'USERNAME'])) return first;

        final nestedUser = first['user'];
        if (nestedUser is Map<String, dynamic>) return nestedUser;
      }

      final usersData = data['data'];
      if (usersData is List && usersData.isNotEmpty && usersData.first is Map) {
        final first = Map<String, dynamic>.from(usersData.first as Map);
        if (_hasAnyKey(first, const ['username', 'USERNAME'])) return first;

        final nestedUser = first['user'];
        if (nestedUser is Map<String, dynamic>) return nestedUser;
      }
    }

    if (payload != null) {
      final nestedUser = payload['user'];
      if (nestedUser is Map<String, dynamic>) return nestedUser;
      if (_hasAnyKey(payload, const ['username', 'USERNAME'])) return payload;
    }

    return null;
  }

  String _extractUserId(dynamic data, Map<String, dynamic>? payload) {
    final Map<String, dynamic>? map = data is Map<String, dynamic>
        ? data
        : null;

    final candidates = [
      map?['user_id'],
      map?['USER_ID'],
      payload?['user_id'],
      payload?['USER_ID'],
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
          final normalized = candidate.trim().toLowerCase();
          if (normalized.contains('method not allowed')) {
            return 'Invalid user';
          }
          return candidate;
        }
      }
    }
    return null;
  }

  bool _hasAnyKey(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      if (map.containsKey(key)) {
        return true;
      }
    }
    return false;
  }

  String _readString(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  int _readInt(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value is num) return value.toInt();
      if (value == null) continue;
      final parsed = int.tryParse(value.toString().trim());
      if (parsed != null) return parsed;
    }
    return 0;
  }

  String _normalizeRoleForApi(String role) {
    final value = role.trim().toLowerCase();
    if (value == 'customer') return '2';
    if (value == 'provider') return '1';
    if (value.isEmpty) return '2';
    return role;
  }
}

// ========================= MODELS =========================

class AuthSession {
  final String token;
  final User user;
  final int userId;

  const AuthSession({
    required this.token,
    required this.user,
    required this.userId,
  });
}

class RegisterResult {
  final String message;
  final String userId;

  const RegisterResult({required this.message, required this.userId});
}

class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}
