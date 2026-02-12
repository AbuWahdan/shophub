import 'package:flutter/material.dart';

import '../model/user.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class AuthState extends ChangeNotifier {
  AuthState({AuthService? authService, StorageService? storageService})
    : _authService = authService ?? AuthService(),
      _storageService = storageService ?? StorageService();

  final AuthService _authService;
  final StorageService _storageService;

  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _errorMessage;
  User? _user;
  String _userId = '';

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get errorMessage => _errorMessage;
  User? get user => _user;
  String get userId => _userId;

  Future<void> initialize() async {
    _isLoggedIn = await _storageService.isLoggedIn();
    _user = await _storageService.getUser();
    _userId = await _storageService.getUserId() ?? '';
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _errorMessage = null;
    notifyListeners();
    try {
      final session = await _authService.login(username, password);
      _isLoggedIn = true;
      _user = session.user;
      _userId = session.userId;
      return true;
    } on AuthException catch (error) {
      _errorMessage = error.message;
      _isLoggedIn = false;
      _userId = '';
      return false;
    } catch (_) {
      _errorMessage = 'Something went wrong. Try again.';
      _isLoggedIn = false;
      _userId = '';
      return false;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<bool> register(User user) async {
    _setLoading(true);
    _errorMessage = null;
    notifyListeners();
    try {
      await _authService.register(user);
      return true;
    } on AuthException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Something went wrong. Try again.';
      return false;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _isLoggedIn = false;
    _user = null;
    _userId = '';
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
  }
}
