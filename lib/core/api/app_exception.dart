class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException(super.message);
}

class TimeoutException extends AppException {
  TimeoutException(super.message);
}

class ServerException extends AppException {
  ServerException(super.message, {super.statusCode});
}

class AuthException extends AppException {
  AuthException(super.message);
}
