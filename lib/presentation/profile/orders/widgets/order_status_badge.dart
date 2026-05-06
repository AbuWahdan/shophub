import 'package:flutter/material.dart';

import '../../../../design/app_colors.dart';
import '../../../../design/app_radius.dart';
import '../../../../design/app_spacing.dart';
import '../../../../design/app_text_styles.dart';

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.trim().toLowerCase();
    final color = _statusColor(normalized);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        _statusLabel(normalized),
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static String labelFromDeliveryStatus(int status) {
    switch (status) {
      case 1:
        return 'delivered';
      case 2:
        return 'preparing';
      case 3:
        return 'shipped';
      case 4:
        return 'cancelled';
      default:
        return 'pending';
    }
  }

  static Color _statusColor(String status) {
    switch (status) {
      case 'delivered':
      case 'd':
        return AppColors.success;
      case 'shipped':
      case 's':
        return AppColors.primary;
      case 'preparing':
      case 'confirmed':
      case 'c':
        return AppColors.accent;
      case 'cancelled':
      case 'x':
        return AppColors.error;
      case 'pending':
      case 'p':
      default:
        return AppColors.warning;
    }
  }

  static String _statusLabel(String status) {
    switch (status) {
      case 'd':
      case 'delivered':
        return 'Delivered';
      case 's':
      case 'shipped':
        return 'Shipped';
      case 'preparing':
        return 'Preparing';
      case 'c':
      case 'confirmed':
        return 'Preparing';
      case 'x':
      case 'cancelled':
        return 'Cancelled';
      case 'p':
      case 'pending':
      default:
        return 'Pending';
    }
  }
}
