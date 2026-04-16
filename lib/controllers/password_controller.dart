import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/repositories/user_repository.dart';
import '../src/l10n/l10n.dart';
import '../src/shared/validation/auth_validators.dart';
import '../src/shared/widgets/app_snackbar.dart';

class PasswordController extends GetxController {
  PasswordController(this._userRepository);

  final UserRepository _userRepository;

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isSubmitting = false.obs;
  final isCurrentPasswordHidden = true.obs;
  final isNewPasswordHidden = true.obs;
  final isConfirmPasswordHidden = true.obs;

  void toggleCurrentPasswordVisibility() {
    isCurrentPasswordHidden.toggle();
  }

  void toggleNewPasswordVisibility() {
    isNewPasswordHidden.toggle();
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.toggle();
  }

  String? validateCurrentPassword(BuildContext context, String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return context.l10n.changePasswordCurrentRequired;
    }
    return null;
  }

  String? validateResetPassword(BuildContext context, String? value) {
    return AuthValidators.password(
      value,
      emptyMessage: context.l10n.validationPasswordRequired,
      tooShortMessage: context.l10n.validationPasswordTooShort,
      minLength: 8,
    );
  }

  String? validateStrongPassword(BuildContext context, String? value) {
    final baseValidation = AuthValidators.password(
      value,
      emptyMessage: context.l10n.validationPasswordRequired,
      tooShortMessage: context.l10n.validationPasswordTooShort,
      minLength: 8,
    );
    if (baseValidation != null) {
      return baseValidation;
    }

    return null;
  }

  String? validateConfirmPassword(BuildContext context, String? value) {
    return AuthValidators.confirmPassword(
      value,
      original: newPasswordController.text.trim(),
      emptyMessage: context.l10n.validationConfirmPasswordRequired,
      mismatchMessage: context.l10n.validationConfirmPasswordMismatch,
    );
  }

  Future<bool> resetPassword({
    required BuildContext context,
    required String username,
  }) async {
    return _updatePassword(
      context: context,
      username: username,
      oldPassword: null,
    );
  }

  Future<bool> changePassword({
    required BuildContext context,
    required String username,
  }) async {
    final currentPassword = currentPasswordController.text.trim();
    if (currentPassword.isEmpty) {
      AppSnackBar.show(
        context,
        message: context.l10n.changePasswordCurrentRequired,
        type: AppSnackBarType.error,
      );
      return false;
    }

    return _updatePassword(
      context: context,
      username: username,
      oldPassword: currentPassword,
    );
  }

  Future<bool> _updatePassword({
    required BuildContext context,
    required String username,
    required String? oldPassword,
  }) async {
    final normalizedUsername = username.trim();
    if (normalizedUsername.isEmpty) {
      AppSnackBar.show(
        context,
        message: context.l10n.productAccountUnavailable,
        type: AppSnackBarType.error,
      );
      return false;
    }

    if (isSubmitting.value) {
      return false;
    }

    isSubmitting.value = true;
    try {
      await _userRepository.resetPassword(
        username: normalizedUsername,
        newPassword: newPasswordController.text.trim(),
        oldPassword: oldPassword,
      );
      return true;
    } catch (error) {
      if (!context.mounted) {
        return false;
      }
      AppSnackBar.show(
        context,
        message: _resolveErrorMessage(context, error),
        type: AppSnackBarType.error,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  void clearControllers() {
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }

  String _resolveErrorMessage(BuildContext context, Object error) {
    final message = error.toString().replaceFirst('Exception: ', '').trim();
    if (message.isEmpty) {
      return context.l10n.resetPasswordFailed;
    }
    return message;
  }

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
