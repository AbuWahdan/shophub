import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/route.dart';
import '../../../../design/app_colors.dart';
import '../../../../design/app_radius.dart';
import '../../../../design/app_spacing.dart';
import '../../../../design/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/orders_model.dart';
import 'delivery_status.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order});

  final OrdersModel order;

  /// Centralized navigation logic to pass arguments cleanly
  void _navigateToDetails(BuildContext context) {
    Navigator.pushNamed(
      context,
      AppRoutes.orderDetails,
      arguments: {
        'orderId': order.orderId,
        'orderNo': order.orderNo,
        'order': order,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final currency = NumberFormat.simpleCurrency(
      locale: Localizations.localeOf(context).toLanguageTag(),
    );
    final promoCode = order.promoCode?.trim() ?? '';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _navigateToDetails(context),
        child: Padding(
          padding: AppSpacing.insetsLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _OrderCardHeader(order: order),
              const SizedBox(height: AppSpacing.md),
              _OrderCardDetails(
                order: order,
                currency: currency,
                promoCode: promoCode,
                l10n: l10n,
                theme: theme,
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  onPressed: () => _navigateToDetails(context),
                  child: Text(
                    l10n.viewDetails,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderCardHeader extends StatelessWidget {
  const _OrderCardHeader({required this.order});

  final OrdersModel order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.orderNo.isEmpty ? '#${order.orderId}' : order.orderNo,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              if (order.username.isNotEmpty)
                Text(
                  order.username,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        DeliveryStatusBadge(status: order.deliveryStatus),
      ],
    );
  }
}

class _OrderCardDetails extends StatelessWidget {
  const _OrderCardDetails({
    required this.order,
    required this.currency,
    required this.promoCode,
    required this.l10n,
    required this.theme,
  });

  final OrdersModel order;
  final NumberFormat currency;
  final String promoCode;
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InfoRow(
          title: l10n.orderDateLabel,
          value: DateFormat.yMMMd().format(order.orderDate),
        ),
        const SizedBox(height: AppSpacing.sm),
        _InfoRow(
          title: l10n.orderCreatedDateLabel,
          value: DateFormat.yMMMd().format(order.createdDate),
        ),
        if (promoCode.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(title: l10n.promoCodeLabel, value: promoCode),
        ],
        const SizedBox(height: AppSpacing.sm),
        _InfoRow(
          title: l10n.orderNet,
          value: currency.format(order.netAmount),
          isHighlight: true,
          theme: theme,
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.title,
    required this.value,
    this.isHighlight = false,
    this.theme,
  });

  final String title;
  final String value;
  final bool isHighlight;
  final ThemeData? theme;

  @override
  Widget build(BuildContext context) {
    final currentTheme = theme ?? Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: currentTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: isHighlight
              ? AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w800,
            color: currentTheme.colorScheme.primary,
          )
              : AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: currentTheme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}