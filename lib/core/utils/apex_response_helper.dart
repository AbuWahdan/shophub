import '../api/app_exception.dart';

class ApexResponseHelper {
  const ApexResponseHelper._();

  static dynamic unwrapResponse(dynamic response, String context) {
    if (response == null) {
      return null;
    }

    if (response is List) {
      return _cleanInnerList(response, context);
    }

    if (response is! Map<String, dynamic>) {
      return response;
    }

    final outerStatus = _readStatus(response);
    if (_isErrorStatus(outerStatus)) {
      throw ServerException(
        messageForContext(
          context,
          response['message']?.toString() ?? response['MESSAGE']?.toString(),
        ),
      );
    }

    final data = response['data'] ?? response['DATA'];
    if (data == null) {
      return response;
    }

    if (data is List) {
      return _cleanInnerList(data, context);
    }

    if (data is Map<String, dynamic>) {
      final innerStatus = _readStatus(data);
      if (_isErrorStatus(innerStatus)) {
        throw ServerException(
          messageForContext(
            context,
            data['message']?.toString() ?? data['MESSAGE']?.toString(),
          ),
        );
      }
      return data;
    }

    return data;
  }

  static List<dynamic> extractData(dynamic response, String context) {
    final payload = unwrapResponse(response, context);
    if (payload == null) {
      return const <dynamic>[];
    }
    if (payload is List) {
      return payload;
    }
    if (payload is Map<String, dynamic>) {
      return <dynamic>[payload];
    }
    throw ServerException('$context returned an unexpected response format.');
  }

  static Map<String, dynamic>? extractFirstMap(
    dynamic response,
    String context,
  ) {
    final data = extractData(response, context);
    if (data.isEmpty) {
      return null;
    }

    final first = data.first;
    if (first is Map<String, dynamic>) {
      return first;
    }
    if (first is Map) {
      return Map<String, dynamic>.from(first);
    }
    throw ServerException('$context returned an unexpected response format.');
  }

  static String messageForContext(String context, [String? rawMessage]) {
    final message = rawMessage?.trim();
    if (message == null || message.isEmpty) {
      return _fallbackMessage(context);
    }

    final normalized = message.toLowerCase();
    if (normalized.contains('ora-01001')) {
      switch (context) {
        case 'GetUserAddress':
          return 'Unable to load addresses right now. Please try again.';
        case 'PlaceOrder':
          return 'Checkout failed. Please try again or contact support.';
        case 'GetOrderDetails':
          return 'Unable to load order details right now. Please try again.';
        case 'DeleteItemCart':
          return 'Could not remove item. Please try again.';
        case 'CheckUserItemOrder':
          return 'We could not verify your order history right now. Please try again.';
      }
    }

    if (normalized.contains('ora-') || normalized.contains('pl/sql')) {
      return _fallbackMessage(context);
    }

    return message;
  }

  static List<dynamic> _cleanInnerList(List<dynamic> data, String context) {
    if (data.isEmpty) {
      return const <dynamic>[];
    }

    final cleanItems = <dynamic>[];
    Map<String, dynamic>? firstError;

    for (final item in data) {
      Map<String, dynamic>? mappedItem;
      if (item is Map<String, dynamic>) {
        mappedItem = item;
      } else if (item is Map) {
        mappedItem = Map<String, dynamic>.from(item);
      }

      if (mappedItem == null) {
        cleanItems.add(item);
        continue;
      }

      if (_isErrorStatus(_readStatus(mappedItem))) {
        firstError ??= mappedItem;
        continue;
      }

      cleanItems.add(mappedItem);
    }

    if (cleanItems.isNotEmpty) {
      return cleanItems;
    }

    if (firstError != null) {
      throw ServerException(
        messageForContext(
          context,
          firstError['message']?.toString() ??
              firstError['MESSAGE']?.toString(),
        ),
      );
    }

    return const <dynamic>[];
  }

  static String _readStatus(Map<String, dynamic> json) {
    return (json['status'] ?? json['STATUS'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
  }

  static bool _isErrorStatus(String status) {
    return status == 'error' || status == 'failed' || status == 'failure';
  }

  static String _fallbackMessage(String context) {
    switch (context) {
      case 'GetUserAddress':
        return 'Unable to load addresses right now. Please try again.';
      case 'PlaceOrder':
        return 'Checkout failed. Please try again or contact support.';
      case 'GetOrderDetails':
        return 'Unable to load order details right now. Please try again.';
      case 'DeleteItemCart':
        return 'Could not remove item. Please try again.';
      case 'CheckUserItemOrder':
        return 'We could not verify your order history right now. Please try again.';
      case 'GetItemComment':
        return 'Unable to load reviews right now. Please try again.';
      default:
        return '$context failed. Please try again.';
    }
  }
}
