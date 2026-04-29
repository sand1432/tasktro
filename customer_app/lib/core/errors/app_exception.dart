sealed class AppException implements Exception {
  const AppException(this.message, {this.code, this.stackTrace});

  final String message;
  final String? code;
  final StackTrace? stackTrace;

  @override
  String toString() => 'AppException($code): $message';
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.stackTrace});
}

class AuthException extends AppException {
  const AuthException(super.message, {super.code, super.stackTrace});
}

class ServerException extends AppException {
  const ServerException(super.message, {super.code, super.stackTrace});
}

class CacheException extends AppException {
  const CacheException(super.message, {super.code, super.stackTrace});
}

class ValidationException extends AppException {
  const ValidationException(super.message, {super.code, super.stackTrace});
}

class PaymentException extends AppException {
  const PaymentException(super.message, {super.code, super.stackTrace});
}

class AIServiceException extends AppException {
  const AIServiceException(super.message, {super.code, super.stackTrace});
}

class LocationException extends AppException {
  const LocationException(super.message, {super.code, super.stackTrace});
}

class StorageException extends AppException {
  const StorageException(super.message, {super.code, super.stackTrace});
}
