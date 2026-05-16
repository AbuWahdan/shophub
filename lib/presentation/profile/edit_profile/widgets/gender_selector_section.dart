import 'package:flutter/material.dart';

import '../../../../core/utils/localization_ar_en/localized_text_extensions.dart';
import '../../../../design/app_colors.dart';
import '../../../../design/app_spacing.dart';
import '../../../../design/app_text_styles.dart';
import '../../../../models/get_code_option_model.dart';

/// Renders the gender radio-list with loading, error, and retry states.
/// Extracted from [EditProfileScreen] to keep each concern in its own widget.
class GenderSelectorSection extends StatelessWidget {
  const GenderSelectorSection({
    super.key,
    required this.options,
    required this.selectedGender,
    required this.isLoading,
    required this.loadError,
    required this.onChanged,
    required this.onRetry,
  });

  final List<GetCodeOptionModel> options;
  final int? selectedGender;
  final bool isLoading;
  final String? loadError;
  final ValueChanged<int?> onChanged;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: LinearProgressIndicator(),
      );
    }

    if (loadError != null && options.isEmpty) {
      return Row(
        children: [
          Expanded(
            child: Text(
              loadError!,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      );
    }

    return Column(
      children: options
          .map(
            (option) => RadioListTile<int>(
          contentPadding: EdgeInsets.zero,
          title: Text(option.localizedTitle(context)),
          value: option.minorCode,
          groupValue: selectedGender,
          onChanged: onChanged,
        ),
      )
          .toList(),
    );
  }
}