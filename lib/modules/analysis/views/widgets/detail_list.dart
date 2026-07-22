import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/analysis_controller.dart';

class DetailList extends GetView<AnalysisController> {
  const DetailList({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 20, left: 24, right: 24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Detailed Analysis',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Obx(() {
                if (controller.lines.isEmpty) return const SizedBox.shrink();
                return Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.cloud_upload_outlined,
                        color: Colors.blueAccent,
                      ),
                      tooltip: 'Sync data to API',
                      onPressed: controller.syncAnalysisData,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                      tooltip: 'Clear lines',
                      onPressed: controller.clearLines,
                    ),
                  ],
                );
              }),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Obx(() {
              final lines = controller.lines;

              if (lines.isEmpty) {
                return Center(
                  child: Text(
                    controller.corePoint.value == null
                        ? 'Tap anywhere to set the Core Point'
                        : 'Drag from the core to count ridges',
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                    ),
                  ),
                );
              }

              return ListView.builder(
                itemCount: lines.length,
                padding: const EdgeInsets.only(bottom: 20),
                itemBuilder: (context, index) {
                  final line = lines[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 4,
                        height: 30,
                        decoration: BoxDecoration(
                          color: line.color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      title: Text(
                        'Line #${index + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: line.ridgeCount != null
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: line.color.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: line.color.withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Text(
                                  '${line.ridgeCount} Ridges',
                                  style: TextStyle(
                                    color: line.color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
