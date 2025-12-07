# Task Loading Fix - Stream to Async Migration

## Issue

**Problem:** After creating a task successfully, the task list showed "Failed to stream tasks" error.

**Root Cause:** The `LoadTasksRequested` event was using Firebase `getTasksStream()` which:
1. Only works with Firebase Realtime Database streaming
2. Had no offline fallback mechanism
3. Failed when Firebase streaming encountered issues
4. Didn't integrate with the offline-first Hive cache

## Fix Applied

Changed `LoadTasksRequested` handler from Firebase streaming to async loading with offline support.

### Before (Broken):
```dart
Future<void> _onLoadTasksRequested(
  LoadTasksRequested event,
  Emitter<TaskState> emit,
) async {
  try {
    emit(const TaskLoading());

    await emit.forEach<List<TaskModel>>(
      _taskRepository.getTasksStream(),  // ❌ Firebase-only streaming
      onData: (tasks) => TasksLoaded(tasks: tasks),
      onError: (error, stackTrace) => TaskError(message: error.toString()),
    );
  } catch (e) {
    emit(TaskError(message: e.toString()));
  }
}
```

### After (Fixed):
```dart
Future<void> _onLoadTasksRequested(
  LoadTasksRequested event,
  Emitter<TaskState> emit,
) async {
  try {
    emit(const TaskLoading());

    final tasks = await _taskRepository.getTasks();  // ✅ Offline-first loading

    emit(TasksLoaded(tasks: tasks));
  } catch (e) {
    emit(TaskError(message: e.toString()));
  }
}
```

## How It Works Now

The `getTasks()` method implements offline-first pattern:

```dart
Future<List<TaskModel>> getTasks() async {
  if (await _networkChecker.isConnected()) {
    try {
      // Get from Firebase
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

## Benefits

1. **✅ Works Offline** - Loads tasks from Hive cache when offline
2. **✅ Automatic Caching** - Caches tasks from Firebase when online
3. **✅ Error Resilient** - Falls back to cache if Firebase fails
4. **✅ Consistent Behavior** - Same pattern as other task loading methods

## Important Note: Permissions

The `LoadTasksRequested` event now loads **all tasks**, not just tasks from user's teams.

### Recommended Usage

For permission-aware task loading, use `LoadTasksForUserTeamsRequested` instead:

```dart
// ❌ Loads ALL tasks (no permission filtering)
context.read<TaskBloc>().add(LoadTasksRequested());

// ✅ Loads only tasks from user's teams
final teams = await teamRepository.getUserTeams(userId);
final teamIds = teams.map((t) => t.id).toList();

context.read<TaskBloc>().add(
  LoadTasksForUserTeamsRequested(teamIds: teamIds)
);
```

## Migration Guide for UI Code

If your UI currently uses `LoadTasksRequested`, you should migrate to `LoadTasksForUserTeamsRequested`:

### Before:
```dart
class TasksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Loads all tasks - no permissions
    context.read<TaskBloc>().add(LoadTasksRequested());

    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TasksLoaded) {
          return TaskList(tasks: state.tasks);
        }
        return CircularProgressIndicator();
      },
    );
  }
}
```

### After:
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

          // Load tasks with permission filtering
          context.read<TaskBloc>().add(
            LoadTasksForUserTeamsRequested(teamIds: teamIds)
          );

          return BlocBuilder<TaskBloc, TaskState>(
            builder: (context, state) {
              if (state is TasksLoaded) {
                return TaskList(tasks: state.tasks);
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

## Testing

### Test 1: Online Task Creation and Loading
1. ✅ Create a task while online
2. ✅ Task should appear in Firebase
3. ✅ Task should appear in the list immediately
4. ✅ Task should be cached locally

### Test 2: Offline Task Loading
1. ✅ Load tasks while online (populates cache)
2. ✅ Turn off network
3. ✅ Refresh task list
4. ✅ Tasks should load from cache

### Test 3: Error Recovery
1. ✅ Simulate Firebase error
2. ✅ Task list should fall back to cache
3. ✅ No error shown to user if cache exists

## Files Modified

- [app/lib/features/tasks/bloc/task_bloc.dart](app/lib/features/tasks/bloc/task_bloc.dart) - Changed streaming to async loading

## Summary

The fix changes task loading from Firebase-only streaming to an offline-first async pattern. This makes task loading:
- More reliable (works offline)
- More consistent (same pattern as other methods)
- Error-resilient (automatic fallback)

For permission-aware task loading, use `LoadTasksForUserTeamsRequested` instead of `LoadTasksRequested`.
