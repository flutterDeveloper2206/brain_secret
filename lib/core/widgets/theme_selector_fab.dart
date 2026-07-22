import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/theme_controller.dart';

class ThemeSelectorFab extends StatelessWidget {
  const ThemeSelectorFab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final presets = [
      FlexScheme.material,
      FlexScheme.vesuviusBurn,
      FlexScheme.bahamaBlue,
      FlexScheme.mallardGreen,
      FlexScheme.mandyRed,
      FlexScheme.espresso,
      FlexScheme.outerSpace,
      FlexScheme.sakura,
    ];

    return FloatingActionButton(
      heroTag: 'theme_selector_fab_${UniqueKey()}',
      onPressed: () {
        Get.bottomSheet(
          Container(
            height: 450,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Theme Scheme',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: presets.length,
                    itemBuilder: (context, index) {
                      final scheme = presets[index];
                      final schemeData = FlexColor.schemes[scheme]!;
                      final colors = isDark ? schemeData.dark : schemeData.light;

                      return GestureDetector(
                        onTap: () {
                          ThemeController.to.changeScheme(scheme);
                          Get.back();
                        },
                        child: Obx(() {
                          final isSelected = ThemeController.to.selectedScheme.value == scheme;
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                                  : (isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.02)),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  schemeData.name,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                ),
                                const Spacer(),
                                // Color Group Swatches (Primary, Secondary, Tertiary)
                                _colorSwatch(colors.primary),
                                const SizedBox(width: 8),
                                _colorSwatch(colors.secondary),
                                const SizedBox(width: 8),
                                _colorSwatch(colors.tertiary),
                              ],
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
      backgroundColor: theme.colorScheme.primary,
      child: const Icon(Icons.palette, color: Colors.white),
    );
  }

  Widget _colorSwatch(Color color) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white24, width: 0.5),
      ),
    );
  }
}
