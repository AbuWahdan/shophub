import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../controllers/password_controller.dart';
import '../../../data/repositories/user_repository.dart';
import '../../l10n/l10n.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_snackbar.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../state/auth_state.dart';
import '../../themes/theme.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

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

    final username = context.read<AuthState>().user?.username.trim() ?? '';
    final changed = await _passwordController.changePassword(
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
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.changePasswordTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppTheme.padding,
          child: Form(
            key: _formKey,
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  AppTextField(
                    controller: _passwordController.newPasswordController,
                    label: l10n.resetPasswordNewLabel,
                    hintText: l10n.changePasswordNewHint,
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
                    label: l10n.changePasswordConfirmLabel,
                    hintText: l10n.changePasswordConfirmHint,
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
