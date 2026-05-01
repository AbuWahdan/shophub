import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/user_model.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';
  static const String _userIdKey = 'auth_user_id';
  static const String _isLoggedInKey = 'auth_is_logged_in';

  Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setBool(_isLoggedInKey, token.isNotEmpty);
  }

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final safeJson = {
      'user_id': user.userId,
      'username': user.username,
      'password_hash': user.passwordHash,
      'fullname': user.fullname,
      'email': user.email,
      'phone': user.phone,
      'address': user.address,
      'role': user.role,
      'country': user.country,
      'gender': user.gender,
      'created_at': user.createdAt,
      'updated_at': user.updatedAt,
      'is_active': user.isActive,
    };
    await prefs.setString(_userKey, jsonEncode(safeJson));
  }

  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final rawUserId = data['user_id'];
      final parsedUserId = rawUserId is num
          ? rawUserId.toInt()
          : int.tryParse((rawUserId ?? '').toString()) ?? 0;
      final rawIsActive = data['is_active'];
      final parsedIsActive = rawIsActive is num
          ? rawIsActive.toInt()
          : int.tryParse((rawIsActive ?? '').toString()) ?? 1;
      return UserModel(
        userId: parsedUserId,
        username: (data['username'] ?? '').toString(),
        passwordHash: (data['password_hash'] ?? '').toString(),
        fullname: (data['fullname'] ?? '').toString(),
        email: (data['email'] ?? '').toString(),
        phone: (data['phone'] ?? '').toString(),
        address: (data['address'] ?? '').toString(),
        role: (data['role'] ?? '').toString(),
        country: (data['country'] ?? '').toString(),
        gender: data['gender'] is num
            ? (data['gender'] as num).toInt()
            : int.tryParse((data['gender'] ?? '').toString()),
        createdAt: (data['created_at'] ?? '').toString(),
        updatedAt: (data['updated_at'] ?? '').toString(),
        isActive: parsedIsActive,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if key exists
    if (!prefs.containsKey(_userIdKey)) return null;

    // Get the value without type casting
    final value = prefs.get(_userIdKey);

    if (value == null) return null;

    // Handle different types safely
    if (value is int) {
      return value;
    }

    if (value is String) {
      if (value.trim().isEmpty) return null;
      return int.tryParse(value.trim());
    }

    // Handle unexpected types
    return null;
  }

  Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, value);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_isLoggedInKey);
  }
}
