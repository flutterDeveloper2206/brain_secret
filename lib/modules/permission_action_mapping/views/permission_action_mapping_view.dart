import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_constants.dart';
import '../../../core/widgets/app_action_button_bar.dart';
import '../../../core/widgets/glass_app_bar.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/theme_selector_fab.dart';
import '../../../data/models/permission_action_tree_node.dart';
import '../controllers/permission_action_mapping_controller.dart';

class PermissionActionMappingView
    extends GetView<PermissionActionMappingController> {
  const PermissionActionMappingView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = controller.permissionName.isNotEmpty
        ? controller.permissionName
        : 'Permission #${controller.permissionCode}';

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: GlassAppBar(
        title: 'Map Actions',
        onBack: () {
          if (controller.isSaving.value) return;
          Get.back();
        },
      ),
      floatingActionButton: const ThemeSelectorFab(
        heroTag: 'permission_action_mapping_theme_fab',
      ),
      body: GradientBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide =
                  constraints.maxWidth >= AppConstants.breakpointTablet;
              return Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        isWide ? 24 : 16,
                        8,
                        isWide ? 24 : 16,
                        0,
                      ),
                      child: Column(
                        children: [
                          GlassContainer(
                            elevated: true,
                            borderRadius: 20,
                            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary
                                        .withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    Icons.account_tree_rounded,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Obx(() {
                                        final count = controller
                                            .selectedActionCodes.length;
                                        controller.selectionVersion.value;
                                        return Text(
                                          'Code ${controller.permissionCode} · $count selected',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: theme.colorScheme.onSurface
                                                .withValues(alpha: 0.65),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                                Obx(() {
                                  final count =
                                      controller.selectedActionCodes.length;
                                  controller.selectionVersion.value;
                                  return Text(
                                    '$count selected',
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          GlassContainer(
                            elevated: true,
                            borderRadius: 16,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            child: Obx(() {
                              final hasQuery =
                                  controller.searchQuery.value.isNotEmpty;
                              final saving = controller.isSaving.value;
                              return TextField(
                                controller: controller.searchController,
                                enabled: !saving && !controller.isLoading.value,
                                onChanged: controller.onSearchChanged,
                                decoration: InputDecoration(
                                  hintText: 'Search actions…',
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  prefixIcon: Icon(
                                    Icons.search_rounded,
                                    color: theme.colorScheme.primary
                                        .withValues(alpha: 0.8),
                                  ),
                                  suffixIcon: hasQuery
                                      ? IconButton(
                                          onPressed: saving
                                              ? null
                                              : () {
                                                  controller.searchController
                                                      .clear();
                                                  controller
                                                      .onSearchChanged('');
                                                },
                                          icon: const Icon(Icons.close_rounded),
                                        )
                                      : null,
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: GlassContainer(
                              elevated: true,
                              borderRadius: 20,
                              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                              child: Obx(() {
                                if (controller.isLoading.value) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                final saving = controller.isSaving.value;
                                final version =
                                    controller.selectionVersion.value;
                                final query = controller.searchQuery.value;
                                final nodes = controller.visibleTree;
                                if (nodes.isEmpty) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.inbox_outlined,
                                            size: 40,
                                            color: theme.colorScheme.onSurface
                                                .withValues(alpha: 0.35),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            query.isEmpty
                                                ? 'No actions available for this permission.'
                                                : 'No actions match your search.',
                                            textAlign: TextAlign.center,
                                            style: theme.textTheme.bodyLarge
                                                ?.copyWith(
                                              color: theme
                                                  .colorScheme.onSurface
                                                  .withValues(alpha: 0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                return AbsorbPointer(
                                  absorbing: saving,
                                  child: Opacity(
                                    opacity: saving ? 0.55 : 1,
                                    child: ListView(
                                      key: ValueKey('tree-$query-$version'),
                                      padding:
                                          const EdgeInsets.only(bottom: 8),
                                      children: [
                                        _ActionTree(
                                          nodes: nodes,
                                          depth: 0,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _FooterBar(isWide: isWide),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FooterBar extends GetView<PermissionActionMappingController> {
  const _FooterBar({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(isWide ? 24 : 16, 10, isWide ? 24 : 16, 16),
        child: Obx(() {
          final saving = controller.isSaving.value;
          final loading = controller.isLoading.value;
          final canSave = !saving && !loading;
          return AppActionButtonBar(
            children: [
              AppActionButton.outlined(
                label: 'Cancel',
                icon: Icons.close_rounded,
                onPressed: canSave ? () => Get.back() : null,
              ),
              AppActionButton.filled(
                label: saving ? 'Saving…' : 'Save',
                icon: Icons.save_rounded,
                isLoading: saving,
                onPressed: canSave ? controller.saveMapping : null,
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _ActionTree extends StatelessWidget {
  const _ActionTree({required this.nodes, required this.depth});

  final List<PermissionActionTreeNode> nodes;
  final int depth;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final node in nodes) _ActionTreeNode(node: node, depth: depth),
      ],
    );
  }
}

class _ActionTreeNode extends GetView<PermissionActionMappingController> {
  const _ActionTreeNode({required this.node, required this.depth});

  final PermissionActionTreeNode node;
  final int depth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      final version = controller.selectionVersion.value;
      final expanded = node.hasChildren && controller.isExpanded(node);
      final state = controller.checkState(node);
      final checked = switch (state) {
        ActionCheckState.checked => true,
        ActionCheckState.unchecked => false,
        ActionCheckState.indeterminate => null,
      };

      return Column(
        key: ValueKey('action-${node.actionCode}-$version'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => controller.toggleNode(node),
            child: Padding(
              padding: EdgeInsets.only(
                left: 4.0 + depth * 22.0,
                right: 4,
                top: 2,
                bottom: 2,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    height: 36,
                    child: node.hasChildren
                        ? IconButton(
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            tooltip: expanded ? 'Collapse' : 'Expand',
                            onPressed: () => controller.toggleExpanded(node),
                            icon: Icon(
                              expanded
                                  ? Icons.expand_more_rounded
                                  : Icons.chevron_right_rounded,
                              size: 22,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.55),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: Checkbox(
                      tristate: true,
                      value: checked,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      side: BorderSide(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.35),
                        width: 1.4,
                      ),
                      onChanged: (_) => controller.toggleNode(node),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      node.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: node.hasChildren
                            ? FontWeight.w700
                            : FontWeight.w500,
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (expanded) _ActionTree(nodes: node.children, depth: depth + 1),
        ],
      );
    });
  }
}

