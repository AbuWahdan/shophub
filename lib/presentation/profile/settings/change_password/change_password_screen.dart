import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../../controllers/password_controller.dart';
import '../../../../../data/repositories/user_repository.dart';
import '../../../../core/config/route.dart';
import '../../../../design/app_spacing.dart';
import '../../../../l10n/l10n.dart';
import '../../../../core/app/app_theme.dart';
import '../../../../core/state/auth_state.dart';
import '../../../../widgets/widgets/app_button.dart';
import '../../../../widgets/widgets/app_snackbar.dart';
import '../../../../widgets/widgets/app_text_field.dart';

enum ChangePasswordFlow { changeWithCurrentPassword, resetFromOtp }

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({
    super.key,
    this.flow = ChangePasswordFlow.changeWithCurrentPassword,
    this.usernameOverride,
  });

  final ChangePasswordFlow flow;
  final String? usernameOverride;

  bool get requiresCurrentPassword =>
      flow == ChangePasswordFlow.changeWithCurrentPassword;

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final String _controllerTag;
  late final PasswordController _passwordController;

  @override
  void initState() {
    super.initState();
    _controllerTag = 'change-password-${identityHashCode(this)}';
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

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final username = (widget.usernameOverride?.trim().isNotEmpty ?? false)
        ? widget.usernameOverride!.trim()
        : context.read<AuthState>().user?.username.trim() ?? '';
    final changed = widget.requiresCurrentPassword
        ? await _passwordController.changePassword(
            context: context,
            username: username,
          )
        : await _passwordController.resetPassword(
            context: context,
            username: username,
          );
    if (!changed || !mounted) {
      return;
    }

    AppSnackBar.show(
      context,
      message: context.l10n.passwordUpdateSuccess,
      type: AppSnackBarType.success,
    );
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) {
      return;
    }
    if (widget.requiresCurrentPassword) {
      Navigator.pop(context, true);
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
    final title = widget.requiresCurrentPassword
        ? l10n.changePasswordTitle
        : l10n.resetPasswordTitle;
    final newPasswordLabel = widget.requiresCurrentPassword
        ? l10n.resetPasswordNewLabel
        : l10n.resetPasswordNewLabel;
    final newPasswordHint = widget.requiresCurrentPassword
        ? l10n.changePasswordNewHint
        : l10n.resetPasswordNewHint;
    final confirmLabel = widget.requiresCurrentPassword
        ? l10n.changePasswordConfirmLabel
        : l10n.resetPasswordConfirmLabel;
    final confirmHint = widget.requiresCurrentPassword
        ? l10n.changePasswordConfirmHint
        : l10n.resetPasswordConfirmHint;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.insetsMd,
          child: Form(
            key: _formKey,
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.requiresCurrentPassword) ...[
                    AppTextField(
                      controller: _passwordController.currentPasswordController,
                      label: l10n.changePasswordCurrentLabel,
                      hintText: l10n.changePasswordCurrentHint,
                      obscureText:
                          _passwordController.isCurrentPasswordHidden.value,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordController.isCurrentPasswordHidden.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed:
                            _passwordController.toggleCurrentPasswordVisibility,
                      ),
                      validator: (value) => _passwordController
                          .validateCurrentPassword(context, value),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  AppTextField(
                    controller: _passwordController.newPasswordController,
                    label: newPasswordLabel,
                    hintText: newPasswordHint,
                    obscureText: _passwordController.isNewPasswordHidden.value,
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
                        .validateStrongPassword(context, value),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    controller: _passwordController.confirmPasswordController,
                    label: confirmLabel,
                    hintText: confirmHint,
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
                  AppButton(
                    label: l10n.resetPasswordUpdateButton,
                    onPressed: _passwordController.isSubmitting.value
                        ? null
                        : _handleSubmit,
                    leading: _passwordController.isSubmitting.value
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
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
