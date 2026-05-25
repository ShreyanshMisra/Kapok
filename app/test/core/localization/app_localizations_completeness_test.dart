import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Lightweight static analysis of `app_localizations.dart` to catch the most
/// common bilingual drift: an English key landing in a PR without its Spanish
/// counterpart (or vice versa).
///
/// This intentionally does **not** import [AppLocalizations] — that would pull
/// Flutter localization plumbing into a unit test. We instead parse the source
/// file and compare key sets.
void main() {
  late File source;

  setUpAll(() {
    source = File('lib/core/localization/app_localizations.dart');
    expect(source.existsSync(), isTrue,
        reason:
            'Localization file not found. Run `flutter test` from the `app/` directory.');
  });

  group('app_localizations.dart', () {
    test('English and Spanish key sets are identical', () {
      final raw = source.readAsStringSync();

      final enKeys = _keysIn(_sliceLocale(raw, "'en':"));
      final esKeys = _keysIn(_sliceLocale(raw, "'es':"));

      expect(enKeys, isNotEmpty,
          reason: 'No English keys parsed — parser likely broken.');
      expect(esKeys, isNotEmpty,
          reason: 'No Spanish keys parsed — parser likely broken.');

      final missingInSpanish = enKeys.difference(esKeys);
      final missingInEnglish = esKeys.difference(enKeys);

      expect(
        missingInSpanish,
        isEmpty,
        reason: 'Spanish translations missing for: $missingInSpanish',
      );
      expect(
        missingInEnglish,
        isEmpty,
        reason: 'English translations missing for: $missingInEnglish',
      );
    });

    test('every getter has a backing entry in the English map', () {
      final raw = source.readAsStringSync();
      final getterKeys = RegExp(r"_getString\('([^']+)'\)")
          .allMatches(raw)
          .map((m) => m.group(1)!)
          .toSet();

      final enKeys = _keysIn(_sliceLocale(raw, "'en':"));

      final orphans = getterKeys.difference(enKeys);
      expect(
        orphans,
        isEmpty,
        reason:
            'These getter keys have no English value (they would return the key itself at runtime): $orphans',
      );
    });
  });
}

/// Returns the slice of [source] for a single locale block.
///
/// The localization file is shaped like:
///
///     'en': {
///       'appName': '...',
///       ...
///     },
///     'es': {
///       'appName': '...',
///       ...
///     },
///
/// We grab from the locale marker to the next `'es':` / `'en':` / end-of-map.
String _sliceLocale(String source, String startMarker) {
  final start = source.indexOf(startMarker);
  if (start < 0) return '';
  final afterStart = start + startMarker.length;

  // Find the closing brace for this locale's map by counting braces.
  final openBraceIdx = source.indexOf('{', afterStart);
  if (openBraceIdx < 0) return '';
  int depth = 0;
  int? endIdx;
  for (var i = openBraceIdx; i < source.length; i++) {
    final ch = source[i];
    if (ch == '{') depth++;
    if (ch == '}') {
      depth--;
      if (depth == 0) {
        endIdx = i;
        break;
      }
    }
  }
  if (endIdx == null) return '';
  return source.substring(openBraceIdx, endIdx + 1);
}

Set<String> _keysIn(String localeBlock) {
  // Matches `'someKey':` at start of an entry, ignoring nested quotes inside
  // values.
  final re = RegExp(r"'([A-Za-z0-9_]+)'\s*:");
  return re.allMatches(localeBlock).map((m) => m.group(1)!).toSet();
}
