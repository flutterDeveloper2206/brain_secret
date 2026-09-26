import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_constants.dart';
import '../../../core/widgets/glass_app_bar.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/theme_selector_fab.dart';
import '../../../data/models/customer_fingerprint.dart';
import '../controllers/analyze_fingerprints_controller.dart';

class AnalyzeFingerprintsView extends GetView<AnalyzeFingerprintsController> {
  const AnalyzeFingerprintsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: const GlassAppBar(title: 'Analyze Fingerprints'),
      floatingActionButton: const ThemeSelectorFab(
        heroTag: 'analyze_fingerprints_theme_fab',
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
                  child: Obx(() {
                    final _ = controller.fingerprints.length;

                    if (controller.isLoading.value &&
                        controller.fingerprints.isEmpty) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: theme.colorScheme.primary,
                        ),
                      );
                    }

                    if (controller.fingerprints.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: controller.refreshList,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(24),
                          children: [
                            const SizedBox(height: 48),
                            Icon(
                              Icons.fingerprint,
                              size: 40,
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No fingerprints yet',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Add scans from Menu → Add Fingerprint first.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodyMedium?.color
                                    ?.withValues(alpha: 0.65),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final groups = controller.groupedByFingerName;

                    return RefreshIndicator(
                      onRefresh: controller.refreshList,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          isNarrow ? 12 : 24,
                          8,
                          isNarrow ? 12 : 24,
                          88,
                        ),
                        children: [
                          _CompactSummary(
                            fingers: controller.fingerCount,
                            scans: controller.totalScans,
                            analyzed: controller.analyzedCount,
                          ),
                          const SizedBox(height: 12),
                          for (final entry in groups.entries) ...[
                            _FingerCard(
                              fingerName: entry.key,
                              items: entry.value,
                              onEdit: controller.openEdit,
                              onPreview: _previewImage,
                            ),
                            const SizedBox(height: 10),
                          ],
                        ],
                      ),
                    );
                  }),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _previewImage(CustomerFingerprint item) {
    if (item.fingerImageUrl.isEmpty) return;
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: InteractiveViewer(
                child: Image.network(
                  item.fingerImageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            TextButton(onPressed: Get.back, child: const Text('Close')),
          ],
        ),
      ),
    );
  }
}

class _CompactSummary extends StatelessWidget {
  const _CompactSummary({
    required this.fingers,
    required this.scans,
    required this.analyzed,
  });

  final int fingers;
  final int scans;
  final int analyzed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pending = scans - analyzed;

    return GlassContainer(
      elevated: true,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      borderRadius: 14,
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Customer #${AppConstants.defaultFingerprintCustomerId}',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _MiniChip(label: '$fingers fingers'),
          const SizedBox(width: 6),
          _MiniChip(label: '$scans scans'),
          const SizedBox(width: 6),
          _MiniChip(
            label: pending > 0 ? '$pending left' : 'Done',
            highlight: pending > 0,
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label, this.highlight = false});

  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        highlight ? theme.colorScheme.tertiary : theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// One finger = one card, with all passes in a single compact row.
class _FingerCard extends StatelessWidget {
  const _FingerCard({
    required this.fingerName,
    required this.items,
    required this.onEdit,
    required this.onPreview,
  });

  final String fingerName;
  final List<CustomerFingerprint> items;
  final Future<void> Function(CustomerFingerprint) onEdit;
  final void Function(CustomerFingerprint) onPreview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = AnalyzeFingerprintsController.fingerTitle(fingerName);
    final analyzed = items
        .where(
          (f) =>
              f.fingerType != null &&
              f.fingerType!.trim().isNotEmpty,
        )
        .length;
    final complete = analyzed == items.length && items.isNotEmpty;

    return GlassContainer(
      elevated: true,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  fingerName,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '$analyzed/${items.length}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: complete
                      ? Colors.green.shade700
                      : theme.textTheme.bodyMedium?.color
                          ?.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: _PassCell(
                    item: items[i],
                    onEdit: () => onEdit(items[i]),
                    onPreview: () => onPreview(items[i]),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _PassCell extends StatelessWidget {
  const _PassCell({
    required this.item,
    required this.onEdit,
    required this.onPreview,
  });

  final CustomerFingerprint item;
  final VoidCallback onEdit;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasType =
        item.fingerType != null && item.fingerType!.trim().isNotEmpty;
    final pass = AnalyzeFingerprintsController.passLabel(item.fingerImageName);

    return Material(
      color: theme.colorScheme.primary.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onPreview,
        onLongPress: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColoredBox(
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.06),
                        child: item.fingerImageUrl.isEmpty
                            ? Icon(
                                Icons.fingerprint,
                                size: 22,
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.4),
                              )
                            : Image.network(
                                item.fingerImageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.broken_image_outlined,
                                  size: 20,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                      ),
                      Positioned(
                        left: 4,
                        top: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            pass,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                hasType ? item.fingerType! : '—',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: hasType
                      ? null
                      : theme.textTheme.bodyMedium?.color
                          ?.withValues(alpha: 0.4),
                ),
              ),
              Text(
                '${item.fingerValue}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.textTheme.bodyMedium?.color
                      ?.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 2),
              SizedBox(
                height: 28,
                width: double.infinity,
                child: TextButton(
                  onPressed: onEdit,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    foregroundColor: theme.colorScheme.primary,
                    textStyle: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Edit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
