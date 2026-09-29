import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/values/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../../../core/widgets/theme_selector_fab.dart';
import '../controllers/entity_picker_controller.dart';
import 'widgets/entity_picker_tile.dart';

class EntityPickerView extends GetView<EntityPickerController> {
  const EntityPickerView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: const GlassAppBar(title: 'Select Entity'),
      floatingActionButton: const ThemeSelectorFab(
        heroTag: 'entity_picker_theme_fab',
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
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isNarrow ? 12 : 24,
                      8,
                      isNarrow ? 12 : 24,
                      12,
                    ),
                    child: Column(
                      children: [
                        _StepHeader(theme: theme),
                        const SizedBox(height: 12),
                        Expanded(
                          child: GlassContainer(
                            elevated: true,
                            borderRadius: 18,
                            padding: EdgeInsets.zero,
                            child: Obx(() {
                              if (controller.isLoading.value) {
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: theme.colorScheme.primary,
                                  ),
                                );
                              }
                              return _StepList(controller: controller);
                            }),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _FooterNav(controller: controller),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StepHeader extends GetView<EntityPickerController> {
  const _StepHeader({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      elevated: true,
      borderRadius: 14,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Obx(() {
        final active = controller.stepIndex;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.stepTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                for (var i = 0; i < EntityPickerController.stepLabels.length; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: i <= active
                            ? theme.colorScheme.primary.withValues(alpha: 0.16)
                            : theme.colorScheme.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        EntityPickerController.stepLabels[i],
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: i <= active
                              ? theme.colorScheme.primary
                              : theme.textTheme.bodyMedium?.color
                                  ?.withValues(alpha: 0.45),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        );
      }),
    );
  }
}

class _StepList extends StatelessWidget {
  const _StepList({required this.controller});

  final EntityPickerController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      final step = controller.step.value;
      final selectedCompanyId = controller.selectedCompanyId.value;
      final selectedFranchiseId = controller.selectedFranchiseId.value;
      final selectedCustomerId = controller.selectedCustomerId.value;
      final selectedFamilyId = controller.selectedFamilyId.value;

      switch (step) {
        case EntityPickerStep.company:
          final items = controller.companies;
          if (items.isEmpty) {
            return _EmptyState(message: 'No companies found', theme: theme);
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = items[index];
              return EntityPickerTile(
                title: item.value,
                selected: selectedCompanyId == item.id,
                onTap: () => controller.selectCompany(item.id),
              );
            },
          );

        case EntityPickerStep.franchise:
          final items = controller.franchises;
          if (items.isEmpty) {
            return _EmptyState(message: 'No franchises found', theme: theme);
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = items[index];
              return EntityPickerTile(
                title: item.franchiseName,
                selected: selectedFranchiseId == item.franchiseCode,
                onTap: () => controller.selectFranchise(item.franchiseCode),
              );
            },
          );

        case EntityPickerStep.customer:
          final items = controller.customers;
          if (items.isEmpty) {
            return _EmptyState(message: 'No customers found', theme: theme);
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = items[index];
              final subtitle = [
                if (item.mobileNo.isNotEmpty) item.mobileNo,
                if (item.emailId.isNotEmpty) item.emailId,
              ].join(' · ');
              return EntityPickerTile(
                title: item.customerFullName,
                subtitle: subtitle.isEmpty ? null : subtitle,
                selected: selectedCustomerId == item.customerId,
                onTap: () => controller.selectCustomer(item.customerId),
              );
            },
          );

        case EntityPickerStep.family:
          final items = controller.familyMembers;
          if (items.isEmpty) {
            return _EmptyState(
              message: 'No family members found',
              theme: theme,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = items[index];
              return EntityPickerTile(
                title: item.value,
                selected: selectedFamilyId == item.id,
                onTap: () => controller.selectFamily(item.id),
              );
            },
          );
      }
    });
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message, required this.theme});

  final String message;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.55),
          ),
        ),
      ),
    );
  }
}

class _FooterNav extends StatelessWidget {
  const _FooterNav({required this.controller});

  final EntityPickerController controller;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      elevated: true,
      borderRadius: 14,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Obx(() {
        final loading = controller.isLoading.value;
        final isFirst = controller.isFirstStep;
        final isLast = controller.isLastStep;

        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: (loading || isFirst) ? null : controller.goPrevious,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Previous'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: loading ? null : controller.goNext,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(isLast ? 'Done' : 'Next'),
              ),
            ),
          ],
        );
      }),
    );
  }
}
