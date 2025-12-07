# Localization Workflow for Kapok App

## Overview

The Kapok app supports English and Spanish. This guide outlines the process for adding new localized strings to ensure all new features are multi-language compatible.

## Core Principles

1. **Centralized Strings**: All user-facing text should be managed through `AppLocalizations`.
2. **Context-Aware**: Always use `AppLocalizations.of(context)` to retrieve strings.
3. **Two-Step Process**: Define the string in `AppLocalizations` (getter and `localizedValues` map) and then use it in your widgets.

## Step-by-Step Guide

### Step 1: Define the New String in `app_localizations.dart`

Navigate to `lib/core/localization/app_localizations.dart`.

**a. Add a Getter:**
Inside the `AppLocalizations` class, add a new getter for your string. Choose a descriptive key.

```dart
// Example: For a new button text "Save Changes"
String get saveChanges => _getString('saveChanges');
```

**b. Add Translations to `localizedValues` Map:**
Scroll down to the `_getString` method and locate the `localizedValues` map. Add your new key with translations for both 'en' (English) and 'es' (Spanish).

```dart
// Inside the _getString method, within the 'en' map:
'en': {
  // ... existing English strings
  'saveChanges': 'Save Changes',
},
// Inside the _getString method, within the 'es' map:
'es': {
  // ... existing Spanish strings
  'saveChanges': 'Guardar Cambios',
},
```

### Step 2: Use the Localized String in Your Widget

In your Flutter widget (e.g., a `Text` widget, `AppBar` title, `Button` label), replace any hardcoded strings with the `AppLocalizations` getter.

**a. Import `app_localizations.dart`:**
Ensure your widget file imports the localization class:

```dart
import 'package:kapok_app/core/localization/app_localizations.dart';
```

**b. Access the String:**
Use `AppLocalizations.of(context).yourStringKey` to display the localized text.

```dart
// Example: For a button label
ElevatedButton(
  onPressed: () {
    // ...
  },
  child: Text(AppLocalizations.of(context).saveChanges),
)

// Example: For an AppBar title
AppBar(
  title: Text(AppLocalizations.of(context).myNewFeatureTitle),
)
```

### Step 3: Test the Localization

After implementing the changes:

1. **Hot Restart** your application (press `R` in the terminal or use your IDE's hot restart button). A full restart might be necessary if you changed core localization delegates or `MaterialApp` properties.
2. Navigate to the feature where you added the new strings.
3. Go to the "Settings" page and switch the app language between English and Spanish.
4. Verify that your new strings correctly change language.

## Best Practices

*   **Descriptive Keys**: Use clear and descriptive keys for your strings (e.g., `loginButtonText` instead of `btn1`).
*   **Avoid Duplication**: Before adding a new string, check if an existing one can be reused.
*   **Contextual Translation**: Provide translations that make sense in the context of the UI.
*   **Dynamic Content**: For content that needs to be translated dynamically (e.g., user-generated input, API responses), use the `LanguageService.instance.translateText()` method. This is separate from `AppLocalizations` which is for static UI strings.

## Checklist for New Features

When adding a new feature, ensure the following:

-   [ ] All user-facing static text has a corresponding getter in `AppLocalizations`.
-   [ ] Both English (`en`) and Spanish (`es`) translations are provided for all new strings in `localizedValues`.
-   [ ] Widgets use `AppLocalizations.of(context).<stringKey>` to display text.
-   [ ] The feature has been tested in both English and Spanish.

## Quick Reference

*   **Localization File**: `lib/core/localization/app_localizations.dart`
*   **Language Service**: `lib/core/services/language_service.dart`
*   **Language Provider**: `lib/core/providers/language_provider.dart`
*   **Accessing Strings**: `AppLocalizations.of(context).yourStringKey`
*   **Dynamic Translation**: `LanguageService.instance.translateText('text', targetLocale: Locale('es'))`

## Common Patterns

### For Dropdown Menus with Localized Options

```dart
DropdownButtonFormField<String>(
  items: () {
    final localizations = AppLocalizations.of(context);
    final options = [
      {'value': 'option1', 'label': localizations.optionOne},
      {'value': 'option2', 'label': localizations.optionTwo},
    ];
    return options.map((Map<String, String> option) {
      return DropdownMenuItem(
        value: option['value'],
        child: Text(option['label']!),
      );
    }).toList();
  }(),
  // ... rest of the widget
)
```

### For Strings with Placeholders

If you need to include dynamic values in your strings:

```dart
// In app_localizations.dart:
'en': {
  'welcomeMessage': 'Welcome, {name}!',
},
'es': {
  'welcomeMessage': '¡Bienvenido, {name}!',
},

// In your widget:
Text(AppLocalizations.of(context).welcomeMessage.replaceAll('{name}', userName))
```

### For Dialog Builders

Always get localizations inside the builder function:

```dart
showDialog(
  context: context,
  builder: (context) {
    final localizations = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(localizations.myDialogTitle),
      content: Text(localizations.myDialogContent),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(localizations.cancel),
        ),
      ],
    );
  },
)
```

## What NOT to Do

❌ **Don't hardcode strings directly in widgets:**
```dart
// BAD
Text('Save Changes')
AppBar(title: Text('My Feature'))
```

✅ **Do use AppLocalizations:**
```dart
// GOOD
Text(AppLocalizations.of(context).saveChanges)
AppBar(title: Text(AppLocalizations.of(context).myFeature))
```

❌ **Don't forget to add Spanish translations:**
```dart
// BAD - Only English
'en': {
  'myString': 'My String',
},
// Missing 'es' translation
```

✅ **Do add both languages:**
```dart
// GOOD
'en': {
  'myString': 'My String',
},
'es': {
  'myString': 'Mi Cadena',
},
```

## Summary

**When implementing a new feature:**

1. **Identify all text** that will be displayed to users
2. **Add getters** in `AppLocalizations` class
3. **Add translations** in both `'en'` and `'es'` maps
4. **Replace hardcoded strings** with `AppLocalizations.of(context).yourKey`
5. **Test** by switching languages in Settings

This ensures your feature will automatically work in both English and Spanish!
