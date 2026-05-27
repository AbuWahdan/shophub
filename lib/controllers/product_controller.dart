import 'package:get/get.dart';
import 'package:sinwar_shoping/controllers/wishlist_controller.dart';
import '../../models/product/product_model.dart';
import '../../repositories/product_repository.dart';

class ProductController extends GetxController {
  final ProductRepository _repository;

  ProductController(this._repository);

  // ── State ────────────────────────────────────────────────────────────────

  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxList<ProductModel> myProducts = <ProductModel>[].obs;
  final RxBool isLoadingProducts = false.obs;
  final RxBool isLoadingMyProducts = false.obs;
  final RxString errorMessage = ''.obs;

  // ── Public API ───────────────────────────────────────────────────────────

  /// Fetches all home/featured products and stores them in [products].
  /// Also syncs wishlist favorite flags if WishlistController is registered.
  Future<void> loadProducts({bool forceRefresh = false}) async {
    if (isLoadingProducts.value) return;
    isLoadingProducts.value = true;
    errorMessage.value = '';

    try {
      final fetched = await _repository.fetchAllProducts(
        forceRefresh: forceRefresh,
      );
      products.assignAll(fetched);
      _syncFavoriteFlags();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoadingProducts.value = false;
    }
  }

  /// Fetches products belonging to the logged-in seller.
  Future<void> loadMyProducts({
    required String username,
    bool forceRefresh = false,
  }) async {
    if (isLoadingMyProducts.value) return;
    isLoadingMyProducts.value = true;
    errorMessage.value = '';

    try {
      final fetched = await _repository.getMyProducts(
        username: username,
        forceRefresh: forceRefresh,
      );
      myProducts.assignAll(fetched);
      _syncFavoriteFlags();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoadingMyProducts.value = false;
    }
  }

  /// Called by WishlistController after wishlist state changes so that
  /// heart icons stay in sync across every product list.
  void syncFavoriteFlags(Set<int> wishlistIds) {
    for (final p in products) {
      p.isFavorite = wishlistIds.contains(p.id);
    }
    for (final p in myProducts) {
      p.isFavorite = wishlistIds.contains(p.id);
    }
    products.refresh();
    myProducts.refresh();
  }

  // ── Internal ─────────────────────────────────────────────────────────────

  void _syncFavoriteFlags() {
    if (!Get.isRegistered<WishlistController>()) return;
    final wishlistIds = Get.find<WishlistController>().wishlistIds;
    syncFavoriteFlags(wishlistIds);
  }
}