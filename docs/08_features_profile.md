# Profile & Settings Features

## Overview

The profile feature provides user account management, app settings, and personalization options. Users can view and edit their profile information, configure app behavior, manage privacy settings, and access support.

## Profile Page

### Location
`lib/features/profile/pages/profile_page.dart`

### UI Components

1. **Profile Header Card**
   - Avatar with user initial (first letter of name)
   - User name (bold, large)
   - User specialty/role (e.g., "Medical", "Engineering")
   - Account type badge (Team Leader, Team Member, Admin)

2. **Profile Actions Card**
   - Edit Profile → navigates to EditProfilePage
   - Settings → navigates to SettingsPage
   - About → navigates to AboutPage

3. **Account Information Card**
   - Email address
   - Account type
   - Role/specialty
   - User ID

4. **Permissions Table**
   - `DataTable` with columns: Action | Team Member | Team Leader | Admin
   - Rows: Create Team, Join Team, View Team, Edit Team, Close Team, Delete Team, Remove Member, Leave Team, View All Teams, Edit Own Tasks, Edit All Tasks
   - The current user's role column is highlighted (bold + subtle blue background)
   - A "Your Role: [role]" chip appears at the top right; the table is horizontally scrollable on smaller screens

### Authentication Check

The page requires `AuthAuthenticated` state. If the user is not authenticated, displays "User not authenticated" message.

## Edit Profile Page

### Location
`lib/features/profile/pages/edit_profile_page.dart`

### Features

- Edit user name
- Edit role/specialty
- Save changes updates user profile via `AuthBloc.ProfileUpdateRequested`
- Form validation for required fields

### Available Roles (Specialties)

- Medical
- Engineering
- Carpentry
- Plumbing
- Construction
- Electrical
- Supplies
- Transportation
- Other

## Settings Page

### Location
`lib/features/profile/pages/settings_page.dart`

### Settings Sections

The Settings page has been simplified. Remaining sections: Location, Language, Appearance (Theme), Data (Sync, Clear Cache), About (with Privacy Policy, Terms of Service, and Administrator Permissions links), and Sign Out. The previous Notifications, Privacy, and Feedback & Support sections have been removed.

#### 1. Location
| Setting | Description |
|---------|-------------|
| Location Services | Toggle for app location access |

#### 2. Language
Supports two languages:
- English (en)
- Spanish (es)

Language selection is persisted via `LanguageProvider` and stored in Hive.

#### 3. Appearance (Theme)
Three options (user-facing label for the follow-device option is "Default", not "System"):
- Default (follows device setting)
- Light
- Dark

Theme selection is persisted via `ThemeProvider` and stored in Hive.

#### 4. Data
| Action | Description |
|--------|-------------|
| Sync | Runs `SyncService.syncPendingChanges()` then dispatches `LoadUserTeams` and `LoadTasksRequested` to re-fetch from Firebase |
| Clear Cache | Clears locally saved data (requires re-login) |
| Export Data | Exports tasks and teams to JSON file |

**Export Data Feature:**
- Exports all user's tasks and teams to JSON
- Shows count of exported items
- Option to share the exported file via system share sheet
- Works offline using cached data

The in-app Analytics/Crash Reporting opt-out toggles were removed in Phase 3.5; defaults still apply via `AnalyticsService`.

#### 5. About
- App version display (1.0.0)
- "Built with ❤️ for disaster response coordination." tagline
- Privacy Policy (placeholder dialog)
- Terms of Service (placeholder dialog)
- Administrator Permissions → navigates to `/admin-permissions`

### Sign Out

Located at the bottom of settings page:
1. Shows confirmation dialog
2. Resets all BLoCs (Team, Task, Map)
3. Dispatches `SignOutRequested` to AuthBloc
4. Navigates to login page, clearing navigation stack

## Providers

### LanguageProvider

`lib/core/providers/language_provider.dart`

Manages app language selection:

```dart
class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale;

  Locale get currentLocale => _currentLocale;

  Future<void> changeLanguage(Locale locale);
  String getLanguageName(Locale locale);
}
```

- Persists language preference to Hive
- Loads saved preference on app start
- Notifies listeners on change (triggers app rebuild)

### ThemeProvider

`lib/core/providers/theme_provider.dart`

Manages app theme selection:

```dart
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  Future<void> changeThemeMode(ThemeMode mode);
}
```

- Persists theme preference to Hive via `ThemeService`
- Loads saved preference on app start
- Notifies listeners on change

## Data Export Service

### Location
`lib/core/services/data_export_service.dart`

### Features

```dart
class DataExportService {
  // Export data to JSON file
  Future<String> exportToJson({
    required List<TaskModel> tasks,
    required List<TeamModel> teams,
    required UserModel currentUser,
  });

  // Share exported file
  Future<void> shareExportedFile(String filePath);
}
```

### Export Format

JSON file with structure:
```json
{
  "exportedAt": "2024-01-15T10:30:00Z",
  "exportedBy": {
    "id": "user_123",
    "name": "John Doe",
    "email": "john@example.com"
  },
  "tasks": [...],
  "teams": [...]
}
```

### File Location

Saved to app's documents directory with filename:
`kapok_export_YYYYMMDD_HHMMSS.json`

## Administrator Permissions Page

### Location
`lib/features/profile/pages/admin_permissions_page.dart`

A standalone page (route `/admin-permissions`) reached from Settings → About → Administrator Permissions. Renders a styled two-column `DataTable`: **Action | Who Can Perform**. Actions documented: Create Team, Join Team, View Team, Edit Team, Close Team, Delete Team, Remove Member, Leave Team, View All Teams. A note at the bottom flags that some admin-specific actions are planned but not yet fully functional.

## About Page

### Location
`lib/app/about_page.dart`

### Sections

1. **Our Mission**
   - Description of Kapok's purpose for disaster relief coordination

2. **A Fair Resolution, LLC**
   - Information about the developing organization

3. **Key Features**
   - List of app capabilities

4. **Technology**
   - Tech stack overview (Flutter, Firebase, Mapbox)

5. **Contact & Support**
   - Support contact information

6. **Legal**
   - Rights and usage information

## Theme Configuration

### Light Theme
Primary color: Blue (`AppColors.primary`, `#013576`)
Background: Light gray (#F5F5F5)

### Dark Theme
Primary color: Blue (`AppColors.primary`, `#013576`)
Background: Dark gray (#121212)

Theme definitions in `lib/core/theme/app_theme.dart`.

## Limitations

- Profile picture upload is not implemented (shows placeholder)
- Push notifications are deferred
- Privacy Policy and Terms of Service are placeholders
- Clear cache shows success but full implementation is pending
