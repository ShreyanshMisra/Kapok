---
title: Models and Data Flow
description: Comprehensive guide to data models, serialization, and data flow patterns in the Kapok application
---

# Models and Data Flow

## Overview

The Kapok application uses a structured approach to data modeling and flow, ensuring type safety, consistency, and efficient data management across the entire application. This document covers the data models, serialization patterns, and data flow architecture.

## Data Models

### UserModel

**Purpose**: Represents user account information and authentication data.

```dart
@JsonSerializable()
class UserModel {
  final String id;              // Unique user identifier
  final String name;            // User's display name
  final String email;           // User's email address
  final String accountType;     // Admin, TeamLeader, TeamMember
  final String role;            // Medical, Engineering, etc.
  final String? teamId;         // Associated team ID
  final DateTime createdAt;     // Account creation timestamp
  final DateTime updatedAt;     // Last update timestamp

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.accountType,
    required this.role,
    this.teamId,
    required this.createdAt,
    required this.updatedAt,
  });

  // JSON serialization
  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  // Firestore integration
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromJson({...data, 'id': doc.id});
  }

  // Immutable updates
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? accountType,
    String? role,
    String? teamId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      accountType: accountType ?? this.accountType,
      role: role ?? this.role,
      teamId: teamId ?? this.teamId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
```

**Key Features**:
- Immutable data structure
- JSON serialization support
- Firestore integration
- CopyWith method for updates
- Equality and hashCode implementations

### TeamModel

**Purpose**: Represents team information and membership data.

```dart
@JsonSerializable()
class TeamModel {
  final String id;              // Unique team identifier
  final String name;            // Team display name
  final String leaderId;        // Team leader's user ID
  final String teamCode;        // Unique team join code
  final List<String> memberIds; // List of team member IDs
  final DateTime createdAt;     // Team creation timestamp
  final DateTime updatedAt;     // Last update timestamp
  final bool isActive;          // Team status

  const TeamModel({
    required this.id,
    required this.name,
    required this.leaderId,
    required this.teamCode,
    required this.memberIds,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  // JSON serialization
  factory TeamModel.fromJson(Map<String, dynamic> json) => _$TeamModelFromJson(json);
  Map<String, dynamic> toJson() => _$TeamModelToJson(this);

  // Immutable updates
  TeamModel copyWith({
    String? id,
    String? name,
    String? leaderId,
    String? teamCode,
    List<String>? memberIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return TeamModel(
      id: id ?? this.id,
      name: name ?? this.name,
      leaderId: leaderId ?? this.leaderId,
      teamCode: teamCode ?? this.teamCode,
      memberIds: memberIds ?? this.memberIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
```

**Key Features**:
- Team membership management
- Unique team codes for joining
- Active/inactive team status
- Leader and member relationships

### TaskModel

**Purpose**: Represents task information with geolocation and assignment data.

```dart
@JsonSerializable()
class TaskModel {
  final String id;              // Unique task identifier
  final String taskName;        // Task title
  final int taskSeverity;       // Severity level (1-5)
  final String taskDescription; // Detailed task description
  final bool taskCompleted;     // Completion status
  final String assignedTo;      // Assigned user ID
  final String teamName;        // Team name for display
  final String teamId;          // Associated team ID
  final double latitude;        // Task location latitude
  final double longitude;       // Task location longitude
  final DateTime createdAt;     // Task creation timestamp
  final DateTime updatedAt;     // Last update timestamp
  final String createdBy;       // Creator's user ID

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
  });

  // JSON serialization
  factory TaskModel.fromJson(Map<String, dynamic> json) => _$TaskModelFromJson(json);
  Map<String, dynamic> toJson() => _$TaskModelToJson(this);

  // Firestore integration
  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel.fromJson({...data, 'id': doc.id});
  }

  // Immutable updates
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
    );
  }
}
```

**Key Features**:
- Geolocation support with latitude/longitude
- Severity levels (1-5) for task prioritization
- Assignment and team association
- Completion tracking
- Creator and assignment tracking

## JSON Serialization

### Code Generation Setup

**pubspec.yaml**:
```yaml
dependencies:
  json_annotation: ^4.9.0

dev_dependencies:
  build_runner: ^2.4.9
  json_serializable: ^6.9.0
```

**Model Implementation**:
```dart
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  // Model implementation
}
```

**Code Generation**:
```bash
# Generate serialization code
flutter packages pub run build_runner build

# Watch for changes
flutter packages pub run build_runner watch

# Clean and rebuild
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Serialization Features

1. **Automatic Serialization**: Fields are automatically serialized/deserialized
2. **Custom Converters**: Support for custom type converters
3. **Field Annotations**: Control serialization behavior
4. **Nested Objects**: Support for complex object hierarchies
5. **Null Safety**: Full null safety support

### Custom Serialization

```dart
@JsonSerializable()
class TaskModel {
  @JsonKey(name: 'task_name')
  final String taskName;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? computedField;
  
  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  final DateTime createdAt;
  
  static DateTime _dateTimeFromTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    return DateTime.parse(timestamp.toString());
  }
  
  static dynamic _dateTimeToTimestamp(DateTime dateTime) {
    return Timestamp.fromDate(dateTime);
  }
}
```

## Data Flow Architecture

### 1. Online Data Flow

```
UI Layer (BLoC) → Repository → Data Source → External Service
     ↓                ↓           ↓
   State Update    Data Transform  Network Request
     ↓                ↓           ↓
   UI Rebuild    Cache Update   Response Processing
```

**Flow Steps**:
1. User action triggers BLoC event
2. BLoC calls repository method
3. Repository determines data source (Firebase/Hive)
4. Data source makes network request
5. Response is processed and cached
6. Repository returns data to BLoC
7. BLoC emits new state
8. UI rebuilds with new data

### 2. Offline Data Flow

```
UI Layer (BLoC) → Repository → Hive Source → Local Storage
     ↓                ↓           ↓
   State Update    Data Transform  Local Write
     ↓                ↓           ↓
   UI Rebuild    Sync Queue    Background Sync
```

**Flow Steps**:
1. User action triggers BLoC event
2. BLoC calls repository method
3. Repository writes to Hive (local storage)
4. Data is queued for sync
5. Repository returns data to BLoC
6. BLoC emits new state
7. UI rebuilds with local data
8. Background sync processes queue when online

### 3. Sync Flow

```
Local Changes → Sync Queue → Network Check → Firebase Sync
     ↓              ↓            ↓              ↓
   Hive Write   Queue Entry   Connectivity    Network Request
     ↓              ↓            ↓              ↓
   Immediate    Background    Retry Logic    Conflict Resolution
   Response     Processing    Strategy       and Merge
```

**Sync Process**:
1. Local changes are queued for sync
2. Network connectivity is checked
3. Queued operations are processed
4. Conflicts are resolved using timestamps
5. Success/failure status is updated
6. Local cache is synchronized

## Repository Pattern

### Repository Interface

```dart
abstract class TaskRepository {
  Future<List<TaskModel>> getTasks();
  Future<TaskModel> getTask(String taskId);
  Future<TaskModel> createTask(TaskModel task);
  Future<TaskModel> updateTask(TaskModel task);
  Future<void> deleteTask(String taskId);
  Future<List<TaskModel>> getTasksByTeam(String teamId);
  Future<List<TaskModel>> getTasksByUser(String userId);
}
```

### Repository Implementation

```dart
class TaskRepositoryImpl implements TaskRepository {
  final FirebaseSource _firebaseSource;
  final HiveSource _hiveSource;
  final NetworkChecker _networkChecker;

  TaskRepositoryImpl({
    required FirebaseSource firebaseSource,
    required HiveSource hiveSource,
    required NetworkChecker networkChecker,
  }) : _firebaseSource = firebaseSource,
       _hiveSource = hiveSource,
       _networkChecker = networkChecker;

  @override
  Future<List<TaskModel>> getTasks() async {
    try {
      // Check network connectivity
      if (await _networkChecker.isConnected()) {
        // Fetch from Firebase
        final tasks = await _firebaseSource.getTasks();
        
        // Cache in Hive
        await _hiveSource.cacheTasks(tasks);
        
        return tasks;
      } else {
        // Return cached data
        return await _hiveSource.getCachedTasks();
      }
    } catch (e) {
      // Fallback to cached data
      return await _hiveSource.getCachedTasks();
    }
  }

  @override
  Future<TaskModel> createTask(TaskModel task) async {
    try {
      // Always save locally first
      await _hiveSource.saveTask(task);
      
      // Try to sync with Firebase
      if (await _networkChecker.isConnected()) {
        final createdTask = await _firebaseSource.createTask(task);
        await _hiveSource.updateTask(createdTask);
        return createdTask;
      } else {
        // Queue for sync
        await _hiveSource.queueForSync(task);
        return task;
      }
    } catch (e) {
      // Task is saved locally, will sync later
      await _hiveSource.queueForSync(task);
      return task;
    }
  }
}
```

## Data Sources

### Firebase Source

```dart
class FirebaseSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<TaskModel>> getTasks() async {
    final snapshot = await _firestore.collection('tasks').get();
    return snapshot.docs
        .map((doc) => TaskModel.fromFirestore(doc))
        .toList();
  }

  Future<TaskModel> createTask(TaskModel task) async {
    final docRef = await _firestore.collection('tasks').add(task.toJson());
    final doc = await docRef.get();
    return TaskModel.fromFirestore(doc);
  }

  Future<TaskModel> updateTask(TaskModel task) async {
    await _firestore.collection('tasks').doc(task.id).update(task.toJson());
    final doc = await _firestore.collection('tasks').doc(task.id).get();
    return TaskModel.fromFirestore(doc);
  }

  Future<void> deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }
}
```

### Hive Source

```dart
class HiveSource {
  final HiveService _hiveService = HiveService.instance;

  Future<List<TaskModel>> getCachedTasks() async {
    final tasksData = _hiveService.getAllTasks();
    return tasksData
        .map((data) => TaskModel.fromJson(data))
        .toList();
  }

  Future<void> cacheTasks(List<TaskModel> tasks) async {
    for (final task in tasks) {
      await _hiveService.storeTask(task.id, task.toJson());
    }
  }

  Future<void> saveTask(TaskModel task) async {
    await _hiveService.storeTask(task.id, task.toJson());
  }

  Future<void> queueForSync(TaskModel task) async {
    await _hiveService.storeSyncData('task_${task.id}', {
      'operation': 'create',
      'data': task.toJson(),
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
```

## State Management Integration

### BLoC Implementation

```dart
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _taskRepository;

  TaskBloc({required TaskRepository taskRepository})
      : _taskRepository = taskRepository,
        super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<CreateTask>(_onCreateTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    
    try {
      final tasks = await _taskRepository.getTasks();
      emit(TaskLoaded(tasks: tasks));
    } catch (e) {
      emit(TaskError(message: e.toString()));
    }
  }

  Future<void> _onCreateTask(CreateTask event, Emitter<TaskState> emit) async {
    try {
      final createdTask = await _taskRepository.createTask(event.task);
      
      if (state is TaskLoaded) {
        final currentTasks = (state as TaskLoaded).tasks;
        emit(TaskLoaded(tasks: [...currentTasks, createdTask]));
      }
    } catch (e) {
      emit(TaskError(message: e.toString()));
    }
  }
}
```

## Error Handling

### Exception Hierarchy

```dart
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });
}

class DatabaseException extends AppException {
  const DatabaseException({
    required String message,
    String? code,
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);
}

class NetworkException extends AppException {
  const NetworkException({
    required String message,
    String? code,
    dynamic originalError,
  }) : super(message: message, code: code, originalError: originalError);
}
```

### Error Handling in Repositories

```dart
Future<TaskModel> createTask(TaskModel task) async {
  try {
    // Implementation
  } on FirebaseException catch (e) {
    throw DatabaseException(
      message: 'Failed to create task in database',
      code: e.code,
      originalError: e,
    );
  } on SocketException catch (e) {
    throw NetworkException(
      message: 'Network error while creating task',
      originalError: e,
    );
  } catch (e) {
    throw AppException(
      message: 'Unexpected error while creating task',
      originalError: e,
    );
  }
}
```

## Performance Considerations

### 1. Data Caching

- **Hive Caching**: Store frequently accessed data locally
- **Memory Caching**: Keep active data in memory
- **Cache Invalidation**: Update cache when data changes

### 2. Pagination

```dart
Future<List<TaskModel>> getTasks({
  int limit = 20,
  DocumentSnapshot? startAfter,
}) async {
  Query query = _firestore.collection('tasks')
      .orderBy('createdAt', descending: true)
      .limit(limit);
  
  if (startAfter != null) {
    query = query.startAfterDocument(startAfter);
  }
  
  final snapshot = await query.get();
  return snapshot.docs
      .map((doc) => TaskModel.fromFirestore(doc))
      .toList();
}
```

### 3. Batch Operations

```dart
Future<void> createMultipleTasks(List<TaskModel> tasks) async {
  final batch = _firestore.batch();
  
  for (final task in tasks) {
    final docRef = _firestore.collection('tasks').doc();
    batch.set(docRef, task.toJson());
  }
  
  await batch.commit();
}
```

## Testing Data Models

### Unit Tests

```dart
void main() {
  group('TaskModel', () {
    test('should create TaskModel from JSON', () {
      final json = {
        'id': 'task_1',
        'taskName': 'Test Task',
        'taskSeverity': 3,
        'taskDescription': 'Test description',
        'taskCompleted': false,
        'assignedTo': 'user_1',
        'teamName': 'Test Team',
        'teamId': 'team_1',
        'latitude': 40.7128,
        'longitude': -74.0060,
        'createdAt': '2023-01-01T00:00:00Z',
        'updatedAt': '2023-01-01T00:00:00Z',
        'createdBy': 'user_1',
      };
      
      final task = TaskModel.fromJson(json);
      
      expect(task.id, 'task_1');
      expect(task.taskName, 'Test Task');
      expect(task.taskSeverity, 3);
    });

    test('should convert TaskModel to JSON', () {
      final task = TaskModel(
        id: 'task_1',
        taskName: 'Test Task',
        taskSeverity: 3,
        taskDescription: 'Test description',
        taskCompleted: false,
        assignedTo: 'user_1',
        teamName: 'Test Team',
        teamId: 'team_1',
        latitude: 40.7128,
        longitude: -74.0060,
        createdAt: DateTime.parse('2023-01-01T00:00:00Z'),
        updatedAt: DateTime.parse('2023-01-01T00:00:00Z'),
        createdBy: 'user_1',
      );
      
      final json = task.toJson();
      
      expect(json['id'], 'task_1');
      expect(json['taskName'], 'Test Task');
      expect(json['taskSeverity'], 3);
    });
  });
}
```

---

*This models and data flow documentation provides comprehensive guidance for working with data in the Kapok application. Follow these patterns to ensure consistency and maintainability across the codebase.*

