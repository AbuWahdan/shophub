import 'package:flutter/material.dart';
import '../../../design/app_colors.dart';
import '../../../design/app_radius.dart';
import '../../../design/app_spacing.dart';
import '../../../design/app_text_styles.dart';

/// Displays remaining stock availability for cart item
/// Shows warning when stock is low
class CartItemStockIndicator extends StatelessWidget {
  const CartItemStockIndicator({
    super.key,
    required this.availableStock,
    required this.bookedQuantity,
  });

  final int availableStock;
  final int bookedQuantity;

  @override
  Widget build(BuildContext context) {
    // Only show if stock is limited
    if (availableStock == 0) {
      return Text(
        'Out of stock',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.error,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    // Show low stock warning
   // if (CartConstants.isLowStock(availableStock))
    if (availableStock <= 100) {
      return Text(
        'Only ${availableStock} left',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.accent,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    // No warning needed
    return const SizedBox.shrink();
  }
}

/// Displays variant information as chips (size, color, brand)
class CartItemVariantChips extends StatelessWidget {
  const CartItemVariantChips({
    super.key,
    required this.size,
    required this.color,
    required this.brand,
  });

  final String size;
  final String color;
  final String brand;

  List<_ChipInfo> _buildChips() {
    final chips = <_ChipInfo>[];

    final normalizedSize = size.trim();
    if (normalizedSize.isNotEmpty &&
        normalizedSize.toLowerCase() != 'default') {
      chips.add(
        _ChipInfo(label: 'Size: $normalizedSize', icon: Icons.straighten),
      );
    }

    final normalizedColor = color.trim();
    if (normalizedColor.isNotEmpty &&
        normalizedColor.toLowerCase() != 'default') {
      chips.add(
        _ChipInfo(
          label: normalizedColor,
          icon: Icons.circle,
          colorHex: normalizedColor,
        ),
      );
    }

    final normalizedBrand = brand.trim();
    if (normalizedBrand.isNotEmpty) {
      chips.add(_ChipInfo(label: normalizedBrand, icon: Icons.sell_outlined));
    }

    return chips;
  }

  @override
  Widget build(BuildContext context) {
    final chips = _buildChips();
    if (chips.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: chips
            .map(
              (info) => _VariantChip(
                label: info.label,
                icon: info.icon,
                colorHex: info.colorHex,
              ),
            )
            .toList(),
      ),
    );
  }
}

/// Single variant chip display
class _VariantChip extends StatelessWidget {
  const _VariantChip({required this.label, required this.icon, this.colorHex});

  final String label;
  final IconData icon;
  final String? colorHex;

  Color? _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    try {
      return Color(int.parse('0xFF${hex.replaceFirst('#', '')}'));
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final parsedColor = _parseColor(colorHex);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border, width: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != Icons.circle)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(icon, size: 12, color: AppColors.textSecondary),
            ),
          if (icon == Icons.circle && parsedColor != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: parsedColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
              ),
            ),
          Text(label, style: AppTextStyles.caption.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}

/// Product image display for cart item
class CartItemImage extends StatelessWidget {
  const CartItemImage({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        color: AppColors.surfaceVariant,
      ),
      child: imageUrl.trim().isEmpty
          ? Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                color: AppColors.textHint,
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.textHint,
                  ),
                ),
              ),
            ),
    );
  }
}

/// Data model for variant chip information
class _ChipInfo {
  final String label;
  final IconData icon;
  final String? colorHex;

  _ChipInfo({required this.label, required this.icon, this.colorHex});
}
