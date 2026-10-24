# Project Structure

_Last verified against the codebase: 2026-10-24._

## Overview

The project follows a feature-based architecture with clear separation of concerns. Code is organized by feature domain, with shared infrastructure in the `core` directory.

## Top-Level Structure

```
lib/
├── main.dart              # App entry point
├── firebase_options.dart  # Firebase configuration (generated)
├── injection_container.dart # Dependency injection setup
├── app/                   # App-level widgets and routing
├── core/                  # Shared infrastructure
├── data/                  # Data layer (models, repos, sources)
└── features/              # Feature modules
```

## Entry Points

### main.dart

Application bootstrap:
1. Initialize Flutter bindings
2. Load environment variables
3. Validate Mapbox configuration
4. Initialize Firebase
5. Set up Crashlytics error handlers (iOS/Android only; web keeps Flutter's default handlers)
6. Initialize dependency injection and core services
7. Initialize `AnalyticsService`
8. Run SplashWrapper

### injection_container.dart

Dependency registration:
- Services (singletons)
- Data sources
- Repositories
- BLoCs (factory registration)

## App Directory

```
app/
├── kapok_app.dart              # Root MaterialApp widget + BLoC providers
├── router.dart                 # Named route definitions
├── home_page.dart              # Main navigation scaffold (4 tabs)
├── about_page.dart             # About screen (also first-login landing)
├── acknowledgements_page.dart  # Credits list
└── legal_document_page.dart    # Renders Privacy Policy / Terms of Service
```

### kapok_app.dart
- MultiBlocProvider setup
- MultiProvider for language/theme
- MaterialApp configuration
- Auth state listener for navigation
- Locale and theme consumer

### router.dart
- Route name constants
- generateRoute() switch for MaterialPageRoute creation
- NotFoundPage for invalid routes

### home_page.dart
- Bottom navigation bar (Map, Tasks, Teams, Profile)
- IndexedStack for page persistence
- Floating action button per tab (`heroTag: 'home_fab'`; TasksPage's own FAB uses `'tasks_page_fab'`, so the two never collide in the IndexedStack)
- Tasks tab badge counts open tasks
- Offline banner + `SyncStatusWidget`
- `AppDrawer` widget (defined but not currently used)

## Core Directory

```
core/
├── constants/
│   ├── app_colors.dart      # Color definitions
│   ├── app_strings.dart     # Static strings
│   ├── app_styles.dart      # TextStyle definitions
│   ├── mapbox_constants.dart # Mapbox config + default map center
│   ├── privacy_policy.dart  # Privacy Policy text (in-app source of truth)
│   └── terms_of_service.dart # Terms of Service text (in-app source of truth)
├── enums/
│   ├── user_role.dart       # UserRole enum
│   ├── task_status.dart     # TaskStatus enum
│   ├── task_priority.dart   # TaskPriority enum
│   └── task_category.dart   # TaskCategory enum
├── error/
│   └── exceptions.dart      # Custom exception classes
├── localization/
│   └── app_localizations.dart # i18n strings (en/es)
├── providers/
│   ├── language_provider.dart # Language state
│   └── theme_provider.dart    # Theme state
├── services/
│   ├── analytics_service.dart
│   ├── data_export_service.dart
│   ├── firebase_service.dart
│   ├── first_login_service.dart
│   ├── geocode_service.dart
│   ├── geolocation_service.dart
│   ├── hive_service.dart
│   ├── language_service.dart
│   ├── migration_service.dart
│   ├── network_checker.dart
│   ├── onboarding_service.dart
│   ├── permission_service.dart
│   ├── sync_service.dart
│   └── theme_service.dart
├── theme/
│   └── app_theme.dart       # Light/dark theme definitions
├── utils/
│   ├── extensions.dart      # Dart extensions (incl. floating snackbar styling)
│   ├── logger.dart          # Logging utility (prints only in debug)
│   ├── role_icons.dart      # Icon per specialty
│   └── validators.dart      # Form validation
└── widgets/
    ├── help_overlay.dart        # Per-page "?" help tips
    ├── kapok_logo.dart          # App bar logo
    ├── priority_stars.dart      # ★/★★/★★★ priority display
    ├── sync_status_widget.dart  # Sync banner
    └── validated_text_field.dart
```

## Data Directory

```
data/
├── models/
│   ├── user_model.dart
│   ├── user_model.g.dart        # Generated
│   ├── task_model.dart
│   ├── task_model.g.dart        # Generated
│   ├── team_model.dart
│   ├── team_model.g.dart        # Generated
│   ├── offline_map_region_model.dart
│   ├── offline_map_region_model.g.dart  # Generated
│   └── map_tile_model.dart
├── repositories/
│   ├── auth_repository.dart
│   ├── task_repository.dart
│   ├── team_repository.dart
│   ├── map_repository.dart
│   └── offline_map_region_repository.dart
└── sources/
    ├── firebase_source.dart
    ├── hive_source.dart
    ├── mapbox_remote_data_source.dart
    ├── offline_map_cache.dart
    ├── firebase_map_snapshot_source.dart
    └── mapbox_source.dart        # Dead code (unused stubs), safe to delete
```

## Features Directory

Each feature follows this structure:

```
features/{feature_name}/
├── bloc/
│   ├── {feature}_bloc.dart
│   ├── {feature}_event.dart
│   └── {feature}_state.dart
├── pages/
│   └── {feature}_page.dart
└── widgets/  (optional)
    └── {widget}.dart
```

### Auth Feature

```
features/auth/
├── bloc/
│   ├── auth_bloc.dart
│   ├── auth_event.dart
│   └── auth_state.dart
└── pages/
    ├── login_page.dart
    ├── signup_page.dart
    ├── forgot_password_page.dart
    └── role_selection_page.dart
```

### Tasks Feature

```
features/tasks/
├── bloc/
│   ├── task_bloc.dart
│   ├── task_event.dart
│   └── task_state.dart
├── pages/
│   ├── tasks_page.dart
│   ├── create_task_page.dart
│   ├── task_detail_page.dart
│   └── edit_task_page.dart      # Placeholder, not linked
└── widgets/
    └── enhanced_task_card.dart  # Task list card
```

### Teams Feature

```
features/teams/
├── bloc/
│   ├── team_bloc.dart
│   ├── team_event.dart
│   └── team_state.dart
└── pages/
    ├── teams_page.dart
    ├── create_team_page.dart
    ├── join_team_page.dart
    ├── edit_team_page.dart
    └── team_detail_page.dart
```

### Map Feature

```
features/map/
├── bloc/
│   ├── map_bloc.dart
│   ├── map_event.dart
│   └── map_state.dart
├── models/
│   └── map_camera_state.dart
├── mobile/
│   └── mapbox_mobile_controller.dart
├── web/
│   ├── mapbox_web_controller.dart
│   └── mapbox_web_controller_stub.dart
├── widgets/
│   └── mapbox_map_view.dart
└── pages/
    ├── map_page.dart
    ├── map_test_page.dart
    └── map_cache_page.dart
```

### Profile Feature

```
features/profile/
└── pages/
    ├── profile_page.dart
    ├── edit_profile_page.dart
    └── settings_page.dart
```

### Analytics Feature

```
features/analytics/
└── pages/
    └── analytics_page.dart   # Charts (fl_chart); route /analytics, not linked from UI
```

### Onboarding Feature

```
features/onboarding/
├── pages/
│   └── onboarding_page.dart
└── widgets/
    └── onboarding_slide.dart
```

### Splash Feature

```
features/splash/
├── splash_wrapper.dart
└── pages/
    └── splash_screen.dart
```

## Test Directory

```
test/
├── widget_test.dart
├── integration/
│   └── critical_flows_test.dart
├── core/
│   ├── enums/            # task_category, task_priority, task_status, user_role
│   ├── localization/
│   │   └── app_localizations_completeness_test.dart  # every EN key has ES
│   └── utils/
│       └── logger_test.dart
├── data/
│   └── models/
│       ├── task_model_test.dart
│       └── user_model_test.dart
└── features/
    ├── map/
    │   └── map_bloc_test.dart
    └── teams/
        ├── team_permission_test.dart
        └── bloc/
            └── team_bloc_remove_member_test.dart

integration_test/
├── app_smoke_test.dart   # On-device smoke test
└── README.md
```

106 tests; run with `flutter test`. CI (`.github/workflows/ci.yml`) runs analyze + test on pushes/PRs.

## Assets

```
assets/
├── images/
│   ├── kapok_icon.png     # App icon source (flutter_launcher_icons)
│   ├── icons/             # Icon size variants
│   └── icon_tagline/      # Logo + tagline wordmarks (light/dark)
└── docs/                  # SUPERSEDED early legal drafts, not bundled
```

`app/.env` is also bundled as an asset (it only holds the public `pk.` Mapbox token and style ID).

## Configuration Files

```
app/.env                                # Mapbox token (gitignored)
app/.env.example                        # Template for .env
app/pubspec.yaml                        # Dependencies, assets, icon/splash config
app/lib/firebase_options.dart           # FlutterFire config
app/ios/Runner/GoogleService-Info.plist # iOS Firebase config (gitignored)
app/ios/Runner/PrivacyInfo.xcprivacy    # iOS privacy manifest
app/android/app/google-services.json    # Android Firebase config (gitignored)
app/android/key.properties              # Android release signing + Mapbox token (gitignored, not created yet)
app/android/key.properties.example      # Template for the above
firebase.json / .firebaserc             # Firebase CLI config (project build-kapok)
firebase/firestore.rules                # Firestore security rules
firebase/firestore.indexes.json
firebase/storage.rules
```

## Generated Files

Files with `.g.dart` extension are generated by `build_runner`:

```bash
dart run build_runner build --delete-conflicting-outputs
```

These contain the JSON serialization methods (`toJson`/`fromJson`) for the user, task, team, and offline-region models.

## Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Files | snake_case | `auth_bloc.dart` |
| Classes | PascalCase | `AuthBloc` |
| Variables | camelCase | `isAuthenticated` |
| Constants | camelCase or SCREAMING_SNAKE | `appName`, `MAX_MEMBERS` |
| Private | _prefix | `_instance` |
| BLoC Events | VerbNoun | `SignInRequested` |
| BLoC States | NounAdjective | `AuthAuthenticated` |
