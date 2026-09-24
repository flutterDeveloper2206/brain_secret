import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/app_logger.dart';
import '../widgets/glass_snackbar.dart';
import '../../data/providers/api_service.dart';
import '../../routes/app_routes.dart';
import 'exceptions.dart';

enum AppErrorKind {
  network,
  unauthorized,
  forbidden,
  notFound,
  validation,
  server,
  unknown,
}

class ErrorHandler {
  static AppErrorKind classify(dynamic error) {
    if (error is NetworkException) return AppErrorKind.network;
    if (error is UnauthorizedException) return AppErrorKind.unauthorized;
    if (error is ForbiddenException) return AppErrorKind.forbidden;
    if (error is NotFoundException) return AppErrorKind.notFound;
    if (error is ValidationException) return AppErrorKind.validation;

    final status = _statusCode(error);
    if (status == 401) return AppErrorKind.unauthorized;
    if (status == 403) return AppErrorKind.forbidden;
    if (status == 404) return AppErrorKind.notFound;
    if (status == 400 || status == 422) return AppErrorKind.validation;
    if (status == 408 || status == 504) return AppErrorKind.network;
    if (status != null && status >= 500) return AppErrorKind.server;

    final message = _rawMessage(error).toLowerCase();
    if (_isUnauthorizedMessage(message)) return AppErrorKind.unauthorized;
    if (_isNotFoundMessage(message)) return AppErrorKind.notFound;
    if (_isValidationMessage(message)) return AppErrorKind.validation;
    if (error is ServerException) return AppErrorKind.server;
    if (error is AppException) return AppErrorKind.server;
    return AppErrorKind.unknown;
  }

  static bool isNotFound(dynamic error) =>
      classify(error) == AppErrorKind.notFound;

  static int? _statusCode(dynamic error) {
    if (error is AppException) return error.statusCode;
    return null;
  }

  static String _rawMessage(dynamic error) {
    if (error is AppException) return error.message;
    return error?.toString() ?? '';
  }

  static bool _isUnauthorizedMessage(String message) {
    return message.contains('unauthorized') ||
        message.contains('unauthenticated') ||
        message.contains('token expired') ||
        message.contains('invalid token') ||
        message.contains('session expired') ||
        message.contains('authentication failed');
  }

  static bool _isNotFoundMessage(String message) {
    return message.contains('not found') ||
        message.contains('does not exist') ||
        message.contains('no data found') ||
        message.contains('data not found') ||
        message.contains('no customer') ||
        message.contains('no franchise') ||
        message.contains('no record') ||
        message.contains('record not exist');
  }

  static bool _isValidationMessage(String message) {
    return message.contains('required') ||
        message.contains('invalid') ||
        message.contains('already exists') ||
        message.contains('duplicate');
  }

  static String _friendlyTitle(AppErrorKind kind, AppException? appError) {
    switch (kind) {
      case AppErrorKind.network:
        return 'Connection Error';
      case AppErrorKind.unauthorized:
        return 'Session Expired';
      case AppErrorKind.forbidden:
        return 'Access Denied';
      case AppErrorKind.notFound:
        return 'Not Found';
      case AppErrorKind.validation:
        return 'Check Details';
      case AppErrorKind.server:
        return 'Server Error';
      case AppErrorKind.unknown:
        return appError?.prefix?.replaceAll(': ', '').trim().isNotEmpty == true
            ? appError!.prefix!.replaceAll(': ', '').trim()
            : 'Error';
    }
  }

  static String _stripStatusCode(String message) {
    var cleaned = message.trim();
    // Remove patterns like "(500)", "[500]", "status code: 500", "status code 500".
    cleaned = cleaned.replaceAll(
      RegExp(r'\s*[\(\[]\s*\d{3}\s*[\)\]]'),
      '',
    );
    cleaned = cleaned.replaceAll(
      RegExp(r'\s*status\s*code\s*[:=]?\s*\d{3}', caseSensitive: false),
      '',
    );
    cleaned = cleaned.replaceAll(RegExp(r'\s{2,}'), ' ').trim();
    cleaned = cleaned.replaceAll(RegExp(r'^[\s,:.\-]+|[\s,:.\-]+$'), '');
    return cleaned;
  }

  static String _friendlyMessage(AppErrorKind kind, String raw) {
    final cleaned = _stripStatusCode(
      raw.trim().isEmpty
          ? 'Something went wrong. Please try again.'
          : raw.trim(),
    );

    final display = cleaned.isEmpty
        ? 'Something went wrong. Please try again.'
        : cleaned;

    switch (kind) {
      case AppErrorKind.network:
        return display.toLowerCase().contains('internet') ||
                display.toLowerCase().contains('connection')
            ? display
            : 'Please check your internet connection and try again.';
      case AppErrorKind.unauthorized:
      case AppErrorKind.forbidden:
      case AppErrorKind.validation:
        return display;
      case AppErrorKind.notFound:
        if (display.toLowerCase().contains('customer')) {
          return 'This customer is no longer available. It may have been deleted.';
        }
        if (display.toLowerCase().contains('franchise')) {
          return 'This franchise is no longer available. It may have been deleted.';
        }
        if (display.toLowerCase().contains('staff') ||
            display.toLowerCase().contains('employee')) {
          return 'This staff member is no longer available. It may have been deleted.';
        }
        return display.toLowerCase().contains('not found')
            ? display
            : 'The requested item was not found. Refresh and try again.';
      case AppErrorKind.server:
        if (display.toLowerCase().contains('request failed') ||
            display == 'Something went wrong. Please try again.') {
          return 'Something went wrong on the server. Please try again later.';
        }
        return display;
      case AppErrorKind.unknown:
        return display;
    }
  }

  static void showSuccess(
    String message, {
    String title = 'Success',
  }) {
    GlassSnackbar.success(message, title: title);
  }

  /// Global error UI. Use [popOnNotFound] to leave the current screen when
  /// the resource no longer exists (e.g. deleted customer/franchise).
  static void handleError(
    dynamic error, {
    bool popOnNotFound = false,
    VoidCallback? onNotFound,
  }) {
    final kind = classify(error);
    final appError = error is AppException ? error : null;
    final status = _statusCode(error);
    final raw = _rawMessage(error);
    final title = _friendlyTitle(kind, appError);
    final message = _friendlyMessage(kind, raw);

    AppLogger.error(
      '$title${status != null ? ' [$status]' : ''}: $message',
      name: 'ErrorHandler',
      error: kind == AppErrorKind.unknown ? error : null,
      stackTrace: kind == AppErrorKind.unknown ? StackTrace.current : null,
    );

    final snackKind = switch (kind) {
      AppErrorKind.notFound => GlassSnackKind.warning,
      AppErrorKind.validation => GlassSnackKind.warning,
      AppErrorKind.forbidden => GlassSnackKind.warning,
      AppErrorKind.unauthorized => GlassSnackKind.warning,
      AppErrorKind.network => GlassSnackKind.network,
      _ => GlassSnackKind.error,
    };

    GlassSnackbar.show(
      title: title,
      message: message,
      kind: snackKind,
      duration: const Duration(seconds: 4),
    );

    if (kind == AppErrorKind.unauthorized) {
      _forceLogoutToLogin();
      return;
    }

    if (kind == AppErrorKind.notFound) {
      onNotFound?.call();
      if (popOnNotFound && (Get.key.currentState?.canPop() ?? false)) {
        // Delay so snackbar is shown on the previous route, not dismissed.
        Future<void>.delayed(const Duration(milliseconds: 50), () {
          if (Get.key.currentState?.canPop() ?? false) {
            Get.back(result: true);
          }
        });
      }
    }
  }

  static void _forceLogoutToLogin() {
    try {
      if (Get.isRegistered<ApiService>()) {
        Get.find<ApiService>().setAuthToken(null);
      }
    } catch (_) {}

    Future<void>.delayed(const Duration(milliseconds: 300), () {
      if (Get.currentRoute != Routes.login) {
        Get.offAllNamed(Routes.login);
      }
    });
  }
}
