import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_constants.dart';
import '../../../core/widgets/app_action_button_bar.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/glass_app_bar.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/theme_selector_fab.dart';
import '../../../data/models/customer.dart';
import '../controllers/customer_details_controller.dart';

class CustomerDetailsView extends GetView<CustomerDetailsController> {
  const CustomerDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: GlassAppBar(
        title: 'Customer Details',
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: controller.loadDetails,
            icon: Icon(Icons.refresh_rounded, color: theme.colorScheme.primary),
          ),
        ],
      ),
      floatingActionButton: const ThemeSelectorFab(
        heroTag: 'customer_details_theme_fab',
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
                        controller.customer.value == null) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final customer = controller.customer.value;
                    if (customer == null) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontal),
                        child: GlassContainer(
                          padding: const EdgeInsets.all(28),
                          borderRadius: 20,
                          child: Text(
                            'Customer details not available.',
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
                                _HeroHeader(customer: customer),
                                const SizedBox(height: 16),
                                _QuickStats(
                                  customer: customer,
                                  isNarrow: isNarrow,
                                ),
                                const SizedBox(height: 16),
                                _SectionGrid(
                                  isNarrow: isNarrow,
                                  sections: [
                                    _SectionData(
                                      title: 'Basic Information',
                                      icon: Icons.person_outline_rounded,
                                      rows: [
                                        (
                                          'Customer ID',
                                          '${customer.customerId}',
                                        ),
                                        (
                                          'Full Name',
                                          customer.customerFullName,
                                        ),
                                        ('Email', customer.emailId),
                                        ('Mobile', customer.mobileNo),
                                        ('Gender', customer.gender),
                                        ('Date of Birth', customer.dob),
                                        ('Age', '${customer.age}'),
                                      ],
                                    ),
                                    _SectionData(
                                      title: 'Address',
                                      icon: Icons.location_on_outlined,
                                      rows: [
                                        ('Country', customer.countryName),
                                        ('State', customer.stateName),
                                        ('City', customer.cityName),
                                        ('PIN Code', customer.pincode),
                                        ('Full Address', customer.fullAddress),
                                      ],
                                    ),
                                    _SectionData(
                                      title: 'Personal',
                                      icon: Icons.work_outline_rounded,
                                      rows: [
                                        ('Occupation', customer.occupation),
                                        ('Organization', customer.organization),
                                        ('Education', customer.education),
                                        (
                                          'Marital Status',
                                          customer.maritalStatus,
                                        ),
                                        (
                                          'Preferred Language',
                                          customer.preferredLanguage,
                                        ),
                                      ],
                                    ),
                                    _SectionData(
                                      title: 'Family',
                                      icon: Icons.family_restroom_rounded,
                                      rows: [
                                        ("Father's Name", customer.fatherName),
                                        ("Mother's Name", customer.motherName),
                                        ('Spouse Name', customer.spouseName),
                                        (
                                          'Emergency Contact',
                                          customer.emergencyContact,
                                        ),
                                      ],
                                    ),
                                    _SectionData(
                                      title: 'Medical',
                                      icon: Icons.medical_services_outlined,
                                      rows: [
                                        (
                                          'Medical Issue',
                                          customer.anyMedicalIssue
                                              ? 'Yes'
                                              : 'No',
                                        ),
                                        (
                                          'Psychological Issue',
                                          customer.anyPsychologicalIssue
                                              ? 'Yes'
                                              : 'No',
                                        ),
                                        (
                                          'Hand Dominance',
                                          customer.leftRightHandDominat
                                              ? 'Right'
                                              : 'Left',
                                        ),
                                      ],
                                    ),
                                    _SectionData(
                                      title: 'Company',
                                      icon: Icons.apartment_outlined,
                                      rows: [
                                        (
                                          'Company Code',
                                          '${customer.companyCode}',
                                        ),
                                        (
                                          'Franchise Code',
                                          '${customer.franchiseCode}',
                                        ),
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
                            onEdit: controller.openEdit,
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
  const _HeroHeader({required this.customer});

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassContainer(
      elevated: true,
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        children: [
          Row(
            children: [
              const AppAvatar(radius: 38),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.customerFullName.isEmpty
                          ? 'Unnamed Customer'
                          : customer.customerFullName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (customer.emailId.isNotEmpty)
                      _ContactLine(
                        icon: Icons.email_outlined,
                        text: customer.emailId,
                      ),
                    if (customer.mobileNo.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _ContactLine(
                        icon: Icons.phone_iphone_rounded,
                        text: customer.mobileNo,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (customer.gender.isNotEmpty)
                  _InfoChip(label: customer.gender),
                if (customer.age > 0) _InfoChip(label: '${customer.age} yrs'),
                if (customer.cityName.isNotEmpty)
                  _InfoChip(label: customer.cityName),
                if (customer.occupation.isNotEmpty)
                  _InfoChip(label: customer.occupation),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactLine extends StatelessWidget {
  const _ContactLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          size: 15,
          color: theme.colorScheme.primary.withValues(alpha: 0.8),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  const _QuickStats({required this.customer, required this.isNarrow});

  final Customer customer;
  final bool isNarrow;

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatItem(
        icon: Icons.badge_outlined,
        label: 'ID',
        value: '#${customer.customerId}',
      ),
      _StatItem(
        icon: Icons.favorite_border,
        label: 'Status',
        value: customer.maritalStatus.isEmpty ? '—' : customer.maritalStatus,
      ),
      _StatItem(
        icon: Icons.translate_outlined,
        label: 'Language',
        value: customer.preferredLanguage.isEmpty
            ? '—'
            : customer.preferredLanguage,
      ),
      _StatItem(
        icon: Icons.back_hand_outlined,
        label: 'Hand',
        value: customer.leftRightHandDominat ? 'Right' : 'Left',
      ),
    ];

    if (isNarrow) {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.55,
        children: items.map((item) => _StatCard(item: item)).toList(),
      );
    }

    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(child: _StatCard(item: items[i])),
        ],
      ],
    );
  }
}

class _StatItem {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.item});

  final _StatItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassContainer(
      elevated: true,
      padding: const EdgeInsets.all(14),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.icon, size: 18, color: theme.colorScheme.primary),
          const Spacer(),
          Text(
            item.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.58),
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
          for (final section in sections) ...[
            _DetailSection(data: section),
            const SizedBox(height: 12),
          ],
        ],
      );
    }

    final rows = <Widget>[];
    for (var i = 0; i < sections.length; i += 2) {
      final left = sections[i];
      final right = i + 1 < sections.length ? sections[i + 1] : null;
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _DetailSection(data: left)),
              const SizedBox(width: 12),
              Expanded(
                child: right == null
                    ? const SizedBox.shrink()
                    : _DetailSection(data: right),
              ),
            ],
          ),
        ),
      );
      rows.add(const SizedBox(height: 12));
    }
    return Column(children: rows);
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.data});

  final _SectionData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassContainer(
      elevated: true,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  data.icon,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                data.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(
            height: 1,
            color: theme.colorScheme.outline.withValues(alpha: 0.12),
          ),
          const SizedBox(height: 4),
          for (final row in data.rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 118,
                    child: Text(
                      row.$1,
                      style: theme.textTheme.bodySmall?.copyWith(
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
    required this.onEdit,
    required this.onDelete,
  });

  final ThemeData theme;
  final bool isDeleting;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AppActionButtonBar(
      children: [
        AppActionButton.filled(
          label: 'Edit',
          icon: Icons.edit_outlined,
          onPressed: onEdit,
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
