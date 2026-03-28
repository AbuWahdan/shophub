import 'package:get/get.dart';
import 'core/api/api_service.dart';
import 'data/datasources/address_remote_datasource.dart';
import 'data/repositories/address_repository_impl.dart';
import 'data/repositories/address_repository_interface.dart';
import 'data/repositories/cart_repository.dart';
import 'data/repositories/order_repository.dart';
import 'data/repositories/product_repository.dart';
import 'data/repositories/user_repository.dart';
import 'controllers/address_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/cart_controller.dart';
import 'controllers/my_products_controller.dart';
import 'controllers/order_controller.dart';
import 'controllers/product_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Core services
    Get.lazyPut<ApiService>(() => ApiService(), fenix: true);

    // Data sources
    Get.lazyPut<AddressRemoteDataSource>(
      () => AddressRemoteDataSource(Get.find<ApiService>()),
      fenix: true,
    );

    // Repositories
    Get.lazyPut<ProductRepository>(
      () => ProductRepository(Get.find<ApiService>()),
      fenix: true,
    );
    Get.lazyPut<CartRepository>(
      () => CartRepository(Get.find<ApiService>()),
      fenix: true,
    );
    Get.lazyPut<OrderRepository>(
      () => OrderRepository(Get.find<ApiService>()),
      fenix: true,
    );
    Get.lazyPut<UserRepository>(
      () => UserRepository(Get.find<ApiService>()),
      fenix: true,
    );
    Get.lazyPut<AddressRepositoryInterface>(
      () => AddressRepositoryImpl(Get.find<AddressRemoteDataSource>()),
      fenix: true,
    );

    // Controllers
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
      () => AddressController(Get.find<AddressRepositoryInterface>()),
      fenix: true,
    );
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
  }
}
