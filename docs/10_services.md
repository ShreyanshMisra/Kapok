# Services

## Overview

Services are singleton classes that provide shared functionality across the app. They handle infrastructure concerns like local storage, networking, location, and analytics.

## Service Registration

Services are registered in `lib/injection_container.dart` using get_it:

```dart
final GetIt sl = GetIt.instance;

sl.registerLazySingleton<ServiceName>(() => ServiceName.instance);
```

## Core Services

### HiveService

**Location:** `lib/core/services/hive_service.dart`

Local NoSQL database using Hive.

**Boxes (Tables):**
| Box | Purpose |
|-----|---------|
| `users` | User data cache |
| `teams` | Team data cache |
| `tasks` | Task data cache |
| `settings` | App preferences |
| `sync` | Pending sync operations |

**Key Methods:**

```dart
// User operations
Future<void> storeUser(String userId, Map<String, dynamic> userData);
Map<String, dynamic>? getUser(String userId);

// Team operations
Future<void> storeTeam(String teamId, Map<String, dynamic> teamData);
Map<String, dynamic>? getTeam(String teamId);

// Task operations
Future<void> storeTask(String taskId, Map<String, dynamic> taskData);
Map<String, dynamic>? getTask(String taskId);
List<Map<String, dynamic>> getAllTasks();
List<Map<String, dynamic>> getTasksByTeam(String teamId);
List<Map<String, dynamic>> getTasksByUser(String userId);
Future<void> deleteTask(String taskId);

// Settings
Future<void> storeSetting(String key, dynamic value);
T? getSetting<T>(String key);

// Sync queue
Future<void> storeSyncData(String key, Map<String, dynamic> data);
Map<String, dynamic>? getSyncData(String key);
List<Map<String, dynamic>> getAllSyncData();

// Maintenance
Future<void> clearAllData();
Future<void> clearBox(String boxName);
int getBoxSize(String boxName);
Future<void> close();
```

### SyncService

**Location:** `lib/core/services/sync_service.dart`

Handles offline-to-online data synchronization.

**Features:**
- Listens for connectivity changes
- Automatically syncs when device comes online
- Processes queued operations sequentially
- Handles failures gracefully (continues with other operations)

**Supported Operations:**
- `create_task` / `update_task` / `delete_task`
- `create_team` / `update_team` / `delete_team`
- `update_profile`
- `join_team` / `leave_team` / `remove_member`

**Key Methods:**

```dart
Future<void> initialize();
Future<void> syncPendingChanges();
Future<void> manualSync();
Future<int> getPendingSyncCount();
Future<void> dispose();
```

### NetworkChecker

**Location:** `lib/core/services/network_checker.dart`

Network connectivity monitoring.

**Features:**
- Checks WiFi, mobile, ethernet connectivity
- Verifies actual internet access (DNS lookup)
- Quality assessment (latency-based)
- Test mode override for development

**Key Methods:**

```dart
Future<bool> isConnected();
Future<ConnectivityResult> getConnectivityStatus();
Stream<ConnectivityResult> get connectivityStream;
Future<bool> isConnectedViaWiFi();
Future<bool> isConnectedViaMobile();
Future<String> getConnectionType();
Future<NetworkQuality> getNetworkQuality();
Future<NetworkStatus> getNetworkStatus();
void setTestModeOverride(bool? override);
```

**Enums:**

```dart
enum NetworkQuality { none, poor, fair, good, excellent }
enum NetworkSpeed { none, verySlow, slow, medium, fast }
```

### GeolocationService

**Location:** `lib/core/services/geolocation_service.dart`

Device location services.

**Features:**
- Current position retrieval
- Permission management
- Address geocoding (coordinates ↔ address)
- Distance/bearing calculations
- Location streaming

**Key Methods:**

```dart
// Permissions
Future<bool> isLocationServiceEnabled();
Future<LocationPermission> requestLocationPermission();
Future<bool> hasLocationPermission();

// Position
Future<Position> getCurrentPosition();
Future<Position?> getLastKnownPosition();
Stream<Position> getLocationUpdates();

// Geocoding
Future<String> coordinatesToAddress({double latitude, double longitude});
Future<Position> addressToCoordinates(String address);

// Calculations
double calculateDistance({startLat, startLon, endLat, endLon});
double getBearing({startLat, startLon, endLat, endLon});
String formatDistance(double distanceInMeters);
bool isValidCoordinates({double latitude, double longitude});

// Settings
Future<void> openLocationSettings();
Future<void> openAppSettings();
```

### AnalyticsService

**Location:** `lib/core/services/analytics_service.dart`

Firebase Analytics and Crashlytics management.

**Features:**
- Privacy-respecting analytics (user can opt out)
- Event tracking
- Screen view logging
- Crash reporting control
- User ID management

**Privacy Settings:**
- Analytics enabled/disabled (stored in Hive)
- Crash reporting enabled/disabled (stored in Hive)
- Both default to enabled

**Key Methods:**

```dart
Future<void> initialize();

// Privacy controls
bool get isAnalyticsEnabled;
bool get isCrashReportingEnabled;
Future<void> setAnalyticsEnabled(bool enabled);
Future<void> setCrashReportingEnabled(bool enabled);

// Event logging
Future<void> logEvent({String name, Map<String, Object>? parameters});
Future<void> logScreenView({String screenName, String? screenClass});
Future<void> logLogin({String loginMethod = 'email'});
Future<void> logSignUp({String signUpMethod = 'email'});

// Custom events
Future<void> logTaskCreated({String? teamId, int? priority});
Future<void> logTaskCompleted({String? taskId});
Future<void> logTeamCreated();
Future<void> logTeamJoined();
Future<void> logOfflineSync({int? itemCount});

// User management
Future<void> setUserId(String? userId);
Future<void> clearUserData();
```

### FirebaseService

**Location:** `lib/core/services/firebase_service.dart`

Firebase initialization wrapper.

**Key Methods:**

```dart
Future<void> initialize();
```

### ThemeService

**Location:** `lib/core/services/theme_service.dart`

Theme preference persistence.

**Key Methods:**

```dart
Future<void> initialize();
Future<ThemeMode> getThemeMode();
Future<void> setThemeMode(ThemeMode mode);
```

### LanguageService

**Location:** `lib/core/services/language_service.dart`

Language preference persistence.

### DataExportService

**Location:** `lib/core/services/data_export_service.dart`

Data export functionality.

**Key Methods:**

```dart
Future<String> exportToJson({
  List<TaskModel> tasks,
  List<TeamModel> teams,
  UserModel currentUser,
});

Future<void> shareExportedFile(String filePath);
```

### PermissionService

**Location:** `lib/core/services/permission_service.dart`

Runtime permission handling.

### OnboardingService

**Location:** `lib/core/services/onboarding_service.dart`

Onboarding flow state management.

### GeocodeService

**Location:** `lib/core/services/geocode_service.dart`

Geocoding utilities (address lookup).

### MigrationService

**Location:** `lib/core/services/migration_service.dart`

Data migration utilities for schema updates.

## Data Sources

### FirebaseSource

**Location:** `lib/data/sources/firebase_source.dart`

Firestore CRUD operations for users, teams, tasks.

### HiveSource

**Location:** `lib/data/sources/hive_source.dart`

Local storage operations, sync queue management.

### MapboxRemoteDataSource

**Location:** `lib/data/sources/mapbox_remote_data_source.dart`

Mapbox API communication for tiles and styles.

### OfflineMapCache

**Location:** `lib/data/sources/offline_map_cache.dart`

Local map tile storage.

### FirebaseMapSnapshotSource

**Location:** `lib/data/sources/firebase_map_snapshot_source.dart`

Map snapshot storage in Firebase.

## Repositories

Repositories coordinate between data sources and provide a clean API to BLoCs.

### AuthRepository

**Location:** `lib/data/repositories/auth_repository.dart`

Authentication operations:
- Sign in/up with email
- Sign out
- Password reset
- Profile updates
- Current user retrieval

### TaskRepository

**Location:** `lib/data/repositories/task_repository.dart`

Task CRUD operations with offline support.

### TeamRepository

**Location:** `lib/data/repositories/team_repository.dart`

Team management with transaction safety.

### MapRepository

**Location:** `lib/data/repositories/map_repository.dart`

Map tile and region management.

### OfflineMapRegionRepository

**Location:** `lib/data/repositories/offline_map_region_repository.dart`

Offline region metadata storage.

## Singleton Pattern

All services use the singleton pattern:

```dart
class ExampleService {
  static ExampleService? _instance;
  static ExampleService get instance => _instance ??= ExampleService._();

  ExampleService._();
}
```

Access via: `ExampleService.instance` or through get_it: `sl<ExampleService>()`
