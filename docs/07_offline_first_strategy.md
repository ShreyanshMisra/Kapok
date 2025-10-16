# Offline-First Strategy

## Overview

The Kapok application implements an **offline-first** architecture to ensure full functionality even when internet connectivity is unavailable. This is crucial for disaster relief scenarios where network access may be intermittent or completely unavailable.

## Core Principles

### 1. Local-First Data Storage
- All data is stored locally first
- Remote synchronization happens in the background
- Users can work with cached data when offline

### 2. Optimistic Updates
- UI updates immediately with local changes
- Background sync handles remote updates
- Conflict resolution when online

### 3. Graceful Degradation
- Core functionality works offline
- Enhanced features available when online
- Clear offline indicators in UI

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    User Interface                           │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐          │
│  │    UI       │ │    UI       │ │    UI       │          │
│  │  Actions    │ │  Actions    │ │  Actions    │          │
│  └─────────────┘ └─────────────┘ └─────────────┘          │
└─────────────────────────────────────────────────────────────┘
                                │
┌─────────────────────────────────────────────────────────────┐
│                    Business Logic                           │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐          │
│  │    BLoC     │ │    BLoC     │ │    BLoC     │          │
│  │   Layer     │ │   Layer     │ │   Layer     │          │
│  └─────────────┘ └─────────────┘ └─────────────┘          │
└─────────────────────────────────────────────────────────────┘
                                │
┌─────────────────────────────────────────────────────────────┐
│                    Data Layer                               │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐          │
│  │ Repository  │ │ Repository  │ │ Repository  │          │
│  │   Layer     │ │   Layer     │ │   Layer     │          │
│  └─────────────┘ └─────────────┘ └─────────────┘          │
└─────────────────────────────────────────────────────────────┘
                                │
┌─────────────────────────────────────────────────────────────┐
│                    Storage Layer                            │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐          │
│  │    Hive     │ │  Firebase   │ │   Sync      │          │
│  │  (Local)    │ │  (Remote)   │ │   Queue     │          │
│  └─────────────┘ └─────────────┘ └─────────────┘          │
└─────────────────────────────────────────────────────────────┘
```

## Local Storage Implementation

### Hive Database Setup

```dart
class HiveService {
  static const String _usersBox = 'users';
  static const String _teamsBox = 'teams';
  static const String _tasksBox = 'tasks';
  static const String _syncBox = 'sync';
  
  Box? _usersBoxInstance;
  Box? _teamsBoxInstance;
  Box? _tasksBoxInstance;
  Box? _syncBoxInstance;
  
  Future<void> initialize() async {
    await Hive.initFlutter();
    
    _usersBoxInstance = await Hive.openBox(_usersBox);
    _teamsBoxInstance = await Hive.openBox(_teamsBox);
    _tasksBoxInstance = await Hive.openBox(_tasksBox);
    _syncBoxInstance = await Hive.openBox(_syncBox);
  }
  
  // User operations
  Future<void> storeUser(String userId, Map<String, dynamic> userData) async {
    await _usersBoxInstance!.put(userId, userData);
  }
  
  Map<String, dynamic>? getUser(String userId) {
    return _usersBoxInstance!.get(userId);
  }
  
  // Task operations
  Future<void> storeTask(String taskId, Map<String, dynamic> taskData) async {
    await _tasksBoxInstance!.put(taskId, taskData);
  }
  
  List<Map<String, dynamic>> getAllTasks() {
    return _tasksBoxInstance!.values
        .map((task) => Map<String, dynamic>.from(task))
        .toList();
  }
  
  // Sync operations
  Future<void> storeSyncData(String key, Map<String, dynamic> data) async {
    await _syncBoxInstance!.put(key, data);
  }
  
  List<Map<String, dynamic>> getAllSyncData() {
    return _syncBoxInstance!.values
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}
```

### Data Models with Local Storage

```dart
@JsonSerializable()
class TaskModel {
  final String id;
  final String taskName;
  final int taskSeverity;
  final String taskDescription;
  final bool taskCompleted;
  final String assignedTo;
  final String teamName;
  final String teamId;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final bool isLocal;        // Flag for local-only tasks
  final bool needsSync;      // Flag for sync status
  
  const TaskModel({
    required this.id,
    required this.taskName,
    required this.taskSeverity,
    required this.taskDescription,
    required this.taskCompleted,
    required this.assignedTo,
    required this.teamName,
    required this.teamId,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.isLocal = false,
    this.needsSync = false,
  });
  
  factory TaskModel.fromJson(Map<String, dynamic> json) => _$TaskModelFromJson(json);
  Map<String, dynamic> toJson() => _$TaskModelToJson(this);
  
  TaskModel copyWith({
    String? id,
    String? taskName,
    int? taskSeverity,
    String? taskDescription,
    bool? taskCompleted,
    String? assignedTo,
    String? teamName,
    String? teamId,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    bool? isLocal,
    bool? needsSync,
  }) {
    return TaskModel(
      id: id ?? this.id,
      taskName: taskName ?? this.taskName,
      taskSeverity: taskSeverity ?? this.taskSeverity,
      taskDescription: taskDescription ?? this.taskDescription,
      taskCompleted: taskCompleted ?? this.taskCompleted,
      assignedTo: assignedTo ?? this.assignedTo,
      teamName: teamName ?? this.teamName,
      teamId: teamId ?? this.teamId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      isLocal: isLocal ?? this.isLocal,
      needsSync: needsSync ?? this.needsSync,
    );
  }
}
```

## Repository Pattern with Offline Support

### Task Repository Implementation

```dart
class TaskRepository {
  final FirebaseSource _firebaseSource;
  final HiveSource _hiveSource;
  final NetworkChecker _networkChecker;
  
  TaskRepository({
    required FirebaseSource firebaseSource,
    required HiveSource hiveSource,
    required NetworkChecker networkChecker,
  }) : _firebaseSource = firebaseSource,
       _hiveSource = hiveSource,
       _networkChecker = networkChecker;
  
  Future<List<TaskModel>> getTasks() async {
    try {
      // Always try to get local data first
      final localTasks = await _hiveSource.getCachedTasks();
      
      // If online, try to sync with remote
      if (await _networkChecker.isConnected()) {
        try {
          final remoteTasks = await _firebaseSource.getTasks();
          
          // Merge local and remote data
          final mergedTasks = _mergeTasks(localTasks, remoteTasks);
          
          // Update local cache
          await _hiveSource.cacheTasks(mergedTasks);
          
          return mergedTasks;
        } catch (e) {
          // If remote fails, return local data
          return localTasks;
        }
      } else {
        // Offline: return local data
        return localTasks;
      }
    } catch (e) {
      throw TaskException(message: 'Failed to get tasks', originalError: e);
    }
  }
  
  Future<TaskModel> createTask(TaskModel task) async {
    try {
      // Always save locally first
      final localTask = task.copyWith(
        isLocal: true,
        needsSync: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _hiveSource.saveTask(localTask);
      
      // Try to sync with remote if online
      if (await _networkChecker.isConnected()) {
        try {
          final remoteTask = await _firebaseSource.createTask(localTask);
          
          // Update local task with remote data
          final syncedTask = remoteTask.copyWith(
            isLocal: false,
            needsSync: false,
          );
          
          await _hiveSource.updateTask(syncedTask);
          
          return syncedTask;
        } catch (e) {
          // Remote sync failed, keep local task
          return localTask;
        }
      } else {
        // Offline: return local task
        return localTask;
      }
    } catch (e) {
      throw TaskException(message: 'Failed to create task', originalError: e);
    }
  }
  
  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      // Always update locally first
      final localTask = task.copyWith(
        needsSync: true,
        updatedAt: DateTime.now(),
      );
      
      await _hiveSource.updateTask(localTask);
      
      // Try to sync with remote if online
      if (await _networkChecker.isConnected()) {
        try {
          final remoteTask = await _firebaseSource.updateTask(localTask);
          
          // Update local task with remote data
          final syncedTask = remoteTask.copyWith(
            needsSync: false,
          );
          
          await _hiveSource.updateTask(syncedTask);
          
          return syncedTask;
        } catch (e) {
          // Remote sync failed, keep local task
          return localTask;
        }
      } else {
        // Offline: return local task
        return localTask;
      }
    } catch (e) {
      throw TaskException(message: 'Failed to update task', originalError: e);
    }
  }
  
  Future<void> deleteTask(String taskId) async {
    try {
      // Always delete locally first
      await _hiveSource.deleteTask(taskId);
      
      // Try to sync with remote if online
      if (await _networkChecker.isConnected()) {
        try {
          await _firebaseSource.deleteTask(taskId);
        } catch (e) {
          // Remote delete failed, queue for sync
          await _hiveSource.queueForSync({
            'operation': 'delete',
            'taskId': taskId,
            'timestamp': DateTime.now().toIso8601String(),
          });
        }
      } else {
        // Offline: queue for sync
        await _hiveSource.queueForSync({
          'operation': 'delete',
          'taskId': taskId,
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      throw TaskException(message: 'Failed to delete task', originalError: e);
    }
  }
  
  List<TaskModel> _mergeTasks(List<TaskModel> localTasks, List<TaskModel> remoteTasks) {
    final Map<String, TaskModel> taskMap = {};
    
    // Add remote tasks first (they have priority)
    for (final task in remoteTasks) {
      taskMap[task.id] = task;
    }
    
    // Add local tasks that don't exist remotely
    for (final task in localTasks) {
      if (!taskMap.containsKey(task.id)) {
        taskMap[task.id] = task;
      }
    }
    
    return taskMap.values.toList();
  }
}
```

## Background Sync Service

### Sync Service Implementation

```dart
class SyncService {
  final FirebaseSource _firebaseSource;
  final HiveSource _hiveSource;
  final NetworkChecker _networkChecker;
  Timer? _syncTimer;
  
  SyncService({
    required FirebaseSource firebaseSource,
    required HiveSource hiveSource,
    required NetworkChecker networkChecker,
  }) : _firebaseSource = firebaseSource,
       _hiveSource = hiveSource,
       _networkChecker = networkChecker;
  
  void startBackgroundSync() {
    // Sync every 30 seconds when online
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_networkChecker.isConnected()) {
        _performSync();
      }
    });
  }
  
  void stopBackgroundSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }
  
  Future<void> _performSync() async {
    try {
      // Get all pending sync operations
      final syncData = _hiveSource.getAllSyncData();
      
      for (final syncItem in syncData) {
        await _processSyncItem(syncItem);
      }
      
      // Sync tasks that need updating
      await _syncTasks();
      
    } catch (e) {
      Logger.sync('Background sync failed', error: e);
    }
  }
  
  Future<void> _processSyncItem(Map<String, dynamic> syncItem) async {
    try {
      final operation = syncItem['operation'] as String;
      
      switch (operation) {
        case 'create':
          await _syncCreateOperation(syncItem);
          break;
        case 'update':
          await _syncUpdateOperation(syncItem);
          break;
        case 'delete':
          await _syncDeleteOperation(syncItem);
          break;
      }
      
      // Remove from sync queue after successful sync
      await _hiveSource.removeSyncData(syncItem['id']);
      
    } catch (e) {
      Logger.sync('Failed to process sync item', error: e);
    }
  }
  
  Future<void> _syncCreateOperation(Map<String, dynamic> syncItem) async {
    final taskData = syncItem['data'] as Map<String, dynamic>;
    final task = TaskModel.fromJson(taskData);
    
    final remoteTask = await _firebaseSource.createTask(task);
    
    // Update local task with remote data
    final syncedTask = remoteTask.copyWith(
      isLocal: false,
      needsSync: false,
    );
    
    await _hiveSource.updateTask(syncedTask);
  }
  
  Future<void> _syncUpdateOperation(Map<String, dynamic> syncItem) async {
    final taskData = syncItem['data'] as Map<String, dynamic>;
    final task = TaskModel.fromJson(taskData);
    
    final remoteTask = await _firebaseSource.updateTask(task);
    
    // Update local task with remote data
    final syncedTask = remoteTask.copyWith(
      needsSync: false,
    );
    
    await _hiveSource.updateTask(syncedTask);
  }
  
  Future<void> _syncDeleteOperation(Map<String, dynamic> syncItem) async {
    final taskId = syncItem['taskId'] as String;
    
    await _firebaseSource.deleteTask(taskId);
  }
  
  Future<void> _syncTasks() async {
    try {
      // Get all tasks that need syncing
      final localTasks = await _hiveSource.getCachedTasks();
      final tasksNeedingSync = localTasks.where((task) => task.needsSync).toList();
      
      for (final task in tasksNeedingSync) {
        try {
          if (task.isLocal) {
            // New task: create on remote
            final remoteTask = await _firebaseSource.createTask(task);
            final syncedTask = remoteTask.copyWith(
              isLocal: false,
              needsSync: false,
            );
            await _hiveSource.updateTask(syncedTask);
          } else {
            // Existing task: update on remote
            final remoteTask = await _firebaseSource.updateTask(task);
            final syncedTask = remoteTask.copyWith(
              needsSync: false,
            );
            await _hiveSource.updateTask(syncedTask);
          }
        } catch (e) {
          Logger.sync('Failed to sync task ${task.id}', error: e);
        }
      }
    } catch (e) {
      Logger.sync('Failed to sync tasks', error: e);
    }
  }
}
```

## Network Status Management

### Network Checker Service

```dart
class NetworkChecker {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _isConnected = false;
  
  bool get isConnected => _isConnected;
  
  Future<void> initialize() async {
    // Check initial connectivity
    _isConnected = await _checkConnectivity();
    
    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (ConnectivityResult result) async {
        _isConnected = await _checkConnectivity();
        _onConnectivityChanged(_isConnected);
      },
    );
  }
  
  Future<bool> _checkConnectivity() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }
      
      // Try to reach a reliable host
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  void _onConnectivityChanged(bool isConnected) {
    if (isConnected) {
      Logger.network('Network connected - starting sync');
      // Trigger immediate sync when coming online
      _triggerSync();
    } else {
      Logger.network('Network disconnected - working offline');
    }
  }
  
  void _triggerSync() {
    // Notify sync service to perform immediate sync
    // This would be implemented with a callback or event system
  }
  
  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
```

## Conflict Resolution

### Conflict Resolution Strategy

```dart
class ConflictResolver {
  static TaskModel resolveTaskConflict(TaskModel localTask, TaskModel remoteTask) {
    // Use timestamp-based conflict resolution
    if (remoteTask.updatedAt.isAfter(localTask.updatedAt)) {
      // Remote is newer, use remote data
      return remoteTask;
    } else if (localTask.updatedAt.isAfter(remoteTask.updatedAt)) {
      // Local is newer, use local data
      return localTask;
    } else {
      // Same timestamp, use remote data as source of truth
      return remoteTask;
    }
  }
  
  static List<TaskModel> resolveTaskListConflicts(
    List<TaskModel> localTasks,
    List<TaskModel> remoteTasks,
  ) {
    final Map<String, TaskModel> taskMap = {};
    
    // Add remote tasks first
    for (final task in remoteTasks) {
      taskMap[task.id] = task;
    }
    
    // Resolve conflicts with local tasks
    for (final localTask in localTasks) {
      if (taskMap.containsKey(localTask.id)) {
        final remoteTask = taskMap[localTask.id]!;
        final resolvedTask = resolveTaskConflict(localTask, remoteTask);
        taskMap[localTask.id] = resolvedTask;
      } else {
        // Local task doesn't exist remotely, add it
        taskMap[localTask.id] = localTask;
      }
    }
    
    return taskMap.values.toList();
  }
}
```

## UI Offline Indicators

### Offline Status Widget

```dart
class OfflineStatusWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NetworkBloc, NetworkState>(
      builder: (context, state) {
        if (state is NetworkOffline) {
          return Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.orange,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off, color: Colors.white),
                const SizedBox(width: 8),
                const Text(
                  'Offline Mode',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          );
        } else if (state is NetworkSyncing) {
          return Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.blue,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Syncing...',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          );
        }
        
        return const SizedBox.shrink();
      },
    );
  }
}
```

### Task Card with Offline Indicators

```dart
class TaskCard extends StatelessWidget {
  final TaskModel task;
  
  const TaskCard({Key? key, required this.task}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(task.taskName),
        subtitle: Text(task.taskDescription),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (task.isLocal)
              const Icon(
                Icons.cloud_off,
                color: Colors.orange,
                size: 16,
              ),
            if (task.needsSync)
              const Icon(
                Icons.sync,
                color: Colors.blue,
                size: 16,
              ),
            Checkbox(
              value: task.taskCompleted,
              onChanged: (value) {
                if (value != null) {
                  final updatedTask = task.copyWith(taskCompleted: value);
                  context.read<TaskBloc>().add(UpdateTask(updatedTask));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

## Testing Offline Functionality

### Unit Tests

```dart
void main() {
  group('TaskRepository Offline Tests', () {
    late TaskRepository taskRepository;
    late MockFirebaseSource mockFirebaseSource;
    late MockHiveSource mockHiveSource;
    late MockNetworkChecker mockNetworkChecker;
    
    setUp(() {
      mockFirebaseSource = MockFirebaseSource();
      mockHiveSource = MockHiveSource();
      mockNetworkChecker = MockNetworkChecker();
      
      taskRepository = TaskRepository(
        firebaseSource: mockFirebaseSource,
        hiveSource: mockHiveSource,
        networkChecker: mockNetworkChecker,
      );
    });
    
    test('should return local tasks when offline', () async {
      // Arrange
      when(() => mockNetworkChecker.isConnected()).thenAnswer((_) async => false);
      when(() => mockHiveSource.getCachedTasks()).thenAnswer((_) async => [testTask]);
      
      // Act
      final tasks = await taskRepository.getTasks();
      
      // Assert
      expect(tasks, [testTask]);
      verify(() => mockHiveSource.getCachedTasks()).called(1);
      verifyNever(() => mockFirebaseSource.getTasks());
    });
    
    test('should create task locally when offline', () async {
      // Arrange
      when(() => mockNetworkChecker.isConnected()).thenAnswer((_) async => false);
      when(() => mockHiveSource.saveTask(any())).thenAnswer((_) async {});
      
      // Act
      final createdTask = await taskRepository.createTask(testTask);
      
      // Assert
      expect(createdTask.isLocal, true);
      expect(createdTask.needsSync, true);
      verify(() => mockHiveSource.saveTask(any())).called(1);
      verifyNever(() => mockFirebaseSource.createTask(any()));
    });
  });
}
```

## Performance Optimization

### 1. Lazy Loading

```dart
class TaskRepository {
  Future<List<TaskModel>> getTasks({int limit = 20, int offset = 0}) async {
    // Load tasks in batches for better performance
    final localTasks = await _hiveSource.getCachedTasks(
      limit: limit,
      offset: offset,
    );
    
    if (await _networkChecker.isConnected()) {
      try {
        final remoteTasks = await _firebaseSource.getTasks(
          limit: limit,
          offset: offset,
        );
        
        return _mergeTasks(localTasks, remoteTasks);
      } catch (e) {
        return localTasks;
      }
    }
    
    return localTasks;
  }
}
```

### 2. Data Compression

```dart
class HiveSource {
  Future<void> saveTask(TaskModel task) async {
    // Compress large task data before storing
    final compressedData = _compressData(task.toJson());
    await _tasksBox.put(task.id, compressedData);
  }
  
  TaskModel getTask(String taskId) {
    final compressedData = _tasksBox.get(taskId);
    final decompressedData = _decompressData(compressedData);
    return TaskModel.fromJson(decompressedData);
  }
  
  Map<String, dynamic> _compressData(Map<String, dynamic> data) {
    // Implement compression logic
    return data;
  }
  
  Map<String, dynamic> _decompressData(dynamic compressedData) {
    // Implement decompression logic
    return Map<String, dynamic>.from(compressedData);
  }
}
```

### 3. Cache Management

```dart
class CacheManager {
  static const int maxCacheSize = 1000; // Maximum number of items to cache
  
  Future<void> manageCache() async {
    final tasks = await _hiveSource.getAllTasks();
    
    if (tasks.length > maxCacheSize) {
      // Remove oldest tasks
      final sortedTasks = tasks..sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
      final tasksToRemove = sortedTasks.take(tasks.length - maxCacheSize);
      
      for (final task in tasksToRemove) {
        await _hiveSource.deleteTask(task.id);
      }
    }
  }
}
```