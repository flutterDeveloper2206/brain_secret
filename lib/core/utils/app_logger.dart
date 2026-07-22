import 'dart:developer' as developer;

class AppLogger {
  /// Base log method using dart:developer log
  static void log(
    String message, {
    String name = 'App',
    Object? error,
    StackTrace? stackTrace,
    int level = 0,
  }) {
    developer.log(
      message,
      name: name,
      error: error,
      stackTrace: stackTrace,
      level: level,
    );
  }

  /// Logs error level messages
  static void error(
    String message, {
    String name = 'App',
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(
      message,
      name: name,
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }

  /// Logs informational messages
  static void info(
    String message, {
    String name = 'App',
  }) {
    log(
      message,
      name: name,
      level: 500,
    );
  }
}
