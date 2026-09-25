import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_constants.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/glass_app_bar.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/theme_selector_fab.dart';
import '../../../data/models/user_profile.dart';
import '../controllers/user_profile_controller.dart';

class UserProfileView extends GetView<UserProfileController> {
  const UserProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: GlassAppBar(
        title: 'My Profile',
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: controller.loadProfile,
            icon: Icon(Icons.refresh_rounded, color: theme.colorScheme.primary),
          ),
        ],
      ),
      floatingActionButton: const ThemeSelectorFab(
        heroTag: 'user_profile_theme_fab',
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
                        controller.profile.value == null) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final user = controller.profile.value;
                    if (user == null) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontal),
                        child: GlassContainer(
                          padding: const EdgeInsets.all(28),
                          borderRadius: 20,
                          child: Text(
                            'User profile not available.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: controller.loadProfile,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: EdgeInsets.fromLTRB(
                          horizontal,
                          8,
                          horizontal,
                          24,
                        ),
                        children: [
                          _HeroHeader(user: user),
                          const SizedBox(height: 16),
                          _SectionGrid(
                            isNarrow: isNarrow,
                            sections: [
                              _SectionData(
                                title: 'Account',
                                icon: Icons.person_outline,
                                rows: [
                                  ('User Code', '${user.userCode}'),
                                  ('Username', user.userName),
                                  ('Full Name', user.fullName ?? '—'),
                                  ('User Type', user.userType),
                                ],
                              ),
                              _SectionData(
                                title: 'Contact',
                                icon: Icons.contact_mail_outlined,
                                rows: [
                                  ('Email', user.emailId),
                                  ('Mobile', user.mobileNo),
                                ],
                              ),
                              _SectionData(
                                title: 'Membership',
                                icon: Icons.calendar_month_outlined,
                                rows: [
                                  (
                                    'Member Since',
                                    _formatMemberSince(user.memberSince),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
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

  String _formatMemberSince(String? value) {
    if (value == null || value.isEmpty) return '—';
    if (value.startsWith('0001-01-01')) return '—';
    return value;
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.user});

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final photoUrl = user.profilePhotoUrl;

    return GlassContainer(
      elevated: true,
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Row(
        children: [
          if (photoUrl != null && photoUrl.isNotEmpty)
            CircleAvatar(
              radius: 38,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
              backgroundImage: NetworkImage(photoUrl),
              onBackgroundImageError: (_, __) {},
            )
          else
            const AppAvatar(radius: 38),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                if (user.emailId.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    user.emailId,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                ],
                if (user.userType.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      user.userType.toUpperCase(),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
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
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      row.$2.isEmpty ? '—' : row.$2,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
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
