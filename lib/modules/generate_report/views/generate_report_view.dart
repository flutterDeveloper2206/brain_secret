import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_constants.dart';
import '../../../core/widgets/glass_app_bar.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/theme_selector_fab.dart';
import '../controllers/generate_report_controller.dart';

class GenerateReportView extends GetView<GenerateReportController> {
  const GenerateReportView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: GlassAppBar(
        title: 'Generate Report',
        actions: [
          IconButton(
            tooltip: 'Select entity',
            icon: const Icon(Icons.account_tree_outlined),
            onPressed: controller.openEntityPicker,
          ),
        ],
      ),
      floatingActionButton: const ThemeSelectorFab(
        heroTag: 'generate_report_theme_fab',
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
                    maxWidth: isNarrow ? double.infinity : 520,
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isNarrow ? 16 : 24,
                      12,
                      isNarrow ? 16 : 24,
                      24,
                    ),
                    child: Obx(() {
                      final entity = controller.selectedEntity.value;
                      final generating = controller.isGenerating.value;

                      return Column(
                        children: [
                          GlassContainer(
                            elevated: true,
                            borderRadius: 18,
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Icon(
                                  Icons.assessment_outlined,
                                  size: 48,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'Generate all reports',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  entity == null
                                      ? 'Select a customer via the hierarchy icon to continue.'
                                      : 'Reports will be generated for ${controller.entityDisplayName}.',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.textTheme.bodyMedium?.color
                                        ?.withValues(alpha: 0.65),
                                  ),
                                ),
                                if (entity != null) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.person_outline,
                                          color: theme.colorScheme.primary,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                controller.entityDisplayName,
                                                style: theme
                                                    .textTheme.titleSmall
                                                    ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              Text(
                                                'ID ${entity.familyId} · Parent ${entity.customerId}',
                                                style: theme
                                                    .textTheme.labelSmall
                                                    ?.copyWith(
                                                  color: theme.textTheme
                                                      .bodyMedium?.color
                                                      ?.withValues(alpha: 0.55),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 20),
                                if (entity == null)
                                  OutlinedButton.icon(
                                    onPressed: controller.openEntityPicker,
                                    icon: const Icon(
                                      Icons.account_tree_outlined,
                                    ),
                                    label: const Text('Select entity'),
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size.fromHeight(48),
                                    ),
                                  )
                                else
                                  FilledButton.icon(
                                    onPressed: generating
                                        ? null
                                        : controller.generateReport,
                                    icon: generating
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(Icons.play_arrow_rounded),
                                    label: Text(
                                      generating
                                          ? 'Generating…'
                                          : 'Generate Report',
                                    ),
                                    style: FilledButton.styleFrom(
                                      minimumSize: const Size.fromHeight(48),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
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
