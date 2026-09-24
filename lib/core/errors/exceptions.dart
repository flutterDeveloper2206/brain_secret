class AppException implements Exception {
  final String message;
  final String? prefix;
  final int? statusCode;

  AppException(this.message, [this.prefix, this.statusCode]);

  @override
  String toString() => '${prefix ?? ''}$message';
}

class NetworkException extends AppException {
  NetworkException(String message, {int? statusCode})
    : super(message, 'Connection Error: ', statusCode);
}

class ServerException extends AppException {
  ServerException(String message, {int? statusCode})
    : super(message, 'Server Error: ', statusCode);
}

class UnauthorizedException extends AppException {
  UnauthorizedException(String message, {int? statusCode = 401})
    : super(message, 'Unauthorized: ', statusCode);
}

class ForbiddenException extends AppException {
  ForbiddenException(String message, {int? statusCode = 403})
    : super(message, 'Forbidden: ', statusCode);
}

class NotFoundException extends AppException {
  NotFoundException(String message, {int? statusCode = 404})
    : super(message, 'Not Found: ', statusCode);
}

class ValidationException extends AppException {
  ValidationException(String message, {int? statusCode = 400})
    : super(message, 'Validation Error: ', statusCode);
}

class PlatformProcessingException extends AppException {
  PlatformProcessingException(String message)
    : super(message, 'Processing Error: ');
}

class FileSystemException extends AppException {
  FileSystemException(String message) : super(message, 'File Error: ');
}
