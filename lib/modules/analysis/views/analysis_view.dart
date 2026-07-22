import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      appBar: AppBar(
        title: const Text('Fingerprint Analysis'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() {
            if (controller.originalImage.value != null &&
                controller.processedImage.value != null) {
              return TextButton.icon(
                onPressed: controller.toggleView,
                icon: Icon(
                  controller.showProcessed.value
                      ? Icons.visibility
                      : Icons.auto_awesome,
                ),
                label: Text(
                  controller.showProcessed.value
                      ? 'Show Original'
                      : 'Show Cleared',
                ),
                style: TextButton.styleFrom(
                  foregroundColor: theme.brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.black87,
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: controller.resetCore,
            icon: const Icon(Icons.center_focus_strong, size: 18),
            label: const Text('Reset Core'),
            style: TextButton.styleFrom(foregroundColor: Colors.blue),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GradientBackground(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 768;

            if (isNarrow) {
              // Mobile portrait layout (Vertical stacked layout)
              return const Column(
                children: [
                  Expanded(
                    flex: 4,
                    child: CanvasContainer(),
                  ),
                  Expanded(
                    flex: 2,
                    child: DetailList(),
                  ),
                ],
              );
            } else {
              // Web / Tablet landscape layout (Horizontal side-by-side layout)
              return const Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: CanvasContainer(),
                  ),
                  VerticalDivider(width: 1, color: Colors.white10),
                  Expanded(
                    flex: 2,
                    child: DetailList(),
                  ),
                ],
              );
            }
          },
        ),
      ),
      floatingActionButton: const ThemeSelectorFab(),
    );
  }
}
