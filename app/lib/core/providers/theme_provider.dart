import 'package:flutter/material.dart';
import '../services/theme_service.dart';

/// Provider for managing theme state
class ThemeProvider extends ChangeNotifier {
  final ThemeService _themeService = ThemeService.instance;
  
  /// Current theme mode
  ThemeMode get themeMode => _themeService.themeMode;
  
  /// Changes the theme mode and notifies listeners
  Future<void> changeThemeMode(ThemeMode mode) async {
    await _themeService.changeThemeMode(mode);
    notifyListeners();
  }
  
  /// Toggles between light and dark mode (skips system)
  Future<void> toggleTheme() async {
    final currentMode = _themeService.themeMode;
    if (currentMode == ThemeMode.light) {
      await changeThemeMode(ThemeMode.dark);
    } else {
      await changeThemeMode(ThemeMode.light);
    }
  }
  
  /// Gets the theme mode name for display
  String getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }
}

