import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/values/app_constants.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../../../data/providers/permission_service.dart';
import '../../../../routes/app_routes.dart';
import '../../../home/controllers/home_controller.dart';

class DashboardTab extends GetView<HomeController> {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: const GlassAppBar(
        title: 'Dashboard',
        showBack: false,
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow =
                      constraints.maxWidth < AppConstants.breakpointTablet;
                  final horizontal = isNarrow ? 16.0 : 28.0;
                  final maxWidth = isNarrow ? double.infinity : 980.0;

                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(
                              horizontal,
                              12,
                              horizontal,
                              24,
                            ),
                            sliver: Obx(() {
                              final permissionService =
                                  Get.find<PermissionService>();
                              final sessionType =
                                  permissionService.session.value?.userType ??
                                  'User';
                              final profile = permissionService.userProfile.value;
                              final active = permissionService.activeAccount;
                              permissionService.activeAccountId.value;

                              final userType =
                                  (profile?.userType.isNotEmpty ?? false)
                                  ? profile!.userType
                                  : sessionType;
                              final displayName =
                                  (active?.displayName.isNotEmpty ?? false)
                                  ? active!.displayName
                                  : profile?.displayName;
                              final email = (active?.email?.isNotEmpty ?? false)
                                  ? active!.email!
                                  : (profile?.emailId ?? '');
                              final mobile =
                                  (active?.mobile?.isNotEmpty ?? false)
                                  ? active!.mobile!
                                  : (profile?.mobileNo ?? '');
                              final accountSubtitle = active?.subtitle;
                              final moduleCount =
                                  permissionService.sideBar.length;
                              final actionCount =
                                  permissionService.actionCodes.length;

                              return SliverList(
                                delegate: SliverChildListDelegate([
                                  _WelcomeHeader(
                                    theme: theme,
                                    userType: userType,
                                    displayName: displayName,
                                    email: email,
                                    mobile: mobile,
                                    accountSubtitle: accountSubtitle,
                                  ),
                                  const SizedBox(height: 16),
                                  _StatsRow(
                                    theme: theme,
                                    isNarrow: isNarrow,
                                    moduleCount: moduleCount,
                                    actionCount: actionCount,
                                    userType: userType,
                                  ),
                                  const SizedBox(height: 22),
                                  Text(
                                    'Quick actions',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Start a scan or import an image for analysis',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.textTheme.bodyMedium?.color
                                          ?.withValues(alpha: 0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  _ActionsGrid(
                                    theme: theme,
                                    isNarrow: isNarrow,
                                    onDemoScan: controller.scanFingerprint,
                                    onDeviceScan: () =>
                                        Get.toNamed(Routes.handSelector),
                                    onImport: controller.pickImage,
                                  ),
                                  const SizedBox(height: 22),
                                  Text(
                                    'Overview',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  _OverviewCard(theme: theme),
                                ]),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Obx(() {
                if (!controller.isLoading.value) {
                  return const SizedBox.shrink();
                }
                return Container(
                  color: Colors.black.withValues(alpha: 0.35),
                  child: const Center(child: CircularProgressIndicator()),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({
    required this.theme,
    required this.userType,
    this.displayName,
    this.email = '',
    this.mobile = '',
    this.accountSubtitle,
  });

  final ThemeData theme;
  final String userType;
  final String? displayName;
  final String email;
  final String mobile;
  final String? accountSubtitle;

  @override
  Widget build(BuildContext context) {
    final title = (displayName != null && displayName!.isNotEmpty)
        ? displayName!
        : AppConstants.appName;
    final subtitleParts = <String>[
      if (accountSubtitle != null && accountSubtitle!.isNotEmpty)
        accountSubtitle!,
      if (email.isNotEmpty) email,
      if (mobile.isNotEmpty) mobile,
    ];

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 22,
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
            ),
            child: const Icon(
              Icons.fingerprint,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withValues(
                      alpha: 0.65,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: theme.colorScheme.primary,
                  ),
                ),
                if (subtitleParts.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitleParts.join(' · '),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withValues(
                        alpha: 0.65,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    userType.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
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

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.theme,
    required this.isNarrow,
    required this.moduleCount,
    required this.actionCount,
    required this.userType,
  });

  final ThemeData theme;
  final bool isNarrow;
  final int moduleCount;
  final int actionCount;
  final String userType;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatCard(
        theme: theme,
        icon: Icons.apps_outlined,
        label: 'Modules',
        value: '$moduleCount',
      ),
      _StatCard(
        theme: theme,
        icon: Icons.verified_user_outlined,
        label: 'Actions',
        value: '$actionCount',
      ),
      _StatCard(
        theme: theme,
        icon: Icons.shield_outlined,
        label: 'Access',
        value: userType.isEmpty ? '—' : userType,
      ),
    ];

    if (isNarrow) {
      return Row(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(child: cards[i]),
          ],
        ],
      );
    }

    return Row(
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          if (i > 0) const SizedBox(width: 14),
          Expanded(child: cards[i]),
        ],
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.theme,
    required this.icon,
    required this.label,
    required this.value,
  });

  final ThemeData theme;
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionsGrid extends StatelessWidget {
  const _ActionsGrid({
    required this.theme,
    required this.isNarrow,
    required this.onDemoScan,
    required this.onDeviceScan,
    required this.onImport,
  });

  final ThemeData theme;
  final bool isNarrow;
  final VoidCallback onDemoScan;
  final VoidCallback onDeviceScan;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionItem(
        title: 'Demo Scan',
        subtitle: 'Simulated FS80H capture',
        icon: Icons.usb_rounded,
        color: theme.colorScheme.secondary,
        onTap: onDemoScan,
      ),
      _ActionItem(
        title: 'Device Scan',
        subtitle: 'Live fingerprint capture',
        icon: Icons.fingerprint,
        color: theme.colorScheme.primary,
        onTap: onDeviceScan,
      ),
      _ActionItem(
        title: 'Import Image',
        subtitle: 'Pick from gallery',
        icon: Icons.photo_library_outlined,
        color: theme.colorScheme.tertiary,
        onTap: onImport,
      ),
    ];

    if (isNarrow) {
      return Column(
        children: [
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _ActionCard(theme: theme, item: actions[i]),
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(width: 14),
          Expanded(child: _ActionCard(theme: theme, item: actions[i])),
        ],
      ],
    );
  }
}

class _ActionItem {
  const _ActionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.theme,
    required this.item,
  });

  final ThemeData theme;
  final _ActionItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(20),
        child: GlassContainer(
          padding: const EdgeInsets.all(18),
          borderRadius: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.icon, color: item.color, size: 26),
              ),
              const SizedBox(height: 16),
              Text(
                item.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withValues(
                    alpha: 0.6,
                  ),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(
                    'Open',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: item.color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: item.color,
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

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: 20,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.tips_and_updates_outlined,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tip',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Use Device Scan for live capture, or Import Image to analyze an existing fingerprint photo.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withValues(
                      alpha: 0.65,
                    ),
                    height: 1.35,
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
