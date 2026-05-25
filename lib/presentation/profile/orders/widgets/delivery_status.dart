import 'package:flutter/cupertino.dart';

import '../../../../design/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/orders_model.dart';

class DeliveryStatusBadge extends StatelessWidget {
  final DeliveryStatus status;

  const DeliveryStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = _resolve(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  (String, Color, Color) _resolve(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return switch (status) {
      DeliveryStatus.pending => (
        l10n.statusPending,
        AppColors.warning.withValues(alpha: 0.15),
        AppColors.warning,
      ),

      DeliveryStatus.processing => (
        l10n.statusProcessing,
        AppColors.info.withValues(alpha: 0.15),
        AppColors.info,
      ),

      DeliveryStatus.shipped => (
        l10n.statusShipped,
        AppColors.success.withValues(alpha: 0.15),
        AppColors.success,
      ),

      DeliveryStatus.delivered => (
        l10n.statusDelivered,
        AppColors.success.withValues(alpha: 0.15),
        AppColors.success,
      ),

      DeliveryStatus.cancelled => (
        l10n.statusCancelled,
        AppColors.error.withValues(alpha: 0.15),
        AppColors.error,
      ),

      DeliveryStatus.unknown => (
        l10n.statusUnknown,
        AppColors.grey.withValues(alpha: 0.15),
        AppColors.grey,
      ),
    };
  }
}
