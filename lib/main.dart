import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/theme_controller.dart';
import 'routes/app_pages.dart';

void main() {
  runApp(const RidgeCounterApp());
}

class RidgeCounterApp extends StatelessWidget {
  const RidgeCounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.put(ThemeController());
    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Fingerprint Ridge Counter',
        theme: themeController.lightTheme,
        darkTheme: themeController.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: AppPages.initial,
        getPages: AppPages.routes,
      ),
    );
  }
}
