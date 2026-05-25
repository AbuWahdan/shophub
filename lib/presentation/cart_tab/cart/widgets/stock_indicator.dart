import 'package:flutter/material.dart';

import '../../../../design/app_colors.dart';
import '../../../../design/app_spacing.dart';

class StockIndicator extends StatelessWidget {
  const StockIndicator({Key? key, required this.countText}) : super(key: key);

  final String countText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.successSurface,
        borderRadius: BorderRadius.circular(AppSpacing.xxxl),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 14, color: AppColors.success),
          const SizedBox(width: AppSpacing.xs),
          Text(countText, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
