# Router Fix - TaskDetailPage Navigation

## Issue

**Error Message:**
```
lib/app/router.dart:141:41: Error: Required named parameter 'currentUserId' must be provided.
          builder: (_) => TaskDetailPage(task: task),
```

**Root Cause:**
The `TaskDetailPage` was created with a required `currentUserId` parameter, but the router was only passing the `task` argument without the user ID.

## Fix Applied

Updated the router and navigation to pass both `task` and `currentUserId` as arguments.

### Changes Made

#### 1. Updated Router ([app/lib/app/router.dart:138-146](app/lib/app/router.dart#L138-L146))

**Before:**
```dart
case taskDetail:
  final task = settings.arguments;
  return MaterialPageRoute(
    builder: (_) => TaskDetailPage(task: task),
    settings: settings,
  );
```

**After:**
```dart
case taskDetail:
  final args = settings.arguments as Map<String, dynamic>;
  return MaterialPageRoute(
    builder: (_) => TaskDetailPage(
      task: args['task'],
      currentUserId: args['currentUserId'],
    ),
    settings: settings,
  );
```

**Why:** Changed from single argument to Map-based arguments to pass multiple values.

#### 2. Updated Navigation Call ([app/lib/features/tasks/pages/tasks_page.dart:196-210](app/lib/features/tasks/pages/tasks_page.dart#L196-L210))

**Before:**
```dart
onTap: () {
  Navigator.of(context).pushNamed(AppRouter.taskDetail, arguments: task);
},
```

**After:**
```dart
onTap: () {
  final authState = context.read<AuthBloc>().state;
  String currentUserId = '';
  if (authState is AuthAuthenticated) {
    currentUserId = authState.user.id;
  }

  Navigator.of(context).pushNamed(
    AppRouter.taskDetail,
    arguments: {
      'task': task,
      'currentUserId': currentUserId,
    },
  );
},
```

**Why:**
- Retrieves the current user ID from the AuthBloc
- Passes both task and currentUserId as a Map
- Enables permission checks in TaskDetailPage

#### 3. Added Imports ([app/lib/features/tasks/pages/tasks_page.dart:7-8](app/lib/features/tasks/pages/tasks_page.dart#L7-L8))

```dart
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
```

**Why:** Needed to access AuthBloc and check authentication state.

## How It Works Now

1. User taps on a task card in the tasks list
2. Navigation handler reads the AuthBloc to get the current user ID
3. Both the task object and currentUserId are passed as a Map
4. Router unpacks the Map and passes both arguments to TaskDetailPage
5. TaskDetailPage uses currentUserId for permission checks

## Permission Flow

```
TasksPage
  ↓ (tap task card)
Get currentUserId from AuthBloc
  ↓
Navigate with {task, currentUserId}
  ↓
Router unpacks arguments
  ↓
TaskDetailPage receives both parameters
  ↓
Permission check: can user edit this task?
  ↓
Show/hide edit button accordingly
```

## Files Modified

- [app/lib/app/router.dart](app/lib/app/router.dart) - Updated taskDetail route to accept Map arguments
- [app/lib/features/tasks/pages/tasks_page.dart](app/lib/features/tasks/pages/tasks_page.dart) - Updated navigation to pass both task and currentUserId

## Testing

To verify the fix works:

1. Run the app: `flutter run`
2. Navigate to the Tasks page
3. Tap on any task card
4. TaskDetailPage should open without errors
5. Edit button should only appear if you created or are assigned to the task

## Summary

The error was caused by a mismatch between the TaskDetailPage constructor (requires `currentUserId`) and the router arguments (only provided `task`).

The fix uses a Map-based argument pattern to pass multiple values through the router, and retrieves the current user ID from the AuthBloc before navigation.

This pattern can be reused for other pages that need multiple arguments or user context.
