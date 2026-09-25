import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find();

  static const _keyThemeMode = 'settings_theme_mode';
  static const _keyFlexScheme = 'settings_flex_scheme';
  static const _keyNotifications = 'settings_notifications';

  late final Rx<FlexScheme> selectedScheme;
  final Rx<ThemeMode> themeMode = ThemeMode.light.obs;
  final RxBool notificationsEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    selectedScheme =
        (kDebugMode ? FlexScheme.vesuviusBurn : FlexScheme.material).obs;
    _hydratePrefs();
  }

  Future<void> _hydratePrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final modeRaw = prefs.getString(_keyThemeMode);
      if (modeRaw == 'dark') {
        themeMode.value = ThemeMode.dark;
      } else if (modeRaw == 'light') {
        themeMode.value = ThemeMode.light;
      }

      final schemeName = prefs.getString(_keyFlexScheme);
      if (schemeName != null && schemeName.isNotEmpty) {
        final match = FlexScheme.values.where((e) => e.name == schemeName);
        if (match.isNotEmpty) {
          selectedScheme.value = match.first;
        }
      }

      if (prefs.containsKey(_keyNotifications)) {
        notificationsEnabled.value = prefs.getBool(_keyNotifications) ?? true;
      }

      Get.changeThemeMode(themeMode.value);
      Get.changeTheme(getTheme(themeMode.value == ThemeMode.dark));
    } catch (_) {
      // Prefer defaults if prefs fail.
    }
  }

  Future<void> _persistThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyThemeMode,
      themeMode.value == ThemeMode.dark ? 'dark' : 'light',
    );
  }

  Future<void> _persistScheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFlexScheme, selectedScheme.value.name);
  }

  Future<void> _persistNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, notificationsEnabled.value);
  }

  void changeScheme(FlexScheme scheme) {
    selectedScheme.value = scheme;
    final isDark = themeMode.value == ThemeMode.dark;
    Get.changeTheme(getTheme(isDark));
    _persistScheme();
  }

  void setThemeMode(ThemeMode mode) {
    if (mode != ThemeMode.light && mode != ThemeMode.dark) {
      mode = ThemeMode.light;
    }
    themeMode.value = mode;
    Get.changeThemeMode(mode);
    Get.changeTheme(getTheme(mode == ThemeMode.dark));
    _persistThemeMode();
  }

  void setNotificationsEnabled(bool enabled) {
    notificationsEnabled.value = enabled;
    _persistNotifications();
  }

  String get schemeDisplayName {
    final data = FlexColor.schemes[selectedScheme.value];
    return data?.name ?? selectedScheme.value.name;
  }

  ThemeData getTheme(bool isDark) {
    final scheme = selectedScheme.value;

    if (isDark) {
      return FlexThemeData.dark(
        scheme: scheme,
        useMaterial3: true,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 13,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 20,
          useMaterial3Typography: true,
          elevatedButtonRadius: 12,
        ),
      );
    }

    return FlexThemeData.light(
      scheme: scheme,
      useMaterial3: true,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 7,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 10,
        useMaterial3Typography: true,
        elevatedButtonRadius: 12,
      ),
    );
  }

  ThemeData get lightTheme => getTheme(false);
  ThemeData get darkTheme => getTheme(true);
}
