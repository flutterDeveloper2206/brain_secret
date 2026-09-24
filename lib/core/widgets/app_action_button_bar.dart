import 'package:flutter/material.dart';
import 'glass_container.dart';

/// Responsive glass action bar for details / preview footers.
/// Stacks buttons vertically when width is tight (common on web resize).
class AppActionButtonBar extends StatelessWidget {
  const AppActionButtonBar({
    super.key,
    required this.children,
    this.spacing = 10,
    this.breakpoint = 520,
  });

  final List<Widget> children;
  final double spacing;
  /// Stack when the bar is narrow. Three actions stay side-by-side on wide web.
  final double breakpoint;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      elevated: true,
      padding: const EdgeInsets.all(12),
      borderRadius: 18,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stack = constraints.maxWidth < breakpoint;

          if (stack) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) SizedBox(height: spacing),
                  SizedBox(width: double.infinity, child: children[i]),
                ],
              ],
            );
          }

          return Row(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) SizedBox(width: spacing),
                Expanded(child: children[i]),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// Shared filled / outlined action button styles that avoid web label overflow.
class AppActionButton extends StatelessWidget {
  const AppActionButton.filled({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  }) : _outlined = false,
       _destructive = false;

  const AppActionButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    bool destructive = false,
  }) : _outlined = true,
       _destructive = destructive;

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool _outlined;
  final bool _destructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final error = theme.colorScheme.error;
    final foreground = _destructive ? error : null;

    final child = isLoading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: foreground ?? theme.colorScheme.primary,
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: foreground),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );

    if (_outlined) {
      return SizedBox(
        height: 48,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: foreground,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            side: _destructive
                ? BorderSide(color: error.withValues(alpha: 0.45))
                : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      height: 48,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: child,
      ),
    );
  }
}
