---
title: App Structure
description: Detailed documentation of the Kapok Flutter application structure and organization
---

# App Structure

## Overview

The Kapok Flutter application follows a feature-based architecture with clear separation of concerns. This document provides a comprehensive guide to the application's structure, explaining the purpose and organization of each component.

## Root Directory Structure

```
Kapok/
├── app/                    # Flutter application root
│   ├── lib/               # Source code
│   ├── android/           # Android-specific files
│   ├── ios/               # iOS-specific files
│   ├── web/               # Web-specific files (future)
│   ├── test/              # Unit and widget tests
│   ├── integration_test/  # Integration tests
│   ├── assets/            # Static assets (images, fonts)
│   ├── pubspec.yaml       # Dependencies and metadata
│   └── README.md          # App-specific documentation
├── firebase/              # Firebase configuration
├── docs/                  # Technical documentation
└── README.md              # Project overview
```

## Source Code Structure (`lib/`)

```
lib/
├── app/                   # Application configuration
│   ├── kapok_app.dart    # Root app widget
│   └── router.dart       # Navigation routing
├── core/                 # Core utilities and services
│   ├── constants/        # App-wide constants
│   ├── error/           # Custom exceptions
│   ├── utils/           # Utility functions
│   ├── localization/    # Internationalization
│   └── services/        # Core services
├── data/                # Data layer
│   ├── models/          # Data models
│   ├── repositories/    # Data access abstraction
│   └── sources/         # External data sources
├── features/            # Feature modules
│   ├── auth/           # Authentication feature
│   ├── tasks/          # Task management feature
│   ├── teams/          # Team management feature
│   ├── map/            # Mapping feature
│   └── profile/        # User profile feature
├── injection_container.dart  # Dependency injection
└── main.dart           # Application entry point
```

## Core Layer (`core/`)

### Constants (`core/constants/`)

**Purpose**: Centralized storage of app-wide constants and configuration values.

```
core/constants/
├── app_colors.dart      # Color palette and theme colors
├── app_strings.dart     # String constants and labels
└── app_styles.dart      # Text styles and UI styling
```

**Key Components**:
- **AppColors**: Color definitions for themes, severity levels, roles
- **AppStrings**: Localized strings and labels
- **AppStyles**: Text styles, button styles, and UI components

### Error Handling (`core/error/`)

**Purpose**: Custom exception classes and error handling utilities.

```
core/error/
└── exceptions.dart      # Custom exception classes
```

**Exception Types**:
- `AppException` - Base exception class
- `AuthException` - Authentication-related errors
- `NetworkException` - Network connectivity issues
- `DatabaseException` - Database operation errors
- `LocationException` - Geolocation service errors
- `ValidationException` - Input validation errors
- `PermissionException` - Permission-related errors
- `CacheException` - Local storage errors
- `TeamException` - Team management errors
- `TaskException` - Task management errors
- `SyncException` - Offline sync errors

### Utilities (`core/utils/`)

**Purpose**: Reusable utility functions and extensions.

```
core/utils/
├── validators.dart      # Input validation functions
├── extensions.dart      # Dart extensions for common types
└── logger.dart         # Logging utility
```

**Key Utilities**:
- **Validators**: Email, password, name, team code validation
- **Extensions**: String, DateTime, List, Map, BuildContext extensions
- **Logger**: Structured logging with different levels and categories

### Localization (`core/localization/`)

**Purpose**: Internationalization support for English and Spanish.

```
core/localization/
├── app_localizations.dart  # Localization delegate and class
├── en.arb                 # English translations
└── es.arb                 # Spanish translations
```

**Features**:
- Dynamic language switching
- Comprehensive translation coverage
- Context-aware localization
- Fallback to English for missing translations

### Services (`core/services/`)

**Purpose**: Core application services and external integrations.

```
core/services/
├── firebase_service.dart    # Firebase integration
├── geolocation_service.dart # Location services
├── hive_service.dart        # Local storage
└── network_checker.dart     # Network connectivity
```

**Service Responsibilities**:
- **FirebaseService**: Authentication, Firestore, Storage operations
- **GeolocationService**: Location permissions, coordinates, address conversion
- **HiveService**: Local database operations, offline storage
- **NetworkChecker**: Connectivity monitoring, network quality assessment

## Data Layer (`data/`)

### Models (`data/models/`)

**Purpose**: Data structures with serialization support.

```
data/models/
├── user_model.dart      # User data model
├── team_model.dart      # Team data model
└── task_model.dart      # Task data model
```

**Model Features**:
- JSON serialization with code generation
- Firestore integration
- Immutable data structures
- CopyWith methods for updates
- Equality and hashCode implementations

### Repositories (`data/repositories/`)

**Purpose**: Data access abstraction layer.

```
data/repositories/
├── auth_repository.dart    # Authentication data access
├── task_repository.dart    # Task data access
└── team_repository.dart    # Team data access
```

**Repository Pattern**:
- Abstracts data sources (Firebase, Hive)
- Provides consistent API for data operations
- Handles offline/online data synchronization
- Implements caching strategies

### Sources (`data/sources/`)

**Purpose**: Direct integration with external data sources.

```
data/sources/
├── firebase_source.dart    # Firebase operations
├── hive_source.dart        # Local storage operations
└── mapbox_source.dart      # Mapbox API integration
```

**Source Responsibilities**:
- **FirebaseSource**: Direct Firestore and Storage operations
- **HiveSource**: Local database operations
- **MapboxSource**: Map and geocoding services

## Feature Modules (`features/`)

Each feature follows the same structure for consistency:

```
features/{feature_name}/
├── bloc/              # State management
│   ├── {feature}_bloc.dart
│   ├── {feature}_event.dart
│   └── {feature}_state.dart
├── pages/             # UI screens
│   ├── {feature}_page.dart
│   └── {feature}_detail_page.dart
└── widgets/           # Reusable components
    ├── {feature}_card.dart
    └── {feature}_form.dart
```

### Authentication Feature (`features/auth/`)

**Purpose**: User authentication and account management.

```
features/auth/
├── bloc/
│   ├── auth_bloc.dart      # Authentication state management
│   ├── auth_event.dart     # Authentication events
│   └── auth_state.dart     # Authentication states
├── pages/
│   ├── login_page.dart     # Login screen
│   ├── signup_page.dart    # Registration screen
│   └── forgot_password_page.dart
└── widgets/
    ├── auth_form.dart      # Authentication form
    └── role_selector.dart  # Role selection widget
```

### Tasks Feature (`features/tasks/`)

**Purpose**: Task creation, management, and tracking.

```
features/tasks/
├── bloc/
│   ├── task_bloc.dart      # Task state management
│   ├── task_event.dart     # Task events
│   └── task_state.dart     # Task states
├── pages/
│   ├── tasks_page.dart     # Task list screen
│   ├── create_task_page.dart
│   ├── task_detail_page.dart
│   └── edit_task_page.dart
└── widgets/
    ├── task_card.dart      # Task display card
    ├── task_form.dart      # Task creation form
    ├── severity_selector.dart
    └── task_filter.dart    # Task filtering
```

### Teams Feature (`features/teams/`)

**Purpose**: Team creation, management, and membership.

```
features/teams/
├── bloc/
│   ├── team_bloc.dart      # Team state management
│   ├── team_event.dart     # Team events
│   └── team_state.dart     # Team states
├── pages/
│   ├── teams_page.dart     # Team list screen
│   ├── create_team_page.dart
│   ├── team_detail_page.dart
│   └── join_team_page.dart
└── widgets/
    ├── team_card.dart      # Team display card
    ├── team_form.dart      # Team creation form
    ├── member_list.dart    # Team member list
    └── team_code_generator.dart
```

### Map Feature (`features/map/`)

**Purpose**: Interactive mapping and geolocation services.

```
features/map/
├── bloc/
│   ├── map_bloc.dart       # Map state management
│   ├── map_event.dart      # Map events
│   └── map_state.dart      # Map states
├── pages/
│   ├── map_page.dart       # Main map screen
│   └── location_picker_page.dart
└── widgets/
    ├── map_widget.dart     # Map display widget
    ├── task_marker.dart    # Task location marker
    ├── location_search.dart
    └── map_controls.dart   # Map interaction controls
```

### Profile Feature (`features/profile/`)

**Purpose**: User profile management and settings.

```
features/profile/
├── bloc/
│   ├── profile_bloc.dart   # Profile state management
│   ├── profile_event.dart  # Profile events
│   └── profile_state.dart  # Profile states
├── pages/
│   ├── profile_page.dart   # Profile screen
│   ├── edit_profile_page.dart
│   └── settings_page.dart
└── widgets/
    ├── profile_card.dart   # Profile display
    ├── profile_form.dart   # Profile editing form
    ├── language_selector.dart
    └── settings_tile.dart  # Settings options
```

## Application Configuration (`app/`)

### Root App Widget (`app/kapok_app.dart`)

**Purpose**: Main application widget with theme and localization setup.

```dart
class KapokApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kapok',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomePage(),
    );
  }
}
```

### Navigation Router (`app/router.dart`)

**Purpose**: Centralized navigation and route management.

```dart
class AppRouter {
  static const String home = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String tasks = '/tasks';
  static const String teams = '/teams';
  static const String map = '/map';
  static const String profile = '/profile';
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Route generation logic
  }
}
```

## Dependency Injection (`injection_container.dart`)

**Purpose**: Centralized dependency management using GetIt.

```dart
final GetIt sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // Service registration
  sl.registerLazySingleton<FirebaseService>(() => FirebaseService.instance);
  sl.registerLazySingleton<HiveService>(() => HiveService.instance);
  
  // Repository registration
  sl.registerLazySingleton<AuthRepository>(() => AuthRepository());
  sl.registerLazySingleton<TaskRepository>(() => TaskRepository());
  
  // BLoC registration
  sl.registerFactory<AuthBloc>(() => AuthBloc());
  sl.registerFactory<TaskBloc>(() => TaskBloc());
}
```

## Entry Point (`main.dart`)

**Purpose**: Application initialization and startup.

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize dependencies
  await initializeDependencies();
  
  // Initialize core services
  await initializeCoreServices();
  
  runApp(const KapokApp());
}
```

## Asset Organization

### Images (`assets/images/`)

```
assets/images/
├── logos/              # App logos and branding
├── icons/              # App icons and UI elements
├── illustrations/      # Onboarding and empty states
└── backgrounds/        # Background images
```

### Fonts (`assets/fonts/`)

```
assets/fonts/
├── Inter/              # Primary font family
│   ├── Inter-Regular.ttf
│   ├── Inter-Medium.ttf
│   └── Inter-Bold.ttf
└── Roboto/             # Fallback font
    └── Roboto-Regular.ttf
```

## Testing Structure

### Unit Tests (`test/`)

```
test/
├── unit/               # Unit tests
│   ├── models/         # Model tests
│   ├── repositories/   # Repository tests
│   ├── services/       # Service tests
│   └── utils/          # Utility tests
├── widget/             # Widget tests
│   └── features/       # Feature widget tests
└── mocks/              # Mock objects
    ├── firebase_mocks.dart
    └── hive_mocks.dart
```

### Integration Tests (`integration_test/`)

```
integration_test/
├── auth_flow_test.dart     # Authentication flow
├── task_management_test.dart
├── team_management_test.dart
└── offline_sync_test.dart
```

## Build Configuration

### Android (`android/`)

```
android/
├── app/
│   ├── build.gradle.kts    # App-level build configuration
│   ├── src/main/
│   │   ├── AndroidManifest.xml
│   │   ├── kotlin/         # Kotlin source files
│   │   └── res/            # Android resources
│   └── google-services.json
├── build.gradle.kts        # Project-level build configuration
└── gradle.properties       # Gradle properties
```

### iOS (`ios/`)

```
ios/
├── Runner/
│   ├── AppDelegate.swift   # iOS app delegate
│   ├── Info.plist         # iOS app configuration
│   ├── Assets.xcassets/   # iOS assets
│   └── GoogleService-Info.plist
├── Runner.xcodeproj/      # Xcode project
└── Podfile               # CocoaPods dependencies
```

## Development Guidelines

### Code Organization

1. **Feature-Based Structure**: Organize code by features, not by technical layers
2. **Consistent Naming**: Use consistent naming conventions across all modules
3. **Separation of Concerns**: Keep UI, business logic, and data access separate
4. **Dependency Direction**: Dependencies should point inward (features → data → core)

### File Naming Conventions

- **Files**: Use snake_case (e.g., `user_model.dart`)
- **Classes**: Use PascalCase (e.g., `UserModel`)
- **Variables**: Use camelCase (e.g., `userName`)
- **Constants**: Use UPPER_SNAKE_CASE (e.g., `API_BASE_URL`)

### Import Organization

```dart
// 1. Dart core libraries
import 'dart:async';

// 2. Flutter libraries
import 'package:flutter/material.dart';

// 3. Third-party packages
import 'package:firebase_core/firebase_core.dart';

// 4. Internal imports (core first, then features)
import 'package:kapok_app/core/constants/app_colors.dart';
import 'package:kapok_app/features/auth/bloc/auth_bloc.dart';
```

---

*This app structure documentation provides a comprehensive guide to understanding and navigating the Kapok Flutter application. Follow the established patterns when adding new features or modifying existing ones.*

