import 'package:flutter/foundation.dart';

import '../../core/api/api_constants.dart';
import '../../core/api/api_service.dart';
import '../../src/model/forget_password_request.dart';

class UserRepository {
  final ApiService _apiService;

  UserRepository(this._apiService);

  /// Send OTP to user for password reset
  Future<void> sendOtp({
    required String username,
    required String email,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('[UserRepository] Sending OTP to $email');
      }

      await _apiService.post(
        ApiConstants.sendOtp,
        body: {'username': username, 'email': email},
        isReadOperation: false,
      );

      if (kDebugMode) {
        debugPrint('[UserRepository] OTP sent successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[UserRepository] Error sending OTP: $e');
      }
      rethrow;
    }
  }

  /// Verify OTP entered by user
  Future<void> verifyOtp({
    required String username,
    required String email,
    required String otp,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('[UserRepository] Verifying OTP for $username');
      }

      await _apiService.post(
        ApiConstants.verifyOtp,
        body: {'username': username, 'email': email, 'otp': otp},
        isReadOperation: false,
      );

      if (kDebugMode) {
        debugPrint('[UserRepository] OTP verified successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[UserRepository] Error verifying OTP: $e');
      }
      rethrow;
    }
  }

  /// Reset user password
  /// Treats HTTP 200 as success regardless of body content (never throws on ORA-)
  Future<void> resetPassword({
    required String username,
    required String newPassword,
    String? oldPassword,
  }) async {
    try {
      final normalizedOldPassword = oldPassword?.trim();
      final request = ForgetPasswordRequest(
        username: username.trim(),
        newPassword: newPassword.trim(),
        oldPassword:
            normalizedOldPassword != null && normalizedOldPassword.isNotEmpty
            ? normalizedOldPassword
            : null,
      );

      if (kDebugMode) {
        debugPrint('[UserRepository] Resetting password for $username');
      }

      // Pass isReadOperation=false so HTTP 200 with ORA- is treated as success
      await _apiService.post(
        ApiConstants.forgetPassword,
        body: request.toJson(),
        isReadOperation: false,
      );

      if (kDebugMode) {
        debugPrint('[UserRepository] Password reset successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[UserRepository] Error resetting password: $e');
      }
      rethrow;
    }
  }
}
