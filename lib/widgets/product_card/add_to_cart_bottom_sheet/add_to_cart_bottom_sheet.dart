import 'package:flutter/material.dart';

import '../../../../design/app_colors.dart';
import '../../../design/app_radius.dart';
import '../../../design/app_spacing.dart';
import '../../../design/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../models/product/product_model.dart';
import 'widgets/product_variant_widgets.dart';

class AddToCartSelection {
  const AddToCartSelection(this.variant, this.qty);

  final ProductVariant variant;
  final int qty;
}

/// Full-feature add-to-cart bottom sheet.
///
/// Layout (top → bottom):
///   1. Drag handle
///   2. Product name + total price summary header
///   3. Scrollable variant list with quantity steppers
///   4. Sticky "Add to cart" CTA anchored above the system nav bar
///
/// The sheet respects [MediaQuery.viewInsets] so it lifts above
/// the soft keyboard when a search / promo field is focused.
class AddToCartBottomSheet extends StatefulWidget {
  const AddToCartBottomSheet({
    super.key,
    required this.product,
    this.variants,
    this.initialDetId,
  });

  final ProductModel product;
  final List<ProductVariant>? variants;
  final int? initialDetId;

  @override
  State<AddToCartBottomSheet> createState() => _AddToCartBottomSheetState();
}

class _AddToCartBottomSheetState extends State<AddToCartBottomSheet> {
  late final List<ProductVariant> _variants;
  late ProductVariant _selected;
  final Map<String, int> _quantitiesByKey = {};

  @override
  void initState() {
    super.initState();
    _variants = resolveProductVariants(widget.product, widget.variants);
    _selected = _variants.firstWhere(
          (v) => v.detId == widget.initialDetId,
      orElse: () => _variants.first,
    );
  }

  void _selectVariant(ProductVariant variant) {
    _selected = variant;
  }

  int _quantityFor(ProductVariant variant) {
    final key = _variantKey(variant);
    return _quantitiesByKey.putIfAbsent(key, () => 1);
  }

  String _variantKey(ProductVariant v) =>
      '${v.detId}|${v.brand}|${v.color}|${v.size}|${v.price}|${v.stock}';

  double get _selectedTotal =>
      effectiveVariantPrice(_selected) * _quantityFor(_selected);

  @override
  Widget build(BuildContext context) {
    final theme        = Theme.of(context);
    final colorScheme  = theme.colorScheme;
    final l10n         = AppLocalizations.of(context);
    final bottomInset  = MediaQuery.of(context).viewInsets.bottom;
    final isOutOfStock = _selected.stock <= 0;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.82,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DragHandle(),
              _SheetHeader(
                product: widget.product,
                totalPrice: _selectedTotal,
                l10n: l10n,
                colorScheme: colorScheme,
              ),
              Flexible(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  shrinkWrap: true,
                  itemCount: _variants.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final variant  = _variants[index];
                    final selected = variant.detId == _selected.detId;
                    final qty      = _quantityFor(variant);

                    return ProductVariantOptionCard(
                      variant: variant,
                      isSelected: selected,
                      quantity: qty,
                      showQuantityStepper: true,
                      showSelectionIndicator: false,
                      onTap: () => setState(() => _selectVariant(variant)),
                      onQuantityChanged: (value) => setState(() {
                        _selectVariant(variant);
                        _quantitiesByKey[_variantKey(variant)] = value;
                      }),
                    );
                  },
                ),
              ),
              _AddToCartButton(
                isOutOfStock: isOutOfStock,
                l10n: l10n,
                onPressed: () => Navigator.of(context).pop(
                  AddToCartSelection(_selected, _quantityFor(_selected)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.xs),
      child: Center(
        child: Container(
          width: AppSpacing.dragHandleWidth,
          height: AppSpacing.dragHandleHeight,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({
    required this.product,
    required this.totalPrice,
    required this.l10n,
    required this.colorScheme,
  });

  final ProductModel product;
  final double totalPrice;
  final AppLocalizations l10n;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final hasName = product.name.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasName)
                  Text(
                    product.name.trim(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleMedium,
                  ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  l10n.cartTotalLabel,
                  style: AppTextStyles.caption.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            totalPrice.toStringAsFixed(2),
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.priceGreen,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddToCartButton extends StatelessWidget {
  const _AddToCartButton({
    required this.isOutOfStock,
    required this.l10n,
    required this.onPressed,
  });

  final bool isOutOfStock;
  final AppLocalizations l10n;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: SizedBox(
        width: double.infinity,
        height: AppSpacing.buttonMd,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
            isOutOfStock ? AppColors.neutral400 : AppColors.primary,
            foregroundColor: AppColors.white,
            disabledBackgroundColor: AppColors.neutral400,
            disabledForegroundColor: AppColors.white,
            elevation: isOutOfStock ? 0 : 2,
            shadowColor: AppColors.primary.withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          onPressed: isOutOfStock ? null : onPressed,
          child: Text(
            isOutOfStock
                ? l10n.stockOutOfStock
                : l10n.productAddToCart,
            style: AppTextStyles.buttonLarge,
          ),
        ),
      ),
    );
  }
}

List<ProductVariant> resolveProductVariants(
    ProductModel product,
    List<ProductVariant>? overrides,
    ) {
  if (overrides != null && overrides.isNotEmpty) return overrides;
  if (product.variants.isNotEmpty) return product.variants;
  return [
    ProductVariant(
      detId: product.detId,
      brand: '',
      color: '',
      size: '',
      discount: product.discountPercentage.toDouble(),
      price: product.finalPrice,
      stock: product.quantity,
    ),
  ];
}