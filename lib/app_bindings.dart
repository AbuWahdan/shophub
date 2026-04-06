import 'package:get/get.dart';

import 'controllers/address_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/cart_controller.dart';
import 'controllers/my_products_controller.dart';
import 'controllers/order_controller.dart';
import 'controllers/product_controller.dart';
import 'core/api/api_service.dart';
import 'data/repositories/address_repository.dart';
import 'data/repositories/cart_repository.dart';
import 'data/repositories/checkout_repository.dart';
import 'data/repositories/comment_repository.dart';
import 'data/repositories/order_repository.dart';
import 'data/repositories/profile_repository.dart';
import 'data/repositories/product_repository.dart';
import 'data/repositories/user_repository.dart';
import 'data/repositories/visual_search_repository.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiService>(() => ApiService(), fenix: true);

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
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
  }
}
