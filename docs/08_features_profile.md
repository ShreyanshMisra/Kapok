# Profile & Settings Features

_Last verified against the codebase: 2026-10-24._

## Overview

The profile area covers the user's account, app settings, legal documents, the About/Acknowledgements pages, and account deletion. It is the fourth tab on the home screen.

## Profile Page

### Location
`lib/features/profile/pages/profile_page.dart`

### UI Components

1. **App bar**: title, Settings gear (→ SettingsPage), Kapok logo
2. **Profile Header Card**
   - Avatar with user initial (first letter of name)
   - User name (bold, large)
   - User specialty/role (e.g., "Medical", "Engineering")
   - Account type badge (Team Leader, Team Member, Admin)
3. **Profile Actions Card**
   - Edit Profile → EditProfilePage
   - Settings → SettingsPage
   - About → AboutPage
4. **Account Information Card**: email, account type, role/specialty, user ID
5. **Permissions Table**
   - `DataTable` with columns: Action | Team Member | Team Leader | Admin
   - Rows: Create Team, Join Team, View Team, Edit Team, Close Team, Delete Team, Remove Member, Leave Team, View All Teams, Edit Own Tasks, Edit All Tasks
   - The current user's role column is highlighted, with a "Your Role: [role]" chip; horizontally scrollable on small screens

### Authentication Check

The page requires `AuthAuthenticated` state. If the user is not authenticated, it shows a "User not authenticated" message.

## Edit Profile Page

### Location
`lib/features/profile/pages/edit_profile_page.dart`

- Edit user name and role/specialty
- Saves via `AuthBloc` `ProfileUpdateRequested`
- Form validation for required fields

### Available Roles (Specialties)

Medical, Engineering, Carpentry, Plumbing, Construction, Electrical, Supplies, Transportation, Other

## Settings Page

### Location
`lib/features/profile/pages/settings_page.dart`

### Settings Sections

Sections, top to bottom: **Location**, **Language**, **Appearance**, **Data**, **About**, then the **Sign Out** and **Delete Account** buttons. The older Notifications, Privacy (analytics/crash toggles), Sync, Export Data, Feedback & Support, and Administrator Permissions entries have all been removed.

#### 1. Location
| Setting | Description |
|---------|-------------|
| Location Services | Toggle for app location access |

#### 2. Language
English (en) or Spanish (es), chosen in a dialog. Persisted via `LanguageProvider` in Hive.

#### 3. Appearance (Theme)
Three options (the follow-device option is labeled "Default", not "System"):
- Default (follows device setting)
- Light
- Dark

Persisted via `ThemeProvider` / `ThemeService` in Hive.

#### 4. Data
| Action | Description |
|--------|-------------|
| Clear Cache | Shows the approximate local cache size ("~N KB cached locally"); after confirmation calls `HiveService.clearAllData()` (tasks, teams, settings). Data is re-fetched from Firebase on next load. |

Analytics and crash reporting have no in-app toggle; collection defaults are applied by `AnalyticsService`. The privacy policy does not promise an in-app opt-out.

#### 5. About
- App version (`1.0.0`) and the "Built with ❤️ for disaster response coordination." tagline
- **Privacy Policy** and **Terms of Service** → open `LegalDocumentPage` (`lib/app/legal_document_page.dart`) with the text from `lib/core/constants/privacy_policy.dart` / `terms_of_service.dart`

### Sign Out

1. Confirmation dialog
2. Resets the Team, Task, and Map BLoCs
3. Dispatches `SignOutRequested`
4. Navigates to `/login`, clearing the navigation stack

### Delete Account

A red **Delete Account** button below Sign Out. The dialog requires typing a confirmation word, then dispatches `DeleteAccountRequested`. See [Authentication → Account Deletion Flow](04_features_authentication.md#account-deletion-flow) for the safeguards (recent sign-in, team leadership) and what is deleted vs. anonymized. On success the app returns to Login; on failure a snackbar explains why and the user stays signed in.

## Legal Documents

`lib/core/constants/privacy_policy.dart` and `terms_of_service.dart` hold the full text plus a `lastUpdated` date (currently **2026-10-24**). Both are marked **DRAFT, pending legal review**. Contact email: **kapok@afairresolution.com**. Keep the privacy policy, `ios/Runner/PrivacyInfo.xcprivacy`, and the store privacy forms in sync. The Terms of Service are also shown during sign-up.

## Providers

### LanguageProvider (`lib/core/providers/language_provider.dart`)

```dart
class LanguageProvider extends ChangeNotifier {
  Locale get currentLocale;
  Future<void> changeLanguage(Locale locale);
  String getLanguageName(Locale locale);
}
```

Persists the language preference to Hive, loads it on start, and notifies listeners (rebuilds the app).

### ThemeProvider (`lib/core/providers/theme_provider.dart`)

```dart
class ThemeProvider extends ChangeNotifier {
  ThemeMode get themeMode;
  Future<void> changeThemeMode(ThemeMode mode);
}
```

Persists the theme preference via `ThemeService`, loads it on start, and notifies listeners.

## About Page

### Location
`lib/app/about_page.dart`

Reached from Profile → About, and shown as the landing page after a user's **first** login (with a **Continue** button that goes to Home; the button only appears when the page can't be popped).

### Sections

1. **Our Mission**
2. **Kapok Icon** ("Inspiration: The Living Tree")
3. **Digging Deeper: Tech Roots**
4. **Key Features** (hanging-indent bullet list)
5. **Technology** (Flutter, Firebase, Mapbox)
6. **Acknowledgements** button → `/acknowledgements`
7. App version + tagline
8. **Legal** (© 2026 A Fair Resolution, LLC)

## Acknowledgements Page

`lib/app/acknowledgements_page.dart`. Credits the people who made Kapok possible. The names come from the `acknowledgementsThanksAlsoToNames` string in `app_localizations.dart` (identical English and Spanish lists; one name per line, in the client's requested order).

## Data Export Service

`lib/core/services/data_export_service.dart` can export tasks and teams to a JSON file and share it, but **no UI calls it** since the Export Data entry was removed from Settings.

## Theme Configuration

Defined in `lib/core/theme/app_theme.dart`.

- **Light**: primary `AppColors.primary` (`#013576`), background `AppColors.background` (`#FEFEFF`)
- **Dark**: primary `AppColors.primary`, background `#121212`, surfaces `#1E1E1E`

## Limitations

- Profile picture upload is not implemented (initial-letter avatar only)
- Push notifications are deferred
- Privacy Policy and Terms of Service are drafts pending legal review
