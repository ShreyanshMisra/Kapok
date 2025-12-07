import 'package:flutter/material.dart';
import '../services/hive_service.dart';
import '../utils/logger.dart';

/// Service for managing theme state and persistence
class ThemeService {
  static ThemeService? _instance;
  static ThemeService get instance => _instance ??= ThemeService._();
  
  ThemeService._();

  static const String _themeModeKey = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.system;

  /// Current theme mode
  ThemeMode get themeMode => _themeMode;

  /// Initializes theme service and loads saved preference
  Future<void> initialize() async {
    try {
      Logger.hive('Initializing ThemeService');
      
      // Load saved theme preference from Hive
      final savedTheme = HiveService.instance.getSetting<String>(_themeModeKey);
      
      if (savedTheme != null) {
        switch (savedTheme) {
          case 'light':
            _themeMode = ThemeMode.light;
            break;
          case 'dark':
            _themeMode = ThemeMode.dark;
            break;
          case 'system':
          default:
            _themeMode = ThemeMode.system;
            break;
        }
        Logger.hive('Theme preference loaded: $_themeMode');
      } else {
        _themeMode = ThemeMode.system;
        Logger.hive('No saved theme preference, using system default');
      }
    } catch (e) {
      Logger.hive('Error initializing ThemeService', error: e);
      _themeMode = ThemeMode.system; // Default to system
    }
  }

  /// Changes the theme mode and saves it
  Future<void> changeThemeMode(ThemeMode mode) async {
    try {
      _themeMode = mode;
      
      // Save to Hive
      String themeString;
      switch (mode) {
        case ThemeMode.light:
          themeString = 'light';
          break;
        case ThemeMode.dark:
          themeString = 'dark';
          break;
        case ThemeMode.system:
          themeString = 'system';
          break;
      }
      
      await HiveService.instance.storeSetting(_themeModeKey, themeString);
      Logger.hive('Theme mode changed to: $mode');
    } catch (e) {
      Logger.hive('Error changing theme mode', error: e);
      rethrow;
    }
  }
}

