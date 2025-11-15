# Offline-First Strategy

## Overview

The Kapok application implements an **offline-first** architecture to ensure full functionality even when internet connectivity is unavailable. This is crucial for disaster relief scenarios where network access may be intermittent or completely unavailable.

## Implementation Status

✅ **Fully Implemented** - The offline-first strategy is now complete with:
- Local-first data storage using Hive
- Automatic sync queue for offline operations
- Connectivity-aware repositories
- Background sync service

## Core Principles

### 1. Local-First Data Storage
- All data is stored locally first using Hive
- Remote synchronization happens automatically when online
- Users can work with cached data when offline

### 2. Optimistic Updates
- UI updates immediately with local changes
- Background sync handles remote updates automatically
- Queued operations sync when connectivity is restored

### 3. Graceful Degradation
- Core functionality (task/team creation) works offline
- Enhanced features (joining teams) require connectivity
- Operations are queued and synced automatically

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    User Interface                           │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐          │
│  │  Task BLoC  │ │  Team BLoC  │ │  Auth BLoC  │          │
│  └─────────────┘ └─────────────┘ └─────────────┘          │
└─────────────────────────────────────────────────────────────┘
                                │
┌─────────────────────────────────────────────────────────────┐
│                    Repository Layer                         │
│  ┌─────────────────┐ ┌─────────────────┐                   │
│  │ TaskRepository  │ │ TeamRepository  │                   │
│  │  (Offline-aware)│ │  (Offline-aware)│                   │
│  └─────────────────┘ └─────────────────┘                   │
└─────────────────────────────────────────────────────────────┘
                                │
┌─────────────────────────────────────────────────────────────┐
│                    Data Sources                             │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐          │
│  │ HiveSource  │ │FirebaseSource│ │NetworkChecker│         │
│  │  (Local)    │ │  (Remote)    │ │             │          │
│  └─────────────┘ └─────────────┘ └─────────────┘          │
└─────────────────────────────────────────────────────────────┘
                                │
┌─────────────────────────────────────────────────────────────┐
│                    Storage & Sync                           │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐          │
│  │    Hive     │ │  Firebase   │ │ SyncService │          │
│  │ (5 Boxes)   │ │  Firestore  │ │ (Auto-sync) │          │
│  └─────────────┘ └─────────────┘ └─────────────┘          │
└─────────────────────────────────────────────────────────────┘
```

## Local Storage Implementation

### Hive Database Setup

The app uses 5 Hive boxes for local storage:

1. **users** - User profile data
2. **teams** - Team information
3. **tasks** - Task/assignment data
4. **settings** - App configuration
5. **sync** - Queue for pending operations

See: `app/lib/core/services/hive_service.dart`

```dart
class HiveService {
  static const String _usersBox = 'users';
  static const String _teamsBox = 'teams';
  static const String _tasksBox = 'tasks';
  static const String _settingsBox = 'settings';
  static const String _syncBox = 'sync';

  Future<void> initialize() async {
    await Hive.initFlutter();

    _usersBoxInstance = await Hive.openBox(_usersBox);
    _teamsBoxInstance = await Hive.openBox(_teamsBox);
    _tasksBoxInstance = await Hive.openBox(_tasksBox);
    _settingsBoxInstance = await Hive.openBox(_settingsBox);
    _syncBoxInstance = await Hive.openBox(_syncBox);
  }
}
```

### HiveSource - Data Access Layer

The `HiveSource` class provides a clean abstraction over Hive operations:

See: `app/lib/data/sources/hive_source.dart`

**Key Methods:**
- `saveTask(TaskModel task)` - Save task to local storage
- `getTask(String taskId)` - Retrieve task from local storage
- `getTasks()` - Get all cached tasks
- `getTasksByTeam(String teamId)` - Get team-specific tasks
- `getTasksByUser(String userId)` - Get user-specific tasks
- `cacheTasks(List<TaskModel> tasks)` - Bulk cache tasks from Firebase
- `queueForSync(Map<String, dynamic> syncData)` - Queue operation for sync
- `getSyncQueue()` - Get all pending sync operations

Similar methods exist for teams and users.

## Repository Pattern with Offline Support

### Task Repository - Offline-First Implementation

See: `app/lib/data/repositories/task_repository.dart`

The `TaskRepository` implements a **local-first** strategy:

#### Create Task Flow

```dart
Future<TaskModel> createTask(TaskModel task) async {
  // 1. Always save locally first
  await _hiveSource.saveTask(task);

  if (await _networkChecker.isConnected()) {
    try {
      // 2. Try to save to Firebase
      final createdTask = await _firebaseSource.createTask(task);

      // 3. Update local cache with Firebase data
      await _hiveSource.saveTask(createdTask);

      return createdTask;
    } catch (e) {
      // Firebase failed, but local save succeeded
      // Queue for sync later
      await _hiveSource.queueForSync({
        'operation': 'create',
        'data': task.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
      });

      return task;
    }
  } else {
    // Offline: queue for sync
    await _hiveSource.queueForSync({
      'operation': 'create',
      'data': task.toJson(),
      'timestamp': DateTime.now().toIso8601String(),
    });

    return task;
  }
}
```

**Key Points:**
- ✅ Local save happens first (guaranteed to work)
- ✅ Firebase sync attempted if online
- ✅ Failed operations are queued for later sync
- ✅ User never blocked by network issues

#### Update Task Flow

Similar pattern:
1. Update locally first
2. Try Firebase if online
3. Queue for sync if offline or Firebase fails

#### Delete Task Flow

1. Delete locally first
2. Try Firebase if online
3. Queue deletion for sync if offline

#### Get Tasks Flow

```dart
Future<List<TaskModel>> getTasks() async {
  if (await _networkChecker.isConnected()) {
    try {
      // Try to get from Firebase
      tasks = await _firebaseSource.getTasks();

      // Cache locally
      await _hiveSource.cacheTasks(tasks);
    } catch (e) {
      // Firebase failed, get from local cache
      tasks = await _hiveSource.getTasks();
    }
  } else {
    // Offline: get from local cache
    tasks = await _hiveSource.getTasks();
  }

  return tasks;
}
```

### Team Repository - Offline-First Implementation

See: `app/lib/data/repositories/team_repository.dart`

The `TeamRepository` follows the same pattern with some exceptions:

**Fully Offline Operations:**
- ✅ Create team
- ✅ Update team
- ✅ View teams
- ✅ Leave team
- ✅ Remove member
- ✅ Close team

**Online-Only Operations:**
- ❌ Join team by code (requires real-time Firebase query)

#### Create Team Flow

```dart
Future<TeamModel> createTeam({required String name, required String leaderId}) async {
  final team = TeamModel(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    name: name,
    leaderId: leaderId,
    teamCode: _generateTeamCode(),
    memberIds: [leaderId],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    isActive: true,
  );

  // Always save locally first
  await _hiveSource.saveTeam(team);

  if (await _networkChecker.isConnected()) {
    try {
      // Save to Firebase
      await _firebaseSource.createTeam(team);
    } catch (e) {
      // Queue for sync
      await _hiveSource.queueForSync({
        'operation': 'create_team',
        'type': 'team',
        'data': team.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  } else {
    // Queue for sync
    await _hiveSource.queueForSync({
      'operation': 'create_team',
      'type': 'team',
      'data': team.toJson(),
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  return team;
}
```

## Background Sync Service

### SyncService - Automatic Synchronization

See: `app/lib/core/services/sync_service.dart`

The `SyncService` handles automatic synchronization of queued operations:

**Features:**
- Listens to connectivity changes using `connectivity_plus`
- Automatically syncs when device comes online
- Processes sync queue in order
- Removes successfully synced operations
- Continues on individual operation failures

**Initialization:**
```dart
Future<void> initialize() async {
  // Listen to connectivity changes
  _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
    (List<ConnectivityResult> results) async {
      final isConnected = !results.contains(ConnectivityResult.none);
      if (isConnected && !_isSyncing) {
        await syncPendingChanges();
      }
    },
  );
}
```

**Sync Queue Processing:**
```dart
Future<void> syncPendingChanges() async {
  final syncQueue = await _hiveSource.getSyncQueue();

  for (final syncData in syncQueue) {
    try {
      await _processSyncItem(syncData);

      // Remove from sync queue after successful sync
      await HiveService.instance.syncBox.delete(key);
    } catch (e) {
      // Continue with next operation even if this one failed
      continue;
    }
  }
}
```

**Supported Operations:**
- `create` / `create_task` - Create task on Firebase
- `update` / `update_task` - Update task on Firebase
- `delete` / `delete_task` - Delete task from Firebase
- `create_team` - Create team on Firebase
- `update_team` - Update team on Firebase

**Manual Sync:**
```dart
// Trigger manual sync from anywhere
await SyncService.instance.manualSync();

// Check pending sync count
final count = await SyncService.instance.getPendingSyncCount();
```

## Network Status Management

### NetworkChecker Service

See: `app/lib/core/services/network_checker.dart`

The `NetworkChecker` service monitors connectivity status:

**Features:**
- Real-time connectivity monitoring
- Checks actual internet access (not just WiFi/mobile)
- Used by repositories to decide offline/online behavior

**Usage in Repositories:**
```dart
if (await _networkChecker.isConnected()) {
  // Online: try Firebase
  await _firebaseSource.createTask(task);
} else {
  // Offline: queue for sync
  await _hiveSource.queueForSync({...});
}
```

## Sync Queue Data Structure

### Queue Item Format

Each queued operation has this structure:

**Task Creation:**
```json
{
  "operation": "create",
  "data": {
    "id": "team123_1234567890",
    "taskName": "Deliver supplies",
    "taskSeverity": 3,
    ...
  },
  "timestamp": "2025-11-15T10:30:00.000Z"
}
```

**Task Update:**
```json
{
  "operation": "update",
  "data": {
    "id": "team123_1234567890",
    "taskCompleted": true,
    ...
  },
  "timestamp": "2025-11-15T10:35:00.000Z"
}
```

**Task Deletion:**
```json
{
  "operation": "delete",
  "taskId": "team123_1234567890",
  "timestamp": "2025-11-15T10:40:00.000Z"
}
```

**Team Creation:**
```json
{
  "operation": "create_team",
  "type": "team",
  "data": {
    "id": "1234567890",
    "name": "Alpha Team",
    "teamCode": "ABC123",
    ...
  },
  "timestamp": "2025-11-15T10:25:00.000Z"
}
```

## Testing Offline Functionality

### Manual Testing Steps

1. **Test Task Creation Offline:**
   - Turn off WiFi/mobile data
   - Create a new task
   - Verify task appears in local list
   - Turn on connectivity
   - Wait for auto-sync
   - Verify task appears in Firebase console

2. **Test Team Creation Offline:**
   - Turn off WiFi/mobile data
   - Create a new team
   - Verify team appears locally
   - Turn on connectivity
   - Wait for auto-sync
   - Verify team appears in Firebase console

3. **Test Offline Data Access:**
   - Load app with connectivity
   - View tasks and teams (populates cache)
   - Turn off connectivity
   - Verify all data still accessible
   - Navigate between screens
   - Verify smooth operation

4. **Test Sync Queue:**
   - Turn off connectivity
   - Create 3 tasks
   - Update 2 tasks
   - Delete 1 task
   - Check sync queue count (should be 6 operations)
   - Turn on connectivity
   - Wait for auto-sync
   - Verify all operations completed
   - Check sync queue (should be empty)

### Automated Testing

Unit tests should cover:

```dart
test('should save task locally when offline', () async {
  when(() => mockNetworkChecker.isConnected()).thenAnswer((_) async => false);

  final task = await taskRepository.createTask(testTask);

  verify(() => mockHiveSource.saveTask(any())).called(1);
  verify(() => mockHiveSource.queueForSync(any())).called(1);
  verifyNever(() => mockFirebaseSource.createTask(any()));
});

test('should sync queued operations when online', () async {
  when(() => mockHiveSource.getSyncQueue()).thenAnswer((_) async => [
    {'operation': 'create', 'data': testTask.toJson()},
  ]);

  await syncService.syncPendingChanges();

  verify(() => mockFirebaseSource.createTask(any())).called(1);
  verify(() => mockHiveService.syncBox.delete(any())).called(1);
});
```

## Dependency Injection Setup

The offline-first services are registered in the DI container:

See: `app/lib/injection_container.dart`

```dart
Future<void> initializeDependencies() async {
  // Core services
  sl.registerLazySingleton<HiveService>(() => HiveService.instance);
  sl.registerLazySingleton<SyncService>(() => SyncService.instance);
  sl.registerLazySingleton<NetworkChecker>(() => NetworkChecker.instance);

  // Data sources
  sl.registerLazySingleton<HiveSource>(() => HiveSource());
  sl.registerLazySingleton<FirebaseSource>(() => FirebaseSource());

  // Repositories
  sl.registerLazySingleton<TaskRepository>(() => TaskRepository(
    firebaseSource: sl<FirebaseSource>(),
    hiveSource: sl<HiveSource>(),
    networkChecker: sl<NetworkChecker>(),
  ));

  sl.registerLazySingleton<TeamRepository>(() => TeamRepository(
    firebaseSource: sl<FirebaseSource>(),
    hiveSource: sl<HiveSource>(),
    networkChecker: sl<NetworkChecker>(),
  ));
}

Future<void> initializeCoreServices() async {
  await sl<FirebaseService>().initialize();
  await sl<HiveService>().initialize();
  await sl<SyncService>().initialize(); // Starts connectivity listener
}
```

## Performance Considerations

### Cache Management

- Hive stores data in key-value format for fast access
- JSON serialization/deserialization handled by models
- No complex queries needed (filter in memory)

### Memory Usage

- Hive is memory-efficient (uses lazy loading)
- Only active boxes are kept in memory
- Sync queue is cleared after successful sync

### Battery Impact

- SyncService only runs when connectivity changes
- No polling or background timers
- Sync triggered once when coming online

## Future Enhancements

### Planned Features

1. **Conflict Resolution UI**
   - Show user when local/remote conflict detected
   - Allow manual resolution for important data

2. **Sync Status Indicators**
   - Badge showing pending sync operations count
   - Progress indicator during active sync
   - Success/failure notifications

3. **Data Compression**
   - Compress large task descriptions
   - Reduce storage footprint

4. **Selective Sync**
   - Allow users to choose what to sync
   - Useful for bandwidth-limited scenarios

5. **Offline Map Tiles**
   - Cache map tiles for offline viewing
   - Pre-download tiles for known areas

## Troubleshooting

### Common Issues

**Issue: Sync queue not clearing**
- Check Firebase permissions
- Verify network connectivity
- Check Firebase console for errors
- Review sync service logs

**Issue: Data not persisting offline**
- Verify Hive initialization
- Check storage permissions
- Review HiveSource logs

**Issue: Duplicate tasks after sync**
- Check task ID generation
- Verify sync queue processing
- Review conflict resolution logic

## References

- [Hive Documentation](https://docs.hivedb.dev/)
- [connectivity_plus Package](https://pub.dev/packages/connectivity_plus)
- [Firebase Offline Capabilities](https://firebase.google.com/docs/firestore/manage-data/enable-offline)
