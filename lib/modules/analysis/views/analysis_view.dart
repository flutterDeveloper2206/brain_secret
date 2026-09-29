import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_constants.dart';
import '../../../core/widgets/glass_app_bar.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/theme_selector_fab.dart';
import '../controllers/analysis_controller.dart';
import 'widgets/canvas_container.dart';
import 'widgets/detail_list.dart';

class AnalysisView extends GetView<AnalysisController> {
  const AnalysisView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: const GlassAppBar(title: 'Fingerprint Analysis'),
      floatingActionButton: const ThemeSelectorFab(
        heroTag: 'analysis_theme_fab',
      ),
      body: GradientBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow =
                  constraints.maxWidth < AppConstants.breakpointTablet;

              return Padding(
                padding: EdgeInsets.fromLTRB(
                  isNarrow ? 12 : 20,
                  4,
                  isNarrow ? 12 : 20,
                  isNarrow ? 12 : 20,
                ),
                child: Column(
                  children: [
                    _Toolbar(theme: theme),
                    const SizedBox(height: 10),
                    Expanded(
                      child: isNarrow
                          ? const Column(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: CanvasContainer(),
                                ),
                                SizedBox(height: 10),
                                Expanded(
                                  flex: 4,
                                  child: DetailList(),
                                ),
                              ],
                            )
                          : const Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: CanvasContainer(),
                                ),
                                SizedBox(width: 14),
                                Expanded(
                                  flex: 2,
                                  child: DetailList(),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Toolbar extends GetView<AnalysisController> {
  const _Toolbar({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      elevated: true,
      borderRadius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Obx(() {
              final tip = controller.corePoint.value == null
                  ? 'Tap canvas to set core point'
                  : 'Drag from core to count ridges';
              return Text(
                tip,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color
                      ?.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              );
            }),
          ),
          Obx(() {
            final ready = controller.originalImage.value != null &&
                controller.processedImage.value != null;
            if (!ready) return const SizedBox.shrink();
            return _ToolChip(
              icon: controller.showProcessed.value
                  ? Icons.visibility_outlined
                  : Icons.auto_awesome,
              label: controller.showProcessed.value ? 'Original' : 'Cleared',
              onTap: controller.toggleView,
            );
          }),
          const SizedBox(width: 6),
          _ToolChip(
            icon: Icons.center_focus_strong,
            label: 'Reset',
            onTap: controller.resetCore,
            accent: true,
          ),
        ],
      ),
    );
  }
}

class _ToolChip extends StatelessWidget {
  const _ToolChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.accent = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        accent ? theme.colorScheme.primary : theme.colorScheme.onSurface;

    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(99),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
