import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/glass_container.dart';
import '../../../../data/models/line_data.dart';
import '../../../analyze_fingerprints/controllers/analyze_fingerprints_controller.dart';
import '../../controllers/analysis_controller.dart';

class DetailList extends GetView<AnalysisController> {
  const DetailList({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassContainer(
      elevated: true,
      borderRadius: 18,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Obx(() {
                    final item = controller.editingFingerprint.value;
                    final title = item == null
                        ? 'Analysis'
                        : AnalyzeFingerprintsController.fingerTitle(
                            item.fingerName,
                          );
                    final subtitle = item?.fingerImageName;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle != null && subtitle.isNotEmpty)
                          Text(
                            subtitle,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withValues(alpha: 0.55),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    );
                  }),
                ),
                Obx(() {
                  if (controller.lines.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!controller.isFingerprintEditMode)
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          tooltip: 'Sync data to API',
                          onPressed: controller.syncAnalysisData,
                          icon: Icon(
                            Icons.cloud_upload_outlined,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Clear lines',
                        onPressed: controller.clearLines,
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Obx(() {
              final lines = controller.lines;
              final editMode = controller.isFingerprintEditMode;

              return ListView(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                children: [
                  if (lines.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        controller.corePoint.value == null
                            ? 'Tap the image to set the core point'
                            : 'Drag from the core to count ridges',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.5),
                        ),
                      ),
                    )
                  else
                    for (var i = 0; i < lines.length; i++)
                      _LineTile(index: i, line: lines[i]),
                  if (editMode) ...[
                    const SizedBox(height: 8),
                    _FingerprintSaveForm(controller: controller),
                  ],
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _LineTile extends StatelessWidget {
  const _LineTile({required this.index, required this.line});

  final int index;
  final LineData line;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = line.color;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 28,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Line #${index + 1}',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: line.ridgeCount != null
                ? Container(
                    key: ValueKey(line.ridgeCount),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: color.withValues(alpha: 0.45)),
                    ),
                    child: Text(
                      '${line.ridgeCount} ridges',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  )
                : SizedBox(
                    key: ValueKey('loading_$index'),
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FingerprintSaveForm extends StatelessWidget {
  const _FingerprintSaveForm({required this.controller});

  final AnalysisController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Save analysis',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: controller.typeController,
                decoration: InputDecoration(
                  labelText: 'Type',
                  hintText: 'e.g. ws',
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller.valueController,
                decoration: InputDecoration(
                  labelText: 'Value',
                  hintText: 'e.g. 10',
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          final updating = controller.isUpdating.value;
          return FilledButton(
            onPressed: updating ? null : controller.saveAnalysis,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: updating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Done'),
          );
        }),
      ],
    );
  }
}
