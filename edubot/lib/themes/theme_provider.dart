import 'package:flutter/material.dart';

// Enum to determine the app theme mode
enum AppThemeMode { system, light, dark }

class ThemeProvider with ChangeNotifier {
  // Assign the themedata an initial value
  AppThemeMode _mode = AppThemeMode.system;

  // Getters and setters
  AppThemeMode get mode => _mode;

  // Get possible theme modes
  ThemeMode get themeMode {
    switch (_mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  // Set theme mode method
  void setMode(AppThemeMode newMode) {
    _mode = newMode;
    notifyListeners();
  }

  // Toggle theme method
  void toggleTheme(bool isDark) {
    setMode(isDark ? AppThemeMode.dark : AppThemeMode.light);
  }
}
