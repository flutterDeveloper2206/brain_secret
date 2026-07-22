import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/app_logger.dart';
import 'exceptions.dart';

class ErrorHandler {
  static void handleError(dynamic error) {
    String title = "Error";
    String message = "Something went wrong. Please try again.";

    if (error is AppException) {
      title = error.prefix?.replaceAll(": ", "") ?? "App Error";
      message = error.message;
    } else if (error is NetworkException) {
      title = "Network Connection Failed";
      message = "Please check your internet connection.";
    }

    // Log error details to the developer console using the common logger
    AppLogger.error(
      "$title: $message",
      name: 'ErrorHandler',
      error: error,
      stackTrace: error is Error ? error.stackTrace : StackTrace.current,
    );

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }
}
