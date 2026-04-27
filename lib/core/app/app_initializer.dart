import 'dart:developer' as AppLogger;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../src/config/mapbox_config.dart';
import '../../src/state/app_settings.dart';
import '../../src/state/auth_state.dart';
import '../../src/state/wishlist_state.dart';

// Core
import '../api/api_service.dart';

// Repositories
import '../../data/repositories/address_repository.dart';
import '../../data/repositories/cart_repository.dart';
import '../../data/repositories/checkout_repository.dart';
import '../../data/repositories/comment_repository.dart';
import '../../data/repositories/codes_repository.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/visual_search_repository.dart';

// Controllers
import '../../controllers/address_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/my_products_controller.dart';
import '../../controllers/order_controller.dart';
import '../../controllers/product_controller.dart';

class AppInitializer {
  AppInitializer._(); // prevent instantiation

  static Future<List<SingleChildWidget>> initialize() async {
    await runZonedGuarded(
          () async {
        _setupErrorHandling();
        await _loadEnvironment();
        await _initializeServices();
      },
          (error, stack) {
        AppLogger.log('[AppInit] Uncaught zoned error: $error\n$stack');
      },
    );

    return _initializeProviders();
  }

  // ─── Error Handling ────────────────────────────────────────────────────────

  static void _setupErrorHandling() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      AppLogger.log('[AppInit] Flutter error: ${details.exceptionAsString()}');
    };
  }

  // ─── Environment ──────────────────────────────────────────────────────────

  static Future<void> _loadEnvironment() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      MapboxOptions.setAccessToken(MapboxConfig.accessToken);
      await AppSettings.load();
      AppLogger.log('[AppInit] Environment loaded.');
    } catch (e) {
      AppLogger.log('[AppInit] Failed to load environment: $e');
    }
  }

  // ─── Services & DI ────────────────────────────────────────────────────────
  //
  // WHY ORDER MATTERS:
  //   ApiService must be registered FIRST. All repositories depend on it.
  //   Controllers are registered LAST — they may call repos in onInit().

  static Future<void> _initializeServices() async {
    // Step 1 — Core service
    final apiService = ApiService();
    Get.put(apiService, permanent: true);
    AppLogger.log('[AppInit] ApiService registered.');

    // Step 2 — Repositories (depend on ApiService)
    Get.lazyPut<AddressRepository>(() => AddressRepository(), fenix: true);
    Get.lazyPut<ProductRepository>(
          () => ProductRepository(Get.find<ApiService>()),
      fenix: true,
    );
    Get.lazyPut<CartRepository>(
          () => CartRepository(Get.find<ApiService>()),
      fenix: true,
    );
    Get.lazyPut<CheckoutRepository>(
          () => CheckoutRepository(Get.find<ApiService>()),
      fenix: true,
    );
    Get.lazyPut<CommentRepository>(
          () => CommentRepository(Get.find<ApiService>()),
      fenix: true,
    );
    Get.lazyPut<CodesRepository>(
          () => CodesRepository(Get.find<ApiService>()),
      fenix: true,
    );
    Get.lazyPut<OrderRepository>(
          () => OrderRepository(Get.find<ApiService>()),
      fenix: true,
    );
    Get.lazyPut<ProfileRepository>(
          () => ProfileRepository(Get.find<ApiService>()),
      fenix: true,
    );
    Get.lazyPut<UserRepository>(
          () => UserRepository(Get.find<ApiService>()),
      fenix: true,
    );
    Get.lazyPut<VisualSearchRepository>(
          () => VisualSearchRepository(),
      fenix: true,
    );
    AppLogger.log('[AppInit] Repositories registered.');

    // Step 3 — Controllers (depend on repositories)
    Get.lazyPut<ProductController>(
          () => ProductController(Get.find<ProductRepository>()),
      fenix: true,
    );
    Get.lazyPut<MyProductsController>(
          () => MyProductsController(Get.find<ProductRepository>()),
      fenix: true,
    );
    Get.lazyPut<CartController>(
          () => CartController(Get.find<CartRepository>()),
      fenix: true,
    );
    Get.lazyPut<OrderController>(
          () => OrderController(Get.find<OrderRepository>()),
      fenix: true,
    );
    Get.lazyPut<AddressController>(
          () => AddressController(Get.find<AddressRepository>()),
      fenix: true,
    );
    AppLogger.log('[AppInit] Controllers registered.');
  }

  // ─── Providers ────────────────────────────────────────────────────────────

  static List<SingleChildWidget> _initializeProviders() {
    final authState = AuthState()..initialize();
    final wishlistState = WishlistState()..updateAuth(authState);

    AppLogger.log('[AppInit] Providers initialized.');

    return [
      ChangeNotifierProvider<AuthState>.value(value: authState),
      ChangeNotifierProxyProvider<AuthState, WishlistState>(
        create: (_) => wishlistState,
        update: (_, auth, wishlist) =>
        (wishlist ?? WishlistState())..updateAuth(auth),
      ),
    ];
  }
}