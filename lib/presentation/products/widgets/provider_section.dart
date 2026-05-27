import 'package:flutter/material.dart';

import '../../../../design/app_colors.dart';
import '../../../../design/app_radius.dart';
import '../../../../design/app_spacing.dart';
import '../../../../design/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';

class ProviderSection extends StatelessWidget {
  final String providerName;
  final VoidCallback onTap;

  const ProviderSection({
    super.key,
    required this.providerName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: AppSpacing.insetsSm,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Icon(
              Icons.storefront_outlined,
              size: 18,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              l10n.productSoldBy,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                providerName,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}