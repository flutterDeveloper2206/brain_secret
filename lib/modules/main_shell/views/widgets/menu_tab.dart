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
          Obx(
            () => IconButton(
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
            ),
          ),
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
                    final displayName = profile?.displayName ?? 'Account';
                    final subtitle = (profile?.emailId.isNotEmpty ?? false)
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
                        GlassContainer(
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
                        const SizedBox(height: 16),
                        GlassContainer(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          borderRadius: 18,
                          child: Material(
                            color: Colors.transparent,
                            child: ListTile(
                              leading: Icon(
                                Icons.account_circle_outlined,
                                color: theme.colorScheme.primary,
                              ),
                              title: Text(
                                'Profile',
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
                              onTap: () => Get.toNamed(Routes.userProfile),
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
                        GlassContainer(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          borderRadius: 18,
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
                              onTap:
                                  loggingOut ? null : controller.confirmLogout,
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
