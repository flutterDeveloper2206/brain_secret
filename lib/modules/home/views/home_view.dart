import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/theme_selector_fab.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fingerprint Scanner Dashboard'),
        centerTitle: true,
      ),
      body: GradientBackground(
        child: Stack(
          children: [
            // Background layout centering widgets
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Dynamic Scanner Icon
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.dark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.primaryColor.withValues(alpha: 0.2),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.fingerprint,
                          size: 90,
                          color: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Biometric Analyzer',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ready to capture scanner frame or upload image for line details counting.',
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color?.withValues(
                            alpha: 0.6,
                          ),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      // Action Scan Button
                      ElevatedButton.icon(
                        onPressed: controller.scanFingerprint,
                        icon: const Icon(Icons.usb),
                        label: const Text('Scan from FS80H (Demo)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Device Scan Button
                      ElevatedButton.icon(
                        onPressed: () => Get.toNamed('/handSelector'),
                        icon: const Icon(Icons.fingerprint),
                        label: const Text('Scan from FS80H (Device)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Gallery Import Button
                      OutlinedButton.icon(
                        onPressed: controller.pickImage,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Import from Gallery'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: theme.primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Loading Overlay indicator
            Obx(() {
              if (controller.isLoading.value) {
                return Container(
                  color: Colors.black54,
                  child: const Center(child: CircularProgressIndicator()),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
      floatingActionButton: const ThemeSelectorFab(),
    );
  }
}
