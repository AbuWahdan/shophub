import 'package:flutter/material.dart';

import '../../../../../design/app_colors.dart';
import '../../../../../design/app_radius.dart';
import '../../../../../design/app_spacing.dart';
import '../../../../../design/app_text_styles.dart';

class CardTypeSelector extends StatelessWidget {
  const CardTypeSelector({
    super.key,
    required this.label,
    required this.types,
    required this.selectedType,
    required this.onChanged,
  });

  final String label;
  final List<String> types;
  final String selectedType;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: types
              .map(
                (type) => Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(
                      end: type == types.last ? 0 : AppSpacing.sm,
                    ),
                    child: _CardTypeChip(
                      type: type,
                      selected: type == selectedType,
                      onTap: () => onChanged(type),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _CardTypeChip extends StatelessWidget {
  const _CardTypeChip({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final String type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: type,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: AppSpacing.buttonMd,
        decoration: BoxDecoration(
          color: selected ? AppColors.surfaceVariant : AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected
                ? AppSpacing.borderThin
                : AppSpacing.borderThin / AppSpacing.borderThin,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: onTap,
          child: Center(
            child: FittedBox(
              child: Text(
                type,
                style: AppTextStyles.labelLarge.copyWith(
                  color: selected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
