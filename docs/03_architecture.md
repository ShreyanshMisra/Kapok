# Application Architecture

_Last verified against the codebase: 2026-10-24._

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

All four are provided **once** at the app root (`MultiBlocProvider` in `lib/app/kapok_app.dart`), so every page shares the same instance. A page that loads a narrower data set into a shared BLoC must restore the app-wide data when it closes. For example, `TeamDetailPage` loads one team's tasks into `TaskBloc` and re-dispatches `LoadUserTeams` in `dispose()` so the Tasks tab, badge and map reload all of the user's tasks.

Each BLoC follows this structure:
- **Events**: User actions or system triggers (e.g., `SignInRequested`)
- **States**: Current application state (e.g., `AuthAuthenticated`)
- **Bloc**: Business logic connecting events to states

### Provider Pattern

`ChangeNotifier` providers manage UI preferences:
- `ThemeProvider`: Light / Dark / Default theme modes (the "Default" option follows the device setting; user-facing label is "Default", not "System")
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
4. **BLoCs** (Factories): registered as factories, but only resolved once each, at the app root (see above)

## Navigation

### Named Routes

All navigation uses named routes defined in `lib/app/router.dart`:

| Route | Page |
|-------|------|
| `/login` | LoginPage |
| `/signup` | SignupPage |
| `/forgot-password` | ForgotPasswordPage |
| `/role-selection` | RoleSelectionPage |
| `/home` | HomePage (Map, Tasks, Teams, Profile tabs) |
| `/about` | AboutPage |
| `/acknowledgements` | AcknowledgementsPage |
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
| `/analytics` | AnalyticsPage |

Routes not linked from any UI today: `/map-test` (development page), `/edit-task` (placeholder; editing happens inside TaskDetailPage), and `/analytics`. `EditTeamPage` is pushed directly with `MaterialPageRoute` from TeamDetailPage rather than through a named route.

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
4. **Network Monitoring**: `SyncService` listens to `connectivity_plus` and syncs on reconnection; repositories use `NetworkChecker` to decide whether to write to Firebase directly or queue

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
Route errors to Crashlytics (iOS/Android only; skipped on web)
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
    ├──▶ SplashScreen (~500ms minimum)
    │
    ├──▶ OnboardingPage (if first launch)
    │
    ├──▶ AboutPage (on first login, as post-login landing)
    │
    └──▶ KapokApp (main app with BLoC providers)
```

There is no manual Sync button in Settings anymore. `SyncService` pushes queued changes automatically on startup and whenever connectivity returns, and the refresh button on the Tasks page re-fetches teams and tasks (`LoadUserTeams` → `LoadTasksForUserTeamsRequested`).

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
