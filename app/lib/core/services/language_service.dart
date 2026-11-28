import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';
import '../utils/logger.dart';
import 'hive_service.dart';

/// Service for managing the app language. The choice is saved in the Hive
/// settings box so it survives restarts (like the theme in ThemeService).
class LanguageService {
  static LanguageService? _instance;
  static LanguageService get instance => _instance ??= LanguageService._();

  LanguageService._();

  /// Settings key for the saved language code. HiveService.clearAllData keeps
  /// this key, so Clear Cache doesn't reset the language.
  static const String languageKey = 'language_code';

  Locale _currentLocale = const Locale('en');

  /// Current locale
  Locale get currentLocale => _currentLocale;

  /// Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('es'),
  ];

  /// Loads the saved language. Call after HiveService.initialize().
  /// Falls back to English when nothing (or something unsupported) is saved.
  Future<void> initialize() async {
    try {
      final saved = HiveService.instance.getSetting<String>(languageKey);
      final match = supportedLocales.where((l) => l.languageCode == saved);
      _currentLocale = match.isNotEmpty ? match.first : const Locale('en');
      Logger.hive('Language loaded: ${_currentLocale.languageCode}');
    } catch (e) {
      Logger.hive('Error loading saved language', error: e);
      _currentLocale = const Locale('en');
    }
  }

  /// Changes the language and saves it.
  Future<void> changeLanguage(Locale locale) async {
    if (!supportedLocales.contains(locale)) {
      throw Exception('Unsupported locale: ${locale.languageCode}');
    }
    _currentLocale = locale;
    try {
      await HiveService.instance.storeSetting(languageKey, locale.languageCode);
    } catch (e) {
      // The switch still applies for this session; it just won't persist.
      Logger.hive('Error saving language', error: e);
    }
  }

  /// Gets localized string from AppLocalizations
  String getLocalizedString(BuildContext context, String Function(AppLocalizations) getter) {
    final localizations = AppLocalizations.of(context);
    return getter(localizations);
  }
}
