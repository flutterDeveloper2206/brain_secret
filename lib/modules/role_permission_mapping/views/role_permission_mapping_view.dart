import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_constants.dart';
import '../../../core/widgets/app_action_button_bar.dart';
import '../../../core/widgets/glass_app_bar.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/theme_selector_fab.dart';
import '../../../data/models/permission_master.dart';
import '../controllers/role_permission_mapping_controller.dart';

class RolePermissionMappingView
    extends GetView<RolePermissionMappingController> {
  const RolePermissionMappingView({super.key});

  @override
  Widget build(BuildContext context) {
    final roleTitle = controller.roleName.isNotEmpty
        ? controller.roleName
        : 'Role #${controller.roleCode}';

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: GlassAppBar(
        title: roleTitle,
        onBack: () {
          if (controller.isSaving.value) return;
          Get.back();
        },
      ),
      floatingActionButton: const ThemeSelectorFab(
        heroTag: 'role_permission_mapping_theme_fab_v2',
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
                        isWide ? 28 : 16,
                        8,
                        isWide ? 28 : 16,
                        0,
                      ),
                      child: isWide
                          ? const Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(flex: 3, child: _MainColumn()),
                                SizedBox(width: 18),
                                SizedBox(
                                  width: 320,
                                  child: _AssignedSidePanel(),
                                ),
                              ],
                            )
                          : const _MainColumn(),
                    ),
                  ),
                  _Footer(isWide: isWide),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MainColumn extends StatelessWidget {
  const _MainColumn();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SearchBar(),
        SizedBox(height: 8),
        _QuickActions(),
        SizedBox(height: 12),
        _AssignedChipsSection(),
        SizedBox(height: 8),
        Expanded(child: _AvailableList()),
      ],
    );
  }
}

class _AssignedChipsSection
    extends GetView<RolePermissionMappingController> {
  const _AssignedChipsSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Obx(() {
      controller.selectionVersion.value;
      final selectedCodes = controller.selectedPermissionCodes.toSet();
      final assigned = controller.permissions
          .where((p) => selectedCodes.contains(p.permissionCode))
          .toList();

      if (assigned.isEmpty) {
        return GlassContainer(
          borderRadius: 16,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Tap a permission below to assign it to this role.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Assigned',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: primary,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: assigned.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = assigned[index];
                return InputChip(
                  label: Text(item.permissionName),
                  selected: true,
                  showCheckmark: false,
                  onDeleted: controller.isSaving.value
                      ? null
                      : () => controller.togglePermission(item),
                  deleteIconColor: primary,
                  selectedColor: primary.withValues(alpha: 0.16),
                  labelStyle: theme.textTheme.labelMedium?.copyWith(
                    color: primary,
                    fontWeight: FontWeight.w700,
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

class _SearchBar extends GetView<RolePermissionMappingController> {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassContainer(
      elevated: true,
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Obx(() {
        final hasQuery = controller.searchQuery.value.isNotEmpty;
        final busy = controller.isSaving.value || controller.isLoading.value;
        return TextField(
          controller: controller.searchController,
          enabled: !busy,
          onChanged: controller.onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Find a permission…',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            prefixIcon: Icon(
              Icons.search_rounded,
              color: theme.colorScheme.primary.withValues(alpha: 0.85),
            ),
            suffixIcon: hasQuery
                ? IconButton(
                    onPressed: busy
                        ? null
                        : () {
                            controller.searchController.clear();
                            controller.onSearchChanged('');
                          },
                    icon: const Icon(Icons.close_rounded),
                  )
                : null,
          ),
        );
      }),
    );
  }
}

class _QuickActions extends GetView<RolePermissionMappingController> {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final busy = controller.isSaving.value || controller.isLoading.value;
      final allSelected = controller.isAllVisibleSelected;
      final noneSelected = controller.selectedPermissionCodes.isEmpty;

      return Row(
        children: [
          Expanded(
            child: allSelected
                ? FilledButton.icon(
                    onPressed: busy ? null : controller.selectAllVisible,
                    icon: const Icon(Icons.done_all_rounded, size: 18),
                    label: const Text('Select all'),
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                    ),
                  )
                : OutlinedButton.icon(
                    onPressed: busy ? null : controller.selectAllVisible,
                    icon: const Icon(Icons.done_all_rounded, size: 18),
                    label: const Text('Select all'),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: noneSelected
                ? FilledButton.tonalIcon(
                    onPressed: busy ? null : controller.clearSelection,
                    icon: const Icon(Icons.remove_done_rounded, size: 18),
                    label: const Text('Clear all'),
                  )
                : OutlinedButton.icon(
                    onPressed: busy ? null : controller.clearSelection,
                    icon: const Icon(Icons.remove_done_rounded, size: 18),
                    label: const Text('Clear all'),
                  ),
          ),
        ],
      );
    });
  }
}

class _AvailableList extends GetView<RolePermissionMappingController> {
  const _AvailableList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'All permissions',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(
          child: GlassContainer(
            elevated: true,
            borderRadius: 20,
            padding: EdgeInsets.zero,
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final saving = controller.isSaving.value;
              final version = controller.selectionVersion.value;
              final items = controller.visiblePermissions;

              if (items.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 36,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.35),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          controller.searchQuery.value.isEmpty
                              ? 'No permissions to show.'
                              : 'No match for your search.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.65),
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
                  child: ListView.builder(
                    key: ValueKey('role-perm-list-$version'),
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return _FriendlyPermissionRow(item: items[index]);
                    },
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _FriendlyPermissionRow
    extends GetView<RolePermissionMappingController> {
  const _FriendlyPermissionRow({required this.item});

  final PermissionMaster item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onSurface = theme.colorScheme.onSurface;

    return Obx(() {
      controller.selectionVersion.value;
      final on = controller.isSelected(item.permissionCode);

      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => controller.togglePermission(item),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
              decoration: BoxDecoration(
                color: on
                    ? primary.withValues(alpha: 0.1)
                    : onSurface.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: on
                          ? primary
                          : onSurface.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      on ? Icons.check_rounded : Icons.add_rounded,
                      size: 20,
                      color: on
                          ? theme.colorScheme.onPrimary
                          : onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.permissionName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (item.permissionDescription.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            item.permissionDescription,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: onSurface.withValues(alpha: 0.55),
                              height: 1.25,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    on ? 'On' : 'Off',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: on
                          ? primary
                          : onSurface.withValues(alpha: 0.4),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _AssignedSidePanel extends GetView<RolePermissionMappingController> {
  const _AssignedSidePanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassContainer(
      elevated: true,
      borderRadius: 22,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Obx(() {
        controller.selectionVersion.value;
        final selectedCodes = controller.selectedPermissionCodes.toSet();
        final assigned = controller.permissions
            .where((p) => selectedCodes.contains(p.permissionCode))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assigned now',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              assigned.isEmpty
                  ? 'Nothing assigned'
                  : '${assigned.length} permission(s)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: assigned.isEmpty
                  ? Center(
                      child: Text(
                        'Select from the list',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.45),
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: assigned.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = assigned[index];
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            item.permissionName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          trailing: IconButton(
                            tooltip: 'Remove',
                            onPressed: () =>
                                controller.togglePermission(item),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }
}

class _Footer extends GetView<RolePermissionMappingController> {
  const _Footer({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(isWide ? 28 : 16, 10, isWide ? 28 : 16, 16),
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
                label: saving ? 'Saving…' : 'Save assignment',
                icon: Icons.check_rounded,
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
