import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../design/app_colors.dart';
import '../../../../../design/app_radius.dart';
import '../../../../../design/app_spacing.dart';
import '../../../../../design/app_text_styles.dart';

class PaymentTextField extends StatefulWidget {
  const PaymentTextField({
    super.key,
    required this.controller,
    required this.label,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final String label;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final TextCapitalization textCapitalization;

  @override
  State<PaymentTextField> createState() => _PaymentTextFieldState();
}

class _PaymentTextFieldState extends State<PaymentTextField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focusNode.hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: focused
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  blurRadius: AppSpacing.lg,
                ),
              ]
            : null,
      ),
      child: TextFormField(
        focusNode: _focusNode,
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        validator: widget.validator,
        textCapitalization: widget.textCapitalization,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          labelText: widget.label,
          prefixIcon: widget.prefixIcon == null
              ? null
              : Icon(widget.prefixIcon),
          suffixIcon: widget.suffixIcon == null
              ? null
              : Icon(widget.suffixIcon),
          filled: true,
          fillColor: AppColors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: AppSpacing.borderThin,
            ),
          ),
        ),
      ),
    );
  }
}
