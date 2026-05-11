import 'package:get/get.dart';
import '../repositories/cart_repository.dart';

/// GetX Controller for Floating Shopping Cart Icon
/// 
/// Manages:
/// - Total cart item count (reactive)
/// - Visibility state (hide if empty)
/// - Animation triggers for add-to-cart actions
class FloatingCartController extends GetxController {
  final CartRepository _cartRepository;

  FloatingCartController(this._cartRepository);

  // ─────────────────────────────────────────────
  // STATE
  // ─────────────────────────────────────────────
  
  /// Total number of items in cart
  final RxInt cartCount = 0.obs;
  
  /// Trigger animation when item is added
  final RxBool shouldAnimateBadge = false.obs;
  
  /// Track current username for auto-refresh
  String? _currentUsername;

  @override
  void onInit() {
    super.onInit();
    _setupCartListener();
  }

  // ─────────────────────────────────────────────
  // PUBLIC API
  // ─────────────────────────────────────────────

  /// Initialize with username and load cart
  Future<void> initializeCart(String username) async {
    _currentUsername = username.trim();
    if (_currentUsername!.isEmpty) {
      cartCount.value = 0;
      return;
    }
    await loadCart();
  }

  /// Manually refresh cart from API
  Future<void> loadCart() async {
    // if (_currentUsername == null || _currentUsername!.isEmpty) return;
    // try {
    //   final items = await _cartRepository.getCart(username: _currentUsername!);
    //   cartCount.value = items.fold<int>(
    //     0,
    //     (sum, item) => sum + item.bookedQty,
    //   );
    // } catch (e) {
    //   // Silent fail for UI - cart icon just shows 0
    //   cartCount.value = 0;
    // }
  }

  /// Trigger badge animation (called when user taps "Add to Cart")
  void triggerAddToCartAnimation() {
    shouldAnimateBadge.value = true;
    Future.delayed(const Duration(milliseconds: 600), () {
      shouldAnimateBadge.value = false;
    });
  }

  /// Check if cart should be visible (count > 0)
  bool get isCartVisible => cartCount.value > 0;

  // ─────────────────────────────────────────────
  // PRIVATE HELPERS
  // ─────────────────────────────────────────────

  void _setupCartListener() {
    // This would integrate with CartController in a real app
    // For now, manual refresh is called from screens
  }
}
