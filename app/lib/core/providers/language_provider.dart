import 'package:flutter/material.dart';
import '../services/language_service.dart';

/// Provider for managing language state
class LanguageProvider extends ChangeNotifier {
  final LanguageService _languageService = LanguageService.instance;
  
  /// Current locale
  Locale get currentLocale => _languageService.currentLocale;
  
  /// Supported locales
  List<Locale> get supportedLocales => LanguageService.supportedLocales;
  
  /// Changes the language and notifies listeners
  Future<void> changeLanguage(Locale locale) async {
    await _languageService.changeLanguage(locale);
    notifyListeners();
  }
  
  /// Gets the language name
  String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      default:
        return locale.languageCode;
    }
  }
}

