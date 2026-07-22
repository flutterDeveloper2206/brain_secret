import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find();

  late final Rx<FlexScheme> selectedScheme;

  @override
  void onInit() {
    super.onInit();
    selectedScheme = (kDebugMode ? FlexScheme.vesuviusBurn : FlexScheme.material).obs;
  }

  void changeScheme(FlexScheme scheme) {
    selectedScheme.value = scheme;
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
    } else {
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
  }

  ThemeData get lightTheme => getTheme(false);
  ThemeData get darkTheme => getTheme(true);
}
