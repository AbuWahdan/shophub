import 'package:flutter/material.dart';

import '../../design/app_spacing.dart';

class CustomFab extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? label;
  final String? tooltip;
  final Color? backgroundColor;

  const CustomFab({
    super.key,
    required this.onPressed,
    required this.icon,
    this.label,
    this.tooltip,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final label = this.label;
    if (label != null && label.isNotEmpty) {
      return FloatingActionButton.extended(
        heroTag: null,
        onPressed: onPressed,
        tooltip: tooltip,
        backgroundColor: backgroundColor,
        elevation: AppSpacing.sm,
        icon: Icon(icon),
        label: Text(label),
      );
    }

    return FloatingActionButton(
      heroTag: null,
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: backgroundColor,
      elevation: AppSpacing.sm,
      child: Icon(icon),
    );
  }
}
