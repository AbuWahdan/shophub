import 'package:flutter/material.dart';

import '../../core/config/route.dart';
import '../../design/app_spacing.dart';
import '../../design/app_text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../widgets/validation/auth_validators.dart';
import '../../widgets/widgets/app_button.dart';
import '../../widgets/widgets/app_snackbar.dart';
import '../../widgets/widgets/app_text_field.dart';


class ForgotPasswordEmailScreen extends StatefulWidget {
  const ForgotPasswordEmailScreen({super.key});

  @override
  State<ForgotPasswordEmailScreen> createState() =>
      _ForgotPasswordEmailScreenState();
}

class _ForgotPasswordEmailScreenState extends State<ForgotPasswordEmailScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final _authService = AuthService();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();

    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.sendOtp(username: username, email: email);

      if (!mounted) return;

      // Navigate to OTP Sent Notice Screen
      Navigator.pushNamed(
        context,
        AppRoutes.otpSent,
        arguments: {
          'username': username,
          'email': email,
        },
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
        message: 'Failed to send OTP. Please try again.',
        type: AppSnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.forgotPasswordTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.insetsMd,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xl),
                Text(
                  l10n.forgotPasswordSubtitle,
                  style: AppTextStyles.bodyMedium,
                ),
                SizedBox(height: AppSpacing.xxxl),
                AppTextField(
                  controller: _usernameController,
                  label: 'Username',
                  hintText: 'Enter your username',
                  prefixIcon: const Icon(Icons.person_outlined),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) return 'Username is required';
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: _emailController,
                  label: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => AuthValidators.email(
                    value,
                    emptyMessage: 'Email is required',
                    invalidMessage: 'Please enter a valid email',
                  ),
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: AppSpacing.xxl),
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    label: l10n.forgotPasswordSendOtp,
                    onPressed: _isLoading ? null : _handleSendOtp,
                    leading: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
