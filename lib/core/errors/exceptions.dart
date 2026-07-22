class AppException implements Exception {
  final String message;
  final String? prefix;

  AppException(this.message, [this.prefix]);

  @override
  String toString() => "${prefix ?? ''}$message";
}

class NetworkException extends AppException {
  NetworkException(String message) : super(message, "Connection Error: ");
}

class ServerException extends AppException {
  ServerException(String message) : super(message, "Server Error: ");
}

class PlatformProcessingException extends AppException {
  PlatformProcessingException(String message) : super(message, "Processing Error: ");
}

class FileSystemException extends AppException {
  FileSystemException(String message) : super(message, "File Error: ");
}
