import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum GlassSnackKind { success, error, warning, info, network }

/// Frosted-glass snackbars matching [GlassContainer] / [GlassPopup].
class GlassSnackbar {
  GlassSnackbar._();

  static void success(
    String message, {
    String title = 'Success',
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      title: title,
      message: message,
      kind: GlassSnackKind.success,
      duration: duration,
    );
  }

  static void error(
    String message, {
    String title = 'Error',
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      title: title,
      message: message,
      kind: GlassSnackKind.error,
      duration: duration,
    );
  }

  static void warning(
    String message, {
    String title = 'Notice',
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      title: title,
      message: message,
      kind: GlassSnackKind.warning,
      duration: duration,
    );
  }

  static void info(
    String message, {
    String title = 'Info',
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      title: title,
      message: message,
      kind: GlassSnackKind.info,
      duration: duration,
    );
  }

  static void show({
    required String title,
    required String message,
    GlassSnackKind kind = GlassSnackKind.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final body = message.trim().isEmpty ? title : message.trim();
    final heading = title.trim().isEmpty ? 'Notice' : title.trim();

    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    Get.showSnackbar(
      GetSnackBar(
        titleText: const SizedBox.shrink(),
        messageText: _GlassSnackCard(
          title: heading,
          message: body,
          kind: kind,
        ),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        borderRadius: 18,
        duration: duration,
        animationDuration: const Duration(milliseconds: 320),
        forwardAnimationCurve: Curves.easeOutCubic,
        reverseAnimationCurve: Curves.easeInCubic,
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }
}

class _GlassSnackCard extends StatelessWidget {
  const _GlassSnackCard({
    required this.title,
    required this.message,
    required this.kind,
  });

  final String title;
  final String message;
  final GlassSnackKind kind;

  IconData get _icon => switch (kind) {
    GlassSnackKind.success => Icons.check_circle_rounded,
    GlassSnackKind.error => Icons.error_outline_rounded,
    GlassSnackKind.warning => Icons.info_outline_rounded,
    GlassSnackKind.network => Icons.wifi_off_rounded,
    GlassSnackKind.info => Icons.notifications_none_rounded,
  };

  Color _accent(ColorScheme scheme) => switch (kind) {
    GlassSnackKind.success => const Color(0xFF2E7D4F),
    GlassSnackKind.error => scheme.error,
    GlassSnackKind.warning => const Color(0xFFC27803),
    GlassSnackKind.network => const Color(0xFF455A64),
    GlassSnackKind.info => scheme.primary,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = _accent(theme.colorScheme);
    const radius = 18.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.white.withValues(alpha: 0.20),
                      accent.withValues(alpha: 0.22),
                      Colors.white.withValues(alpha: 0.08),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.88),
                      accent.withValues(alpha: 0.14),
                      Colors.white.withValues(alpha: 0.62),
                    ],
            ),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.22)
                  : Colors.white.withValues(alpha: 0.95),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(alpha: isDark ? 0.28 : 0.16),
                    border: Border.all(
                      color: accent.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Icon(_icon, color: accent, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.78,
                          ),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
