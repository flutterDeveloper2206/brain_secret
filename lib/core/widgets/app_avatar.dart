import 'package:flutter/material.dart';

/// Consistent default person avatar used across customer screens.
class AppAvatar extends StatelessWidget {
  const AppAvatar({super.key, this.radius = 24, this.icon});

  final double radius;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconSize = radius * 1.15;

    return CircleAvatar(
      radius: radius,
      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
      child: Icon(
        icon ?? Icons.person_rounded,
        size: iconSize,
        color: theme.colorScheme.primary,
      ),
    );
  }
}
