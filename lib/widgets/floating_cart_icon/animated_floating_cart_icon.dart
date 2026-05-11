import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sinwar_shoping/controllers/floating_cart_controller.dart';
import 'package:sinwar_shoping/design/app_colors.dart';
import 'package:sinwar_shoping/design/app_spacing.dart';
import 'package:sinwar_shoping/design/app_text_styles.dart';

/// Animated Floating Shopping Cart Icon
/// 
/// **Features:**
/// - Shows cart count badge with scale animation on add
/// - Hides completely when cart is empty (count == 0)
/// - Taps navigate to cart screen without back button
/// - Animated counter bump when items added
class AnimatedFloatingCartIcon extends StatefulWidget {
  const AnimatedFloatingCartIcon({
    super.key,
    required this.controller,
  });

  final FloatingCartController controller;

  @override
  State<AnimatedFloatingCartIcon> createState() =>
      _AnimatedFloatingCartIconState();
}

class _AnimatedFloatingCartIconState extends State<AnimatedFloatingCartIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _badgeAnimController;
  late Animation<double> _badgeScaleAnim;

  @override
  void initState() {
    super.initState();
    _badgeAnimController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _badgeScaleAnim = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _badgeAnimController, curve: Curves.elasticOut),
    );

    // Listen for animation triggers
    widget.controller.shouldAnimateBadge.listen((shouldAnimate) {
      if (shouldAnimate) {
        _badgeAnimController.forward().then((_) {
          _badgeAnimController.reverse();
        });
      }
    });
  }

  @override
  void dispose() {
    _badgeAnimController.dispose();
    super.dispose();
  }

  void _navigateToCart() {
    // Navigate without back button - clears the nav stack or uses offNamed
    Get.offNamed('/cart');
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        // Hide entire FAB if cart is empty
        if (!widget.controller.isCartVisible) {
          return const SizedBox.shrink();
        }

        return Positioned(
          bottom: AppSpacing.lg,
          right: AppSpacing.lg,
          child: FloatingActionButton(
            heroTag: 'cart-fab',
            backgroundColor: AppColors.primary,
            onPressed: _navigateToCart,
            tooltip: 'Go to Cart',
            child: Stack(
              children: [
                // Cart Icon
                const Icon(
                  Icons.shopping_cart_outlined,
                  color: AppColors.black,
                  size: 28,
                ),
                // Animated Badge
                Positioned(
                  top: 0,
                  right: 0,
                  child: ScaleTransition(
                    scale: _badgeScaleAnim,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.error,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.controller.cartCount.value.toString(),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Reusable Cart Badge Widget (for use in other contexts)
class CartCountBadge extends StatelessWidget {
  const CartCountBadge({
    super.key,
    required this.count,
    this.isAnimating = false,
    this.animationScale = 1.0,
  });

  final int count;
  final bool isAnimating;
  final double animationScale;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    return Transform.scale(
      scale: animationScale,
      child: Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.error,
        ),
        alignment: Alignment.center,
        child: Text(
          count.toString(),
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
