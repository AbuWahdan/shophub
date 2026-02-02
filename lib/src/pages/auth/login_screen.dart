import 'package:flutter/material.dart';

import '../../design/app_spacing.dart';
import '../../design/app_text_styles.dart';
import '../../l10n/l10n.dart';
import '../../shared/validation/auth_validators.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../themes/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppTheme.padding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xxl),
                Text(l10n.loginWelcomeBack,
                    style: AppTextStyles.headlineLarge(context)),
                const SizedBox(height: AppSpacing.sm),
                Text(l10n.loginSubtitle,
                    style: AppTextStyles.bodyMedium(context)),
                const SizedBox(height: AppSpacing.xxxl),
                AppTextField(
                  controller: _emailController,
                  label: l10n.loginEmailOrPhoneLabel,
                  hintText: l10n.loginEmailOrPhoneHint,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.contains('@')) {
                      return AuthValidators.email(
                        trimmed,
                        emptyMessage: l10n.validationEmailRequired,
                        invalidMessage: l10n.validationEmailInvalid,
                      );
                    }
                    return AuthValidators.phone(
                      trimmed,
                      emptyMessage: l10n.validationPhoneRequired,
                      invalidMessage: l10n.validationPhoneInvalid,
                    );
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: _passwordController,
                  label: l10n.loginPasswordLabel,
                  hintText: l10n.loginPasswordHint,
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) => AuthValidators.password(
                    value,
                    emptyMessage: l10n.validationPasswordRequired,
                    tooShortMessage: l10n.validationPasswordTooShort,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Navigate to forgot password
                    },
                    child: Text(l10n.loginForgotPassword),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                AppButton(
                  label: l10n.loginSignIn,
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      Navigator.of(context).pushReplacementNamed('/main');
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: l10n.loginContinueAsGuest,
                  style: AppButtonStyle.outlined,
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/main');
                  },
                ),
                const SizedBox(height: AppSpacing.xxl),
                Center(
                  child: Text(
                    l10n.loginNoAccount,
                    style: AppTextStyles.bodyMedium(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: l10n.loginCreateAccount,
                  style: AppButtonStyle.secondary,
                  onPressed: () {
                    Navigator.of(context).pushNamed('/register');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
