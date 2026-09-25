import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_constants.dart';
import '../../../core/widgets/glass_app_bar.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/theme_selector_fab.dart';
import '../../../data/models/role_master.dart';
import '../controllers/role_master_controller.dart';

class RoleMasterView extends GetView<RoleMasterController> {
  const RoleMasterView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: GlassAppBar(
        title: 'Role Master',
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => controller.loadRoles(force: true),
            icon: Icon(Icons.refresh_rounded, color: theme.colorScheme.primary),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const ThemeSelectorFab(heroTag: 'role_master_theme_fab'),
          const SizedBox(height: 12),
          Obx(() {
            final formOpen = controller.isFormVisible.value;
            if (formOpen) {
              return FloatingActionButton(
                heroTag: 'roleMasterCloseFab',
                tooltip: 'Close form',
                onPressed: controller.closeForm,
                child: const Icon(Icons.close_rounded),
              );
            }
            return FloatingActionButton.extended(
              heroTag: 'roleMasterCreateFab',
              onPressed: controller.openCreateForm,
              icon: const Icon(Icons.add_rounded),
              label: const Text('New Role'),
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
                  if (!Get.isRegistered<RoleMasterController>() ||
                      controller.isClosed) {
                    return const SizedBox.shrink();
                  }

                  final loading =
                      controller.isLoading.value && controller.roles.isEmpty;

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

class _MobileBody extends GetView<RoleMasterController> {
  const _MobileBody();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final showForm = controller.isFormVisible.value;
      if (showForm) {
        return const SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 120),
          child: _RoleFormPanel(isWide: false),
        );
      }

      final list = controller.filteredRoles;
      final hasData = controller.roles.isNotEmpty;

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
                    onRefresh: () => controller.loadRoles(force: true),
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.only(bottom: 120),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        return _RoleTile(item: list[index]);
                      },
                    ),
                  ),
          ),
        ],
      );
    });
  }
}

class _WideBody extends GetView<RoleMasterController> {
  const _WideBody();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = controller.filteredRoles;
      final hasData = controller.roles.isNotEmpty;
      final showForm = controller.isFormVisible.value;

      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 420,
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
                          onRefresh: () => controller.loadRoles(force: true),
                          child: ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            padding: const EdgeInsets.only(bottom: 120),
                            itemCount: list.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              return _RoleTile(item: list[index]);
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
                ? const SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 120),
                    child: _RoleFormPanel(isWide: true),
                  )
                : const _WidePlaceholder(),
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
    return Row(
      children: [
        Icon(Icons.groups_2_rounded, color: theme.colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Roles',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (count > 0)
          Text(
            '$count',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
      ],
    );
  }
}

class _SearchField extends GetView<RoleMasterController> {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassContainer(
      elevated: true,
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Obx(() {
        final hasQuery = controller.searchQuery.value.isNotEmpty;
        return TextField(
          controller: controller.searchController,
          onChanged: controller.onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search roles…',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            prefixIcon: Icon(
              Icons.search_rounded,
              color: theme.colorScheme.primary.withValues(alpha: 0.8),
            ),
            suffixIcon: hasQuery
                ? IconButton(
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

class _EmptyState extends GetView<RoleMasterController> {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: GlassContainer(
        elevated: true,
        borderRadius: 22,
        padding: const EdgeInsets.fromLTRB(28, 30, 28, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.groups_outlined,
              size: 42,
              color: theme.colorScheme.primary.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 12),
            Text(
              'No roles yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Create a role, then assign permissions.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: controller.openCreateForm,
              icon: const Icon(Icons.add_rounded),
              label: const Text('New Role'),
            ),
          ],
        ),
      ),
    );
  }
}

class _WidePlaceholder extends GetView<RoleMasterController> {
  const _WidePlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: GlassContainer(
        elevated: true,
        borderRadius: 22,
        padding: const EdgeInsets.fromLTRB(32, 36, 32, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.manage_accounts_outlined,
              size: 48,
              color: theme.colorScheme.primary.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 14),
            Text(
              'Select a role',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Pick a role from the list to edit,\nor create a new one.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleTile extends GetView<RoleMasterController> {
  const _RoleTile({required this.item});

  final RoleMaster item;

  String get _initials {
    final parts = item.roleName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'R';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onSurface = theme.colorScheme.onSurface;

    return Obx(() {
      final selected = controller.highlightedCode.value == item.roleCode;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => controller.editRole(item),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            decoration: BoxDecoration(
              color: selected
                  ? primary.withValues(alpha: 0.1)
                  : theme.colorScheme.surface.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(16),
              border: Border(
                left: BorderSide(
                  color: selected ? primary : Colors.transparent,
                  width: 3.5,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: primary.withValues(alpha: 0.14),
                      child: Text(
                        _initials,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.roleName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.roleDescription.isNotEmpty
                                ? item.roleDescription
                                : 'Role #${item.roleCode}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: onSurface.withValues(alpha: 0.55),
                            ),
                          ),
                          const SizedBox(height: 6),
                          _DotStatus(
                            active: item.isActive,
                            blocked: item.isBlock,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: () =>
                            controller.openPermissionMapping(item),
                        icon: const Icon(Icons.link_rounded, size: 18),
                        label: const Text('Assign permissions'),
                        style: FilledButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => controller.editRole(item),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _DotStatus extends StatelessWidget {
  const _DotStatus({required this.active, required this.blocked});

  final bool active;
  final bool blocked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StatusDot(
          color: active ? Colors.green : theme.colorScheme.onSurface,
          label: active ? 'Active' : 'Off',
        ),
        if (blocked) ...[
          const SizedBox(width: 8),
          _StatusDot(color: theme.colorScheme.error, label: 'Blocked'),
        ],
      ],
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _RoleFormPanel extends GetView<RoleMasterController> {
  const _RoleFormPanel({required this.isWide});

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
                    Icons.manage_accounts_rounded,
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
                          editing ? 'Edit Role' : 'New Role',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          editing
                              ? 'Update role details'
                              : 'Define a role, then assign permissions',
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
            Text.rich(
              TextSpan(
                text: 'Role Name',
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
                hintText: 'e.g. Super Administrator',
                filled: true,
                fillColor: theme.colorScheme.surface.withValues(alpha: 0.55),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Role name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            if (isWide)
              Row(
                children: [
                  Expanded(child: _ToggleCard.active()),
                  const SizedBox(width: 12),
                  Expanded(child: _ToggleCard.block()),
                ],
              )
            else ...[
              _ToggleCard.active(),
              const SizedBox(height: 12),
              _ToggleCard.block(),
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
                hintText: 'What this role is for…',
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
                    onPressed: saving ? null : controller.saveRole,
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

enum _ToggleKind { active, block }

class _ToggleCard extends GetView<RoleMasterController> {
  const _ToggleCard._({required this.kind});

  factory _ToggleCard.active() => const _ToggleCard._(kind: _ToggleKind.active);
  factory _ToggleCard.block() => const _ToggleCard._(kind: _ToggleKind.block);

  final _ToggleKind kind;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final value = kind == _ToggleKind.active
          ? controller.isActive.value
          : controller.isBlock.value;
      final title = kind == _ToggleKind.active ? 'Active' : 'Blocked';
      final subtitle = kind == _ToggleKind.active
          ? (value ? 'Role can be assigned' : 'Role is inactive')
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
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: value,
              onChanged: (next) {
                if (kind == _ToggleKind.active) {
                  controller.setActive(next);
                } else {
                  controller.setBlocked(next);
                }
              },
            ),
          ],
        ),
      );
    });
  }
}
