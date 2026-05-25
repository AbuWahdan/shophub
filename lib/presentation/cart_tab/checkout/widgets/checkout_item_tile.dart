import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../design/app_colors.dart';
import '../../../../design/app_radius.dart';
import '../../../../design/app_shadows.dart';
import '../../../../design/app_spacing.dart';
import '../../../../design/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/cart_item_model.dart';
import '../../../../widgets/custom_image.dart';
import 'checkout_tokens.dart';

class CheckoutItemTile extends StatelessWidget {
  const CheckoutItemTile({super.key, required this.item});

  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currency = NumberFormat.simpleCurrency(
      locale: Localizations.localeOf(context).toLanguageTag(),
    );
    final variant = [
      l10n.checkoutQuantity(item.bookedQty),
      if (item.color.trim().isNotEmpty) item.displayColor,
      if (item.size.trim().isNotEmpty) item.displaySize,
    ].join(' · ');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: const [AppShadows.subtleShadow],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: CustomImage(
              path: item.imageUrl,
              width: CheckoutTokens.imageSize,
              height: CheckoutTokens.imageSize,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.brand.trim().isEmpty ? item.description : item.brand,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  variant,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            currency.format(item.lineTotal),
            style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
