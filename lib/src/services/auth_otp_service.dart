import 'package:flutter/material.dart';
import '../config/route.dart';
import '../shared/widgets/app_snackbar.dart';
import 'auth_service.dart';

/// Reusable OTP verification service for sign up and forgot password flows.
/// Handles the OTP verification process and provides callbacks for success/failure.
class AuthOtpService {
  AuthOtpService({AuthService? authService})
      : _authService = authService ?? AuthService();

  final AuthService _authService;

  /// Sends OTP to the provided email and navigates to ORP verification screen.
  ///
  /// This method:
  /// 1. Validates email/username
  /// 2. Sends OTP via AuthService.sendOtp()
  /// 3. Navigates to OTP verification screen on success
  /// 4. Shows error snackbar on failure
  Future<bool> sendOtp({
    required BuildContext context,
    required String username,
    required String email,
  }) async {
    try {
      // Validate inputs
      if (username.trim().isEmpty) {
        if (!context.mounted) return false;
        AppSnackBar.show(
          context,
          message: 'Username is required.',
          type: AppSnackBarType.error,
        );
        return false;
      }

      if (email.trim().isEmpty) {
        if (!context.mounted) return false;
        AppSnackBar.show(
          context,
          message: 'Email is required.',
          type: AppSnackBarType.error,
        );
        return false;
      }

      // Send OTP
      await _authService.sendOtp(
        username: username.trim(),
        email: email.trim(),
      );

      if (!context.mounted) return false;

      // Navigate to OTP verification screen
      Navigator.pushNamed(
        context,
        AppRoutes.otpVerification,
        arguments: {
          'username': username.trim(),
          'email': email.trim(),
        },
      );

      return true;
    } on AuthException catch (error) {
      if (!context.mounted) return false;

      AppSnackBar.show(
        context,
        message: error.message,
        type: AppSnackBarType.error,
      );
      return false;
    } catch (error) {
      if (!context.mounted) return false;

      AppSnackBar.show(
        context,
        message: 'Failed to send OTP. Please try again.',
        type: AppSnackBarType.error,
      );
      return false;
    }
  }

  /// Verifies OTP and calls the appropriate callback based on flow type.
  ///
  /// Parameters:
  /// - [context]: Build context for navigation
  /// - [username]: User's username
  /// - [email]: User's email
  /// - [otp]: 6-digit OTP code
  /// - [flowType]: 'signup' or 'forgot_password' to determine post-verification action
  /// - [onSignupSuccess]: Callback when signup OTP verification succeeds
  /// - [onForgotPasswordSuccess]: Callback when forgot password OTP verification succeeds
  Future<bool> verifyOtp({
    required BuildContext context,
    required String username,
    required String email,
    required String otp,
    required String flowType, // 'signup' or 'forgot_password'
    VoidCallback? onSignupSuccess,
    VoidCallback? onForgotPasswordSuccess,
  }) async {
    try {
      // Validate OTP
      if (otp.trim().isEmpty || otp.trim().length != 6) {
        if (!context.mounted) return false;

        AppSnackBar.show(
          context,
          message: 'Please enter a valid 6-digit OTP.',
          type: AppSnackBarType.error,
        );
        return false;
      }

      // Verify OTP
      await _authService.verifyOtp(
        username: username.trim(),
        email: email.trim(),
        otp: otp.trim(),
      );

      if (!context.mounted) return false;

      // Handle post-verification actions based on flow type
      if (flowType == 'signup') {
        onSignupSuccess?.call();
        AppSnackBar.show(
          context,
          message: 'Email verified successfully!',
          type: AppSnackBarType.success,
        );
        return true;
      } else if (flowType == 'forgot_password') {
        onForgotPasswordSuccess?.call();
        // Navigate to reset password screen
        Navigator.pushNamed(
          context,
          AppRoutes.resetPassword,
          arguments: {
            'username': username.trim(),
          },
        );
        return true;
      }

      return false;
    } on AuthException catch (error) {
      if (!context.mounted) return false;

      AppSnackBar.show(
        context,
        message: error.message,
        type: AppSnackBarType.error,
      );
      return false;
    } catch (error) {
      if (!context.mounted) return false;

      AppSnackBar.show(
        context,
        message: 'OTP verification failed. Please try again.',
        type: AppSnackBarType.error,
      );
      return false;
    }
  }
}
