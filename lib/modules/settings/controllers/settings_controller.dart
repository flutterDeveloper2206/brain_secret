import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/theme_scheme_bottom_sheet.dart';

class SettingsController extends GetxController {
  ThemeController get themeController => ThemeController.to;

  void openThemeSchemeSheet() {
    showThemeSchemeBottomSheet();
  }

  void setThemeMode(ThemeMode mode) {
    themeController.setThemeMode(mode);
  }

  void setNotificationsEnabled(bool enabled) {
    themeController.setNotificationsEnabled(enabled);
  }
}
