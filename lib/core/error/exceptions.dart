class AppException implements Exception {
  final String message;
  final String? prefix;
  final int? statusCode;

  AppException(this.message, [this.prefix, this.statusCode]);

  @override
  String toString() {
    return '${prefix ?? ''}$message';
  }
}

class ServerException extends AppException {
  ServerException([String? message, int? statusCode])
      : super(message ?? 'Server error occurred', 'Server Error: ', statusCode);
}

class NetworkException extends AppException {
  NetworkException([String? message])
      : super(message ?? 'No internet connection', 'Network Error: ');
}

class TimeoutException extends AppException {
  TimeoutException([String? message])
      : super(message ?? 'Connection timed out', 'Timeout Error: ');
}

class AuthException extends AppException {
  AuthException([String? message, int? statusCode])
      : super(message ?? 'Authentication failed', 'Auth Error: ', statusCode);
}

class CacheException extends AppException {
  CacheException([String? message])
      : super(message ?? 'Cache error occurred', 'Cache Error: ');
}
