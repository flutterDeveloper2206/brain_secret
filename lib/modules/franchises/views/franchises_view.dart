import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_constants.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/glass_app_bar.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/theme_selector_fab.dart';
import '../../../data/models/franchise.dart';
import '../controllers/franchises_controller.dart';

class FranchisesView extends GetView<FranchisesController> {
  const FranchisesView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: GlassAppBar(
        title: 'Franchises',
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: controller.loadFranchises,
            icon: Icon(Icons.refresh_rounded, color: theme.colorScheme.primary),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const ThemeSelectorFab(heroTag: 'franchises_theme_fab'),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'createFranchiseFab',
            onPressed: controller.openCreateFranchise,
            icon: const Icon(Icons.add_business_rounded),
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
                  if (!Get.isRegistered<FranchisesController>() ||
                      controller.isClosed) {
                    return const SizedBox.shrink();
                  }

                  final list = controller.filteredFranchises;
                  final loading =
                      controller.isLoading.value &&
                      controller.franchises.isEmpty;

                  if (loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (isNarrow) {
                    return _MobileFranchisesBody(
                      theme: theme,
                      franchises: list,
                    );
                  }

                  return _WideFranchisesBody(theme: theme, franchises: list);
                }),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MobileFranchisesBody extends GetView<FranchisesController> {
  const _MobileFranchisesBody({
    required this.theme,
    required this.franchises,
  });

  final ThemeData theme;
  final List<Franchise> franchises;

  @override
  Widget build(BuildContext context) {
    final hasData = controller.franchises.isNotEmpty;

    return Column(
      children: [
        _FranchisesHeader(
          theme: theme,
          count: hasData ? franchises.length : 0,
        ),
        if (hasData) ...[
          const SizedBox(height: 12),
          _SearchField(theme: theme),
          const SizedBox(height: 14),
        ] else
          const SizedBox(height: 14),
        Expanded(
          child: franchises.isEmpty
              ? _EmptyState(theme: theme)
              : RefreshIndicator(
                  onRefresh: controller.loadFranchises,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.only(bottom: 120),
                    itemCount: franchises.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final franchise = franchises[index];
                      return _FranchiseListCard(
                        franchise: franchise,
                        selected: false,
                        onTap: () =>
                            controller.openFranchiseDetails(franchise),
                        onDelete: () => controller.confirmDelete(franchise),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

class _WideFranchisesBody extends GetView<FranchisesController> {
  const _WideFranchisesBody({
    required this.theme,
    required this.franchises,
  });

  final ThemeData theme;
  final List<Franchise> franchises;

  @override
  Widget build(BuildContext context) {
    final hasData = controller.franchises.isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 380,
          child: Column(
            children: [
              _FranchisesHeader(
                theme: theme,
                count: hasData ? franchises.length : 0,
              ),
              if (hasData) ...[
                const SizedBox(height: 12),
                _SearchField(theme: theme),
                const SizedBox(height: 14),
              ] else
                const SizedBox(height: 14),
              Expanded(
                child: franchises.isEmpty
                    ? _EmptyState(theme: theme)
                    : RefreshIndicator(
                        onRefresh: controller.loadFranchises,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: const EdgeInsets.only(bottom: 120),
                          itemCount: franchises.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final franchise = franchises[index];
                            return Obx(() {
                              final selected =
                                  controller.selectedFranchiseCode.value ==
                                  franchise.franchiseCode;
                              return _FranchiseListCard(
                                franchise: franchise,
                                selected: selected,
                                onTap: () =>
                                    controller.selectFranchise(franchise),
                                onDelete: () =>
                                    controller.confirmDelete(franchise),
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
            final selected = controller.selectedFranchise;
            if (selected == null) {
              return _EmptyPreview(theme: theme);
            }
            return _FranchisePreviewPanel(
              theme: theme,
              franchise: selected,
              onOpenDetails: () => controller.openFranchiseDetails(selected),
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

class _FranchisesHeader extends StatelessWidget {
  const _FranchisesHeader({required this.theme, required this.count});

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
            child: Icon(
              Icons.storefront_rounded,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Franchise directory',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  count == 0
                      ? 'No franchises yet'
                      : '$count franchise${count == 1 ? '' : 's'} available',
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

class _SearchField extends GetView<FranchisesController> {
  const _SearchField({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<FranchisesController>() || controller.isClosed) {
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
            hintText: 'Search name, owner, mobile, city…',
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

class _FranchiseListCard extends StatelessWidget {
  const _FranchiseListCard({
    required this.franchise,
    required this.selected,
    required this.onTap,
    required this.onDelete,
  });

  final Franchise franchise;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final location = [
      franchise.city,
      franchise.state,
      franchise.country,
    ].where((e) => e.trim().isNotEmpty).join(', ');

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
                      franchise.franchiseName.isEmpty
                          ? 'Unnamed Franchise'
                          : franchise.franchiseName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: onSurface,
                      ),
                    ),
                    if (franchise.ownerName.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        franchise.ownerName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: onSurface.withValues(alpha: 0.72),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    if (franchise.mobileNo.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        franchise.mobileNo,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: onSurface.withValues(alpha: 0.58),
                        ),
                      ),
                    ],
                    if (location.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        location,
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
                        color: (franchise.isActive
                                ? Colors.green
                                : theme.colorScheme.error)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        franchise.isActive ? 'Active' : 'Inactive',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: franchise.isActive
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

class _EmptyState extends GetView<FranchisesController> {
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
                Icons.store_mall_directory_outlined,
                size: 30,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              controller.searchQuery.value.isEmpty
                  ? 'No franchises yet'
                  : 'No matches found',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              controller.searchQuery.value.isEmpty
                  ? 'Create your first franchise to get started.'
                  : 'Try a different name, owner, or city.',
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
                onPressed: controller.openCreateFranchise,
                icon: const Icon(Icons.add_business_rounded),
                label: const Text('Create Franchise'),
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
              'Select a franchise',
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

class _FranchisePreviewPanel extends StatelessWidget {
  const _FranchisePreviewPanel({
    required this.theme,
    required this.franchise,
    required this.onOpenDetails,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  final ThemeData theme;
  final Franchise franchise;
  final VoidCallback onOpenDetails;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final location = [
      franchise.city,
      franchise.state,
      franchise.country,
    ].where((e) => e.trim().isNotEmpty).join(', ');

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
                      franchise.franchiseName.isEmpty
                          ? 'Unnamed Franchise'
                          : franchise.franchiseName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      [
                        if (franchise.ownerName.isNotEmpty) franchise.ownerName,
                        if (franchise.mobileNo.isNotEmpty) franchise.mobileNo,
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
                    value: franchise.emailId,
                  ),
                  _PreviewRow(
                    icon: Icons.receipt_long_outlined,
                    label: 'GST',
                    value: franchise.gstNumber,
                  ),
                  _PreviewRow(
                    icon: Icons.home_outlined,
                    label: 'Address',
                    value: franchise.fullAddress,
                  ),
                  _PreviewRow(
                    icon: Icons.location_on_outlined,
                    label: 'Location',
                    value: location,
                  ),
                  _PreviewRow(
                    icon: Icons.account_balance_outlined,
                    label: 'Bank',
                    value: franchise.bankName,
                  ),
                  _PreviewRow(
                    icon: Icons.tag_outlined,
                    label: 'Code',
                    value: '${franchise.franchiseCode}',
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
                    franchise.isActive
                        ? Icons.toggle_on_outlined
                        : Icons.toggle_off_outlined,
                  ),
                  label: Text(franchise.isActive ? 'Inactive' : 'Active'),
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
