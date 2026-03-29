import 'package:flutter/material.dart';

import '../../design/app_text_styles.dart';
import '../../l10n/l10n.dart';
import '../../model/product_api.dart';

class AddToCartSelection {
  const AddToCartSelection(this.variant, this.qty);

  final ApiProductVariant variant;
  final int qty;
}

class AddToCartBottomSheet extends StatefulWidget {
  const AddToCartBottomSheet({
    super.key,
    required this.product,
    this.variants,
    this.initialDetId,
  });

  final ApiProduct product;
  final List<ApiProductVariant>? variants;
  final int? initialDetId;

  @override
  State<AddToCartBottomSheet> createState() => _AddToCartBottomSheetState();
}

class _AddToCartBottomSheetState extends State<AddToCartBottomSheet> {
  late final List<ApiProductVariant> _variants;
  late ApiProductVariant _selected;
  int _qty = 1;

  @override
  void initState() {
    super.initState();
    _variants = _resolveVariants(widget.product, widget.variants);
    _selected = _variants.firstWhere(
      (variant) => variant.detId == widget.initialDetId,
      orElse: () => _variants.first,
    );
  }

  bool _hasMeaningfulValue(String? value) {
    final normalized = (value ?? '').trim().toLowerCase();
    return normalized.isNotEmpty &&
        normalized != '0' &&
        normalized != 'null' &&
        normalized != 'n/a';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(top: AppSpacing.xl, bottom: viewInsetsBottom),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: AppSpacing.xxl,
                      height: AppSpacing.xs,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('Select Variant', style: AppTextStyles.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _variants.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final variant = _variants[index];
                        final isSelected = variant.detId == _selected.detId;
                        final hasDiscount = variant.discount > 0;
                        final discounted =
                            variant.itemPrice * (1 - (variant.discount / 100));
                        final showColor = _hasMeaningfulValue(variant.color);
                        final showBrand = _hasMeaningfulValue(variant.brand);
                        final showSize = _hasMeaningfulValue(variant.itemSize);
                        final showDefaultVariant =
                            !showColor && !showBrand && !showSize;

                        return InkWell(
                          onTap: () => setState(() {
                            _selected = variant;
                            if (_qty > variant.itemQty && variant.itemQty > 0) {
                              _qty = variant.itemQty;
                            }
                          }),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd,
                          ),
                          child: Container(
                            padding: AppSpacing.insetsMd,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : theme.dividerColor,
                                width: isSelected
                                    ? AppSpacing.borderThick
                                    : AppSpacing.borderThin,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (showDefaultVariant)
                                        Text(
                                          'Default Variant',
                                          style: AppTextStyles.labelLarge,
                                        ),
                                      if (showColor)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: AppSpacing.xs,
                                          ),
                                          child: Text(
                                            'Color: ${variant.color.trim()}',
                                            style: AppTextStyles.bodySmall,
                                          ),
                                        ),
                                      if (showBrand)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: AppSpacing.xs,
                                          ),
                                          child: Text(
                                            'Brand: ${variant.brand.trim()}',
                                            style: AppTextStyles.bodySmall,
                                          ),
                                        ),
                                      if (showSize)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: AppSpacing.xs,
                                          ),
                                          child: Text(
                                            'Size: ${variant.itemSize.trim()}',
                                            style: AppTextStyles.bodySmall,
                                          ),
                                        ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Wrap(
                                        spacing: AppSpacing.sm,
                                        children: [
                                          if (variant.itemPrice > 0)
                                            Text(
                                              '\$${(hasDiscount ? discounted : variant.itemPrice).toStringAsFixed(2)}',
                                              style: AppTextStyles.labelLarge
                                                  .copyWith(
                                                    color: AppColors.primary,
                                                  ),
                                            ),
                                          if (hasDiscount)
                                            Text(
                                              '\$${variant.itemPrice.toStringAsFixed(2)}',
                                              style: AppTextStyles.bodySmall
                                                  .copyWith(
                                                    decoration: TextDecoration
                                                        .lineThrough,
                                                  ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    color: AppColors.primary,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Text(
                        context.l10n.cartQuantity,
                        style: AppTextStyles.titleSmall,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      IconButton(
                        onPressed: _qty > 1
                            ? () => setState(() => _qty--)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text(_qty.toString(), style: AppTextStyles.labelLarge),
                      IconButton(
                        onPressed:
                            (_selected.itemQty <= 0 ||
                                _qty >= _selected.itemQty)
                            ? null
                            : () => setState(() => _qty++),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    height: AppSpacing.buttonMd,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusLg,
                          ),
                        ),
                      ),
                      onPressed: _selected.itemQty <= 0
                          ? null
                          : () => Navigator.of(
                              context,
                            ).pop(AddToCartSelection(_selected, _qty)),
                      child: Text(
                        context.l10n.productAddToCart,
                        style: AppTextStyles.buttonLarge.copyWith(
                          color: AppColors.textOnPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

List<ApiProductVariant> _resolveVariants(
  ApiProduct product,
  List<ApiProductVariant>? overrides,
) {
  if (overrides != null && overrides.isNotEmpty) {
    return overrides;
  }

  if (product.details.isNotEmpty) {
    return product.details;
  }

  return [
    ApiProductVariant(
      detId: product.detId,
      brand: 'Unknown',
      color: 'Default',
      itemSize: 'Default',
      discount: 0,
      itemPrice: product.price,
      itemQty: product.quantity,
    ),
  ];
}
