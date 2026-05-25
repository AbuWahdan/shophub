import 'package:flutter/material.dart';

import '../../../../design/app_colors.dart';

class RemoveItemButton extends StatelessWidget {
  const RemoveItemButton({Key? key, required this.onPressed}) : super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: 40,
      child: Material(
        color: AppColors.error.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: const Icon(Icons.delete_outline, color: AppColors.error),
        ),
      ),
    );
  }
}
