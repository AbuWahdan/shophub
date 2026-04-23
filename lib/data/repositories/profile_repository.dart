import 'package:flutter/foundation.dart';
import '../../core/api/api_constants.dart';
import '../../core/api/api_service.dart';
import '../../core/utils/apex_response_helper.dart';
import '../../models/user.dart';

class ProfileRepository {
  final ApiService _apiService;

  ProfileRepository(this._apiService);

  Future<void> updateUser(User request) async {
    final normalizedUser = request.copyWith(
      userId: request.userId,
      fullname: request.fullname.trim(),
      email: request.email.trim(),
      phone: request.phone.trim(),
      country: request.country.trim(),
    );
    final payload = _buildUserPayload(normalizedUser);
    final attempts = <Map<String, dynamic>>[
      {
        'users': [payload],
      },
      {
        'items': [payload],
      },
      {
        'data': [payload],
      },
      payload,
    ];

    Object? lastError;

    for (final body in attempts) {
      try {
        if (kDebugMode) {
          debugPrint(
            '[ProfileRepository] Updating user ${normalizedUser.username} with body: $body',
          );
        }

        final response = await _apiService.post(
          ApiConstants.updateUser,
          body: body,
          isReadOperation: false,
        );
        ApexResponseHelper.unwrapResponse(response, 'UpdateUser');
        return;
      } catch (error) {
        lastError = error;
        if (kDebugMode) {
          debugPrint('[ProfileRepository] Update attempt failed: $error');
        }
      }
    }

    if (kDebugMode) {
      debugPrint('[ProfileRepository] Error updating user: $lastError');
    }
    throw lastError ?? Exception('Failed to update profile.');
  }

  Map<String, dynamic> _buildUserPayload(User user) {
    return {
      'user_id': user.userId,
      'username': user.username,
      'fullname': user.fullname,
      'full_name': user.fullname,
      'email': user.email,
      'phone': user.phone,
      'country': user.country,
      if (user.gender != null) 'gender': user.gender,
      'USER_ID': user.userId,
      'USERNAME': user.username,
      'FULL_NAME': user.fullname,
      'EMAIL': user.email,
      'PHONE': user.phone,
      'COUNTRY': user.country,
      if (user.gender != null) 'GENDER': user.gender,
      'PASSWORD_HASH': user.passwordHash,
      'ADDRESS': user.address,
      'ROLE': user.role,
      'IS_ACTIVE': user.isActive,
    };
  }
}
