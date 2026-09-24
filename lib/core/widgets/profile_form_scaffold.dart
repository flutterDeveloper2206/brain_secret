import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../values/app_constants.dart';
import 'custom_button.dart';
import 'glass_app_bar.dart';
import 'glass_container.dart';
import 'gradient_background.dart';
import 'theme_selector_fab.dart';

class ProfileFormScaffold extends StatelessWidget {
  const ProfileFormScaffold({
    super.key,
    required this.title,
    required this.form,
    required this.isSaving,
    required this.onSave,
    this.saveLabel = 'Save & Continue',
  });

  final String title;
  final Widget form;
  final RxBool isSaving;
  final VoidCallback onSave;
  final String saveLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(title: title),
      floatingActionButton: const ThemeSelectorFab(
        heroTag: 'profile_theme_fab',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: GradientBackground(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow =
                constraints.maxWidth < AppConstants.breakpointTablet;
            final maxWidth = isNarrow ? double.infinity : 920.0;
            final horizontalPadding = isNarrow ? 16.0 : 28.0;
            final topInset =
                MediaQuery.of(context).padding.top + kToolbarHeight;
            // Keep save bar clear of the theme FAB on web/desktop.
            final fabClearance = isNarrow ? 16.0 : 88.0;

            return Column(
              children: [
                SizedBox(height: topInset + 12),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      0,
                      horizontalPadding,
                      24,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: form,
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      0,
                      horizontalPadding + (isNarrow ? 0 : 8),
                      12,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isNarrow
                              ? maxWidth
                              : (maxWidth - fabClearance).clamp(280.0, maxWidth),
                        ),
                        child: GlassContainer(
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                          borderRadius: 18,
                          blur: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Review the details, then save to continue',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodyMedium?.color
                                      ?.withValues(alpha: 0.65),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              Obx(
                                () => CustomButton(
                                  text: saveLabel,
                                  icon: Icons.arrow_forward_rounded,
                                  width: double.infinity,
                                  isLoading: isSaving.value,
                                  onPressed: onSave,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
