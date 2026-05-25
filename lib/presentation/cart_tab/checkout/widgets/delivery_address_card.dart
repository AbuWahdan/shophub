import 'package:flutter/material.dart';

import '../../../../design/app_colors.dart';
import '../../../../design/app_radius.dart';
import '../../../../design/app_shadows.dart';
import '../../../../design/app_spacing.dart';
import '../../../../design/app_text_styles.dart';
import '../../../../models/addresses/address_model.dart';
import 'checkout_tokens.dart';

class DeliveryAddressCard extends StatelessWidget {
  const DeliveryAddressCard({
    super.key,
    required this.title,
    required this.selectLabel,
    required this.estimateText,
    required this.address,
    required this.isLoading,
    required this.errorText,
    required this.onTap,
  });

  final String title;
  final String selectLabel;
  final String estimateText;
  final AddressModel? address;
  final bool isLoading;
  final String? errorText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final parts = address == null
        ? <String>[]
        : [
            address!.streetAddress,
            address!.city,
            address!.country,
          ].where((part) => part.trim().isNotEmpty).toList();

    return _CheckoutCard(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _IconBox(icon: CheckoutTokens.locationIcon),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: isLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        child: LinearProgressIndicator(),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: AppTextStyles.titleMedium),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            address?.label ?? selectLabel,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: address == null
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          if (parts.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              parts.join(', '),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                          const SizedBox(height: AppSpacing.xs),
                          Text(estimateText, style: AppTextStyles.caption),
                          if (errorText != null) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              errorText!,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckoutCard extends StatelessWidget {
  const _CheckoutCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: const [AppShadows.subtleShadow],
      ),
      child: child,
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: CheckoutTokens.iconBoxSize,
      height: CheckoutTokens.iconBoxSize,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: CheckoutTokens.iconGradient),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(icon, color: AppColors.white),
    );
  }
}
