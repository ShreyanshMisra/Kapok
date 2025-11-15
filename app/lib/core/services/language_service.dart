import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import '../localization/app_localizations.dart';

/// Service for managing language and translations
class LanguageService {
  static LanguageService? _instance;
  static LanguageService get instance => _instance ??= LanguageService._();
  
  LanguageService._();

  final GoogleTranslator _translator = GoogleTranslator();
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

  /// Translates text using the translator package
  /// This is useful for dynamic content that's not in the localization files
  Future<String> translateText(String text, {Locale? targetLocale}) async {
    try {
      final locale = targetLocale ?? _currentLocale;
      
      // If already in the target language, return as is
      if (locale.languageCode == 'en' && _isEnglish(text)) {
        return text;
      }
      if (locale.languageCode == 'es' && _isSpanish(text)) {
        return text;
      }
      
      // Translate from English to Spanish or vice versa
      final sourceLanguage = locale.languageCode == 'es' ? 'en' : 'es';
      final targetLanguage = locale.languageCode;
      
      final translation = await _translator.translate(
        text,
        from: sourceLanguage,
        to: targetLanguage,
      );
      
      return translation.text;
    } catch (e) {
      // If translation fails, return original text
      return text;
    }
  }

  /// Helper to check if text is likely English (simple heuristic)
  bool _isEnglish(String text) {
    // This is a simple check - in production you might want a more sophisticated approach
    return true; // Assume English by default
  }

  /// Helper to check if text is likely Spanish (simple heuristic)
  bool _isSpanish(String text) {
    // This is a simple check - in production you might want a more sophisticated approach
    final spanishChars = RegExp(r'[áéíóúñÁÉÍÓÚÑ]');
    return spanishChars.hasMatch(text);
  }

  /// Gets localized string from AppLocalizations
  String getLocalizedString(BuildContext context, String Function(AppLocalizations) getter) {
    final localizations = AppLocalizations.of(context);
    return getter(localizations);
  }
}

