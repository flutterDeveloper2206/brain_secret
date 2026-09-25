import 'package:flutter/material.dart';
import 'theme_scheme_bottom_sheet.dart';

class ThemeSelectorFab extends StatelessWidget {
  const ThemeSelectorFab({
    super.key,
    this.heroTag = 'theme_selector_fab',
  });

  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FloatingActionButton(
      heroTag: heroTag,
      onPressed: showThemeSchemeBottomSheet,
      backgroundColor: theme.colorScheme.secondary,
      foregroundColor: theme.colorScheme.onSecondary,
      child: Icon(Icons.palette, color: theme.colorScheme.onSecondary),
    );
  }
}
