import 'package:flutter/material.dart';

import '../../../../core/app/app_theme.dart';
import '../../../../design/app_spacing.dart';
import '../../../../design/app_text_styles.dart';


class InfoPage extends StatelessWidget {
  final String title;
  final String content;

  const InfoPage({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: AppSpacing.insetsMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(content, style: AppTextStyles.bodyMedium),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
