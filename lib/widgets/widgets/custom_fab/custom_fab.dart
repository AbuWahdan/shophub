import 'package:flutter/material.dart';

class CustomFab extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? backgroundColor;

  const CustomFab({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: null, // 🔥 FIX: prevents Hero animation conflicts
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: backgroundColor,
      elevation: 6,
      child: Icon(icon),
    );
  }
}