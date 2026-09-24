import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Shared iOS-style frosted-glass confirmation / alert popup.
class GlassPopup {
  GlassPopup._();

  static Future<T?> show<T>({
    required String title,
    required String message,
    String cancelText = 'Cancel',
    String confirmText = 'OK',
    bool barrierDismissible = true,
    Color? confirmColor,
    bool isDestructive = false,
  }) {
    return Get.dialog<T>(
      GlassPopupDialog(
        title: title,
        message: message,
        cancelText: cancelText,
        confirmText: confirmText,
        confirmColor: confirmColor,
        isDestructive: isDestructive,
      ),
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      transitionDuration: const Duration(milliseconds: 280),
      transitionCurve: Curves.easeOutCubic,
    );
  }

  static Future<bool> confirm({
    required String title,
    required String message,
    String cancelText = 'Cancel',
    String confirmText = 'OK',
    bool isDestructive = false,
  }) async {
    final result = await show<bool>(
      title: title,
      message: message,
      cancelText: cancelText,
      confirmText: confirmText,
      isDestructive: isDestructive,
    );
    return result == true;
  }
}

class GlassPopupDialog extends StatelessWidget {
  const GlassPopupDialog({
    super.key,
    required this.title,
    required this.message,
    this.cancelText = 'Cancel',
    this.confirmText = 'OK',
    this.confirmColor,
    this.isDestructive = false,
  });

  final String title;
  final String message;
  final String cancelText;
  final String confirmText;
  final Color? confirmColor;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = confirmColor ??
        (isDestructive
            ? theme.colorScheme.error
            : theme.colorScheme.primary);
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.14)
        : Colors.black.withValues(alpha: 0.08);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.92, end: 1),
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: ((scale - 0.92) / 0.08).clamp(0.0, 1.0),
              child: child,
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          Colors.white.withValues(alpha: 0.22),
                          Colors.white.withValues(alpha: 0.08),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.78),
                          Colors.white.withValues(alpha: 0.52),
                        ],
                ),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.28)
                      : Colors.white.withValues(alpha: 0.85),
                  width: 1.1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 32,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 24, 22, 10),
                      child: Column(
                        children: [
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            message,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.35,
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withValues(alpha: 0.72),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, thickness: 1, color: dividerColor),
                    SizedBox(
                      height: 50,
                      child: Row(
                        children: [
                          Expanded(
                            child: _GlassPopupAction(
                              label: cancelText,
                              onTap: () => Get.back(result: false),
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.75),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          VerticalDivider(
                            width: 1,
                            thickness: 1,
                            color: dividerColor,
                          ),
                          Expanded(
                            child: _GlassPopupAction(
                              label: confirmText,
                              onTap: () => Get.back(result: true),
                              color: accent,
                              fontWeight: FontWeight.w700,
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
        ),
      ),
    );
  }
}

class _GlassPopupAction extends StatelessWidget {
  const _GlassPopupAction({
    required this.label,
    required this.onTap,
    required this.color,
    required this.fontWeight,
  });

  final String label;
  final VoidCallback onTap;
  final Color color;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: fontWeight,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }
}
