import 'package:flutter/material.dart';

import '../../../design/app_colors.dart';
import '../../../design/app_radius.dart';
import '../../../design/app_spacing.dart';
import '../../../design/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/credit_card_model.dart';

enum _CreditCardAction { setDefault, delete }

class CreditCardTile extends StatelessWidget {
  const CreditCardTile({
    super.key,
    required this.card,
    this.compact = false,
    this.selected = false,
    this.onTap,
    this.onSetDefault,
    this.onDelete,
  });

  final CreditCardModel card;
  final bool compact;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onSetDefault;
  final Future<void> Function()? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final gradientColors = _gradientColors(card.cardType);

    return Semantics(
      button: onTap != null,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        onLongPress: () => _showActions(context),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: AspectRatio(
          aspectRatio: AppSpacing.cardAspectRatio,
          child: Container(
            padding: compact ? AppSpacing.insetsMd : AppSpacing.insetsLg,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradientColors),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: selected ? AppColors.success : AppColors.transparent,
                width: AppSpacing.xs / AppSpacing.xs,
              ),
            ),
            child: Stack(
              children: [
                if (card.isDefault)
                  _Badge(
                    label: l10n.cardDefaultBadge,
                    backgroundColor: AppColors.white.withValues(alpha: 0.14),
                    foregroundColor: AppColors.white,
                  ),
                Align(
                  alignment: Alignment.topRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        card.cardType,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (!compact) ...[
                        const SizedBox(width: AppSpacing.xs),
                        PopupMenuButton<_CreditCardAction>(
                          icon: const Icon(
                            Icons.more_vert_rounded,
                            color: AppColors.white,
                          ),
                          onSelected: (action) =>
                              _handleAction(context, action),
                          itemBuilder: (context) => [
                            // PopupMenuItem(
                            //   value: _CreditCardAction.setDefault,
                            //   enabled: onSetDefault != null && !card.isDefault,
                            //   child: Text(l10n.cardActionSetDefault),
                            // ),
                            PopupMenuItem(
                              value: _CreditCardAction.delete,
                              enabled: onDelete != null,
                              child: Text(l10n.cardActionDelete),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Center(
                  child: Text(
                    card.maskedNumber,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.white,
                      letterSpacing: AppSpacing.xs,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    card.cardholderName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    card.expiryFormatted,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
                if (card.isExpired)
                  Align(
                    alignment: Alignment.center,
                    child: _Badge(
                      label: l10n.cardExpiredBadge,
                      backgroundColor: AppColors.error,
                      foregroundColor: AppColors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _gradientColors(String type) {
    switch (type.toUpperCase()) {
      case 'VISA':
        return const [AppColors.cardVisaStart, AppColors.cardVisaEnd];
      case 'MASTERCARD':
        return const [
          AppColors.cardMastercardStart,
          AppColors.cardMastercardEnd,
        ];
      default:
        return const [AppColors.cardDefaultStart, AppColors.cardDefaultEnd];
    }
  }

  void _showActions(BuildContext context) {
    if (compact || (onSetDefault == null && onDelete == null)) return;
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle_outline_rounded),
              title: Text(l10n.cardActionSetDefault),
              enabled: onSetDefault != null && !card.isDefault,
              onTap: () {
                Navigator.of(context).pop();
                onSetDefault?.call();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded),
              title: Text(l10n.cardActionDelete),
              enabled: onDelete != null,
              onTap: () {
                Navigator.of(context).pop();
                _confirmDelete(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleAction(BuildContext context, _CreditCardAction action) {
    switch (action) {
      case _CreditCardAction.setDefault:
        onSetDefault?.call();
        break;
      case _CreditCardAction.delete:
        _confirmDelete(context);
        break;
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteCardTitle),
        content: Text(l10n.deleteCardConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.deleteCardCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.deleteCardConfirmButton),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await onDelete?.call();
    }
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.symmetric(h: AppSpacing.sm, v: AppSpacing.xs),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
