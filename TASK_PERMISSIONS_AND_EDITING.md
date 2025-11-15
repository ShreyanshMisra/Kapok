# Task Permissions and Editing Implementation

## Overview

This document describes the implementation of task permissions, task editing, and enhanced offline support for the Kapok disaster relief application.

## Features Implemented

### 1. Task Permissions - Team-Based Access Control

**Requirement:** Users should only see tasks from teams they belong to.

**Implementation:**

#### New Repository Method: `getTasksForUserTeams()`

Location: `app/lib/data/repositories/task_repository.dart:380-419`

```dart
Future<List<TaskModel>> getTasksForUserTeams(List<String> teamIds) async {
  // Online: Fetch tasks for each team from Firebase and cache locally
  // Offline: Load tasks from local cache

  // Returns only tasks from the specified teams
}
```

**How it works:**
- Accepts a list of team IDs that the user belongs to
- When online: Fetches tasks from Firebase for each team
- Automatically caches all fetched tasks locally
- When offline: Loads tasks from local Hive cache
- Ensures users only see tasks from their teams

#### New BLoC Event: `LoadTasksForUserTeamsRequested`

Location: `app/lib/features/tasks/bloc/task_event.dart:144-152`

```dart
const LoadTasksForUserTeamsRequested({required List<String> teamIds});
```

**Usage Example:**
```dart
// Get user's teams
final userTeams = await teamRepository.getUserTeams(userId);
final teamIds = userTeams.map((team) => team.id).toList();

// Load tasks for those teams only
context.read<TaskBloc>().add(
  LoadTasksForUserTeamsRequested(teamIds: teamIds)
);
```

### 2. Task Editing with Permission Control

**Requirement:** Users can edit tasks they created or tasks assigned to them.

**Implementation:**

#### Permission Check Method: `canEditTask()`

Location: `app/lib/data/repositories/task_repository.dart:434-438`

```dart
bool canEditTask(TaskModel task, String userId) {
  return task.createdBy == userId || task.assignedTo == userId;
}
```

**Permission Rules:**
- ✅ Can edit if you created the task
- ✅ Can edit if the task is assigned to you
- ❌ Cannot edit tasks created by others and not assigned to you

#### Edit Task Method: `editTask()`

Location: `app/lib/data/repositories/task_repository.dart:440-485`

```dart
Future<TaskModel> editTask({
  required String taskId,
  required String userId,
  String? taskName,
  int? taskSeverity,
  String? taskDescription,
  bool? taskCompleted,
  String? assignedTo,
}) async {
  // 1. Get current task
  // 2. Check permissions
  // 3. Update with new values
  // 4. Save (with offline support)
}
```

**Features:**
- All parameters except `taskId` and `userId` are optional
- Only updates fields that are provided (partial updates)
- Throws `TaskException` if user lacks permission
- Supports offline editing (queues for sync)

#### New BLoC Event: `EditTaskRequested`

Location: `app/lib/features/tasks/bloc/task_event.dart:154-184`

```dart
const EditTaskRequested({
  required String taskId,
  required String userId,
  String? taskName,
  int? taskSeverity,
  String? taskDescription,
  bool? taskCompleted,
  String? assignedTo,
});
```

**Usage Example:**
```dart
// Edit task name and severity only
context.read<TaskBloc>().add(
  EditTaskRequested(
    taskId: task.id,
    userId: currentUser.id,
    taskName: 'Updated task name',
    taskSeverity: 4,
    // Other fields remain unchanged
  )
);
```

### 3. Enhanced Offline Support - Auto-Caching

**Requirement:** User's tasks should be available offline.

**Implementation:**

The `getTasksForUserTeams()` method automatically caches all fetched tasks locally:

```dart
// When online
for (final teamId in teamIds) {
  final teamTasks = await _firebaseSource.getTasksByTeam(teamId);
  allTasks.addAll(teamTasks);
}

// Cache ALL tasks locally
await _hiveSource.cacheTasks(allTasks);
```

**Benefits:**
- Tasks are automatically saved to Hive when fetched
- When offline, tasks load instantly from local cache
- No manual caching needed from UI layer
- Seamless online/offline transition

## Usage Guide

### Loading Tasks with Permissions

**Recommended Approach:**

```dart
class TasksScreen extends StatelessWidget {
  final String userId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeamBloc, TeamState>(
      builder: (context, teamState) {
        if (teamState is TeamsLoaded) {
          // Get user's team IDs
          final teamIds = teamState.teams.map((t) => t.id).toList();

          // Load tasks for those teams
          context.read<TaskBloc>().add(
            LoadTasksForUserTeamsRequested(teamIds: teamIds)
          );

          return BlocBuilder<TaskBloc, TaskState>(
            builder: (context, taskState) {
              if (taskState is TasksLoaded) {
                // Display tasks - user only sees their teams' tasks
                return TaskList(tasks: taskState.tasks);
              }
              return CircularProgressIndicator();
            },
          );
        }
        return CircularProgressIndicator();
      },
    );
  }
}
```

### Editing Tasks with Permission Check

**Pattern 1: Check permission in UI**

```dart
Widget buildTaskCard(TaskModel task, String currentUserId) {
  // Check if user can edit
  final canEdit = task.createdBy == currentUserId ||
                  task.assignedTo == currentUserId;

  return Card(
    child: Column(
      children: [
        Text(task.taskName),
        if (canEdit)
          ElevatedButton(
            onPressed: () => _editTask(task, currentUserId),
            child: Text('Edit'),
          ),
      ],
    ),
  );
}

void _editTask(TaskModel task, String userId) {
  context.read<TaskBloc>().add(
    EditTaskRequested(
      taskId: task.id,
      userId: userId,
      taskName: 'New name',
      taskSeverity: 5,
    )
  );
}
```

**Pattern 2: Let repository handle permission check**

```dart
void _editTask(TaskModel task, String userId) {
  // No UI check - repository will throw exception if no permission
  context.read<TaskBloc>().add(
    EditTaskRequested(
      taskId: task.id,
      userId: userId,
      taskName: 'New name',
    )
  );
}

// Handle errors in BLoC consumer
BlocListener<TaskBloc, TaskState>(
  listener: (context, state) {
    if (state is TaskError) {
      if (state.message.contains('permission')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You cannot edit this task'))
        );
      }
    }
  },
  child: ...,
)
```

### Offline Task Access

**Automatic caching:**

```dart
// First load (online)
context.read<TaskBloc>().add(
  LoadTasksForUserTeamsRequested(teamIds: userTeamIds)
);
// → Fetches from Firebase AND caches locally

// Later (offline)
context.read<TaskBloc>().add(
  LoadTasksForUserTeamsRequested(teamIds: userTeamIds)
);
// → Loads from local cache automatically
```

**Editing offline:**

```dart
// Works exactly the same offline
context.read<TaskBloc>().add(
  EditTaskRequested(
    taskId: task.id,
    userId: userId,
    taskName: 'Updated offline',
  )
);
// → Saves locally and queues for sync
```

## API Reference

### TaskRepository Methods

#### `getTasksForUserTeams(List<String> teamIds)`
- **Purpose:** Load tasks from specified teams only (permission-aware)
- **Online behavior:** Fetch from Firebase, cache locally
- **Offline behavior:** Load from local cache
- **Returns:** `Future<List<TaskModel>>`

#### `canEditTask(TaskModel task, String userId)`
- **Purpose:** Check if user has permission to edit task
- **Rules:** Created by user OR assigned to user
- **Returns:** `bool`

#### `editTask({...})`
- **Purpose:** Edit task with permission check and offline support
- **Required:** `taskId`, `userId`
- **Optional:** `taskName`, `taskSeverity`, `taskDescription`, `taskCompleted`, `assignedTo`
- **Throws:** `TaskException` if no permission
- **Returns:** `Future<TaskModel>`

### TaskBloc Events

#### `LoadTasksForUserTeamsRequested`
```dart
LoadTasksForUserTeamsRequested({
  required List<String> teamIds,
})
```

#### `EditTaskRequested`
```dart
EditTaskRequested({
  required String taskId,
  required String userId,
  String? taskName,
  int? taskSeverity,
  String? taskDescription,
  bool? taskCompleted,
  String? assignedTo,
})
```

## Permission Matrix

| Scenario | Can View? | Can Edit? |
|----------|-----------|-----------|
| Task in my team, created by me | ✅ Yes | ✅ Yes |
| Task in my team, assigned to me | ✅ Yes | ✅ Yes |
| Task in my team, created/assigned to others | ✅ Yes | ❌ No |
| Task in other team | ❌ No | ❌ No |

## Offline Behavior

### Load Tasks
| State | Online | Offline |
|-------|--------|---------|
| First load | Fetch from Firebase → Cache | Show empty or error |
| After cache populated | Fetch from Firebase → Update cache | Load from cache |

### Edit Task
| State | Online | Offline |
|-------|--------|---------|
| Permission check | Check & save to Firebase | Check & save to Hive |
| Failed Firebase | Queue for sync | Queue for sync |
| Success | Return updated task | Return updated task |

## Testing Checklist

### Permissions
- [ ] User sees tasks from Team A when they're in Team A
- [ ] User doesn't see tasks from Team B when not in Team B
- [ ] User can edit task they created
- [ ] User can edit task assigned to them
- [ ] User cannot edit task created by/assigned to others
- [ ] Permission error shows clear message

### Offline Support
- [ ] Load tasks while online → tasks cached
- [ ] Turn off network → tasks still visible
- [ ] Edit task offline → saves locally
- [ ] Edit task offline → queued for sync
- [ ] Go online → sync queue processes
- [ ] Edited task appears in Firebase after sync

### Edge Cases
- [ ] Empty team list → no tasks shown
- [ ] User in multiple teams → sees all teams' tasks
- [ ] Edit while offline then change minds online
- [ ] Permission denied error handled gracefully
- [ ] Network interruption during edit

## Migration Guide

### For Existing Code Using `LoadTasksRequested`

**Before:**
```dart
// Loads ALL tasks (no permission filtering)
context.read<TaskBloc>().add(LoadTasksRequested());
```

**After:**
```dart
// Load only tasks from user's teams
final teams = await teamRepository.getUserTeams(userId);
final teamIds = teams.map((t) => t.id).toList();

context.read<TaskBloc>().add(
  LoadTasksForUserTeamsRequested(teamIds: teamIds)
);
```

### For Existing Code Using `UpdateTaskRequested`

**Before:**
```dart
// Direct update, no permission check
context.read<TaskBloc>().add(
  UpdateTaskRequested(
    taskId: task.id,
    taskName: 'New name',
    taskSeverity: task.taskSeverity,
    taskDescription: task.taskDescription,
    taskCompleted: task.taskCompleted,
    assignedTo: task.assignedTo,
  )
);
```

**After:**
```dart
// Edit with permission check
context.read<TaskBloc>().add(
  EditTaskRequested(
    taskId: task.id,
    userId: currentUserId, // Add user ID
    taskName: 'New name',   // Only specify changed fields
  )
);
```

## Files Modified

### Core Implementation
- [app/lib/data/repositories/task_repository.dart](app/lib/data/repositories/task_repository.dart) - Added permission methods and team-based loading
- [app/lib/features/tasks/bloc/task_event.dart](app/lib/features/tasks/bloc/task_event.dart) - Added new events
- [app/lib/features/tasks/bloc/task_bloc.dart](app/lib/features/tasks/bloc/task_bloc.dart) - Added event handlers

## Summary

These features provide:

1. **Security:** Team-based access control ensures data privacy
2. **Usability:** Users can edit their own tasks easily
3. **Reliability:** Full offline support with automatic caching
4. **Flexibility:** Partial updates allow changing specific fields

All features work seamlessly both online and offline, with automatic synchronization when connectivity is restored.
