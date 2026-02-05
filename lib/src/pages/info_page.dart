import 'package:flutter/material.dart';

import '../design/app_spacing.dart';
import '../design/app_text_styles.dart';
import '../themes/theme.dart';

class InfoPage extends StatelessWidget {
  final String title;
  final String content;

  const InfoPage({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: AppTheme.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(content, style: AppTextStyles.bodyMedium(context)),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
