# Data Models

_Last verified against the codebase: 2026-10-24._

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
| `title` | String | Yes | Task name (3–100 chars) |
| `description` | String? | No | Details (max 500 chars) |
| `createdBy` | String | Yes | Creator's user ID |
| `assignedTo` | String? | No | Assignee's user ID |
| `teamId` | String | Yes | Associated team ID |
| `geoLocation` | GeoPoint | Yes | Latitude/longitude |
| `address` | String? | No | Location text from Create Task (address, or `lat, lon` fallback) |
| `status` | TaskStatus | Yes | Current status |
| `priority` | TaskPriority | Yes | Priority level |
| `category` | TaskCategory | Yes | Non-nullable, defaults to `TaskCategory.other` |
| `dueDate` | DateTime? | No | Stored on the model but **not surfaced in task UI** (Phase 4.1) |
| `createdAt` | DateTime | Yes | Creation timestamp |
| `updatedAt` | DateTime | Yes | Last modification |
| `completedAt` | DateTime? | No | Completion timestamp |
| `statusHistory` | List<Map<String, dynamic>> | No | Status change log (defaults to `[]`) |

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

// Check if overdue (present on the model but not surfaced in UI; retained for data compatibility)
bool get isOverdue;

// Legacy color helpers (as int). Still on the model, but the UI shows
// priority as stars (PriorityStars) and uses AppColors.primary for pins/status.
int get priorityColor;
int get statusColor;
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
| `isActive` | bool | Yes | `false` once closed; missing in Firestore = `true` |

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
| `zoomMin` | int | Minimum zoom level cached |
| `zoomMax` | int | Maximum zoom level cached |
| `northEastLat` / `northEastLon` | double | Bounding box corner |
| `southWestLat` / `southWestLon` | double | Bounding box corner |
| `lastSyncedAt` | DateTime | Last download timestamp |
| `totalTiles` | int | Total tiles in region |
| `downloadedTiles` | int | Tiles downloaded |
| `status` | String | Download status (e.g. `downloading`) |

### Hive Storage

Serialized with `json_serializable` (`toJson`/`fromJson`) and stored in Hive as maps.

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
| `task_category.dart` | TaskCategory | Task type: medical, engineering, carpentry, plumbing, construction, electrical, supplies, transportation, other |

## Code Generation

Models using `@JsonSerializable()` require code generation:

```bash
dart run build_runner build --delete-conflicting-outputs
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
/mapSnapshots/{userId}   # offline region metadata (owner-only rule)
```

Rules live in `firebase/firestore.rules`. Diff them against the live ruleset before deploying (see `12_development_notes.md`).

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
