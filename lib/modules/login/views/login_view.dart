import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_constants.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/theme_selector_fab.dart';
import '../controllers/login_controller.dart';
import 'widgets/login_form.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: GradientBackground(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow =
                constraints.maxWidth < AppConstants.breakpointTablet;

            if (isNarrow) {
              return _MobileLoginLayout(theme: theme);
            }
            return _WideLoginLayout(theme: theme);
          },
        ),
      ),
      floatingActionButton: const ThemeSelectorFab(),
    );
  }
}

class _MobileLoginLayout extends StatelessWidget {
  const _MobileLoginLayout({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _BrandHeader(theme: theme, logoSize: 96),
                const SizedBox(height: 28),
                const GlassContainer(
                  padding: EdgeInsets.all(24),
                  borderRadius: 20,
                  child: LoginForm(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WideLoginLayout extends StatelessWidget {
  const _WideLoginLayout({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: _BrandHeader(theme: theme, logoSize: 140),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 32,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: const GlassContainer(
                    padding: EdgeInsets.all(28),
                    borderRadius: 22,
                    child: LoginForm(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.theme, required this.logoSize});

  final ThemeData theme;
  final double logoSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GlassContainer(
          borderRadius: 999,
          blur: 16,
          padding: EdgeInsets.all(logoSize * 0.12),
          child: SizedBox(
            width: logoSize * 0.76,
            height: logoSize * 0.76,
            child: Icon(
              Icons.fingerprint,
              size: logoSize * 0.5,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          AppConstants.appName,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          AppConstants.appTagline,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.65),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
