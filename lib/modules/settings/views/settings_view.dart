import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/values/app_constants.dart';
import '../../../core/widgets/glass_app_bar.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/theme_selector_fab.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: const GlassAppBar(title: 'Settings'),
      floatingActionButton: const ThemeSelectorFab(
        heroTag: 'settings_theme_fab',
      ),
      body: GradientBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow =
                  constraints.maxWidth < AppConstants.breakpointTablet;
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isNarrow ? double.infinity : 720,
                  ),
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isNarrow ? 16 : 28,
                      vertical: 16,
                    ),
                    children: [
                      _SettingsTile(
                        icon: Icons.palette_outlined,
                        title: 'Color theme',
                        subtitleBuilder: () =>
                            ThemeController.to.schemeDisplayName,
                        onTap: controller.openThemeSchemeSheet,
                      ),
                      const SizedBox(height: 12),
                      GlassContainer(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                        borderRadius: 18,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.brightness_6_outlined,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Appearance',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Obx(() {
                              final mode =
                                  ThemeController.to.themeMode.value;
                              return Row(
                                children: [
                                  Expanded(
                                    child: _ModeChip(
                                      label: 'Light',
                                      icon: Icons.light_mode_outlined,
                                      selected: mode == ThemeMode.light,
                                      onTap: () => controller.setThemeMode(
                                        ThemeMode.light,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _ModeChip(
                                      label: 'Dark',
                                      icon: Icons.dark_mode_outlined,
                                      selected: mode == ThemeMode.dark,
                                      onTap: () => controller.setThemeMode(
                                        ThemeMode.dark,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      GlassContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        borderRadius: 18,
                        child: Material(
                          color: Colors.transparent,
                          child: Obx(
                            () => SwitchListTile.adaptive(
                              secondary: Icon(
                                Icons.notifications_outlined,
                                color: theme.colorScheme.primary,
                              ),
                              title: Text(
                                'Notifications',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Text(
                                ThemeController.to.notificationsEnabled.value
                                    ? 'Enabled'
                                    : 'Disabled',
                              ),
                              value: ThemeController
                                  .to.notificationsEnabled.value,
                              onChanged: controller.setNotificationsEnabled,
                              activeTrackColor: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GlassContainer(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        borderRadius: 18,
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'About',
                                    style: theme.textTheme.titleSmall
                                        ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${AppConstants.appName} · v${AppConstants.appVersion}',
                                    style: theme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: theme.textTheme.bodyMedium
                                          ?.color
                                          ?.withValues(alpha: 0.65),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitleBuilder,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String Function() subtitleBuilder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      borderRadius: 18,
      child: Material(
        color: Colors.transparent,
        child: Obx(
          () {
            // Subscribe to scheme changes for subtitle.
            ThemeController.to.selectedScheme.value;
            return ListTile(
              leading: Icon(icon, color: theme.colorScheme.primary),
              title: Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(subtitleBuilder()),
              trailing: Icon(
                Icons.chevron_right,
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
              ),
              onTap: onTap,
            );
          },
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected
          ? theme.colorScheme.primary.withValues(alpha: 0.14)
          : theme.colorScheme.surface.withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: selected
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withValues(alpha: 0.22),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
