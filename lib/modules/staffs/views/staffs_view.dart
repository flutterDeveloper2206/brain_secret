import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_constants.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/glass_app_bar.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/theme_selector_fab.dart';
import '../../../data/models/staff.dart';
import '../controllers/staffs_controller.dart';

class StaffsView extends GetView<StaffsController> {
  const StaffsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: GlassAppBar(
        title: 'Staff / Employees',
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: controller.loadStaff,
            icon: Icon(Icons.refresh_rounded, color: theme.colorScheme.primary),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const ThemeSelectorFab(heroTag: 'staffs_theme_fab'),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'createStaffFab',
            onPressed: controller.openCreateStaff,
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: const Text('Create'),
          ),
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
                  if (!Get.isRegistered<StaffsController>() ||
                      controller.isClosed) {
                    return const SizedBox.shrink();
                  }

                  final list = controller.filteredStaff;
                  final loading =
                      controller.isLoading.value &&
                      controller.staffList.isEmpty;

                  if (loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (isNarrow) {
                    return _MobileStaffsBody(theme: theme, staffList: list);
                  }

                  return _WideStaffsBody(theme: theme, staffList: list);
                }),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MobileStaffsBody extends GetView<StaffsController> {
  const _MobileStaffsBody({required this.theme, required this.staffList});

  final ThemeData theme;
  final List<Staff> staffList;

  @override
  Widget build(BuildContext context) {
    final hasData = controller.staffList.isNotEmpty;

    return Column(
      children: [
        _StaffsHeader(theme: theme, count: hasData ? staffList.length : 0),
        if (hasData) ...[
          const SizedBox(height: 12),
          _SearchField(theme: theme),
          const SizedBox(height: 14),
        ] else
          const SizedBox(height: 14),
        Expanded(
          child: staffList.isEmpty
              ? _EmptyState(theme: theme)
              : RefreshIndicator(
                  onRefresh: controller.loadStaff,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.only(bottom: 120),
                    itemCount: staffList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final staff = staffList[index];
                      return _StaffListCard(
                        staff: staff,
                        selected: false,
                        onTap: () => controller.openStaffDetails(staff),
                        onDelete: () => controller.confirmDelete(staff),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

class _WideStaffsBody extends GetView<StaffsController> {
  const _WideStaffsBody({required this.theme, required this.staffList});

  final ThemeData theme;
  final List<Staff> staffList;

  @override
  Widget build(BuildContext context) {
    final hasData = controller.staffList.isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 380,
          child: Column(
            children: [
              _StaffsHeader(
                theme: theme,
                count: hasData ? staffList.length : 0,
              ),
              if (hasData) ...[
                const SizedBox(height: 12),
                _SearchField(theme: theme),
                const SizedBox(height: 14),
              ] else
                const SizedBox(height: 14),
              Expanded(
                child: staffList.isEmpty
                    ? _EmptyState(theme: theme)
                    : RefreshIndicator(
                        onRefresh: controller.loadStaff,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: const EdgeInsets.only(bottom: 120),
                          itemCount: staffList.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final staff = staffList[index];
                            return Obx(() {
                              final selected =
                                  controller.selectedEmployeeId.value ==
                                  staff.employeeId;
                              return _StaffListCard(
                                staff: staff,
                                selected: selected,
                                onTap: () => controller.selectStaff(staff),
                                onDelete: () =>
                                    controller.confirmDelete(staff),
                              );
                            });
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Obx(() {
            final selected = controller.selectedStaff;
            if (selected == null) {
              return _EmptyPreview(theme: theme);
            }
            return _StaffPreviewPanel(
              theme: theme,
              staff: selected,
              onOpenDetails: () => controller.openStaffDetails(selected),
              onEdit: controller.openEditSelected,
              onToggle: () => controller.toggleActive(selected),
              onDelete: () => controller.confirmDelete(selected),
            );
          }),
        ),
      ],
    );
  }
}

class _StaffsHeader extends StatelessWidget {
  const _StaffsHeader({required this.theme, required this.count});

  final ThemeData theme;
  final int count;

  @override
  Widget build(BuildContext context) {
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
            child: Icon(Icons.badge_outlined, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Staff directory',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  count == 0
                      ? 'No staff yet'
                      : '$count staff member${count == 1 ? '' : 's'} available',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withValues(
                      alpha: 0.62,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$count',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends GetView<StaffsController> {
  const _SearchField({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<StaffsController>() || controller.isClosed) {
      return const SizedBox.shrink();
    }

    return GlassContainer(
      elevated: true,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      borderRadius: 16,
      child: Obx(() {
        if (controller.isClosed) return const SizedBox.shrink();
        final hasQuery = controller.searchQuery.value.isNotEmpty;
        return TextField(
          controller: controller.searchController,
          onChanged: controller.onSearchChanged,
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Search name, mobile, email, department…',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            prefixIcon: Icon(
              Icons.search_rounded,
              color: theme.colorScheme.primary,
            ),
            suffixIcon: hasQuery
                ? IconButton(
                    onPressed: controller.clearSearch,
                    icon: Icon(
                      Icons.close_rounded,
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.55,
                      ),
                    ),
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        );
      }),
    );
  }
}

class _StaffListCard extends StatelessWidget {
  const _StaffListCard({
    required this.staff,
    required this.selected,
    required this.onTap,
    required this.onDelete,
  });

  final Staff staff;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final roleLine = [
      staff.designationName,
      staff.departmentName,
    ].where((e) => e.trim().isNotEmpty).join(' · ');

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: selected
            ? Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.55),
                width: 1.4,
              )
            : null,
      ),
      child: GlassContainer(
        elevated: true,
        padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
        borderRadius: 20,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppAvatar(radius: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      staff.employeeFullName.isEmpty
                          ? 'Unnamed Staff'
                          : staff.employeeFullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: onSurface,
                      ),
                    ),
                    if (roleLine.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        roleLine,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: onSurface.withValues(alpha: 0.72),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    if (staff.mobileNo.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        staff.mobileNo,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: onSurface.withValues(alpha: 0.58),
                        ),
                      ),
                    ],
                    if (staff.emailId.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        staff.emailId,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: onSurface.withValues(alpha: 0.48),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 4, right: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: (staff.isActive
                                ? Colors.green
                                : theme.colorScheme.error)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        staff.isActive ? 'Active' : 'Inactive',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: staff.isActive
                              ? Colors.green.shade700
                              : theme.colorScheme.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    onPressed: onDelete,
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends GetView<StaffsController> {
  const _EmptyState({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
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
                Icons.badge_outlined,
                size: 30,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              controller.searchQuery.value.isEmpty
                  ? 'No staff yet'
                  : 'No matches found',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              controller.searchQuery.value.isEmpty
                  ? 'Add your first staff member to get started.'
                  : 'Try a different name, mobile, or department.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(
                  alpha: 0.62,
                ),
              ),
            ),
            if (controller.searchQuery.value.isEmpty) ...[
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: controller.openCreateStaff,
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: const Text('Add Staff'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyPreview extends StatelessWidget {
  const _EmptyPreview({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      elevated: true,
      padding: const EdgeInsets.all(32),
      borderRadius: 22,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.touch_app_rounded,
              size: 36,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Select a staff member',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Choose one from the list to preview details.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(
                  alpha: 0.62,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaffPreviewPanel extends StatelessWidget {
  const _StaffPreviewPanel({
    required this.theme,
    required this.staff,
    required this.onOpenDetails,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  final ThemeData theme;
  final Staff staff;
  final VoidCallback onOpenDetails;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      elevated: true,
      padding: const EdgeInsets.all(22),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const AppAvatar(radius: 36),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      staff.employeeFullName.isEmpty
                          ? 'Unnamed Staff'
                          : staff.employeeFullName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      [
                        if (staff.designationName.isNotEmpty)
                          staff.designationName,
                        if (staff.mobileNo.isNotEmpty) staff.mobileNo,
                      ].join('  ·  '),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withValues(
                          alpha: 0.68,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _PreviewRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: staff.emailId,
                  ),
                  _PreviewRow(
                    icon: Icons.apartment_outlined,
                    label: 'Department',
                    value: staff.departmentName,
                  ),
                  _PreviewRow(
                    icon: Icons.work_outline,
                    label: 'Designation',
                    value: staff.designationName,
                  ),
                  _PreviewRow(
                    icon: Icons.event_outlined,
                    label: 'Joining Date',
                    value: staff.joiningDate,
                  ),
                  _PreviewRow(
                    icon: Icons.cake_outlined,
                    label: 'Date of Birth',
                    value: staff.dob,
                  ),
                  _PreviewRow(
                    icon: Icons.tag_outlined,
                    label: 'Employee ID',
                    value: '${staff.employeeId}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onOpenDetails,
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Details'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onToggle,
                  icon: Icon(
                    staff.isActive
                        ? Icons.toggle_on_outlined
                        : Icons.toggle_off_outlined,
                  ),
                  label: Text(staff.isActive ? 'Inactive' : 'Active'),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filledTonal(
                onPressed: onDelete,
                tooltip: 'Delete',
                style: IconButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withValues(
                      alpha: 0.55,
                    ),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.trim().isEmpty ? '—' : value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
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
