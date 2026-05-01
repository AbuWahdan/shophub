import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/repositories/user_repository.dart';
import '../l10n/app_localizations.dart';
import '../widgets/validation/auth_validators.dart';
import '../widgets/widgets/app_snackbar.dart';

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
      return AppLocalizations.of(context).changePasswordCurrentRequired;
    }
    return null;
  }

  String? validateResetPassword(BuildContext context, String? value) {
    return AuthValidators.password(
      value,
      emptyMessage: AppLocalizations.of(context).validationPasswordRequired,
      tooShortMessage: AppLocalizations.of(context).validationPasswordTooShort,
      minLength: 8,
    );
  }

  String? validateStrongPassword(BuildContext context, String? value) {
    final baseValidation = AuthValidators.password(
      value,
      emptyMessage: AppLocalizations.of(context).validationPasswordRequired,
      tooShortMessage: AppLocalizations.of(context).validationPasswordTooShort,
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
      emptyMessage: AppLocalizations.of(context).validationConfirmPasswordRequired,
      mismatchMessage: AppLocalizations.of(context).validationConfirmPasswordMismatch,
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
        message: AppLocalizations.of(context).changePasswordCurrentRequired,
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
        message: AppLocalizations.of(context).productAccountUnavailable,
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
      return AppLocalizations.of(context).resetPasswordFailed;
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
