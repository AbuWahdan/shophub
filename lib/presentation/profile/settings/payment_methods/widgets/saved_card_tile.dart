import 'package:flutter/material.dart';

import '../../../../../design/app_colors.dart';
import '../../../../../design/app_radius.dart';
import '../../../../../design/app_shadows.dart';
import '../../../../../design/app_spacing.dart';
import '../../../../../design/app_text_styles.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../models/credit_card_model.dart';
import 'payment_methods_tokens.dart';

class SavedCardTile extends StatelessWidget {
  const SavedCardTile({
    super.key,
    required this.card,
    required this.onSetDefault,
    required this.onDelete,
  });

  final CreditCardModel card;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final gradient = card.cardType == 'MASTERCARD'
        ? PaymentMethodsTokens.mastercardGradient
        : card.cardType == 'VISA'
        ? PaymentMethodsTokens.visaGradient
        : PaymentMethodsTokens.defaultGradient;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: const [AppShadows.subtleShadow],
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: PaymentMethodsTokens.cardIconSize,
            height: PaymentMethodsTokens.cardIconSize,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              PaymentMethodsTokens.cardIcon,
              color: AppColors.white,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '${card.cardType} ${card.maskedNumber}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.titleMedium,
                      ),
                    ),
                    if (card.isDefault) ...[
                      const SizedBox(width: AppSpacing.sm),
                      _DefaultBadge(label: l10n.defaultBadge),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${l10n.expiresLabel} ${card.expiryFormatted}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          PopupMenuButton<_CardAction>(
            icon: const Icon(PaymentMethodsTokens.moreIcon),
            onSelected: (action) {
              switch (action) {
                case _CardAction.setDefault:
                  onSetDefault();
                case _CardAction.delete:
                  onDelete();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _CardAction.setDefault,
                child: Text(l10n.addressesSetDefault),
              ),
              PopupMenuItem(
                value: _CardAction.delete,
                child: Text(l10n.commonDelete),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _CardAction { setDefault, delete }

class _DefaultBadge extends StatelessWidget {
  const _DefaultBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(color: AppColors.success),
      ),
    );
  }
}
