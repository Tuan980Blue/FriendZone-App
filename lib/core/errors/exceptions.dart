class ServerException implements Exception {
  final String message;

  ServerException([this.message = "Lỗi máy chủ"]);

  @override
  String toString() => "ServerException: $message";
}

class CacheException implements Exception {
  final String message;
  CacheException(this.message);
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);
} 