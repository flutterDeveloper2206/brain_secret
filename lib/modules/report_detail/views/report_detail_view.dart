import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/values/app_constants.dart';
import '../../../core/widgets/glass_app_bar.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/theme_selector_fab.dart';
import '../controllers/report_detail_controller.dart';

class ReportDetailView extends GetView<ReportDetailController> {
  const ReportDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final report = controller.report;
    if (report == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final entries = controller.displayEntries;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: GlassAppBar(title: report.reportName),
      floatingActionButton: const ThemeSelectorFab(
        heroTag: 'report_detail_theme_fab',
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
                  child: ListView(
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
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              report.reportName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              report.reportDatetime,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodyMedium?.color
                                    ?.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Customer #${report.customerId} · Parent #${report.parentId}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.textTheme.bodyMedium?.color
                                    ?.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (entries.isEmpty)
                        GlassContainer(
                          elevated: true,
                          borderRadius: 14,
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'No result fields in this report.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withValues(alpha: 0.6),
                            ),
                          ),
                        )
                      else
                        GlassContainer(
                          elevated: true,
                          borderRadius: 16,
                          padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                          child: Column(
                            children: [
                              for (var i = 0; i < entries.length; i++) ...[
                                if (i > 0)
                                  Divider(
                                    height: 1,
                                    color: theme.dividerColor
                                        .withValues(alpha: 0.25),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          _prettyKey(entries[i].key),
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: theme
                                                .textTheme.bodyMedium?.color
                                                ?.withValues(alpha: 0.65),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          entries[i].value,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  static String _prettyKey(String key) => key.replaceAll('_', ' ');
}
