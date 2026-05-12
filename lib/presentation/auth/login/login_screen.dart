import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/config/route.dart';

import '../../../core/state/auth_state.dart';
import '../../../design/app_spacing.dart';
import '../../../design/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/custom_button/custom_button.dart';
import '../../../widgets/custom__snack_bar/custom_snack_bar.dart';
import '../../../widgets/custom_text_field/custom_text_field.dart';
import '../validation/auth_validators.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = context.watch<AuthState>();
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.insetsMd,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xxl),
                Text(l10n.loginSubtitle, style: AppTextStyles.bodyMedium),
                SizedBox(height: AppSpacing.xxl),
                CustomTextField(
                  controller: _usernameController,
                  label: 'Username',
                  hintText: 'Enter your username',
                  keyboardType: TextInputType.text,
                  prefixIcon: const Icon(Icons.person_outlined),
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) return 'Username is required';
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.lg),
                CustomTextField(
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
                    minLength: 6,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: (){
                      Navigator.of(context).pushNamed(AppRoutes.forgotPassword);

                    },
                    child: Text(l10n.loginForgotPassword),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                CustomButton(
                  label: l10n.loginSignIn,
                  leading: authState.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                  onPressed: authState.isLoading
                      ? null
                      : () async {
                          if (!(_formKey.currentState?.validate() ?? false)) {
                            return;
                          }
                          final success = await context.read<AuthState>().login(
                            _usernameController.text.trim(),
                            _passwordController.text.trim(),
                          );
                          if (!mounted) return;
                          if (success) {
                            Navigator.of(context).pushReplacementNamed('/main');
                            return;
                          }
                          final message =
                              authState.errorMessage ??
                              'Invalid credentials. Please try again.';
                          CustomSnackBar.show(
                            context,
                            message: message,
                            type: AppSnackBarType.error,
                          );
                        },
                ),
                const SizedBox(height: AppSpacing.md),
                CustomButton(
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
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                CustomButton(
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
