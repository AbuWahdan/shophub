import 'dart:async';

import 'package:flutter/material.dart';

import '../model/data.dart';
import '../model/user.dart';
import '../services/auth_service.dart';
import '../services/product_service.dart';
import '../services/storage_service.dart';

class AuthState extends ChangeNotifier {
  AuthState({AuthService? authService, StorageService? storageService})
    : _authService = authService ?? AuthService(),
      _storageService = storageService ?? StorageService();

  final AuthService _authService;
  final StorageService _storageService;
  final ProductService _productService = ProductService();

  bool _isLoading = false;
  bool _isInitializing = false;
  bool _isInitialized = false;
  Future<void>? _initializationFuture;
  bool _isLoggedIn = false;
  String? _errorMessage;
  User? _user;
  int _userId = 0;

  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  bool get isInitialized => _isInitialized;
  bool get isLoggedIn => _isLoggedIn;
  String? get errorMessage => _errorMessage;
  User? get user => _user;
  int get userId => _userId;

  Future<void> initialize() async {
    if (_initializationFuture != null) {
      return _initializationFuture;
    }
    _isInitializing = true;
    notifyListeners();
    _initializationFuture = () async {
      _isLoggedIn = await _storageService.isLoggedIn();
      _user = await _storageService.getUser();
      _userId = await _storageService.getUserId() ?? _user?.userId ?? 0;
      if (_user != null && _userId > 0 && _user!.userId != _userId) {
        _user = _user!.copyWith(userId: _userId);
        unawaited(_storageService.saveUser(_user!));
      }
      _isInitialized = true;
      _isInitializing = false;
      notifyListeners();

      if (_isLoggedIn && (_user?.username.trim().isNotEmpty ?? false)) {
        unawaited(_synchronizeCartCache());
      } else {
        AppData.setCartItems(const []);
      }
    }();
    return _initializationFuture;
  }

  Future<void> ensureInitialized() async {
    if (_isInitialized && !_isInitializing) return;
    await initialize();
  }

  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _errorMessage = null;
    notifyListeners();
    try {
      final session = await _authService.login(username, password);
      _isLoggedIn = true;
      _user = session.user.copyWith(
        userId: session.user.userId > 0 ? session.user.userId : session.userId,
      );
      _userId = _user?.userId ?? session.userId;
      if (_user != null) {
        await _storageService.saveUser(_user!);
      }
      if (_userId > 0) {
        await _storageService.saveUserId(_userId);
      }
      await _synchronizeCartCache(clearOnFailure: true);
      return true;
    } on AuthException catch (error) {
      _errorMessage = error.message;
      _isLoggedIn = false;
      _user = null;
      _userId = 0;
      AppData.setCartItems(const []);
      return false;
    } catch (_) {
      _errorMessage = 'Something went wrong. Try again.';
      _isLoggedIn = false;
      _user = null;
      _userId = 0;
      AppData.setCartItems(const []);
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
    _userId = 0;
    _errorMessage = null;
    AppData.setCartItems(const []);
    notifyListeners();
  }

  Future<void> updateCurrentUser(User user) async {
    final resolvedUser = user.copyWith(
      userId: user.userId > 0 ? user.userId : _userId,
    );
    _user = resolvedUser;
    _userId = resolvedUser.userId;
    await _storageService.saveUser(resolvedUser);
    if (_userId > 0) {
      await _storageService.saveUserId(_userId);
    }
    notifyListeners();
  }

  Future<void> _synchronizeCartCache({bool clearOnFailure = false}) async {
    final username = _user?.username.trim() ?? '';
    if (username.isEmpty) {
      AppData.setCartItems(const []);
      return;
    }

    try {
      final cartItems = await _productService.getItemCart(username: username);
      AppData.setCartItems(cartItems);
    } catch (_) {
      if (clearOnFailure) {
        AppData.setCartItems(const []);
      }
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
  }
}
