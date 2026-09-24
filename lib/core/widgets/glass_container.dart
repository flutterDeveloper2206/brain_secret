import 'dart:ui';

import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.blur = 18,
    this.width,
    this.elevated = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final double? width;

  /// Use for list/detail cards that need stronger contrast.
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final radius = BorderRadius.circular(borderRadius);

    final lightFill = elevated
        ? [
            Colors.white.withValues(alpha: 0.96),
            Colors.white.withValues(alpha: 0.90),
          ]
        : [
            Colors.white.withValues(alpha: 0.88),
            Colors.white.withValues(alpha: 0.72),
          ];

    final darkFill = elevated
        ? [
            theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.94),
            theme.colorScheme.surfaceContainer.withValues(alpha: 0.88),
          ]
        : [
            theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.82),
            theme.colorScheme.surface.withValues(alpha: 0.72),
          ];

    return Container(
      width: width,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.08),
            blurRadius: elevated ? 22 : 18,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark ? darkFill : lightFill,
              ),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.16)
                    : Colors.white.withValues(alpha: 0.95),
                width: 1.2,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
