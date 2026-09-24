import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/theme_selector_fab.dart';
import '../controllers/main_shell_controller.dart';
import 'widgets/dashboard_tab.dart';
import 'widgets/menu_tab.dart';
import 'widgets/report_tab.dart';

class MainShellView extends GetView<MainShellController> {
  const MainShellView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final index = controller.currentIndex.value;
      return Scaffold(
        body: IndexedStack(
          index: index,
          children: const [
            DashboardTab(),
            ReportTab(),
            MenuTab(),
          ],
        ),
        floatingActionButton: const ThemeSelectorFab(),
        bottomNavigationBar: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: (isDark ? Colors.black : Colors.white).withValues(
                  alpha: isDark ? 0.45 : 0.72,
                ),
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.18),
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: NavigationBar(
                  selectedIndex: index,
                  onDestinationSelected: controller.changeTab,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  indicatorColor: theme.colorScheme.primary.withValues(
                    alpha: 0.16,
                  ),
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard),
                      label: 'Dashboard',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.description_outlined),
                      selectedIcon: Icon(Icons.description),
                      label: 'Report',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.menu),
                      selectedIcon: Icon(Icons.menu_open),
                      label: 'Menu',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
