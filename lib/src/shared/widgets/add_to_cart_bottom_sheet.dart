import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../design/app_text_styles.dart';
import '../../../models/product_api.dart';
import 'product_variant_widgets.dart';

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
  final Map<String, int> _quantitiesByKey = <String, int>{};

  @override
  void initState() {
    super.initState();
    _variants = resolveProductVariants(widget.product, widget.variants);
    _selected = _variants.firstWhere(
      (variant) => variant.detId == widget.initialDetId,
      orElse: () => _variants.first,
    );
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
                  if (widget.product.itemName.trim().isNotEmpty)
                    Text(
                      widget.product.itemName.trim(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleMedium,
                    ),
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
                        final quantity = _quantityFor(variant);

                        return ProductVariantOptionCard(
                          variant: variant,
                          isSelected: isSelected,
                          quantity: quantity,
                          showQuantityStepper: true,
                          showSelectionIndicator: false,
                          onTap: () {
                            setState(() {
                              _selectVariant(variant);
                            });
                          },
                          onQuantityChanged: (value) {
                            setState(() {
                              _selectVariant(variant);
                              _quantitiesByKey[_variantKey(variant)] = value;
                            });
                          },
                        );
                      },
                    ),
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
                          : () => Navigator.of(context).pop(
                              AddToCartSelection(
                                _selected,
                                _quantityFor(_selected),
                              ),
                            ),
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

  void _selectVariant(ApiProductVariant variant) {
    _selected = variant;
  }

  int _quantityFor(ApiProductVariant variant) {
    final key = _variantKey(variant);
    final stored = _quantitiesByKey[key];
    if (stored != null) {
      return stored;
    }
    _quantitiesByKey[key] = 1;
    return 1;
  }

  String _variantKey(ApiProductVariant variant) {
    return '${variant.detId}|${variant.brand}|${variant.color}|${variant.itemSize}|${variant.itemPrice}|${variant.itemQty}';
  }
}

List<ApiProductVariant> resolveProductVariants(
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
      brand: '',
      color: '',
      itemSize: '',
      discount: 0,
      itemPrice: product.price,
      itemQty: product.quantity,
    ),
  ];
}
