import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../../../data/providers/permission_service.dart';
import '../../../../routes/app_routes.dart';
import '../../../role_master/bindings/role_master_binding.dart';
import '../../../role_master/views/role_master_view.dart';
import '../../controllers/main_shell_controller.dart';

class MenuTab extends GetView<MainShellController> {
  const MenuTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: GlassAppBar(
        title: 'Menu',
        showBack: false,
        actions: [
          Obx(() {
            final permissionService = Get.find<PermissionService>();
            final profile = permissionService.userProfile.value;
            final isCustomer = profile?.isCustomer ?? false;
            final canSwitch = isCustomer && (profile?.accounts.length ?? 0) > 1;

            if (canSwitch) {
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Center(
                  child: Material(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(22),
                    child: InkWell(
                      onTap: () =>
                          _openSwitchAccountSheet(context, permissionService),
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.35,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.published_with_changes_rounded,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Switch',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }

            if (isCustomer) return const SizedBox.shrink();

            return IconButton(
              tooltip: 'Logout',
              onPressed: controller.isLoggingOut.value
                  ? null
                  : controller.confirmLogout,
              icon: controller.isLoggingOut.value
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : Icon(Icons.logout, color: theme.colorScheme.primary),
            );
          }),
        ],
      ),
      body: GradientBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 768;
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isNarrow ? double.infinity : 720,
                  ),
                  child: Obx(() {
                    final permissionService = Get.find<PermissionService>();
                    final userType =
                        permissionService.session.value?.userType ?? '';
                    final profile = permissionService.userProfile.value;
                    final active = permissionService.activeAccount;
                    // Touch activeAccountId so Obx rebuilds on switch.
                    permissionService.activeAccountId.value;

                    final displayName =
                        (active?.displayName.isNotEmpty ?? false)
                        ? active!.displayName
                        : (profile?.displayName ?? 'Account');
                    final subtitle = (active?.email?.isNotEmpty ?? false)
                        ? active!.email!
                        : (active?.subtitle?.isNotEmpty ?? false)
                        ? active!.subtitle!
                        : (profile?.emailId.isNotEmpty ?? false)
                        ? profile!.emailId
                        : (profile?.userType.isNotEmpty ?? false)
                        ? profile!.userType
                        : userType;
                    final loggingOut = controller.isLoggingOut.value;
                    final photoUrl = profile?.profilePhotoUrl;

                    return ListView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isNarrow ? 16 : 28,
                        vertical: 16,
                      ),
                      children: [
                        GestureDetector(
                          onTap: () => Get.toNamed(Routes.userProfile),

                          child: GlassContainer(
                            padding: const EdgeInsets.all(16),
                            borderRadius: 18,
                            child: Row(
                              children: [
                                if (photoUrl != null && photoUrl.isNotEmpty)
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: theme.colorScheme.primary
                                        .withValues(alpha: 0.15),
                                    backgroundImage: NetworkImage(photoUrl),
                                    onBackgroundImageError: (_, __) {},
                                  )
                                else
                                  CircleAvatar(
                                    backgroundColor: theme.colorScheme.primary
                                        .withValues(alpha: 0.15),
                                    child: Icon(
                                      Icons.person_outline,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        displayName,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      if (subtitle.isNotEmpty)
                                        Text(
                                          subtitle,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: theme
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.color
                                                    ?.withValues(alpha: 0.65),
                                              ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // GlassContainer(
                        //   margin: const EdgeInsets.only(bottom: 12),
                        //   padding: const EdgeInsets.symmetric(horizontal: 8),
                        //   borderRadius: 18,
                        //   child: Material(
                        //     color: Colors.transparent,
                        //     child: ListTile(
                        //       leading: Icon(
                        //         Icons.account_circle_outlined,
                        //         color: theme.colorScheme.primary,
                        //       ),
                        //       title: Text(
                        //         'Profile',
                        //         style: theme.textTheme.titleSmall?.copyWith(
                        //           fontWeight: FontWeight.w700,
                        //         ),
                        //       ),
                        //       trailing: Icon(
                        //         Icons.chevron_right,
                        //         color: theme.colorScheme.primary.withValues(
                        //           alpha: 0.7,
                        //         ),
                        //       ),
                        //       onTap: () => Get.toNamed(Routes.userProfile),
                        //     ),
                        //   ),
                        // ),
                        GlassContainer(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          borderRadius: 18,
                          child: Material(
                            color: Colors.transparent,
                            child: ListTile(
                              leading: Icon(
                                Icons.people_outline,
                                color: theme.colorScheme.primary,
                              ),
                              title: Text(
                                'Customers',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              trailing: Icon(
                                Icons.chevron_right,
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                              onTap: () => Get.toNamed(Routes.customers),
                            ),
                          ),
                        ),
                        GlassContainer(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          borderRadius: 18,
                          child: Material(
                            color: Colors.transparent,
                            child: ListTile(
                              leading: Icon(
                                Icons.storefront_outlined,
                                color: theme.colorScheme.primary,
                              ),
                              title: Text(
                                'Franchises',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              trailing: Icon(
                                Icons.chevron_right,
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                              onTap: () => Get.toNamed(Routes.franchises),
                            ),
                          ),
                        ),
                        GlassContainer(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          borderRadius: 18,
                          child: Material(
                            color: Colors.transparent,
                            child: ListTile(
                              leading: Icon(
                                Icons.badge_outlined,
                                color: theme.colorScheme.primary,
                              ),
                              title: Text(
                                'Staff / Employees',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              trailing: Icon(
                                Icons.chevron_right,
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                              onTap: () => Get.toNamed(Routes.staffs),
                            ),
                          ),
                        ),
                        GlassContainer(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          borderRadius: 18,
                          child: Material(
                            color: Colors.transparent,
                            child: ListTile(
                              leading: Icon(
                                Icons.fingerprint,
                                color: theme.colorScheme.primary,
                              ),
                              title: Text(
                                'Add Fingerprint',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              trailing: Icon(
                                Icons.chevron_right,
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                              onTap: () => Get.toNamed(Routes.handSelector),
                            ),
                          ),
                        ),
                        GlassContainer(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          borderRadius: 18,
                          child: Material(
                            color: Colors.transparent,
                            child: ListTile(
                              leading: Icon(
                                Icons.analytics_outlined,
                                color: theme.colorScheme.primary,
                              ),
                              title: Text(
                                'Analyze Fingerprints',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              trailing: Icon(
                                Icons.chevron_right,
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                              onTap: () =>
                                  Get.toNamed(Routes.analyzeFingerprints),
                            ),
                          ),
                        ),
                        GlassContainer(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          borderRadius: 18,
                          child: Material(
                            color: Colors.transparent,
                            child: ListTile(
                              leading: Icon(
                                Icons.settings_outlined,
                                color: theme.colorScheme.primary,
                              ),
                              title: Text(
                                'Settings',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              trailing: Icon(
                                Icons.chevron_right,
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                              onTap: () => Get.toNamed(Routes.settings),
                            ),
                          ),
                        ),
                        GlassContainer(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          borderRadius: 18,
                          child: Material(
                            color: Colors.transparent,
                            child: ListTile(
                              leading: Icon(
                                Icons.admin_panel_settings_outlined,
                                color: theme.colorScheme.primary,
                              ),
                              title: Text(
                                'Permission Master',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              trailing: Icon(
                                Icons.chevron_right,
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                              onTap: () => Get.toNamed(Routes.permissions),
                            ),
                          ),
                        ),
                        GlassContainer(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          borderRadius: 18,
                          child: Material(
                            color: Colors.transparent,
                            child: ListTile(
                              leading: Icon(
                                Icons.groups_2_outlined,
                                color: theme.colorScheme.primary,
                              ),
                              title: Text(
                                'Role Master',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              trailing: Icon(
                                Icons.chevron_right,
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                              onTap: () {
                                Get.to(
                                  () => const RoleMasterView(),
                                  binding: RoleMasterBinding(),
                                  transition: Transition.cupertino,
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        GlassContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          borderRadius: 18,
                          child: Material(
                            color: Colors.transparent,
                            child: ListTile(
                              leading: loggingOut
                                  ? SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: theme.colorScheme.error,
                                      ),
                                    )
                                  : Icon(
                                      Icons.logout,
                                      color: theme.colorScheme.error,
                                    ),
                              title: Text(
                                loggingOut ? 'Logging out...' : 'Logout',
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onTap: loggingOut
                                  ? null
                                  : controller.confirmLogout,
                            ),
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

Future<void> _openSwitchAccountSheet(
  BuildContext context,
  PermissionService permissionService,
) async {
  final profile = permissionService.userProfile.value;
  if (profile == null) return;
  final accounts = profile.accounts;
  if (accounts.length <= 1) return;

  final theme = Theme.of(context);
  final selectedId = permissionService.activeAccountId.value;

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Material(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Switch Account',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                    itemCount: accounts.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final account = accounts[index];
                      final selected = account.id == selectedId;
                      return ListTile(
                        leading: Icon(
                          account.isFamilyMember
                              ? Icons.family_restroom_outlined
                              : Icons.person_outline,
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(account.displayName),
                        subtitle: Text(
                          [
                            if (account.isFamilyMember) 'Family',
                            if (account.email?.isNotEmpty ?? false)
                              account.email!,
                            if (account.subtitle?.isNotEmpty ?? false)
                              account.subtitle!,
                          ].join(' · '),
                        ),
                        trailing: selected
                            ? Icon(
                                Icons.check_circle,
                                color: theme.colorScheme.primary,
                              )
                            : null,
                        selected: selected,
                        onTap: () async {
                          await permissionService.setActiveAccount(account.id);
                          if (context.mounted) Navigator.pop(context);
                          if (Get.isRegistered<MainShellController>()) {
                            Get.find<MainShellController>().changeTab(0);
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
