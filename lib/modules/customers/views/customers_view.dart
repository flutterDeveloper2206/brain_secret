import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_constants.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_searchable_dropdown_field.dart';
import '../../../core/widgets/glass_app_bar.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/theme_selector_fab.dart';
import '../../../data/models/customer.dart';
import '../controllers/customers_controller.dart';

class CustomersView extends GetView<CustomersController> {
  const CustomersView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: GlassAppBar(
        title: 'Customers',
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: controller.loadCustomers,
            icon: Icon(Icons.refresh_rounded, color: theme.colorScheme.primary),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const ThemeSelectorFab(heroTag: 'customers_theme_fab'),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'createCustomerFab',
            onPressed: controller.openCreateCustomer,
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
                  if (!Get.isRegistered<CustomersController>() ||
                      controller.isClosed) {
                    return const SizedBox.shrink();
                  }

                  final list = controller.filteredCustomers;
                  final loading =
                      controller.isLoading.value &&
                      controller.customers.isEmpty;

                  if (loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (isNarrow) {
                    return _MobileCustomersBody(theme: theme, customers: list);
                  }

                  return _WideCustomersBody(theme: theme, customers: list);
                }),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MobileCustomersBody extends GetView<CustomersController> {
  const _MobileCustomersBody({required this.theme, required this.customers});

  final ThemeData theme;
  final List<Customer> customers;

  @override
  Widget build(BuildContext context) {
    final hasData = controller.customers.isNotEmpty;

    return Column(
      children: [
        const SizedBox(height: 8),
        const _CompanyFranchiseFilters(),
        if (hasData) ...[
          const SizedBox(height: 10),
          _SearchField(theme: theme),
          const SizedBox(height: 14),
        ] else
          const SizedBox(height: 14),
        Expanded(
          child: customers.isEmpty
              ? _EmptyState(theme: theme)
              : RefreshIndicator(
                  onRefresh: controller.loadCustomers,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.only(bottom: 120),
                    itemCount: customers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final customer = customers[index];
                      return _CustomerListCard(
                        customer: customer,
                        selected: false,
                        onTap: () => controller.openCustomerDetails(customer),
                        onDelete: () => controller.confirmDelete(customer),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

class _WideCustomersBody extends GetView<CustomersController> {
  const _WideCustomersBody({required this.theme, required this.customers});

  final ThemeData theme;
  final List<Customer> customers;

  @override
  Widget build(BuildContext context) {
    final hasData = controller.customers.isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 380,
          child: Column(
            children: [
              const SizedBox(height: 8),
              const _CompanyFranchiseFilters(),
              if (hasData) ...[
                const SizedBox(height: 10),
                _SearchField(theme: theme),
                const SizedBox(height: 14),
              ] else
                const SizedBox(height: 14),
              Expanded(
                child: customers.isEmpty
                    ? _EmptyState(theme: theme)
                    : RefreshIndicator(
                        onRefresh: controller.loadCustomers,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: const EdgeInsets.only(bottom: 120),
                          itemCount: customers.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final customer = customers[index];
                            return Obx(() {
                              final selected =
                                  controller.selectedCustomerId.value ==
                                  customer.customerId;
                              return _CustomerListCard(
                                customer: customer,
                                selected: selected,
                                onTap: () =>
                                    controller.selectCustomer(customer),
                                onDelete: () =>
                                    controller.confirmDelete(customer),
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
            final selected = controller.selectedCustomer;
            if (selected == null) {
              return _EmptyPreview(theme: theme);
            }
            return _CustomerPreviewPanel(
              theme: theme,
              customer: selected,
              onOpenDetails: () => controller.openCustomerDetails(selected),
              onEdit: controller.openEditSelected,
              onDelete: () => controller.confirmDelete(selected),
            );
          }),
        ),
      ],
    );
  }
}

class _CompanyFranchiseFilters extends GetView<CustomersController> {
  const _CompanyFranchiseFilters();

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CustomersController>() || controller.isClosed) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      if (controller.isClosed) return const SizedBox.shrink();
      final hasCompany = controller.selectedCompanyId.value != null;

      return Column(
        children: [
          AppSearchableDropdownField<int>(
            label: 'Company',
            hint: 'Select company',
            prefixIcon: Icons.apartment_outlined,
            value: controller.selectedCompanyId.value,
            displayLabel: controller.selectedCompanyLabel,
            items: controller.companyDropdownItems,
            isLoading: controller.isLoadingCompanies.value,
            loadItems: controller.loadCompanies,
            searchHint: 'Search company…',
            onChanged: controller.onCompanySelected,
          ),
          const SizedBox(height: 10),
          AppSearchableDropdownField<int>(
            label: 'Franchise',
            hint: hasCompany ? 'Select franchise' : 'Select company first',
            prefixIcon: Icons.storefront_outlined,
            value: controller.selectedFranchiseId.value,
            displayLabel: controller.selectedFranchiseLabel,
            items: controller.franchiseDropdownItems,
            isLoading: controller.isLoadingFranchises.value,
            enabled: hasCompany,
            loadItems: hasCompany ? controller.loadFranchisesSheet : null,
            searchHint: 'Search franchise…',
            emptyMessage: hasCompany
                ? 'No franchises for this company'
                : 'Select a company first',
            onChanged: controller.onFranchiseSelected,
          ),
        ],
      );
    });
  }
}

class _SearchField extends GetView<CustomersController> {
  const _SearchField({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CustomersController>() || controller.isClosed) {
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
            hintText: 'Search name, mobile, email, city…',
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

class _CustomerListCard extends StatelessWidget {
  const _CustomerListCard({
    required this.customer,
    required this.selected,
    required this.onTap,
    required this.onDelete,
  });

  final Customer customer;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final location = [
      customer.cityName,
      customer.stateName,
      customer.countryName,
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
                      customer.customerFullName.isEmpty
                          ? 'Unnamed Customer'
                          : customer.customerFullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: onSurface,
                      ),
                    ),
                    if (customer.mobileNo.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        customer.mobileNo,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: onSurface.withValues(alpha: 0.72),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    if (customer.emailId.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        customer.emailId,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                  if (customer.age > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, right: 4),
                      child: Text(
                        '${customer.age}y',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.primary,
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

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.theme});

  final String label;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyState extends GetView<CustomersController> {
  const _EmptyState({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final needsCompany = controller.selectedCompanyId.value == null;
    final needsFranchise = controller.selectedFranchiseId.value == null;
    final searching = controller.searchQuery.value.isNotEmpty;

    String title;
    String subtitle;
    if (needsCompany) {
      title = 'Select a company';
      subtitle = 'Choose a company above to load franchises.';
    } else if (needsFranchise) {
      title = 'Select a franchise';
      subtitle = 'Choose a franchise to load customers.';
    } else if (searching) {
      title = 'No matches found';
      subtitle = 'Try a different name, mobile, or city.';
    } else {
      title = 'No customers yet';
      subtitle = 'Create your first customer profile to get started.';
    }

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
                needsCompany || needsFranchise
                    ? Icons.filter_list_rounded
                    : Icons.person_search_rounded,
                size: 30,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(
                  alpha: 0.62,
                ),
              ),
            ),
            if (!needsCompany && !needsFranchise && !searching) ...[
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: controller.openCreateCustomer,
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: const Text('Create Customer'),
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
              'Select a customer',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Choose someone from the list to preview details.',
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

class _CustomerPreviewPanel extends StatelessWidget {
  const _CustomerPreviewPanel({
    required this.theme,
    required this.customer,
    required this.onOpenDetails,
    required this.onEdit,
    required this.onDelete,
  });

  final ThemeData theme;
  final Customer customer;
  final VoidCallback onOpenDetails;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final location = [
      customer.cityName,
      customer.stateName,
      customer.countryName,
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
                      customer.customerFullName.isEmpty
                          ? 'Unnamed Customer'
                          : customer.customerFullName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      [
                        if (customer.mobileNo.isNotEmpty) customer.mobileNo,
                        if (customer.emailId.isNotEmpty) customer.emailId,
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
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (customer.gender.isNotEmpty)
                _Chip(label: customer.gender, theme: theme),
              if (customer.age > 0)
                _Chip(label: '${customer.age} yrs', theme: theme),
              if (customer.occupation.isNotEmpty)
                _Chip(label: customer.occupation, theme: theme),
              if (location.isNotEmpty) _Chip(label: location, theme: theme),
            ],
          ),
          const SizedBox(height: 22),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _PreviewRow(
                    icon: Icons.business_outlined,
                    label: 'Organization',
                    value: customer.organization,
                  ),
                  _PreviewRow(
                    icon: Icons.school_outlined,
                    label: 'Education',
                    value: customer.education,
                  ),
                  _PreviewRow(
                    icon: Icons.home_outlined,
                    label: 'Address',
                    value: customer.fullAddress,
                  ),
                  _PreviewRow(
                    icon: Icons.favorite_border,
                    label: 'Marital Status',
                    value: customer.maritalStatus,
                  ),
                  _PreviewRow(
                    icon: Icons.translate_outlined,
                    label: 'Language',
                    value: customer.preferredLanguage,
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
                  label: const Text('Full Details'),
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
