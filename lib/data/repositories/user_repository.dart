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
      if (kDebugMode) debugPrint('[UserRepository] Sending OTP to $email');
      await _apiService.post(
        ApiConstants.sendOtp,
        body: {'username': username, 'email': email},
        isReadOperation: false,
      );
      if (kDebugMode) debugPrint('[UserRepository] OTP sent successfully');
    } catch (e) {
      if (kDebugMode) debugPrint('[UserRepository] Error sending OTP: $e');
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
      if (kDebugMode) debugPrint('[UserRepository] Verifying OTP for $username');
      await _apiService.post(
        ApiConstants.verifyOtp,
        body: {'username': username, 'email': email, 'otp': otp},
        isReadOperation: false,
      );
      if (kDebugMode) debugPrint('[UserRepository] OTP verified successfully');
    } catch (e) {
      if (kDebugMode) debugPrint('[UserRepository] Error verifying OTP: $e');
      rethrow;
    }
  }

  /// Reset or change user password.
  ///
  /// - OTP flow   → [oldPassword] is null   → sends {username, new_password}
  /// - Change flow → [oldPassword] is set   → sends {username, old_password, new_password}
  ///
  /// The API always returns HTTP 200. Success/failure is indicated by the
  /// body: {"status": 1} = success, {"status": 0} = failure (e.g. wrong
  /// current password).  Any other truthy status string is also treated as
  /// success so the method works if the backend ever changes to
  /// {"status": "success"}.
  Future<void> resetPassword({
    required String username,
    required String newPassword,
    String? oldPassword,
  }) async {
    final normalizedOld = oldPassword?.trim();
    final request = ForgetPasswordRequest(
      username:    username.trim(),
      newPassword: newPassword.trim(),
      oldPassword: (normalizedOld != null && normalizedOld.isNotEmpty)
          ? normalizedOld
          : null,
    );

    if (kDebugMode) {
      debugPrint('[UserRepository] resetPassword for $username '
          '(hasOldPassword: ${request.oldPassword != null})');
    }

    // isReadOperation: true so the ApiService returns the decoded body
    // instead of discarding it — we need to read the status field.
    final response = await _apiService.post(
      ApiConstants.forgetPassword,
      body:            request.toJson(),
      isReadOperation: true,
    );

    if (kDebugMode) {
      debugPrint('[UserRepository] resetPassword response: $response');
    }

    // ── FIX: check the response body ─────────────────────────────────────
    // The API returns HTTP 200 for both success and failure.
    // {"status": 0} means failure (e.g. wrong current password).
    // {"status": 1} or {"status": "success"} means success.
    // Any non-map / null response (e.g. empty body) is treated as success
    // to stay compatible with backends that return no body on success.
    if (response is Map<String, dynamic>) {
      final raw    = response['status'] ?? response['STATUS'];
      final isZero = raw != null &&
          (raw == 0 ||
              raw == '0' ||
              raw.toString().toLowerCase() == 'false' ||
              raw.toString().toLowerCase() == 'fail' ||
              raw.toString().toLowerCase() == 'failed' ||
              raw.toString().toLowerCase() == 'error');

      if (isZero) {
        // Extract any message the backend included, fall back to a generic one.
        final message = _extractMessage(response) ??
            (request.oldPassword != null
                ? 'Current password is incorrect.'
                : 'Password update failed. Please try again.');
        throw Exception(message);
      }
    }
    // ─────────────────────────────────────────────────────────────────────

    if (kDebugMode) debugPrint('[UserRepository] Password updated successfully');
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  String? _extractMessage(Map<String, dynamic> data) {
    for (final key in const [
      'message', 'MESSAGE',
      'error',   'ERROR',
      'detail',  'DETAIL',
      'msg',     'MSG',
    ]) {
      final v = data[key];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    return null;
  }
}