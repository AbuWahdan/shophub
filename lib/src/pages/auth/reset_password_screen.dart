import 'package:flutter/material.dart';

import '../../design/app_spacing.dart';
import '../../design/app_text_styles.dart';
import '../../l10n/l10n.dart';
import '../../services/auth_service.dart';
import '../../shared/validation/auth_validators.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_snackbar.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../themes/theme.dart';
import '../../config/route.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String username;

  const ResetPasswordScreen({
    required this.username,
    super.key,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  final _authService = AuthService();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final newPassword = _newPasswordController.text.trim();

    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.resetPassword(
        username: widget.username,
        newPassword: newPassword,
      );

      if (!mounted) return;

      // Show green success snackbar
      AppSnackBar.show(
        context,
        message: 'Password updated successfully',
        type: AppSnackBarType.success,
      );

      // Wait 1 second before navigating so user can see the snackbar
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      // Navigate to password updated screen without back button
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.passwordUpdated,
        (route) => false,
      );
    } on AuthException catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      AppSnackBar.show(
        context,
        message: error.message,
        type: AppSnackBarType.error,
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      AppSnackBar.show(
        context,
        message: 'Failed to reset password. Please try again.',
        type: AppSnackBarType.error,
      );
    }
  }

  String? _validatePassword(String? value) {
    return AuthValidators.password(
      value,
      emptyMessage: 'Password is required',
      tooShortMessage: 'Password must be at least 8 characters',
      minLength: 8,
    );
  }

  String? _validateConfirmPassword(String? value) {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = value?.trim() ?? '';

    if (confirmPassword.isEmpty) {
      return 'Confirm password is required';
    }

    if (newPassword != confirmPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.resetPasswordTitle),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: AppTheme.padding,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    l10n.resetPasswordSubtitle,
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  AppTextField(
                    controller: _newPasswordController,
                    label: l10n.resetPasswordNewLabel,
                    hintText: 'Enter new password',
                    obscureText: _obscureNewPassword,
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNewPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureNewPassword = !_obscureNewPassword;
                        });
                      },
                    ),
                    validator: _validatePassword,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    controller: _confirmPasswordController,
                    label: l10n.resetPasswordConfirmLabel,
                    hintText: 'Confirm new password',
                    obscureText: _obscureConfirmPassword,
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword =
                              !_obscureConfirmPassword;
                        });
                      },
                    ),
                    validator: _validateConfirmPassword,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      label: l10n.resetPasswordUpdateButton,
                      onPressed: _isLoading ? null : _handleResetPassword,
                      leading: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
