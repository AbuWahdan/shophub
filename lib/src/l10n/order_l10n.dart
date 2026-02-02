import 'package:flutter/widgets.dart';

import '../model/order.dart';
import 'app_localizations.dart';

extension OrderStatusL10n on OrderStatus {
  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case OrderStatus.pending:
        return l10n.orderStatusPending;
      case OrderStatus.processing:
        return l10n.orderStatusProcessing;
      case OrderStatus.shipped:
        return l10n.orderStatusShipped;
      case OrderStatus.delivered:
        return l10n.orderStatusDelivered;
      case OrderStatus.cancelled:
        return l10n.orderStatusCancelled;
    }
  }
}
