import 'package:flutter/material.dart';
import '../../../../../design/app_colors.dart';
import '../../../../../design/app_radius.dart';
import '../../../../../design/app_shadows.dart';
import '../../../../../design/app_spacing.dart';
import '../../../../../design/app_text_styles.dart';
import '../../../../../l10n/app_localizations.dart';
import 'payment_methods_tokens.dart';

class CardPreviewWidget extends StatelessWidget {
  const CardPreviewWidget({
    super.key,
    required this.cardType,
    required this.cardNumber,
    required this.cardholderName,
    required this.expiryText,
  });

  final String cardType;
  final String cardNumber;
  final String cardholderName;
  final String expiryText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final gradient = switch (cardType.toUpperCase()) {
      'VISA' => PaymentMethodsTokens.visaGradient,
      'MASTERCARD' => PaymentMethodsTokens.mastercardGradient,
      _ => PaymentMethodsTokens.defaultGradient,
    };
    final number = cardNumber.trim().isEmpty
        ? l10n.cardPreviewMaskedNumber
        : cardNumber;
    final holder = cardholderName.trim().isEmpty
        ? l10n.cardHolderNameLabel.toUpperCase()
        : cardholderName.toUpperCase();

    return AspectRatio(
      aspectRatio: PaymentMethodsTokens.cardPreviewAspectRatio,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: const [AppShadows.cardShadow],
        ),
        child: Stack(
          children: [
            PositionedDirectional(
              end: -PaymentMethodsTokens.circleSmall,
              top: -AppSpacing.xl,
              child: _DecorativeCircle(size: PaymentMethodsTokens.circleLarge),
            ),
            PositionedDirectional(
              end: AppSpacing.lg,
              bottom: -AppSpacing.xl,
              child: _DecorativeCircle(size: PaymentMethodsTokens.circleSmall),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const _ChipMark(),
                      Text(
                        cardType.toUpperCase(),
                        style: AppTextStyles.headingSmall.copyWith(
                          color: AppColors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      number,
                      maxLines: 1,
                      style: AppTextStyles.headingMedium.copyWith(
                        color: AppColors.white,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: _CardMeta(
                          label: l10n.cardHolderNameLabel,
                          value: holder,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      _CardMeta(label: l10n.expiresLabel, value: expiryText),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  const _DecorativeCircle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.white.withValues(alpha: 0.08),
      ),
    );
  }
}

class _ChipMark extends StatelessWidget {
  const _ChipMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: PaymentMethodsTokens.chipWidth,
      height: PaymentMethodsTokens.chipHeight,
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.35)),
      ),
    );
  }
}

class _CardMeta extends StatelessWidget {
  const _CardMeta({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.white.withValues(alpha: 0.68),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.labelLarge.copyWith(color: AppColors.white),
        ),
      ],
    );
  }
}
