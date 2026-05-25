import 'package:flutter/material.dart';

import '../../../../design/app_colors.dart';
import '../../../../design/app_spacing.dart';
import '../../../../design/app_text_styles.dart';

class CartBadgesWrap extends StatelessWidget {
  const CartBadgesWrap({Key? key, required this.badges}) : super(key: key);

  final List<String> badges;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: badges
          .where((b) => b.isNotEmpty)
          .map((b) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(AppSpacing.xxxl),
                ),
                child: Text(
                  b,
                  style: AppTextStyles.caption.copyWith(color: AppColors.primaryDark),
                ),
              ))
          .toList(),
    );
  }
}
