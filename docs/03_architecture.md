# Application Architecture

## High-Level Structure

Kapok follows a layered architecture with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│  (Pages, Widgets, BLoCs)                                    │
├─────────────────────────────────────────────────────────────┤
│                    Business Logic Layer                      │
│  (BLoCs, Providers, Services)                               │
├─────────────────────────────────────────────────────────────┤
│                    Data Layer                                │
│  (Repositories, Data Sources, Models)                       │
├─────────────────────────────────────────────────────────────┤
│                    Infrastructure                            │
│  (Firebase, Hive, Mapbox, Platform Services)                │
└─────────────────────────────────────────────────────────────┘
```

## State Management

### BLoC Pattern

The app uses `flutter_bloc` for state management with four main BLoCs:

| BLoC | Responsibility |
|------|----------------|
| `AuthBloc` | User authentication state |
| `TaskBloc` | Task CRUD operations |
| `TeamBloc` | Team management |
| `MapBloc` | Map state and offline caching |

Each BLoC follows this structure:
- **Events**: User actions or system triggers (e.g., `SignInRequested`)
- **States**: Current application state (e.g., `AuthAuthenticated`)
- **Bloc**: Business logic connecting events to states

### Provider Pattern

`ChangeNotifier` providers manage UI preferences:
- `ThemeProvider`: Light/Dark/System theme modes
- `LanguageProvider`: English/Spanish locale selection

## Dependency Injection

GetIt service locator (`lib/injection_container.dart`) manages dependencies:

```dart
// Example access pattern
final authBloc = sl<AuthBloc>();
final taskRepository = sl<TaskRepository>();
```

### Registration Categories

1. **Services** (Singletons): Core platform services
2. **Data Sources** (Singletons): Database and API access
3. **Repositories** (Singletons): Business logic and data coordination
4. **BLoCs** (Factories): New instance per use

## Navigation

### Named Routes

All navigation uses named routes defined in `lib/app/router.dart`:

| Route | Page |
|-------|------|
| `/login` | LoginPage |
| `/signup` | SignupPage |
| `/forgot-password` | ForgotPasswordPage |
| `/role-selection` | RoleSelectionPage |
| `/home` | HomePage |
| `/tasks` | TasksPage |
| `/create-task` | CreateTaskPage |
| `/task-detail` | TaskDetailPage |
| `/edit-task` | EditTaskPage |
| `/teams` | TeamsPage |
| `/create-team` | CreateTeamPage |
| `/join-team` | JoinTeamPage |
| `/team-detail` | TeamDetailPage |
| `/map` | MapPage |
| `/map-test` | MapTestPage |
| `/map-cache` | MapCachePage |
| `/profile` | ProfilePage |
| `/edit-profile` | EditProfilePage |
| `/settings` | SettingsPage |
| `/onboarding` | OnboardingPage |
| `/about` | AboutPage |

### Route Parameters

Some routes accept parameters:
- `/team-detail`: Receives `TeamModel`
- `/task-detail`: Receives `{task: TaskModel, currentUserId: String}`
- `/onboarding`: Accepts optional `VoidCallback` for completion

## Data Flow

### Repository Pattern

```
UI Layer                Business Layer           Data Layer
┌──────────┐           ┌──────────────┐         ┌──────────────┐
│  Widget  │ ──event──▶│    BLoC      │ ──────▶│  Repository  │
│          │◀──state── │              │◀────── │              │
└──────────┘           └──────────────┘         └──────────────┘
                                                      │
                                    ┌─────────────────┼─────────────────┐
                                    ▼                 ▼                 ▼
                              ┌──────────┐     ┌──────────┐     ┌──────────┐
                              │  Hive    │     │ Firebase │     │  Mapbox  │
                              │  (Local) │     │ (Remote) │     │  (Maps)  │
                              └──────────┘     └──────────┘     └──────────┘
```

### Offline-First Strategy

1. **Write Operations**: Save to Hive first, then sync to Firebase
2. **Read Operations**: Try Firebase, fall back to Hive cache
3. **Sync Queue**: Failed operations queued for later retry
4. **Network Monitoring**: `NetworkChecker` triggers sync on reconnection

## App Initialization Flow

```
main.dart
    │
    ▼
Load Environment Variables (.env)
    │
    ▼
Initialize Firebase
    │
    ▼
Initialize Dependencies (GetIt)
    │
    ▼
Initialize Core Services
    │
    ▼
SplashWrapper
    │
    ├──▶ SplashScreen (3 seconds)
    │
    ├──▶ OnboardingPage (if first launch)
    │
    └──▶ KapokApp (main app with BLoC providers)
```

## Error Handling

### Custom Exceptions

The app defines specialized exceptions in `lib/core/error/exceptions.dart`:

- `AuthException`: Authentication failures
- `NetworkException`: Connectivity issues
- `DatabaseException`: Firestore/Hive errors
- `LocationException`: GPS/location errors
- `ValidationException`: Form validation failures
- `PermissionException`: Access denied errors
- `CacheException`: Local storage errors
- `TeamException`: Team operation errors
- `TaskException`: Task operation errors
- `SyncException`: Synchronization errors

### Error Flow

1. Data sources throw specific exceptions
2. Repositories catch and may transform exceptions
3. BLoCs catch exceptions and emit error states
4. UI displays user-friendly error messages via SnackBars
