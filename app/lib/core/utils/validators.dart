import '../localization/app_localizations.dart';

/// Static validators for form fields.
///
/// Every method has two variants:
///   - `validate*(value)` — returns a hardcoded English string (for contexts
///     where [AppLocalizations] is unavailable, e.g. inside a [TextFormField]
///     `validator` callback without a context).
///   - `validate*(value, l10n: localizations)` — returns a localized string.
class Validators {
  // ─────────────────────────── Email ───────────────────────────

  static String? validateEmail(String? value, {AppLocalizations? l10n}) {
    if (value == null || value.isEmpty) {
      return l10n?.validationEmailRequired ?? 'Email is required';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return l10n?.validationEmailInvalid ?? 'Please enter a valid email address';
    }
    return null;
  }

  // ─────────────────────────── Password ────────────────────────

  static String? validatePassword(String? value, {AppLocalizations? l10n}) {
    if (value == null || value.isEmpty) {
      return l10n?.validationPasswordRequired ?? 'Password is required';
    }
    if (value.length < 6) {
      return l10n?.validationPasswordTooShort ?? 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? confirmPassword(String? value, String? password, {AppLocalizations? l10n}) {
    if (value == null || value.isEmpty) {
      return l10n?.validationPasswordRequired ?? 'Password is required';
    }
    if (value != password) {
      return l10n?.validationPasswordsNoMatch ?? 'Passwords do not match';
    }
    return null;
  }

  // ─────────────────────────── Name ────────────────────────────

  static String? validateName(String? value, {AppLocalizations? l10n}) {
    if (value == null || value.isEmpty) {
      return l10n?.validationNameRequired ?? 'Name is required';
    }
    if (value.length < 2) {
      return l10n?.validationNameTooShort ?? 'Name must be at least 2 characters';
    }
    if (value.length > 50) {
      return l10n?.validationNameTooLong ?? 'Name must be less than 50 characters';
    }
    return null;
  }

  // ─────────────────────────── Team code ───────────────────────

  static String? teamCode(String? value, {AppLocalizations? l10n}) {
    if (value == null || value.isEmpty) {
      return l10n?.validationTeamCodeRequired ?? 'Team code is required';
    }
    if (value.length < 4) {
      return l10n?.validationTeamCodeTooShort ?? 'Team code must be at least 4 characters';
    }
    if (value.length > 20) {
      return l10n?.validationTeamCodeTooLong ?? 'Team code must be less than 20 characters';
    }
    final codeRegex = RegExp(r'^[a-zA-Z0-9]+$');
    if (!codeRegex.hasMatch(value)) {
      return l10n?.validationTeamCodeAlphanumeric ?? 'Team code can only contain letters and numbers';
    }
    return null;
  }

  // ─────────────────────────── Team name ───────────────────────

  static String? teamName(String? value, {AppLocalizations? l10n}) {
    if (value == null || value.isEmpty) {
      return l10n?.validationTeamNameRequired ?? 'Team name is required';
    }
    if (value.length < 3) {
      return l10n?.validationTeamNameTooShort ?? 'Team name must be at least 3 characters';
    }
    if (value.length > 50) {
      return l10n?.validationTeamNameTooLong ?? 'Team name must be less than 50 characters';
    }
    return null;
  }

  // ─────────────────────────── Task name ───────────────────────

  static String? taskName(String? value, {AppLocalizations? l10n}) {
    if (value == null || value.isEmpty) {
      return l10n?.validationTaskNameRequired ?? 'Task name is required';
    }
    if (value.length < 3) {
      return l10n?.validationTaskNameTooShort ?? 'Task name must be at least 3 characters';
    }
    if (value.length > 100) {
      return l10n?.validationTaskNameTooLong ?? 'Task name must be less than 100 characters';
    }
    return null;
  }

  // ─────────────────────────── Task description ────────────────

  static String? taskDescription(String? value, {AppLocalizations? l10n}) {
    if (value != null && value.length > 500) {
      return l10n?.validationTaskDescTooLong ?? 'Description must be less than 500 characters';
    }
    return null;
  }

  // ─────────────────────────── Generic ─────────────────────────

  static String? required(String? value, String fieldName, {AppLocalizations? l10n}) {
    if (value == null || value.isEmpty) {
      return l10n?.validationFieldRequired ?? '$fieldName is required';
    }
    return null;
  }

  static String? taskSeverity(int? value) {
    if (value == null) return 'Task severity is required';
    if (value < 1 || value > 5) return 'Task severity must be between 1 and 5';
    return null;
  }

  static String? latitude(double? value) {
    if (value == null) return 'Latitude is required';
    if (value < -90 || value > 90) return 'Latitude must be between -90 and 90';
    return null;
  }

  static String? longitude(double? value) {
    if (value == null) return 'Longitude is required';
    if (value < -180 || value > 180) return 'Longitude must be between -180 and 180';
    return null;
  }

  static String? minLength(String? value, int minLen, String fieldName) {
    if (value == null || value.isEmpty) return '$fieldName is required';
    if (value.length < minLen) return '$fieldName must be at least $minLen characters';
    return null;
  }

  static String? maxLength(String? value, int maxLen, String fieldName) {
    if (value == null || value.isEmpty) return '$fieldName is required';
    if (value.length > maxLen) return '$fieldName must be less than $maxLen characters';
    return null;
  }

  static String? numericRange(num? value, num min, num max, String fieldName) {
    if (value == null) return '$fieldName is required';
    if (value < min || value > max) return '$fieldName must be between $min and $max';
    return null;
  }

  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    final digits = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length < 10) return 'Phone number must be at least 10 digits';
    if (digits.length > 15) return 'Phone number must be less than 15 digits';
    return null;
  }

  static String? url(String? value) {
    if (value == null || value.isEmpty) return 'URL is required';
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    if (!urlRegex.hasMatch(value)) return 'Please enter a valid URL';
    return null;
  }

  static String? combine(List<String? Function()> validators) {
    for (final v in validators) {
      final result = v();
      if (result != null) return result;
    }
    return null;
  }

  // ─── Legacy aliases (keep backward compatibility) ─────────────
  static String? email(String? value) => validateEmail(value);
  static String? password(String? value) => validatePassword(value);
  static String? name(String? value) => validateName(value);
}
