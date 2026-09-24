import 'dart:ui';

import 'package:flutter/material.dart';

/// Soft frosted atmosphere used across screens.
/// Light mode mirrors the airy peach → cream → sage look from the menu.
class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;
    final tertiary = theme.colorScheme.tertiary;
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.sizeOf(context);

    final warm = Color.lerp(primary, const Color(0xFFE8C4A8), 0.55) ?? primary;
    final cool =
        Color.lerp(secondary, const Color(0xFFB7D0C8), 0.65) ?? secondary;
    final softMint =
        Color.lerp(tertiary, const Color(0xFFC9D9D0), 0.55) ?? tertiary;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  const Color(0xFF1C1F26),
                  Color.lerp(const Color(0xFF22262F), primary, 0.18) ??
                      const Color(0xFF22262F),
                  Color.lerp(const Color(0xFF1A1E24), secondary, 0.14) ??
                      const Color(0xFF1A1E24),
                ]
              : const [Color(0xFFF4EFEA), Color(0xFFF7F4F0), Color(0xFFEEF3F1)],
          stops: const [0.0, 0.45, 1.0],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Soft out-of-focus wash (peach / cream / sage).
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 36, sigmaY: 36),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    top: -size.height * 0.12,
                    left: -size.width * 0.2,
                    child: _GlowOrb(
                      color: warm.withValues(alpha: isDark ? 0.34 : 0.55),
                      size: size.width * 0.95,
                    ),
                  ),
                  Positioned(
                    top: size.height * 0.08,
                    right: -size.width * 0.28,
                    child: _GlowOrb(
                      color: primary.withValues(alpha: isDark ? 0.22 : 0.28),
                      size: size.width * 0.85,
                    ),
                  ),
                  Positioned(
                    bottom: -size.height * 0.18,
                    left: -size.width * 0.12,
                    child: _GlowOrb(
                      color: cool.withValues(alpha: isDark ? 0.28 : 0.48),
                      size: size.width * 1.05,
                    ),
                  ),
                  Positioned(
                    bottom: size.height * 0.04,
                    right: -size.width * 0.22,
                    child: _GlowOrb(
                      color: softMint.withValues(alpha: isDark ? 0.2 : 0.34),
                      size: size.width * 0.8,
                    ),
                  ),
                  Positioned(
                    top: size.height * 0.32,
                    left: size.width * 0.2,
                    child: _GlowOrb(
                      color: Colors.white.withValues(
                        alpha: isDark ? 0.06 : 0.7,
                      ),
                      size: size.width * 0.55,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Gentle light veil so cards sit on soft glass air.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          Colors.black.withValues(alpha: 0.12),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.08),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.34),
                          Colors.white.withValues(alpha: 0.08),
                          cool.withValues(alpha: 0.08),
                        ],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withValues(alpha: 0.4),
              color.withValues(alpha: 0),
            ],
            stops: const [0.0, 0.42, 1.0],
          ),
        ),
      ),
    );
  }
}
