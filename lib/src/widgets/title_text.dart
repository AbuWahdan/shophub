import 'package:flutter/material.dart';

import '../design/app_text_styles.dart';

class TitleText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const TitleText({
    super.key,
    required this.text,
    this.style,
    required int fontSize,
    required Color color,
  });
  @override
  Widget build(BuildContext context) {
    return Text(text, style: style ?? AppTextStyles.titleLarge);
  }
}
