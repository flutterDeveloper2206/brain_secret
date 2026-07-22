import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppColors {
  // Light Mode Color Palette
  static const Color primaryLight = Colors.blue;
  static const Color backgroundLight = Color(0xFFF5F5F7);
  static const Color cardLight = Colors.white;
  static const Color textLight = Color(0xFF1D1D1F);
  static const Color accentLight = Colors.blueAccent;

  // Dark Mode Color Palette
  static const Color primaryDark = Color(0xFF2196F3);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1E1E1E);
  static const Color textDark = Colors.white;
  static const Color accentDark = Colors.blueAccent;

  // Debug Mode Overrides (e.g. Orange accent)
  static const Color primaryDebug = Colors.deepOrangeAccent;
  static const Color accentDebug = Colors.orangeAccent;

  // Dynamic Primary Color resolver
  static Color getPrimary(bool isDark) {
    if (kDebugMode) {
      return primaryDebug;
    }
    return isDark ? primaryDark : primaryLight;
  }

  // Dynamic Accent Color resolver
  static Color getAccent(bool isDark) {
    if (kDebugMode) {
      return accentDebug;
    }
    return isDark ? accentDark : accentLight;
  }
}
