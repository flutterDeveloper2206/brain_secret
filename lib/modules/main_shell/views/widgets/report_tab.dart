import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/values/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../../../data/models/customer_report.dart';
import '../../controllers/report_tab_controller.dart';

class ReportTab extends GetView<ReportTabController> {
  const ReportTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: GlassAppBar(
        title: 'Report',
        showBack: false,
        actions: [
          IconButton(
            tooltip: 'Select entity',
            icon: const Icon(Icons.account_tree_outlined),
            onPressed: controller.openEntityPicker,
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: controller.refreshList,
          ),
        ],
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
                    controller.reports.length;
                    controller.selectedEntity.value;

                    if (controller.isLoading.value &&
                        controller.reports.isEmpty) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: theme.colorScheme.primary,
                        ),
                      );
                    }

                    if (!controller.hasSelection) {
                      return _EmptySelectEntity(
                        theme: theme,
                        onSelect: controller.openEntityPicker,
                      );
                    }

                    if (controller.reports.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: controller.refreshList,
                        child: CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            ContainedSliver(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.description_outlined,
                                        size: 48,
                                        color: theme.colorScheme.primary
                                            .withValues(alpha: 0.4),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No reports yet',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'No generated reports for ${controller.selectionLabel}.',
                                        textAlign: TextAlign.center,
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: theme.textTheme.bodyMedium
                                              ?.color
                                              ?.withValues(alpha: 0.65),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final groups = controller.groupedByReportName;

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
                          GlassContainer(
                            elevated: true,
                            borderRadius: 14,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    controller.selectionLabel,
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '${controller.reports.length} reports',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.textTheme.bodyMedium?.color
                                        ?.withValues(alpha: 0.55),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          for (final entry in groups.entries) ...[
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 4,
                                bottom: 8,
                                top: 4,
                              ),
                              child: Text(
                                entry.key,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            for (final report in entry.value) ...[
                              _ReportTile(
                                report: report,
                                onTap: () =>
                                    controller.openReportDetail(report),
                              ),
                              const SizedBox(height: 8),
                            ],
                            const SizedBox(height: 6),
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
}

/// Fills viewport so pull-to-refresh empty states can center content.
class ContainedSliver extends StatelessWidget {
  const ContainedSliver({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: child,
    );
  }
}

class _EmptySelectEntity extends StatelessWidget {
  const _EmptySelectEntity({
    required this.theme,
    required this.onSelect,
  });

  final ThemeData theme;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 48),
        Icon(
          Icons.account_tree_outlined,
          size: 48,
          color: theme.colorScheme.primary.withValues(alpha: 0.4),
        ),
        const SizedBox(height: 12),
        Text(
          'Select an entity',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Tap the hierarchy icon to choose company → franchise → customer → family.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.65),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: FilledButton.icon(
            onPressed: onSelect,
            icon: const Icon(Icons.account_tree_outlined),
            label: const Text('Select entity'),
          ),
        ),
      ],
    );
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({
    required this.report,
    required this.onTap,
  });

  final CustomerReport report;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassContainer(
      elevated: true,
      borderRadius: 14,
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.description_outlined,
                    color: theme.colorScheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.reportName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        report.reportDatetime,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.55),
                        ),
                      ),
                      if (report.regenerateDatetime != null &&
                          report.regenerateDatetime!.isNotEmpty)
                        Text(
                          'Regen: ${report.regenerateDatetime}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.tertiary,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.primary.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
