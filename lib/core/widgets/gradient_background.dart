import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  theme.scaffoldBackgroundColor,
                  primary.withValues(alpha: 0.08),
                  theme.scaffoldBackgroundColor,
                ]
              : [
                  theme.scaffoldBackgroundColor,
                  primary.withValues(alpha: 0.05),
                  Colors.white,
                ],
        ),
      ),
      child: child,
    );
  }
}
