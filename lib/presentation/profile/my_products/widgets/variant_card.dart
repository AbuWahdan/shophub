import 'package:flutter/material.dart';
import '../../../../core/config/size_options.dart';
import '../../../../design/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../widgets/widgets/app_text_field.dart';
import '../color_picker/color_hex_field.dart';
import '../models/variant_form_entry.dart';
import '../utils/product_validators.dart';

/// A self-contained card for one product variant.
/// Shared between [InsertProductPage] and [EditProductPage].
///
/// [showActiveToggle] — shown only in Edit mode (existing variants).
/// [showRemoveButton] — shown only for unsaved (new) variants.
class VariantCard extends StatelessWidget {
  const VariantCard({
    super.key,
    required this.index,
    required this.entry,
    required this.isSubmitting,
    this.showActiveToggle = false,
    this.showRemoveButton = false,
    this.onActiveToggled,
    this.onRemovePressed,
    this.onSizeGroupChanged,
    this.onSizeChanged,
  });

  final int index;
  final VariantFormEntry entry;
  final bool isSubmitting;

  final bool showActiveToggle;
  final bool showRemoveButton;

  final ValueChanged<bool>? onActiveToggled;
  final VoidCallback? onRemovePressed;
  final ValueChanged<int?>? onSizeGroupChanged;
  final ValueChanged<int?>? onSizeChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final validators = ProductValidators.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final groupSizes = sizeOptions[entry.sizeGroupId] ?? const <SizeOption>[];

    final borderColor = entry.isActive
        ? Theme.of(context).dividerColor
        : colorScheme.error.withOpacity(0.5);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _VariantCardHeader(
              index: index,
              entry: entry,
              isSubmitting: isSubmitting,
              showActiveToggle: showActiveToggle,
              showRemoveButton: showRemoveButton,
              onActiveToggled: onActiveToggled,
              onRemovePressed: onRemovePressed,
            ),
            if (!entry.isActive && entry.pendingDeactivate)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  l10n.variantWillBeRemovedOnSave,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.error,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: entry.brandController,
                    label: l10n.productBrand,
                    hintText: l10n.productBrandHint,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ColorHexField(
                    initialColor: entry.colorController.text,
                    label: l10n.productColor,
                    onColorChanged: (v) => entry.colorController.text = v,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _SizeGroupDropdown(
              entry: entry,
              isSubmitting: isSubmitting,
              onChanged: onSizeGroupChanged,
            ),
            const SizedBox(height: AppSpacing.md),
            _SizeDropdown(
              entry: entry,
              groupSizes: groupSizes,
              isSubmitting: isSubmitting,
              onChanged: onSizeChanged,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: entry.priceController,
                    label: l10n.productPriceLabel,
                    hintText: l10n.productPriceHint,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: validators.positiveDouble,
                    showRequiredAsterisk: true,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppTextField(
                    controller: entry.qtyController,
                    label: l10n.productQuantityLabel,
                    hintText: l10n.productQuantityHint,
                    keyboardType: TextInputType.number,
                    validator: validators.positiveInt,
                    showRequiredAsterisk: true,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppTextField(
                    controller: entry.discountController,
                    label: l10n.productDiscountLabel,
                    hintText: l10n.productDiscountHint,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: validators.optionalDiscount,
                    textInputAction: TextInputAction.done,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _VariantCardHeader extends StatelessWidget {
  const _VariantCardHeader({
    required this.index,
    required this.entry,
    required this.isSubmitting,
    required this.showActiveToggle,
    required this.showRemoveButton,
    required this.onActiveToggled,
    required this.onRemovePressed,
  });

  final int index;
  final VariantFormEntry entry;
  final bool isSubmitting;
  final bool showActiveToggle;
  final bool showRemoveButton;
  final ValueChanged<bool>? onActiveToggled;
  final VoidCallback? onRemovePressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            'Variant ${index + 1}${entry.isNew ? ' (new)' : ''}',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 4),
        if (showRemoveButton && entry.isNew)
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            tooltip: 'Remove variant',
            onPressed: isSubmitting ? null : onRemovePressed,
          )
        else if (showActiveToggle)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  entry.isActive ? 'Active' : 'Inactive',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: entry.isActive
                        ? Colors.green
                        : colorScheme.error,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Switch(
                value: entry.isActive,
                activeThumbColor: Colors.green,
                onChanged: isSubmitting ? null : onActiveToggled,
              ),
            ],
          ),
      ],
    );
  }
}

class _SizeGroupDropdown extends StatelessWidget {
  const _SizeGroupDropdown({
    required this.entry,
    required this.isSubmitting,
    required this.onChanged,
  });

  final VariantFormEntry entry;
  final bool isSubmitting;
  final ValueChanged<int?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DropdownButtonFormField<int>(
      value: entry.sizeGroupId,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: l10n.productSizeGroup,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
      hint: Text(
        l10n.productSelectGroupOptional,
        overflow: TextOverflow.ellipsis,
      ),
      items: sizeGroups
          .map(
            (g) => DropdownMenuItem<int>(
          value: g.id,
          child: Text(g.name, overflow: TextOverflow.ellipsis, maxLines: 1),
        ),
      )
          .toList(),
      onChanged: isSubmitting ? null : onChanged,
    );
  }
}

class _SizeDropdown extends StatelessWidget {
  const _SizeDropdown({
    required this.entry,
    required this.groupSizes,
    required this.isSubmitting,
    required this.onChanged,
  });

  final VariantFormEntry entry;
  final List<SizeOption> groupSizes;
  final bool isSubmitting;
  final ValueChanged<int?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DropdownButtonFormField<int>(
      value: entry.sizeId,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: l10n.productSize,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
      hint: Text(
        entry.sizeGroupId == null
            ? l10n.productSelectGroupFirst
            : l10n.productSelectSizeOptional,
        overflow: TextOverflow.ellipsis,
      ),
      items: groupSizes
          .map(
            (s) => DropdownMenuItem<int>(
          value: s.id,
          child: Text(s.name, overflow: TextOverflow.ellipsis, maxLines: 1),
        ),
      )
          .toList(),
      onChanged: (isSubmitting || entry.sizeGroupId == null) ? null : onChanged,
    );
  }
}