import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/password_controller.dart';
import '../../../data/repositories/user_repository.dart';
import '../../src/config/route.dart';
import '../../src/core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../src/shared/widgets/app_button.dart';
import '../../src/shared/widgets/app_snackbar.dart';
import '../../src/shared/widgets/app_text_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String username;

  const ResetPasswordScreen({required this.username, super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final String _controllerTag;
  late final PasswordController _passwordController;

  @override
  void initState() {
    super.initState();
    _controllerTag = 'reset-password-${identityHashCode(this)}';
    _passwordController = Get.put(
      PasswordController(Get.find<UserRepository>()),
      tag: _controllerTag,
    );
  }

  @override
  void dispose() {
    if (Get.isRegistered<PasswordController>(tag: _controllerTag)) {
      Get.delete<PasswordController>(tag: _controllerTag);
    }
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final resetSucceeded = await _passwordController.resetPassword(
      context: context,
      username: widget.username,
    );
    if (!resetSucceeded || !mounted) {
      return;
    }

    AppSnackBar.show(
      context,
      message: context.l10n.passwordUpdateSuccess,
      type: AppSnackBarType.success,
    );
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) {
      return;
    }
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.passwordUpdated,
      (route) => false,
    );
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
              child: Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      l10n.resetPasswordSubtitle,
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                    AppTextField(
                      controller: _passwordController.newPasswordController,
                      label: l10n.resetPasswordNewLabel,
                      hintText: l10n.resetPasswordNewHint,
                      obscureText:
                          _passwordController.isNewPasswordHidden.value,
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordController.isNewPasswordHidden.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed:
                            _passwordController.toggleNewPasswordVisibility,
                      ),
                      validator: (value) => _passwordController
                          .validateResetPassword(context, value),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      controller: _passwordController.confirmPasswordController,
                      label: l10n.resetPasswordConfirmLabel,
                      hintText: l10n.resetPasswordConfirmHint,
                      obscureText:
                          _passwordController.isConfirmPasswordHidden.value,
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordController.isConfirmPasswordHidden.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed:
                            _passwordController.toggleConfirmPasswordVisibility,
                      ),
                      validator: (value) => _passwordController
                          .validateConfirmPassword(context, value),
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        label: l10n.resetPasswordUpdateButton,
                        onPressed: _passwordController.isSubmitting.value
                            ? null
                            : _handleResetPassword,
                        leading: _passwordController.isSubmitting.value
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
      ),
    );
  }
}
