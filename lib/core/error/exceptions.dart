abstract class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

final class ServerException extends AppException {
  const ServerException(super.message, {this.code});

  final int? code;
}

final class CacheException extends AppException {
  const CacheException(super.message);
}

final class NetworkException extends AppException {
  const NetworkException(super.message);
}

final class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message);
}
