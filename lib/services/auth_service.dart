import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/forget_password_request_model.dart';
import '../../models/user_model.dart';
import 'api_client.dart';
import 'storage_service.dart';

class AuthService {
  static const String _baseUrl = 'https://oracleapex.com/ords/topg/users';
  static const String _loginUrl = '$_baseUrl/login';
  static const String _registerUrl = '$_baseUrl/register';
  static const Duration _timeout = Duration(seconds: 30);

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

    for (var requestRound = 0; requestRound < 2; requestRound++) {
      var hadTimeoutError = false;
      var hadNetworkError = false;
      var hadServerError = false;

      for (final attempt in attempts) {
        http.Response response;
        try {
          response = await attempt().timeout(_timeout);
        } on TimeoutException {
          hadTimeoutError = true;
          continue;
        } on SocketException {
          hadNetworkError = true;
          continue;
        } catch (_) {
          hadNetworkError = true;
          continue;
        }

        final data = _decode(response.body);
        if (response.statusCode < 200 || response.statusCode >= 300) {
          hadServerError = true;
          lastError = _extractMessage(data);
          continue;
        }

        final payload = _extractPayload(data);
        final status = _extractStatus(data, payload);

        if (status == 'error' || (status.isNotEmpty && status != 'success')) {
          hadServerError = true;
          lastError = _extractMessage(data);
          continue;
        }

        final userData = _extractUser(data, payload);
        if (userData == null) {
          hadServerError = true;
          lastError = 'Unexpected server response.';
          continue;
        }

        final token = _extractToken(data, payload);
        final user = UserModel(
          userId: _readInt(userData, const ['user_id', 'USER_ID']),
          username: _readString(userData, const ['username', 'USERNAME']),
          passwordHash: _readString(userData, const [
            'password_hash',
            'PASSWORD_HASH',
            'password',
            'PASSWORD',
          ]),
          fullname: _readString(
              userData, const ['fullname', 'full_name', 'FULL_NAME']),
          email: _readString(userData, const ['email', 'EMAIL']),
          phone: _readString(userData, const ['phone', 'PHONE']),
          address: _readString(userData, const ['address', 'ADDRESS']),
          role: _readString(userData, const ['role', 'ROLE']),
          country: _readString(userData, const ['country', 'COUNTRY']),
          gender: _readNullableInt(userData, const ['gender', 'GENDER']),
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
        final extractedUserId =
            int.tryParse(_extractUserId(data, payload)) ?? 0;
        final userId = user.userId > 0 ? user.userId : extractedUserId;
        final resolvedUser = user.copyWith(userId: userId);

        await _storageService.saveAuthToken(token);
        await _storageService.saveUser(resolvedUser);
        if (userId > 0) await _storageService.saveUserId(userId);
        await _storageService.setLoggedIn(true);

        return AuthSession(token: token, user: resolvedUser, userId: userId);
      }

      if (requestRound == 0 && (hadTimeoutError || hadNetworkError)) continue;
      if (hadTimeoutError) throw AuthException('Request timed out. Please try again.');
      if (hadNetworkError) throw AuthException('Network error. Please try again.');
      if (hadServerError) {
        throw AuthException(
          lastError?.trim().isNotEmpty == true
              ? lastError!
              : 'Login failed, please check your credentials.',
        );
      }
    }

    throw AuthException(
      lastError?.trim().isNotEmpty == true
          ? lastError!
          : 'Login failed, please check your credentials.',
    );
  }

  // ========================= REGISTER =========================

  Future<RegisterResult> register(UserModel user) async {
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
      if (user.gender != null) 'gender': user.gender,
      'is_active': user.isActive,
      'USERNAME': user.username,
      'PASSWORD': user.passwordHash,
      'FULL_NAME': user.fullname,
      'EMAIL': user.email,
      'PHONE': user.phone,
      'ADDRESS': user.address,
      'ROLE': normalizedRole,
      'COUNTRY': user.country,
      if (user.gender != null) 'GENDER': user.gender,
      'IS_ACTIVE': user.isActive,
    };

    final requestMap = {
      'users': [registerPayload],
      'items': [registerPayload],
      'data': [registerPayload],
    };

    final registerAttempts = <Future<http.Response> Function()>[
          () => _client.post(
        Uri.parse(_registerUrl),
        headers: _defaultHeaders(),
        body: jsonEncode(requestMap),
      ),
          () => _client.post(
        Uri.parse(_registerUrl),
        headers: _defaultHeaders(),
        body: jsonEncode({'users': [registerPayload]}),
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
        lastError = _extractMessage(data) ??
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

    if (timeoutError != null) throw AuthException('Request timed out. Please try again.');
    if (hadNetworkError && lastError == null) throw AuthException('Network error. Please try again.');
    throw AuthException(lastError ?? 'Registration failed.');
  }

  // ========================= ACTIVATE USER =========================

  Future<void> activateUser(UserModel pendingUser) async {
    final activeUser = pendingUser.copyWith(isActive: 1);

    final payload = {
      'user_id': activeUser.userId,
      'username': activeUser.username,
      'fullname': activeUser.fullname,
      'full_name': activeUser.fullname,
      'email': activeUser.email,
      'phone': activeUser.phone,
      'address': activeUser.address,
      'country': activeUser.country,
      if (activeUser.gender != null) 'gender': activeUser.gender,
      'is_active': 1,
      'USER_ID': activeUser.userId,
      'USERNAME': activeUser.username,
      'FULL_NAME': activeUser.fullname,
      'EMAIL': activeUser.email,
      'PHONE': activeUser.phone,
      'ADDRESS': activeUser.address,
      'COUNTRY': activeUser.country,
      if (activeUser.gender != null) 'GENDER': activeUser.gender,
      'PASSWORD_HASH': activeUser.passwordHash,
      'ROLE': activeUser.role,
      'IS_ACTIVE': 1,
    };

    final bodies = [
      {'users': [payload]},
      {'items': [payload]},
      {'data': [payload]},
      payload,
    ];

    for (final body in bodies) {
      try {
        final response = await _client
            .post(
          Uri.parse('$_baseUrl/UpdateUser'),
          headers: _defaultHeaders(),
          body: jsonEncode(body),
        )
            .timeout(_timeout);

        if (response.statusCode >= 200 && response.statusCode < 300) return;
      } on TimeoutException {
        throw AuthException('Request timed out. Please try again.');
      } catch (_) {
        throw AuthException('Network error. Please try again.');
      }
    }

    throw AuthException('Failed to activate account.');
  }

  // ========================= LOGOUT =========================

  Future<void> logout() async {
    await _storageService.clearAll();
  }

  // ========================= SEND OTP (forgot-password — username + email) =========================

  /// IMPORTANT: Never retry this call. Each call generates a NEW OTP and
  /// invalidates the previous one. The user would receive the first email
  /// but Oracle would only accept the last generated code.
  Future<void> sendOtp({
    required String username,
    required String email,
  }) async {
    final usernameValue = username.trim();
    final emailValue = email.trim();

    if (usernameValue.isEmpty) throw AuthException('Username is required.');
    if (emailValue.isEmpty) throw AuthException('Email is required.');

    try {
      final response = await _client
          .post(
        Uri.parse('$_baseUrl/SendOTP'),
        headers: _defaultHeaders(),
        body: jsonEncode({
          'username': usernameValue,
          'email': emailValue,
          'USERNAME': usernameValue,
          'EMAIL': emailValue,
        }),
      )
          .timeout(_timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) return;

      final msg = _extractMessage(_decode(response.body));
      throw AuthException(msg ?? 'Sending OTP failed (HTTP ${response.statusCode}).');
    } on AuthException {
      rethrow;
    } on TimeoutException {
      throw AuthException('Request timed out. Please try again.');
    } catch (_) {
      throw AuthException('Network error. Please try again.');
    }
  }

  // ========================= SEND OTP BY EMAIL ONLY (signup) =========================

  /// IMPORTANT: Never retry this call. Each call generates a NEW OTP and
  /// invalidates the previous one. The user would receive the first email
  /// but Oracle would only accept the last generated code.
  Future<void> sendOtpByEmail({required String email}) async {
    final emailValue = email.trim();
    if (emailValue.isEmpty) throw AuthException('Email is required.');

    try {
      final response = await _client
          .post(
        Uri.parse('$_baseUrl/SendOTP'),
        headers: _defaultHeaders(),
        body: jsonEncode({
          'email': emailValue,
          'EMAIL': emailValue,
        }),
      )
          .timeout(_timeout);

      // ✅ Always read the body — Oracle returns 200 even on FK errors
      final data = _decode(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final msg = _extractMessage(data);
        throw AuthException(msg ?? 'Sending OTP failed (HTTP ${response.statusCode}).');
      }

      // ✅ Check body status even on HTTP 200
      if (data is Map<String, dynamic>) {
        final status = (data['status'] ?? data['STATUS'] ?? '').toString().toUpperCase();
        if (status == 'ERROR' || status == 'FAIL' || status == 'FAILED') {
          final msg = _extractMessage(data);
          throw AuthException(msg ?? 'OTP could not be sent.');
        }
      }

      return; // success
    } on AuthException {
      rethrow;
    } on TimeoutException {
      throw AuthException('Request timed out. Please try again.');
    } catch (_) {
      throw AuthException('Network error. Please try again.');
    }
  }
  // ========================= VERIFY OTP =========================

  Future<void> verifyOtp({
    required String email,
    required String otp,
    String? username,
  }) async {
    final emailValue = email.trim();
    final otpValue = otp.trim();

    if (emailValue.isEmpty) throw AuthException('Email is required.');
    if (otpValue.isEmpty) throw AuthException('OTP is required.');

    // CLEAN PAYLOAD: No uppercase duplicates
    final payload = <String, dynamic>{
      'email': emailValue,
      'otp': otpValue,
      if (username != null && username.trim().isNotEmpty)
        'username': username.trim(),
    };

    if (kDebugMode) {
      debugPrint('=== VerifyOTP request ===');
      debugPrint('  payload: $payload');
    }

    try {
      final response = await _client
          .post(
        Uri.parse('$_baseUrl/VerifyOTP'),
        headers: _defaultHeaders(),
        body: jsonEncode(payload),
      )
          .timeout(_timeout);

      if (kDebugMode) {
        debugPrint('=== VerifyOTP response ===');
        debugPrint('  status code : ${response.statusCode}');
        debugPrint('  raw body    : ${response.body}');
      }

      // Non-2xx = real HTTP failure
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final msg = _extractMessage(_decode(response.body));
        throw AuthException(
            msg ?? 'OTP verification failed (HTTP ${response.statusCode}).');
      }

      // HTTP 200 — Oracle returns 200 for both success AND failure.
      // Must read the body. Confirmed response shapes:
      //   success → {"status":"SUCCESS","message":"OTP is valid"}
      //   failure → {"status":"ERROR","message":"OTP is invalid or expired"}
      final data = _decode(response.body);
      if (data is Map<String, dynamic>) {
        final raw = (data['status'] ?? data['STATUS'] ?? '').toString().trim();
        final upper = raw.toUpperCase();

        if (kDebugMode) debugPrint('  parsed status: "$raw" → upper: "$upper"');

        // Explicit success — return immediately
        if (upper == 'SUCCESS' || upper == '1' || upper == 'TRUE' || upper == 'OK') {
          return;
        }

        // Explicit failure
        if (upper == 'ERROR' || upper == 'FAIL' || upper == 'FAILED' ||
            upper == '0' || upper == 'FALSE') {
          final msg = _extractMessage(data) ?? 'Invalid or expired OTP.';
          throw AuthException(msg);
        }

        // Unknown status — treat HTTP 200 as success
        return;
      }

      // No parseable body on HTTP 200 → success
      return;
    } on AuthException {
      rethrow;
    } on TimeoutException {
      throw AuthException('Request timed out. Please try again.');
    } catch (_) {
      throw AuthException('Network error. Please try again.');
    }
  }

  // ========================= RESET PASSWORD =========================

  Future<void> resetPassword({
    required String username,
    required String newPassword,
    String? oldPassword,
  }) async {
    final usernameValue = username.trim();
    final passwordValue = newPassword.trim();
    final oldPasswordValue = oldPassword?.trim();

    if (usernameValue.isEmpty) throw AuthException('Username is required.');
    if (passwordValue.isEmpty) throw AuthException('Password is required.');

    String? lastError;
    TimeoutException? timeoutError;
    bool hadNetworkError = false;

    final payload = ForgetPasswordRequestModel(
      username: usernameValue,
      newPassword: passwordValue,
      oldPassword:
      oldPasswordValue != null && oldPasswordValue.isNotEmpty ? oldPasswordValue : null,
    ).toJson();

    for (int attempt = 0; attempt < 2; attempt++) {
      try {
        final response = await _client
            .post(
          Uri.parse('$_baseUrl/ForgetPassword'),
          headers: _defaultHeaders(),
          body: jsonEncode(payload),
        )
            .timeout(_timeout);

        if (response.statusCode >= 200 && response.statusCode < 300) return;

        lastError = _extractMessage(_decode(response.body)) ??
            'Password reset failed (HTTP ${response.statusCode}).';
        continue;
      } on TimeoutException catch (error) {
        timeoutError = error;
        continue;
      } catch (_) {
        hadNetworkError = true;
        continue;
      }
    }

    if (timeoutError != null) throw AuthException('Request timed out. Please try again.');
    if (hadNetworkError && lastError == null) throw AuthException('Network error. Please try again.');
    throw AuthException(lastError ?? 'Password reset failed.');
  }

  // ========================= HELPERS =========================

  Map<String, String> _defaultHeaders() => const {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

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
    if (data is Map<String, dynamic>) raw = data['status'];
    raw ??= payload?['status'];
    return (raw ?? '').toString().toLowerCase();
  }

  String _extractToken(dynamic data, Map<String, dynamic>? payload) {
    final Map<String, dynamic>? map =
    data is Map<String, dynamic> ? data : null;
    for (final candidate in [
      map?['token'],
      map?['access_token'],
      map?['session'],
      payload?['token'],
      payload?['access_token'],
      payload?['session'],
    ]) {
      if (candidate is String && candidate.trim().isNotEmpty) {
        return candidate.trim();
      }
    }
    return '';
  }

  Map<String, dynamic>? _extractUser(
      dynamic data, Map<String, dynamic>? payload) {
    if (data is Map<String, dynamic>) {
      final user = data['user'];
      if (user is Map<String, dynamic>) return user;

      for (final key in ['items', 'data']) {
        final list = data[key];
        if (list is List && list.isNotEmpty && list.first is Map) {
          final first = Map<String, dynamic>.from(list.first as Map);
          if (_hasAnyKey(first, const ['username', 'USERNAME'])) return first;
          final nested = first['user'];
          if (nested is Map<String, dynamic>) return nested;
        }
      }
    }

    if (payload != null) {
      final nested = payload['user'];
      if (nested is Map<String, dynamic>) return nested;
      if (_hasAnyKey(payload, const ['username', 'USERNAME'])) return payload;
    }
    return null;
  }

  String _extractUserId(dynamic data, Map<String, dynamic>? payload) {
    final Map<String, dynamic>? map =
    data is Map<String, dynamic> ? data : null;
    for (final candidate in [
      map?['user_id'],
      map?['USER_ID'],
      payload?['user_id'],
      payload?['USER_ID'],
    ]) {
      if (candidate != null) {
        final s = candidate.toString().trim();
        if (s.isNotEmpty) return s;
      }
    }
    return '';
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      for (final key in [
        'message', 'error', 'detail', 'status_message'
      ]) {
        final v = data[key];
        if (v is String && v.trim().isNotEmpty) {
          final n = v.trim().toLowerCase();
          if (n.contains('method not allowed')) return 'Invalid user';
          return v.trim();
        }
      }
    }
    return null;
  }

  bool _hasAnyKey(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      if (map.containsKey(key)) return true;
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

  int? _readNullableInt(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value is num) return value.toInt();
      if (value == null) continue;
      final parsed = int.tryParse(value.toString().trim());
      if (parsed != null) return parsed;
    }
    return null;
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
  final UserModel user;
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