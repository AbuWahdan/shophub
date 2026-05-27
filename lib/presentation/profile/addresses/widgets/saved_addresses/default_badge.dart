import 'package:flutter/material.dart';

import '../../../../../design/app_colors.dart';
import '../../../../../design/app_radius.dart';
import '../../../../../design/app_spacing.dart';
import '../../../../../design/app_text_styles.dart';
import '../../../../../l10n/app_localizations.dart';

class DefaultBadge extends StatelessWidget {
  const DefaultBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        l10n.addressesDefault.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
      ),
    );
  }
}
