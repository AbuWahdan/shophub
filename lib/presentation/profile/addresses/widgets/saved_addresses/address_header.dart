import 'package:flutter/material.dart';

import '../../../../../design/app_colors.dart';
import '../../../../../design/app_spacing.dart';
import '../../../../../design/app_text_styles.dart';

class AddressHeader extends StatelessWidget {
  const AddressHeader({
    super.key,
    required this.title,
    required this.onBack,
    required this.onSettings,
    required this.settingsSemanticLabel,
  });

  final String title;
  final VoidCallback onBack;
  final VoidCallback onSettings;
  final String settingsSemanticLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: SizedBox(
        height: AppSpacing.xxxl,
        child: Row(
          children: [
            IconButton(
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.titleLarge,
              ),
            ),
            IconButton(
              tooltip: settingsSemanticLabel,
              onPressed: onSettings,
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
      ),
    );
  }
}
