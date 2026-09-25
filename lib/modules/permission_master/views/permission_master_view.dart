import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_constants.dart';
import '../../../core/widgets/glass_app_bar.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/theme_selector_fab.dart';
import '../../../data/models/permission_master.dart';
import '../controllers/permission_master_controller.dart';

class PermissionMasterView extends GetView<PermissionMasterController> {
  const PermissionMasterView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: GlassAppBar(
        title: 'Permissions',
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => controller.loadPermissions(force: true),
            icon: Icon(Icons.refresh_rounded, color: theme.colorScheme.primary),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const ThemeSelectorFab(heroTag: 'permission_master_theme_fab'),
          const SizedBox(height: 12),
          Obx(() {
            final formOpen = controller.isFormVisible.value;
            if (formOpen) {
              return FloatingActionButton(
                heroTag: 'permissionMasterCloseFab',
                tooltip: 'Close form',
                onPressed: controller.closeForm,
                child: const Icon(Icons.close_rounded),
              );
            }
            return FloatingActionButton.extended(
              heroTag: 'permissionMasterCreateFab',
              onPressed: controller.openCreateForm,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add'),
            );
          }),
        ],
      ),
      body: GradientBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow =
                  constraints.maxWidth < AppConstants.breakpointTablet;
              final horizontal = isNarrow ? 16.0 : 24.0;

              return Padding(
                padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 0),
                child: Obx(() {
                  if (!Get.isRegistered<PermissionMasterController>() ||
                      controller.isClosed) {
                    return const SizedBox.shrink();
                  }

                  final loading = controller.isLoading.value &&
                      controller.permissions.isEmpty;

                  if (loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (isNarrow) {
                    return const _MobileBody();
                  }
                  return const _WideBody();
                }),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MobileBody extends GetView<PermissionMasterController> {
  const _MobileBody();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final showForm = controller.isFormVisible.value;
      if (showForm) {
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 120),
                child: _PermissionFormPanel(isWide: false),
              ),
            ),
          ],
        );
      }

      final list = controller.filteredPermissions;
      final hasData = controller.permissions.isNotEmpty;

      return Column(
        children: [
          _ListHeader(count: hasData ? list.length : 0),
          if (hasData) ...[
            const SizedBox(height: 12),
            const _SearchField(),
            const SizedBox(height: 14),
          ] else
            const SizedBox(height: 14),
          Expanded(
            child: list.isEmpty
                ? const _EmptyState()
                : RefreshIndicator(
                    onRefresh: () => controller.loadPermissions(force: true),
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.only(bottom: 120),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _PermissionCard(item: list[index]);
                      },
                    ),
                  ),
          ),
        ],
      );
    });
  }
}

class _WideBody extends GetView<PermissionMasterController> {
  const _WideBody();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = controller.filteredPermissions;
      final hasData = controller.permissions.isNotEmpty;
      final showForm = controller.isFormVisible.value;

      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 400,
            child: Column(
              children: [
                _ListHeader(count: hasData ? list.length : 0),
                if (hasData) ...[
                  const SizedBox(height: 12),
                  const _SearchField(),
                  const SizedBox(height: 14),
                ] else
                  const SizedBox(height: 14),
                Expanded(
                  child: list.isEmpty
                      ? const _EmptyState()
                      : RefreshIndicator(
                          onRefresh: () =>
                              controller.loadPermissions(force: true),
                          child: ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            padding: const EdgeInsets.only(bottom: 120),
                            itemCount: list.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              return _PermissionCard(item: list[index]);
                            },
                          ),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: showForm
                ? SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 120),
                    child: _PermissionFormPanel(isWide: true),
                  )
                : const _FormPlaceholder(),
          ),
        ],
      );
    });
  }
}

class _ListHeader extends StatelessWidget {
  const _ListHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassContainer(
      elevated: true,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      borderRadius: 20,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.admin_panel_settings_rounded,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Permission List',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  count == 0
                      ? 'Manage roles and access rights'
                      : '$count permission${count == 1 ? '' : 's'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends GetView<PermissionMasterController> {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassContainer(
      elevated: true,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      borderRadius: 16,
      child: Obx(() {
        final hasQuery = controller.searchQuery.value.isNotEmpty;
        return TextField(
          controller: controller.searchController,
          onChanged: controller.onSearchChanged,
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Search by name, code, or description…',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            prefixIcon: Icon(
              Icons.search_rounded,
              color: theme.colorScheme.primary.withValues(alpha: 0.8),
            ),
            suffixIcon: hasQuery
                ? IconButton(
                    tooltip: 'Clear',
                    onPressed: controller.clearSearch,
                    icon: const Icon(Icons.close_rounded),
                  )
                : null,
          ),
        );
      }),
    );
  }
}

class _EmptyState extends GetView<PermissionMasterController> {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searching = controller.searchQuery.value.trim().isNotEmpty;

    return Center(
      child: GlassContainer(
        elevated: true,
        padding: const EdgeInsets.fromLTRB(28, 30, 28, 28),
        borderRadius: 22,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                searching
                    ? Icons.search_off_rounded
                    : Icons.shield_outlined,
                size: 30,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              searching ? 'No matches' : 'No permissions yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              searching
                  ? 'Try a different search term.'
                  : 'Tap Add to create your first permission role.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
            if (!searching) ...[
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: controller.openCreateForm,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add permission'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FormPlaceholder extends GetView<PermissionMasterController> {
  const _FormPlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: GlassContainer(
        elevated: true,
        padding: const EdgeInsets.fromLTRB(32, 36, 32, 32),
        borderRadius: 22,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.edit_note_rounded,
                size: 34,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Create or edit a permission',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a permission from the list to edit,\nor tap Add to create a new one.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: controller.openCreateForm,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add permission'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionCard extends GetView<PermissionMasterController> {
  const _PermissionCard({required this.item});

  final PermissionMaster item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final primary = theme.colorScheme.primary;

    return Obx(() {
      final selected = controller.highlightedCode.value == item.permissionCode;

      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: selected
              ? Border.all(
                  color: primary.withValues(alpha: 0.55),
                  width: 1.4,
                )
              : null,
        ),
        child: GlassContainer(
          elevated: true,
          borderRadius: 20,
          padding: EdgeInsets.zero,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => controller.editPermission(item),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: 4,
                      decoration: BoxDecoration(
                        color: selected ? primary : Colors.transparent,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(20),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: primary.withValues(
                                      alpha: selected ? 0.18 : 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    '${item.permissionCode}',
                                    style:
                                        theme.textTheme.titleSmall?.copyWith(
                                      color: primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.permissionName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.2,
                                          color: onSurface,
                                        ),
                                      ),
                                      if (item.permissionDescription
                                          .isNotEmpty) ...[
                                        const SizedBox(height: 3),
                                        Text(
                                          item.permissionDescription,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: onSurface.withValues(
                                              alpha: 0.58,
                                            ),
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 10),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 6,
                                        children: [
                                          _StatusPill(
                                            label: item.isActive
                                                ? 'Active'
                                                : 'Inactive',
                                            tone: item.isActive
                                                ? Colors.green
                                                : onSurface.withValues(
                                                    alpha: 0.5,
                                                  ),
                                          ),
                                          if (item.isBlock)
                                            _StatusPill(
                                              label: 'Blocked',
                                              tone: theme.colorScheme.error,
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      tooltip: 'Map actions',
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () =>
                                          controller.openActionMapping(item),
                                      icon: Icon(
                                        Icons.account_tree_outlined,
                                        color: primary,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Edit',
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () =>
                                          controller.editPermission(item),
                                      icon: Icon(
                                        Icons.edit_outlined,
                                        color: primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.tone,
  });

  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: tone,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PermissionFormPanel extends GetView<PermissionMasterController> {
  const _PermissionFormPanel({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassContainer(
      elevated: true,
      borderRadius: 22,
      padding: EdgeInsets.fromLTRB(isWide ? 24 : 18, 20, isWide ? 24 : 18, 20),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.security_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() {
                    final editing = controller.editingCode.value != null;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          editing ? 'Edit Permission' : 'New Permission',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          editing
                              ? 'Update name, status, and description'
                              : 'Fill in the details and save',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
                if (!isWide)
                  IconButton(
                    tooltip: 'Back to list',
                    onPressed: controller.closeForm,
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            _NameField(),
            const SizedBox(height: 16),
            if (isWide)
              Row(
                children: [
                  Expanded(child: _StatusTile.active()),
                  const SizedBox(width: 12),
                  Expanded(child: _StatusTile.block()),
                ],
              )
            else ...[
              _StatusTile.active(),
              const SizedBox(height: 12),
              _StatusTile.block(),
            ],
            const SizedBox(height: 16),
            Text(
              'Description',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: controller.descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'What this permission allows…',
                filled: true,
                fillColor: theme.colorScheme.surface.withValues(alpha: 0.55),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),
            Obx(() {
              final saving = controller.isSaving.value;
              final editing = controller.editingCode.value != null;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: saving ? null : controller.savePermission,
                    icon: saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_rounded),
                    label: Text(editing ? 'Update' : 'Save'),
                  ),
                  OutlinedButton.icon(
                    onPressed: saving ? null : controller.resetForm,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Reset'),
                  ),
                  TextButton(
                    onPressed: saving ? null : controller.closeForm,
                    child: const Text('Cancel'),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _NameField extends GetView<PermissionMasterController> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: 'Permission Name',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            children: [
              TextSpan(
                text: ' *',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.nameController,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: 'e.g. Staff Permission',
            filled: true,
            fillColor: theme.colorScheme.surface.withValues(alpha: 0.55),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Permission name is required';
            }
            return null;
          },
        ),
      ],
    );
  }
}

class _StatusTile extends GetView<PermissionMasterController> {
  const _StatusTile._({required this.kind});

  factory _StatusTile.active() => const _StatusTile._(kind: _StatusKind.active);
  factory _StatusTile.block() => const _StatusTile._(kind: _StatusKind.block);

  final _StatusKind kind;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final value = kind == _StatusKind.active
          ? controller.isActive.value
          : controller.isBlock.value;
      final title = kind == _StatusKind.active ? 'Active' : 'Blocked';
      final subtitle = kind == _StatusKind.active
          ? (value ? 'Permission can be assigned' : 'Hidden from assignment')
          : (value ? 'Access is blocked' : 'Access is allowed');

      return GlassContainer(
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: value,
              onChanged: (v) {
                if (kind == _StatusKind.active) {
                  controller.setActive(v);
                } else {
                  controller.setBlocked(v);
                }
              },
            ),
          ],
        ),
      );
    });
  }
}

enum _StatusKind { active, block }
