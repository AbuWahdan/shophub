import 'package:flutter/material.dart';

import '../../../../design/app_spacing.dart';
import '../../../../design/app_text_styles.dart';
import '../../../../l10n/l10n.dart';
import '../../../../core/app/app_theme.dart';


class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsAboutApp)),
      body: SingleChildScrollView(
        padding: AppSpacing.insetsMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.appTitle, style: AppTextStyles.headingSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(l10n.appVersion, style: AppTextStyles.bodySmall),
            const SizedBox(height: AppSpacing.lg),
            Text(l10n.appLegalese, style: AppTextStyles.bodyMedium),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
