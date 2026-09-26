import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/gradient_background.dart';
import '../controllers/device_scan_controller.dart';

class DeviceScanView extends GetView<DeviceScanController> {
  const DeviceScanView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Finger: ${controller.fingerCode}'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => controller.clearScans(),
            tooltip: "Reset Captures",
          )
        ],
      ),
      body: GradientBackground(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLargeScreen = constraints.maxWidth >= 768;

            final widgetsList = [
              // 1. Status / Instructions box
              Obx(() => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.light 
                          ? Colors.grey.shade100 
                          : Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.brightness == Brightness.light 
                            ? Colors.grey.shade300 
                            : Colors.grey.shade700,
                      ),
                    ),
                    child: Text(
                      controller.statusText.value,
                      style: textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                        color: controller.isScanning.value 
                            ? theme.colorScheme.primary 
                            : textTheme.bodyMedium?.color,
                      ),
                    ),
                  )),

              // 2. Settings Checkboxes Wrap
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12.0,
                  runSpacing: 4.0,
                  children: [
                    Obx(() => _buildCheckbox(
                          context: context,
                          label: "Frame",
                          value: controller.isFrame.value,
                          onChanged: (val) => controller.isFrame.value = val ?? false,
                        )),
                    Obx(() => _buildCheckbox(
                          context: context,
                          label: "LFD",
                          value: controller.isLfd.value,
                          onChanged: (val) => controller.isLfd.value = val ?? false,
                        )),
                    Obx(() => _buildCheckbox(
                          context: context,
                          label: "Invert",
                          value: controller.isInvert.value,
                          onChanged: (val) => controller.isInvert.value = val ?? false,
                        )),
                    Obx(() => _buildCheckbox(
                          context: context,
                          label: "Nfiq",
                          value: controller.isNfiq.value,
                          onChanged: (val) => controller.isNfiq.value = val ?? false,
                        )),
                  ],
                ),
              ),

              // 3. Scan Slots Progress Indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Scanning Progress (3 Passes Needed)",
                      style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Obx(() {
                      final scans = controller.capturedScans;
                      final saving = controller.isSaving.value;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(3, (index) {
                          final hasImage = scans.length > index;
                          return Expanded(
                            child: GestureDetector(
                              onTap: hasImage || saving
                                  ? null
                                  : () => controller.fillDummyScan(index),
                              child: Container(
                                height: 85,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  color: hasImage
                                      ? theme.cardColor
                                      : theme.colorScheme.primary
                                          .withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: hasImage
                                        ? Colors.greenAccent
                                        : theme.colorScheme.primary
                                            .withValues(alpha: 0.2),
                                    width: hasImage ? 2 : 1,
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: hasImage
                                    ? Image.memory(
                                        scans[index],
                                        fit: BoxFit.cover,
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.fingerprint,
                                            size: 24,
                                            color: theme.colorScheme.primary
                                                .withValues(alpha: 0.3),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Pass #${index + 1}",
                                            style: textTheme.bodySmall?.copyWith(
                                              fontSize: 10,
                                              color: textTheme.bodySmall?.color
                                                  ?.withValues(alpha: 0.6),
                                            ),
                                          ),
                                          Text(
                                            "Tap dummy",
                                            style: textTheme.bodySmall?.copyWith(
                                              fontSize: 9,
                                              color: theme.colorScheme.primary
                                                  .withValues(alpha: 0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          );
                        }),
                      );
                    }),
                  ],
                ),
              ),

              // 4. Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Obx(() => ElevatedButton(
                              onPressed: controller.isScanning.value || controller.capturedScans.length >= 3
                                  ? null
                                  : () => controller.startScan(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Scan"),
                            )),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Obx(() => ElevatedButton(
                              onPressed: !controller.isScanning.value
                                  ? null
                                  : () => controller.stopScan(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Stop"),
                            )),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Obx(() => ElevatedButton(
                              onPressed: controller.isSaving.value ||
                                      controller.capturedScans.length < 3
                                  ? null
                                  : () => controller.saveScan(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              child: controller.isSaving.value
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text("Save"),
                            )),
                      ),
                    ),
                  ],
                ),
              ),

              // 5. Live Scanner Image Frame
              Center(
                child: Container(
                  width: 250,
                  height: 310,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.light 
                        ? Colors.grey.shade200 
                        : Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Obx(() {
                    final bytes = controller.liveImageBytes.value;
                    if (bytes != null) {
                      return Image.memory(
                        bytes,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                      );
                    }
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fingerprint,
                          size: 80,
                          color: theme.colorScheme.primary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Ready for Live Scanning",
                          style: textTheme.bodyMedium?.copyWith(
                            color: textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),

              // 6. USB Host Mode Checkbox
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Center(
                  child: Obx(() => _buildCheckbox(
                        context: context,
                        label: "USB Host Mode",
                        value: controller.isUsbHost.value,
                        onChanged: (val) => controller.isUsbHost.value = val ?? false,
                      )),
                ),
              ),
            ];

            if (isLargeScreen) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: widgetsList.sublist(0, 4),
                      ),
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widgetsList.sublist(4),
                    ),
                  ),
                ],
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widgetsList,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCheckbox({
    required BuildContext context,
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: theme.colorScheme.primary,
        ),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
