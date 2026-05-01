import 'package:flutter/foundation.dart';

import '../../core/api/api_constants.dart';
import '../../core/api/api_service.dart';
import '../../core/api/app_exception.dart';
import '../../core/utils/apex_response_helper.dart';
import '../../models/checkout_request_model.dart';

class CheckoutRepository {
  final ApiService _apiService;

  CheckoutRepository(this._apiService);

  Future<Map<String, dynamic>> placeOrder(CheckoutRequestModel request) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '[CheckoutRepository] Placing order for ${request.username}',
        );
      }

      final response = await _apiService.post(
        ApiConstants.checkout,
        body: request.toJson(),
        isReadOperation: false,
      );

      final payload = ApexResponseHelper.unwrapResponse(response, 'PlaceOrder');
      if (payload == null) {
        return const <String, dynamic>{};
      }
      if (payload is List) {
        if (payload.isEmpty) {
          return const <String, dynamic>{};
        }
        final first = payload.first;
        if (first is Map<String, dynamic>) {
          return first;
        }
        if (first is Map) {
          return Map<String, dynamic>.from(first);
        }
      }
      if (payload is Map<String, dynamic>) {
        return payload;
      }
      if (payload is Map) {
        return Map<String, dynamic>.from(payload);
      }
      return <String, dynamic>{'result': payload};
    } on ServerException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CheckoutRepository] Error placing order: $e');
      }
      rethrow;
    }
  }
}
