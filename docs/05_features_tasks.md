# Tasks Feature

## Overview

The task management system allows users to create, assign, and track location-based tasks. Tasks are associated with teams and can be assigned to specific team members.

## Task Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | String | Unique identifier (format: `task_{timestamp}`) |
| `title` | String | Task name (max 100 characters) |
| `description` | String? | Optional description (max 500 characters) |
| `createdBy` | String | User ID of creator |
| `assignedTo` | String? | User ID of assignee (optional) |
| `teamId` | String | Associated team ID |
| `geoLocation` | GeoPoint | Latitude/longitude coordinates |
| `address` | String? | Human-readable address |
| `status` | TaskStatus | Current status |
| `priority` | TaskPriority | Task priority level |
| `dueDate` | DateTime? | Optional deadline |
| `createdAt` | DateTime | Creation timestamp |
| `updatedAt` | DateTime | Last modification |
| `completedAt` | DateTime? | Completion timestamp |

## Task Status

Defined in `lib/core/enums/task_status.dart`:

| Status | Display Name | Description |
|--------|--------------|-------------|
| `pending` | Pending | Not yet started |
| `inProgress` | In Progress | Currently being worked on |
| `completed` | Completed | Task finished |

## Task Priority

Defined in `lib/core/enums/task_priority.dart`:

| Priority | Display Name | Color |
|----------|--------------|-------|
| `low` | Low | Green |
| `medium` | Medium | Amber |
| `high` | High | Red |

## Pages

### TasksPage (`lib/features/tasks/pages/tasks_page.dart`)

Main task list view with filtering capabilities.

**Features:**
- Displays all tasks from user's teams
- Filter by status (Pending, In Progress, Completed)
- Filter by priority (Low, Medium, High)
- Filter by assignment (All, My Tasks, Unassigned)
- Search by title or description
- Task cards show priority badge, status chip, location, team info
- Tap card to view task details

**Filtering:**
- All filtering happens client-side on cached data
- No network request required to filter
- Supports multiple simultaneous filters

### CreateTaskPage (`lib/features/tasks/pages/create_task_page.dart`)

Full-screen map interface for creating tasks with location.

**Features:**
- Interactive Mapbox map
- Double-click map to select location (triggers reverse geocoding)
- Manual address entry with geocoding
- Current location button
- Draggable form overlay from bottom
- Team selection dropdown
- Assignee selection (loads team members dynamically)
- Priority selection

**Location Selection Methods:**
1. Double-click on map → reverse geocodes to address
2. Enter address manually → forward geocodes to coordinates
3. "Current Location" button → uses device GPS

### TaskDetailPage (`lib/features/tasks/pages/task_detail_page.dart`)

Detailed task view with editing capabilities.

**Features:**
- Map display (50% of screen height) showing task location
- Task information display
- Edit mode toggle (permission-based)
- Editable fields: title, description, status, priority
- Delete button (permission-based)
- Custom pin marker that updates with map movement

**Permissions:**
- Edit: Task creator, assigned user, admin, or team leader
- Delete: Task creator, admin, or team leader

### EditTaskPage (`lib/features/tasks/pages/edit_task_page.dart`)

Placeholder page - editing is handled in TaskDetailPage.

## BLoC Structure

### Events (`lib/features/tasks/bloc/task_event.dart`)

| Event | Parameters | Purpose |
|-------|------------|---------|
| `CreateTaskRequested` | title, description, location, teamId, etc. | Create new task |
| `LoadTasksRequested` | userId | Load all user's tasks |
| `LoadTasksByTeamRequested` | teamId | Load tasks for specific team |
| `LoadTasksByUserRequested` | userId | Load tasks assigned to user |
| `LoadTasksForUserTeamsRequested` | teamIds, userId | Load tasks from user's teams |
| `UpdateTaskRequested` | taskId, fields to update | Update task properties |
| `EditTaskRequested` | taskId, userId, updated fields | Edit with permission check |
| `DeleteTaskRequested` | taskId | Delete task |
| `MarkTaskCompletedRequested` | taskId | Mark as completed |
| `AssignTaskRequested` | taskId, userId | Assign to user |
| `TaskReset` | none | Clear state (on logout) |

### States (`lib/features/tasks/bloc/task_state.dart`)

| State | Properties | Meaning |
|-------|------------|---------|
| `TaskInitial` | none | Initial state |
| `TaskLoading` | none | Operation in progress |
| `TasksLoaded` | tasks | Tasks loaded successfully |
| `TaskCreated` | task | Task created |
| `TaskUpdated` | task | Task updated |
| `TaskDeleted` | taskId | Task deleted |
| `TaskError` | message | Operation failed |

## Repository (`lib/data/repositories/task_repository.dart`)

### Key Methods

```dart
// Create new task
Future<TaskModel> createTask(TaskModel task)

// Get single task
Future<TaskModel?> getTask(String taskId)

// Get all tasks for user's teams
Future<List<TaskModel>> getTasksForUserTeams(List<String> teamIds, String userId)

// Get tasks by team
Future<List<TaskModel>> getTasksByTeam(String teamId)

// Update task
Future<TaskModel> updateTask(TaskModel task)

// Delete task
Future<void> deleteTask(String taskId)

// Edit with permission check
Future<TaskModel> editTask(String taskId, String userId, {...})

// Mark as completed
Future<TaskModel> markTaskCompleted(String taskId)

// Assign to user
Future<TaskModel> assignTask(String taskId, String userId)
```

### Offline Support

1. **Create**: Saves to Hive first, syncs to Firebase when online
2. **Read**: Tries Firebase, falls back to Hive cache
3. **Update**: Updates Hive first, syncs when online
4. **Delete**: Deletes from Hive, queues Firebase deletion

### Transaction Safety

Task creation and deletion use Firestore transactions to:
- Update team's `taskIds` array atomically
- Ensure data consistency between task and team documents

## Firestore Structure

Tasks are stored at `tasks/{taskId}`:

```json
{
  "id": "task_1234567890",
  "title": "Deliver supplies to shelter",
  "description": "Medical supplies needed at main shelter",
  "createdBy": "user_abc",
  "assignedTo": "user_xyz",
  "teamId": "team_123",
  "geoLocation": {
    "latitude": 42.3736,
    "longitude": -72.5199
  },
  "address": "123 Main St, Amherst, MA",
  "status": "pending",
  "priority": "high",
  "dueDate": null,
  "createdAt": "2024-01-15T10:00:00Z",
  "updatedAt": "2024-01-15T10:00:00Z",
  "completedAt": null
}
```

## Permission Model

| Action | Who Can Perform |
|--------|-----------------|
| Create Task | Any team member |
| View Task | Any team member |
| Edit Task | Creator OR assigned user |
| Delete Task | Creator OR admin/team leader |
| Assign Task | Admin or team leader |
| Complete Task | Assigned user or creator |

## Map Integration

Tasks display on the map with color-coded markers:

| Priority | Color |
|----------|-------|
| High | Red |
| Medium | Orange |
| Low | Green |
| Completed | Gray |

Clicking a marker navigates to the task detail page.
