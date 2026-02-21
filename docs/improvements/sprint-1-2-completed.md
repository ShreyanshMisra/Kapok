# Sprints 1 & 2: Implementation Reference

> Companion to `roadmap.md`. This document captures **what was built, where it lives, and how it works** so that a follow-up agent can pick up Sprints 3-5 without re-exploring the codebase.

---

## Project Structure Quick Reference

```
app/lib/
  app/            home_page.dart, about_page.dart, router.dart
  core/
    constants/    app_colors.dart
    enums/        task_priority.dart, task_status.dart, task_category.dart, user_role.dart
    localization/ app_localizations.dart  (single file, EN + ES maps)
    services/     hive_service.dart, sync_service.dart, network_checker.dart
    widgets/      kapok_logo.dart, priority_stars.dart, sync_status_widget.dart
  data/
    models/       task_model.dart (+.g.dart), team_model.dart, user_model.dart
    repositories/ task_repository.dart, team_repository.dart, auth_repository.dart
    sources/      firebase_source.dart, hive_source.dart
  features/
    auth/         bloc/ (auth_bloc, auth_event, auth_state), pages/ (login, signup, forgot_password)
    map/          pages/ (map_page), bloc/ (map_bloc, offline_bubble_bloc)
    tasks/        bloc/ (task_bloc, task_event, task_state), pages/ (tasks_page, task_detail_page, create_task_page)
    teams/        bloc/ (team_bloc, team_event, team_state), pages/ (teams_page, team_detail_page, create_team_page, join_team_page)
    profile/      pages/ (profile_page, edit_profile_page)
```

---

## Sprint 1 Completed (Critical Fixes)

Sprint 1 changes were committed before this agent's session. Items addressed:
- Offline map caching improvements
- Task assignment / reassignment
- Leave team functionality
- Task location selection UX

These are stable and should not need revisiting for Sprints 3-5.

---

## Sprint 2 Completed (Core Enhancements)

### 2.1 Task Filtering & Search

**Files modified:** `tasks_page.dart`

| What | Where | Details |
|------|-------|---------|
| Expanded search | `_getFilteredTasks()` ~line 164-180 | Matches query against `task.title`, `task.description`, `task.address`, and resolved assignee name via `_getUserName()` |
| Filter persistence | `_loadPersistedFilters()` ~line 48-71 | Loads from Hive on `initState()` using keys `taskFilter_status`, `taskFilter_priority`, `taskFilter_category`, `taskFilter_assignment` |
| Persist helper | `_persistFilter(key, value)` ~line 73-84 | Calls `HiveService.instance.storeSetting()` / deletes on null |
| Filter setters | `_setStatusFilter()`, `_setPriorityFilter()`, `_setCategoryFilter()`, `_setAssignmentFilter()` | Each calls `setState` + `_persistFilter` |
| Clear all | `_clearFilters()` | Resets state + clears all 4 Hive keys |

**How persistence works:** Each filter uses `HiveService.instance.storeSetting(key, stringValue)` on change and `getSetting<String>(key)` on load. Keys are simple strings. The settings Hive box is already initialized at app startup.

---

### 2.2 Task Status Workflow

#### Model Layer

**File:** `task_model.dart` + `task_model.g.dart`

- Added `final List<Map<String, dynamic>> statusHistory` field (line 26)
- Default: `const []`
- Each entry: `{ 'status': String, 'changedBy': String, 'changedAt': String (ISO 8601), 'previousStatus': String }`
- Included in `fromJson`, `toJson`, `fromFirestore`, `toFirestore`, `copyWith`
- `.g.dart` was manually regenerated (not via `build_runner` since the custom fromJson/toJson is used)

#### Event

**File:** `task_event.dart` — `StatusChangeRequested` (line ~202)

```dart
class StatusChangeRequested extends TaskEvent {
  final String taskId;
  final TaskStatus newStatus;
  final String userId;
  final String userRole; // 'admin', 'teamLeader', 'teamMember'
}
```

#### BLoC Handler

**File:** `task_bloc.dart` — `_onStatusChangeRequested` (line ~290)

Calls `_taskRepository.changeTaskStatus(...)`, emits `TaskUpdated` on success.

#### Repository

**File:** `task_repository.dart`

| Method | Line | Purpose |
|--------|------|---------|
| `changeTaskStatus()` | ~1064 | Validates transition, builds history entry, calls `updateTask()` |
| `_isValidStatusTransition()` | ~1113 | Role-based rules (see below) |

**Transition rules:**
- Admin / Team Leader: any transition allowed
- Team Member: only `pending -> inProgress` and `inProgress -> completed`
- All other transitions blocked for team members

#### UI — Task Detail Page

**File:** `task_detail_page.dart`

| Widget/Method | Line | Purpose |
|--------------|------|---------|
| `_currentUserRole` getter | ~142 | Reads `AuthBloc` state to determine `'admin'`/`'teamLeader'`/`'teamMember'` |
| Status dropdown | ~487-525 | `DropdownButtonFormField<TaskStatus>` with colored circle icons |
| `_saveChanges()` | modified | If status changed, dispatches `StatusChangeRequested` separately from `EditTaskRequested` |
| `_getTimeInCurrentStatus()` | ~816 | Calculates duration from last `statusHistory` entry's `changedAt` |
| `_buildStatusTimeline()` | ~838 | Renders history entries newest-first with colored dots, transition arrows, user names, formatted dates |
| `_getStatusColorForValue()` | nearby | Returns gray/blue/green based on status string value |

#### UI — Tasks Page (cards)

**File:** `tasks_page.dart`

| Method | Line | Purpose |
|--------|------|---------|
| `_getStatusColor()` | ~1206 | Gray=pending, Blue=inProgress, Green=completed |
| `_getStatusIcon()` | nearby | schedule/play_arrow/check_circle per status |
| `_getTimeInStatus()` | ~1228 | Compact format: `Xd` / `Xh` / `Xm` |
| `_buildStatusChip()` | modified | Colored chip with icon + label + time-in-status text |

---

### 2.3 Team Member Roles & Permissions

#### Repository

**File:** `team_repository.dart` — added `changeMemberRole()` method

Updates user's `role` field in Firestore for team context.

#### Event

**File:** `team_event.dart` — `ChangeMemberRoleRequested`

```dart
class ChangeMemberRoleRequested extends TeamEvent {
  final String teamId;
  final String memberId;
  final String leaderId;
  final String newRole; // specialty role string: 'Medical', 'Engineering', etc.
}
```

#### BLoC

**File:** `team_bloc.dart` — `_onChangeMemberRoleRequested` (line ~372)

Calls repository, then dispatches `LoadTeamMembers` to refresh.

#### UI — Team Detail Page

**File:** `team_detail_page.dart`

| Method | Line | Purpose |
|--------|------|---------|
| `_getRoleIcon()` | ~464 | Maps role string to IconData (medical_services, engineering, carpenter, plumbing, construction, electrical_services, inventory, local_shipping, work) |
| `_showChangeRoleDialog()` | ~488 | Dialog with radio buttons for each specialty role |
| `_buildExpandableMemberCard()` | ~560 | CircleAvatar shows role icon, badge chip shows specialty, action row has "CHANGE ROLE" + "REMOVE" buttons (visible to leader only) |

#### UI — Create Task Page

**File:** `create_task_page.dart`

| Method | Line | Purpose |
|--------|------|---------|
| `_getCategoryMatchingRole()` | ~998 | Maps `TaskCategory` enum to matching specialty role string (e.g., `TaskCategory.medical` -> `'Medical'`) |
| `_getRoleIcon()` | ~1022 | Same icon mapping as other pages |
| Assignment dropdown | ~737-759 | Filters by user role (team members see self only), then sorts matching-role members to top with bold styling |

#### UI — Task Detail Page

Assignment dropdown also has `_getRoleIcon()` (~792) and shows role icons next to member names.

---

### 2.4 Offline Sync Improvements

#### SyncState Enum & Stream

**File:** `sync_service.dart`

```dart
enum SyncState { synced, syncing, pending, error }
```

- `_syncStateController` — `StreamController<SyncState>.broadcast()`
- `syncStateStream` — public getter for the stream
- `_updateSyncState(SyncState)` — sets state + emits to stream
- Called at key points in `syncPendingChanges()`: start (syncing), empty queue (synced), completion (synced/error), finally block (pending if items remain)

#### Retry with Exponential Backoff

**File:** `sync_service.dart` — within `syncPendingChanges()` catch block (~line 116-132)

- On failure: reads `retryCount` from sync item (default 0), increments, saves back
- Delays: `[1, 5, 30, 300, 300]` seconds for retries 0-4
- Max 5 retries per item
- Schedules `Future.delayed` that calls `syncPendingChanges()` if not already syncing

#### Last Synced Timestamp

- Stored after successful sync: `HiveService.instance.storeSetting('lastSyncTimestamp', DateTime.now().toIso8601String())`
- Retrieved via `getLastSyncTimestamp()` method (~line 368)

#### Offline Banner

**File:** `home_page.dart`

- Listens to `Connectivity().onConnectivityChanged` in `initState()`
- `_isOffline` state drives a `MaterialBanner` at top of body Column
- Uses `AppLocalizations.of(context).offlineBanner` for text
- Auto-dismisses when connectivity returns

#### Sync Status Widget

**File:** `core/widgets/sync_status_widget.dart` (NEW)

- Subscribes to `SyncService.instance.syncStateStream`
- Shows colored bar: blue (syncing, with rotating icon), orange (pending + count), red (error), green (synced)
- Hidden (`SizedBox.shrink()`) when synced with 0 pending
- Uses `SingleTickerProviderStateMixin` for rotation animation
- Placed in `home_page.dart` body Column between offline banner and main content

---

## Localization Strings Added

All added to `app_localizations.dart` in both `'en'` and `'es'` maps:

| Key | English | Category |
|-----|---------|----------|
| `offlineBanner` | "You're offline — changes will sync when connected" | Sync |
| `syncPending` | "pending" | Sync |
| `syncError` | "Sync error" | Sync |
| `lastSynced` | "Last synced" | Sync |
| `statusHistory` | "Status History" | Status Workflow |
| `timeInStatus` | "Time in status" | Status Workflow |
| `statusChanged` | "Status changed" | Status Workflow |
| `invalidStatusTransition` | "Invalid status transition" | Status Workflow |
| `changeSpecialtyRole` | "Change Specialty Role" | Roles |
| `roleSaved` | "Role saved successfully" | Roles |
| `selectRole` | "Select Role" | Roles |

**Localization pattern:** Single file with `_getString(key)` method, two inline maps (`'en'` and `'es'`). New getters are declared as `String get keyName => _getString('keyName');` at the top of the class, values added to both maps.

---

## Patterns & Conventions for Future Sprints

### Enum Pattern
All enums in `core/enums/` follow this structure:
```dart
enum TaskStatus {
  pending('pending', 'Pending'),
  inProgress('inProgress', 'In Progress'),
  completed('completed', 'Completed');

  final String value;
  final String displayName;
  const TaskStatus(this.value, this.displayName);

  factory TaskStatus.fromString(String value) { ... }
}
```

### BLoC Pattern
- Events extend `TaskEvent` (Equatable), use `const` constructors
- States extend `TaskState` (Equatable), carry relevant data
- Handlers are private `_onEventName` methods registered in constructor via `on<EventType>`
- Emit `Loading` -> do work -> emit `Success`/`Error`

### AppBar Pattern
- Main pages (in bottom nav): `automaticallyImplyLeading: false`, `leading: KapokLogo()`
- Sub-pages (pushed): default back arrow, `centerTitle: true`, `KapokLogo()` in `actions`

### Repository Pattern
- Methods are async, throw typed exceptions (`TeamException`, `DatabaseException`, `CacheException`)
- Offline-first: write to Hive first, then attempt Firestore, queue to sync if offline
- Sync queue items stored in `HiveService.instance.syncBox` with operation type + data

### Role Icon Mapping
The `_getRoleIcon(String role)` helper is duplicated in 3 files (task_detail_page, create_task_page, team_detail_page). Consider extracting to a shared utility in `core/widgets/` or `core/utils/` during Sprint 3.

### Filter Persistence
Uses `HiveService.instance.storeSetting(key, value)` / `getSetting<String>(key)`. The settings box is a general-purpose key-value store already opened at startup.

---

## Known Issues & Technical Debt

1. **`_getRoleIcon()` duplication** — Same method in 3 files. Should be a shared utility.
2. **`withOpacity` deprecation warnings** — Flutter now recommends `.withValues()`. These are pre-existing across many files. Not blocking.
3. **`print` statements in `main.dart` / `kapok_app.dart`** — Should use `Logger` utility instead. Pre-existing.
4. **Radio widget deprecation** — Some Radio widgets use deprecated `groupValue`/`onChanged` pattern. Pre-existing.
5. **Task model `.g.dart`** — Was manually edited rather than regenerated via `build_runner`. If new fields are added, run `dart run build_runner build --delete-conflicting-outputs` from `app/` directory, but note the custom `fromJson`/`toJson` may need manual adjustment since they don't use the generated versions directly for all fields.
6. **No Android SDK on current dev machine** — `flutter build apk` fails. Use `flutter analyze` for validation. iOS builds should work.
7. **Sync conflict resolution** — The roadmap specifies last-write-wins and conflict dialogs (2.4), but only retry logic was implemented. Conflict resolution is deferred.
8. **"Pending sync" badges on task cards** — Listed in the plan but not implemented. The `SyncStatusWidget` covers overall status; per-card badges would require tracking which task IDs have pending sync ops.
9. **"Last synced" display in settings** — The timestamp is stored in Hive but not yet shown in the settings page UI.

---

## What Sprints 3-5 Should Know

### Sprint 3 (UX Polish) — Key entry points

- **Task cards redesign (3.1):** Start in `tasks_page.dart` `_buildTaskCard()`. Status chips, priority stars, and time-in-status are already rendered. Swipe actions would wrap the card in `Dismissible`. The `PriorityStars` widget is in `core/widgets/priority_stars.dart`.
- **Map visualization (3.2):** Map rendering is in `features/map/pages/map_page.dart`. Marker customization requires editing the Mapbox symbol layer. Task pins already show priority stars. Clustering would use Mapbox's built-in clustering config.
- **Form validation (3.3):** Create/edit forms are in `create_task_page.dart`, `create_team_page.dart`, login/signup pages. Current validation is minimal — `TextFormField` with basic `validator:` callbacks.
- **Settings (3.4):** Settings page is at `features/profile/pages/` or reachable from drawer. Theme is managed via `ThemeData` in `kapok_app.dart`. Language switching uses `AppLocalizationsDelegate` with `Locale` state.

### Sprint 4 (Advanced Features) — Key considerations

- **Due dates (2.5 / 4.x):** Add `dueDate` field to `TaskModel` (same pattern as `statusHistory` — add to model, fromJson/toJson, fromFirestore/toFirestore, copyWith, .g.dart). Add date picker to create/edit forms.
- **Navigation (3.5):** Router is in `app/router.dart`. Named routes are used throughout. Deep linking would require `go_router` or `uni_links` package.
- **Team communication (4.1):** Would need a new Firestore subcollection (`teams/{teamId}/messages`), a new model, and a new BLoC. Pattern follows existing team/task BLoC structure.
- **Analytics (4.2):** `fl_chart` package is mentioned in roadmap. Data can be computed from existing task/team models in repository layer.

### Sprint 5 (Final Polish) — Key considerations

- **Accessibility (4.3):** Add `Semantics` widgets. Current codebase has minimal semantic labels. Start with interactive elements (buttons, cards, dropdowns).
- **Advanced offline (4.4):** Build on `sync_service.dart`. Media caching would extend the Hive storage. Conflict detection could use Firestore document version fields.
- **Onboarding (4.5):** `shared_preferences` or Hive setting to track first launch. Onboarding screens would be a new feature module.

### Build & Verify

```bash
cd app
flutter analyze        # Zero errors expected, info-level warnings are pre-existing
flutter test           # Unit tests in test/ directory
dart run build_runner build --delete-conflicting-outputs  # If models change
```

No Android SDK is configured on this machine. iOS builds work. Use `flutter analyze` as the primary compilation check.
