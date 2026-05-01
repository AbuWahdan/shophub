import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:sinwar_shoping/design/app_radius.dart';

import '../../controllers/cart_controller.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../design/app_text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../models/cart_item_model.dart';
import '../../core/config/route.dart';
import '../../widgets/dialogs/app_dialogs.dart';
import '../../widgets/widgets/app_button.dart';
import '../../widgets/widgets/app_image.dart';
import '../../widgets/widgets/app_snackbar.dart';
import '../../core/state/auth_state.dart';
import '../../widgets/widgets/empty_state.dart';
import '../../widgets/widgets/quantity_stepper.dart';
import '../home_tab/main_page.dart';
import 'checkout/checkout_screen.dart';

class ShoppingCartPage extends StatefulWidget {
  const ShoppingCartPage({super.key});

  @override
  State<ShoppingCartPage> createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  final CartController cartController = Get.find<CartController>();

  static const int homeTabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCartFromApi();
    });
  }

  Future<String> _getUsername() async {
    if (!mounted) return '';
    final authState = context.read<AuthState>();
    await authState.ensureInitialized();
    return authState.user?.username.trim() ?? '';
  }

  Future<void> _loadCartFromApi() async {
    final username = await _getUsername();
    if (username.isNotEmpty) {
      await cartController.loadCart(username: username);
    }
  }

  void _openProductDetails(CartItemModel cartItem) {
    Navigator.pushNamed(
      context,
      AppRoutes.productDetails,
      arguments: {
        'product':       cartItem.product,
        'selectedSize':  cartItem.displaySize,
        'selectedColor': cartItem.displayColor,
        'selectedDetId': cartItem.itemDetId,
      },
    );
  }

  double get totalPrice =>
      cartController.items.fold(0, (sum, item) => sum + item.total);

  void _showRemoveConfirmation(CartItemModel cartItem) {
    final l10n = AppLocalizations.of(context);
    AppDialogs.showConfirmation(
      context: context,
      title:   l10n.cartRemoveItemTitle,
      message: l10n.cartRemoveItemMessage,
      confirmLabel: l10n.commonRemove,
      cancelLabel:  l10n.commonCancel,
      onConfirm: () async {
        final username = await _getUsername();
        if (username.isEmpty) {
          AppSnackBar.show(
            context,
            message: AppLocalizations.of(context).productAccountUnavailable,
            type: AppSnackBarType.error,
          );
          return;
        }
        final success = await cartController.removeItem(
          item: cartItem, username: username,
        );
        if (mounted && success) {
          AppSnackBar.show(
            context,
            message: l10n.cartItemRemoved,
            type: AppSnackBarType.info,
          );
        }
      },
    );
  }

  // ── Cart item card ─────────────────────────────────────────────────────────

  Widget _buildCartItemCard(CartItemModel item) {
    final isUpdating =
        cartController.itemLoading[cartController.itemKey(item)] == true;

    final availableStock =
    item.availableQty ;
        //> 0 ? item.availableQty : item.itemQty;

    // FIX: Build the image URL directly from ApiCartItem fields instead of
    // going through toProduct() — toProduct() may produce an empty images list
    // when itemImgUrl contains a path rather than a URL, or when the split
    // produces empty strings.
    final imageUrl = item.itemImgUrl.trim();

    final hasDiscount = item.discount > 0 && item.discount < 100;
    final finalPrice  = item.finalPrice;
    final itemTotal   = finalPrice * item.itemQty;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        onTap: isUpdating ? null : () => _openProductDetails(item),
        child: Padding(
          padding: AppSpacing.insetsMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top row: image + info + delete ───────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FIX: image loaded from itemImgUrl directly
                  _CartItemImage(imageUrl: imageUrl),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product name
                        Text(
                          item.itemName.trim().isEmpty
                              ? 'Product'
                              : item.itemName.trim(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),

                        // Price row
                        Wrap(
                          spacing: AppSpacing.sm,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              '\$${finalPrice.toStringAsFixed(2)}',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.black,
                              ),
                            ),
                            if (hasDiscount)
                              Text(
                                '\$${item.itemPrice.toStringAsFixed(2)}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            if (hasDiscount)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xs,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '-${item.discount.toStringAsFixed(0)}%',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),

                        // FIX: Show all variant details — size, color, brand
                        _buildVariantChips(item),

                        const SizedBox(height: AppSpacing.xs),
                        if (availableStock < 10)
                          Text(
                            'Only $availableStock left',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Delete button
                  IconButton(
                    icon: const Icon(Icons.close, size: AppSpacing.iconMd),
                    onPressed: isUpdating
                        ? null
                        : () => _showRemoveConfirmation(item),
                    color: Theme.of(context).colorScheme.onSurface,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),

              const Divider(height: AppSpacing.lg),

              // ── Bottom row: quantity stepper + item total ─────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context).cartQuantity,
                      style: AppTextStyles.bodyMedium),

                  // FIX: spinner shown only when THIS item is loading,
                  // not any item.
                  if (isUpdating)
                    const SizedBox(
                      width: 50,
                      height: 40,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else
                    QuantityStepper(
                      value: item.itemQty,
                      decrementIcon: item.itemQty <= 1
                          ? Icons.delete_outline
                          : Icons.remove,
                      onDecrement: () async {
                        final username = await _getUsername();
                        if (username.isNotEmpty) {
                          await cartController.decrementItem(
                            item: item, username: username,
                          );
                        }
                      },

                      onIncrement: item.itemQty < item.availableQty
                          ? () async {
                        final username = await _getUsername();
                        if (username.isNotEmpty) {
                          await cartController.incrementItem(
                            item: item, username: username,
                          );
                        }
                      }
                          : null,
                    ),
                ],
              ),

              const Divider(height: AppSpacing.lg),

              // Item subtotal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context).cartItemTotal,
                      style: AppTextStyles.bodySmall),
                  Text(
                    '\$${itemTotal.toStringAsFixed(2)}',
                    style: AppTextStyles.labelLarge,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows size / color / brand as small chips.
  Widget _buildVariantChips(CartItemModel item) {
    final chips = <_ChipData>[];

    final size = item.itemSize.trim();
    if (size.isNotEmpty && size.toLowerCase() != 'default') {
      chips.add(_ChipData(label: 'Size: $size', icon: Icons.straighten));
    }

    final color = item.color.trim();
    if (color.isNotEmpty && color.toLowerCase() != 'default') {
      chips.add(_ChipData(label: color, icon: Icons.circle,
          colorHex: color));
    }

    final brand = item.brand.trim();
    if (brand.isNotEmpty) {
      chips.add(_ChipData(label: brand, icon: Icons.sell_outlined));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: chips.map((c) => _VariantChip(data: c)).toList(),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return EmptyState(
      icon: Icons.shopping_cart_outlined,
      title: AppLocalizations.of(context).cartEmptyTitle,
      message: AppLocalizations.of(context).cartEmptyMessage,
      action: AppButton(
        label: AppLocalizations.of(context).cartStartShopping,
        onPressed: () {
          final switched =
          MainPage.switchToTab(context, homeTabIndex);
          if (switched) return;
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.main,
                (route) => false,
            arguments: {'initialTabIndex': homeTabIndex},
          );
        },
        leading: const Icon(Icons.shopping_bag),
        fullWidth: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).cartTitle),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Obx(() {
        if (cartController.isLoading.value && cartController.items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: AppSpacing.xl),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (cartController.items.isEmpty) {
          return _buildEmptyCart();
        }

        return RefreshIndicator(
          onRefresh: _loadCartFromApi,
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints:
                BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: AppSpacing.insetsMd,
                  child: Column(
                    children: [
                      // FIX: each card is wrapped in its own Obx so only
                      // the affected card rebuilds when itemLoading changes.
                      ...cartController.items.map(
                            (item) => Obx(() => _buildCartItemCard(item)),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        if (cartController.items.isEmpty || cartController.isLoading.value) {
          return const SizedBox.shrink();
        }

        return SafeArea(
          child: Container(
            padding: AppSpacing.insetsMd,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: AppSpacing.borderThin,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\$${totalPrice.toStringAsFixed(2)}',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${AppLocalizations.of(context).cartShipping}: ${AppLocalizations.of(context).cartShippingFree}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: SizedBox(
                        height: AppSpacing.buttonMd,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppRadius.sm),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CheckoutScreen(
                                  cartItems: cartController.items.toList(),
                                ),
                              ),
                            );
                          },
                          child: Text(
                            AppLocalizations.of(context).cartCheckout,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(color: AppColors.black),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ── Cart item image widget ─────────────────────────────────────────────────────
// FIX: Dedicated widget that loads from the raw itemImgUrl string.
// Using AppImage directly handles all URL/path types that your backend returns.

class _CartItemImage extends StatelessWidget {
  final String imageUrl;
  const _CartItemImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.imageMd,
      height: AppSpacing.imageMd,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: imageUrl.isEmpty
            ? const _ImagePlaceholder()
            : AppImage(
          path: imageUrl,
          fit: BoxFit.cover,
          // If AppImage doesn't handle errors, wrap with a try or use
          // the errorBuilder pattern below.
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceVariant,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        size: AppSpacing.iconLg,
        color: AppColors.textHint,
      ),
    );
  }
}

// ── Variant chip helpers ───────────────────────────────────────────────────────

class _ChipData {
  final String label;
  final IconData icon;
  final String? colorHex;
  const _ChipData({required this.label, required this.icon, this.colorHex});
}

class _VariantChip extends StatelessWidget {
  final _ChipData data;
  const _VariantChip({required this.data});

  Color? _parseColor(String hex) {
    final clean = hex.replaceAll('#', '').trim();
    if (clean.length == 6) {
      return Color(int.tryParse('FF$clean', radix: 16) ?? 0);
    }
    if (clean.length == 8) {
      return Color(int.tryParse(clean, radix: 16) ?? 0);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final parsedColor = data.colorHex != null ? _parseColor(data.colorHex!) : null;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (parsedColor != null)
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: parsedColor,
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
            )
          else
            Icon(data.icon, size: 11, color: AppColors.textSecondary),
          const SizedBox(width: 3),
          Text(
            data.label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}