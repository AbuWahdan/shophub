import 'package:flutter/material.dart';

import '../../../../design/app_colors.dart';
import '../../../../design/app_radius.dart';
import '../../../../design/app_spacing.dart';
import '../../../../design/app_text_styles.dart';

/// A non-editable profile field that displays a label and a read-only value.
/// Used for fields like [username], [email], and [country] that the user
/// cannot change directly from this screen.
class ReadOnlyProfileField extends StatelessWidget {
  const ReadOnlyProfileField({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: AppSpacing.insetsMd,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Text(
            value,
            style: AppTextStyles.bodyLarge,
          ),
        ),
      ],
    );
  }
}