# Data Models

## Overview

The app uses strongly-typed Dart models with JSON serialization support. Models handle conversion between Firestore documents, JSON, and Dart objects. Code generation via `json_serializable` creates the `.g.dart` files.

## UserModel

### Location
`lib/data/models/user_model.dart`

### Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `id` | String | Yes | Unique identifier |
| `name` | String | Yes | Display name |
| `email` | String | Yes | Email address |
| `userRole` | UserRole | Yes | Account type enum |
| `role` | String | Yes | Specialty (Medical, Engineering, etc.) |
| `teamId` | String? | No | Associated team ID |
| `createdAt` | DateTime | Yes | Account creation timestamp |
| `updatedAt` | DateTime | Yes | Last modification timestamp |
| `lastActiveAt` | DateTime? | No | Last activity timestamp |

### UserRole Enum

```dart
enum UserRole {
  teamLeader('teamLeader', 'Team Leader'),
  teamMember('teamMember', 'Team Member'),
  admin('admin', 'Admin');
}
```

**Role parsing** handles variations:
- `teamleader`, `team_leader`, `leader` → `teamLeader`
- `teammember`, `team_member`, `member` → `teamMember`
- `admin` → `admin`
- Default fallback: `teamMember`

### Serialization Methods

```dart
// JSON
factory UserModel.fromJson(Map<String, dynamic> json);
Map<String, dynamic> toJson();

// Firestore
factory UserModel.fromFirestore(DocumentSnapshot doc);
Map<String, dynamic> toFirestore();

// Copy with modifications
UserModel copyWith({...});
```

### Firestore Migration

Handles legacy `accountType` field migration to `userRole` automatically in `fromFirestore()`.

## TaskModel

### Location
`lib/data/models/task_model.dart`

### Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `id` | String | Yes | Unique identifier |
| `title` | String | Yes | Task name (max 100 chars) |
| `description` | String? | No | Details (max 500 chars) |
| `createdBy` | String | Yes | Creator's user ID |
| `assignedTo` | String? | No | Assignee's user ID |
| `teamId` | String | Yes | Associated team ID |
| `geoLocation` | GeoPoint | Yes | Latitude/longitude |
| `address` | String? | No | Human-readable address |
| `status` | TaskStatus | Yes | Current status |
| `priority` | TaskPriority | Yes | Priority level |
| `dueDate` | DateTime? | No | Optional deadline |
| `createdAt` | DateTime | Yes | Creation timestamp |
| `updatedAt` | DateTime | Yes | Last modification |
| `completedAt` | DateTime? | No | Completion timestamp |

### TaskStatus Enum

```dart
enum TaskStatus {
  pending('pending', 'Pending'),
  inProgress('inProgress', 'In Progress'),
  completed('completed', 'Completed');
}
```

### TaskPriority Enum

```dart
enum TaskPriority {
  low('low', 'Low'),
  medium('medium', 'Medium'),
  high('high', 'High');
}
```

### Computed Properties

```dart
// Location convenience
double get latitude => geoLocation.latitude;
double get longitude => geoLocation.longitude;

// Check if overdue
bool get isOverdue;

// UI colors (as int)
int get priorityColor;  // Green, Amber, or Red
int get statusColor;    // Gray, Blue, or Green
```

### Deprecated Getters

For backward compatibility during migration:
- `taskName` → use `title`
- `taskDescription` → use `description`
- `taskSeverity` → use `priority`
- `taskCompleted` → use `status == TaskStatus.completed`

## TeamModel

### Location
`lib/data/models/team_model.dart`

### Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `id` | String | Yes | Unique identifier |
| `teamName` | String | Yes | Display name |
| `leaderId` | String | Yes | Leader's user ID |
| `teamCode` | String | Yes | 6-char join code |
| `memberIds` | List<String> | Yes | All member IDs |
| `taskIds` | List<String> | No | Associated task IDs |
| `description` | String? | No | Optional description |
| `createdAt` | DateTime | Yes | Creation timestamp |
| `updatedAt` | DateTime | Yes | Last modification |
| `isActive` | bool | Yes | Soft-delete flag |

### Computed Properties

```dart
int get memberCount => memberIds.length;
bool get isFull => memberIds.length >= 50;
bool isMember(String userId) => memberIds.contains(userId);
bool isLeader(String userId) => leaderId == userId;
```

### Backward Compatibility

Handles legacy `name` field mapping to `teamName` in JSON parsing.

## OfflineMapRegion

### Location
`lib/data/models/offline_map_region_model.dart`

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | String | Unique identifier |
| `name` | String | Human-readable region name |
| `centerLat` | double | Center latitude |
| `centerLon` | double | Center longitude |
| `radiusKm` | double | Coverage radius in km |
| `zoomMin` | int | Minimum zoom level cached |
| `zoomMax` | int | Maximum zoom level cached |
| `lastSyncedAt` | DateTime | Last download timestamp |
| `tileCount` | int | Total tiles in region |
| `downloadedTileCount` | int | Tiles downloaded |

### Hive Storage

Uses Hive type adapter (generated) for local persistence.

## MapTileModel

### Location
`lib/data/models/map_tile_model.dart`

Represents individual cached map tiles for offline use.

## Enums Location

All enums are in `lib/core/enums/`:

| File | Enum | Purpose |
|------|------|---------|
| `user_role.dart` | UserRole | Account types |
| `task_status.dart` | TaskStatus | Task states |
| `task_priority.dart` | TaskPriority | Task urgency |

## Code Generation

Models using `@JsonSerializable()` require code generation:

```bash
flutter pub run build_runner build
```

Generated files:
- `user_model.g.dart`
- `task_model.g.dart`
- `team_model.g.dart`
- `offline_map_region_model.g.dart`

## Firestore Structure

### Collections

```
/users/{userId}
/teams/{teamId}
/tasks/{taskId}
```

### Timestamp Handling

All models handle both:
- Firestore `Timestamp` objects
- ISO 8601 string formats

Conversion happens automatically in `fromFirestore()` methods.

## Data Flow

```
Firestore Document
       ↓
  fromFirestore()
       ↓
   Dart Model
       ↓
    toJson()
       ↓
  Hive Storage
       ↓
   fromJson()
       ↓
   Dart Model
```

## Equality

Models implement `==` and `hashCode` based on key identifying properties (not all fields) to enable proper comparison in BLoC states and lists.
