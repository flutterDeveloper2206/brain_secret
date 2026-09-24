import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_constants.dart';
import '../../../core/widgets/app_action_button_bar.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/glass_app_bar.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/theme_selector_fab.dart';
import '../../../data/models/franchise.dart';
import '../controllers/franchise_details_controller.dart';

class FranchiseDetailsView extends GetView<FranchiseDetailsController> {
  const FranchiseDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: GlassAppBar(
        title: 'Franchise Details',
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: controller.loadDetails,
            icon: Icon(Icons.refresh_rounded, color: theme.colorScheme.primary),
          ),
        ],
      ),
      floatingActionButton: const ThemeSelectorFab(
        heroTag: 'franchise_details_theme_fab',
      ),
      body: GradientBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow =
                  constraints.maxWidth < AppConstants.breakpointTablet;
              final horizontal = isNarrow ? 16.0 : 28.0;
              final maxWidth = isNarrow ? double.infinity : 980.0;

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Obx(() {
                    if (controller.isLoading.value &&
                        controller.franchise.value == null) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final franchise = controller.franchise.value;
                    if (franchise == null) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontal),
                        child: GlassContainer(
                          padding: const EdgeInsets.all(28),
                          borderRadius: 20,
                          child: Text(
                            'Franchise details not available.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: controller.loadDetails,
                            child: ListView(
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              padding: EdgeInsets.fromLTRB(
                                horizontal,
                                8,
                                horizontal,
                                16,
                              ),
                              children: [
                                _HeroHeader(franchise: franchise),
                                const SizedBox(height: 16),
                                _SectionGrid(
                                  isNarrow: isNarrow,
                                  sections: [
                                    _SectionData(
                                      title: 'Business',
                                      icon: Icons.storefront_outlined,
                                      rows: [
                                        (
                                          'Franchise Code',
                                          '${franchise.franchiseCode}',
                                        ),
                                        (
                                          'Company Code',
                                          '${franchise.companyCode}',
                                        ),
                                        ('Name', franchise.franchiseName),
                                        ('Owner', franchise.ownerName),
                                        ('GST', franchise.gstNumber),
                                        ('Website', franchise.website),
                                      ],
                                    ),
                                    _SectionData(
                                      title: 'Contact',
                                      icon: Icons.contact_mail_outlined,
                                      rows: [
                                        ('Mobile', franchise.mobileNo),
                                        ('Email', franchise.emailId),
                                      ],
                                    ),
                                    _SectionData(
                                      title: 'Address',
                                      icon: Icons.location_on_outlined,
                                      rows: [
                                        ('Country', franchise.country),
                                        ('State', franchise.state),
                                        ('City', franchise.city),
                                        ('PIN Code', franchise.pincode),
                                        ('Full Address', franchise.fullAddress),
                                      ],
                                    ),
                                    _SectionData(
                                      title: 'Banking',
                                      icon: Icons.account_balance_outlined,
                                      rows: [
                                        ('Bank', franchise.bankName),
                                        (
                                          'Account Holder',
                                          franchise.accountHolderName,
                                        ),
                                        (
                                          'Account Number',
                                          franchise.accountNumber,
                                        ),
                                        ('IFSC', franchise.ifscCode),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            horizontal,
                            0,
                            horizontal,
                            12,
                          ),
                          child: _BottomActions(
                            theme: theme,
                            isDeleting: controller.isDeleting.value,
                            isToggling: controller.isToggling.value,
                            isActive: franchise.isActive,
                            onEdit: controller.openEdit,
                            onToggle: controller.toggleActive,
                            onDelete: controller.confirmDelete,
                          ),
                        ),
                      ],
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

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.franchise});

  final Franchise franchise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassContainer(
      elevated: true,
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Row(
        children: [
          const AppAvatar(radius: 38),
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
                if (franchise.ownerName.isNotEmpty)
                  Text(
                    franchise.ownerName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
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
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: franchise.isActive
                          ? Colors.green.shade700
                          : theme.colorScheme.error,
                      fontWeight: FontWeight.w700,
                    ),
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

class _SectionData {
  const _SectionData({
    required this.title,
    required this.icon,
    required this.rows,
  });

  final String title;
  final IconData icon;
  final List<(String, String)> rows;
}

class _SectionGrid extends StatelessWidget {
  const _SectionGrid({required this.isNarrow, required this.sections});

  final bool isNarrow;
  final List<_SectionData> sections;

  @override
  Widget build(BuildContext context) {
    if (isNarrow) {
      return Column(
        children: [
          for (var i = 0; i < sections.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _SectionCard(section: sections[i]),
          ],
        ],
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final section in sections)
          SizedBox(
            width: (MediaQuery.sizeOf(context).width - 28 * 2 - 12) / 2 > 420
                ? 420
                : (MediaQuery.sizeOf(context).width - 28 * 2 - 12) / 2,
            child: _SectionCard(section: section),
          ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section});

  final _SectionData section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassContainer(
      elevated: true,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(section.icon, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                section.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final row in section.rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      row.$1,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withValues(
                          alpha: 0.55,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      row.$2.trim().isEmpty ? '—' : row.$2,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
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

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.theme,
    required this.isDeleting,
    required this.isToggling,
    required this.isActive,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  final ThemeData theme;
  final bool isDeleting;
  final bool isToggling;
  final bool isActive;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AppActionButtonBar(
      breakpoint: 640,
      children: [
        AppActionButton.filled(
          label: 'Edit',
          icon: Icons.edit_outlined,
          onPressed: onEdit,
        ),
        AppActionButton.outlined(
          label: isActive ? 'Set Inactive' : 'Set Active',
          icon: isActive ? Icons.toggle_on_outlined : Icons.toggle_off_outlined,
          onPressed: isToggling ? null : onToggle,
          isLoading: isToggling,
        ),
        AppActionButton.outlined(
          label: 'Delete',
          icon: Icons.delete_outline,
          onPressed: isDeleting ? null : onDelete,
          isLoading: isDeleting,
          destructive: true,
        ),
      ],
    );
  }
}
