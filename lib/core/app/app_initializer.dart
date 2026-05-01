import 'dart:developer' as logger;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

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
import '../config/mapbox_config.dart';
import '../../presentation/profile/settings/app_settings.dart';
import '../state/auth_state.dart';
import '../state/wishlist_state.dart';

/// Initializes all app-level dependencies before [runApp].
///
/// ZONE MISMATCH FIX:
/// The original code wrapped initialization in [runZonedGuarded], which created
/// a new zone. [WidgetsFlutterBinding.ensureInitialized] then ran inside that
/// zone, but [runApp] was called outside it — Flutter detects this mismatch and
/// throws. The fix is simple: do NOT use [runZonedGuarded] here. Instead, set up
/// [FlutterError.onError] directly and let errors propagate normally.
/// If you need zone-level error catching, wrap the entire [main] body — including
/// [runApp] — inside the same [runZonedGuarded] call.
abstract final class AppInitializer {
  /// Returns the Provider list to pass to [MultiProvider] in [MyApp].
  static Future<List<SingleChildWidget>> initialize() async {
    _setupErrorHandling();
    await _loadEnvironment();
    _registerDependencies();
    return _buildProviders();
  }

  // ── Error handling ─────────────────────────────────────────────────────────

  static void _setupErrorHandling() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      logger.log(
        '[AppInit] Flutter error: ${details.exceptionAsString()}',
        name: 'AppInit',
      );
    };
  }

  // ── Environment ────────────────────────────────────────────────────────────

  static Future<void> _loadEnvironment() async {
    try {
      // ensureInitialized is called here, in the SAME zone as runApp in main().
      // Do NOT move this inside a runZonedGuarded block unless runApp is also
      // inside that same block.
      WidgetsFlutterBinding.ensureInitialized();
      MapboxOptions.setAccessToken(MapboxConfig.accessToken);
      await AppSettings.load();
      logger.log('[AppInit] Environment loaded.', name: 'AppInit');
    } catch (e, stack) {
      logger.log(
        '[AppInit] Failed to load environment: $e\n$stack',
        name: 'AppInit',
      );
      // Re-throw so main() can decide whether to abort or continue.
      rethrow;
    }
  }

  // ── Dependency registration ────────────────────────────────────────────────
  //
  // Order matters:
  //   1. ApiService  — no dependencies
  //   2. Repositories — depend on ApiService
  //   3. Controllers  — depend on repositories, may call repos in onInit()

  static void _registerDependencies() {
    // 1 — Core service
    Get.put(ApiService(), permanent: true);
    logger.log('[AppInit] ApiService registered.', name: 'AppInit');

    // 2 — Repositories
    _registerRepositories();
    logger.log('[AppInit] Repositories registered.', name: 'AppInit');

    // 3 — Controllers
    _registerControllers();
    logger.log('[AppInit] Controllers registered.', name: 'AppInit');
  }

  static void _registerRepositories() {
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
  }

  static void _registerControllers() {
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
  }

  // ── Providers ──────────────────────────────────────────────────────────────

  static List<SingleChildWidget> _buildProviders() {
    final authState = AuthState()..initialize();
    final wishlistState = WishlistState()..updateAuth(authState);

    logger.log('[AppInit] Providers built.', name: 'AppInit');

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