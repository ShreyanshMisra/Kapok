import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';

/// Service for managing language and translations
class LanguageService {
  static LanguageService? _instance;
  static LanguageService get instance => _instance ??= LanguageService._();
  
  LanguageService._();

  Locale _currentLocale = const Locale('en');
  
  /// Current locale
  Locale get currentLocale => _currentLocale;
  
  /// Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('es'),
  ];

  /// Changes the language
  Future<void> changeLanguage(Locale locale) async {
    if (!supportedLocales.contains(locale)) {
      throw Exception('Unsupported locale: ${locale.languageCode}');
    }
    _currentLocale = locale;
  }

  /// Gets localized string from AppLocalizations
  String getLocalizedString(BuildContext context, String Function(AppLocalizations) getter) {
    final localizations = AppLocalizations.of(context);
    return getter(localizations);
  }
}

