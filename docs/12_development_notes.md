# Development Notes

_Last verified against the codebase: 2026-10-24._

## Prerequisites

- Flutter 3.35.4 (stable), the version CI and store builds use
- Dart SDK ^3.9.2
- Xcode 26+ for iOS store builds
- Firebase CLI (for Firebase setup)
- Mapbox account (for access token)
- Xcode (for iOS development)
- Android Studio (for Android development)

## Environment Setup

### 1. Clone and Install Dependencies

```bash
cd app
flutter pub get
```

### 2. Environment Variables

Create `app/.env` from the template:

```bash
cd app
cp .env.example .env
```

```
MAPBOX_ACCESS_TOKEN=pk.your_public_token
MAPBOX_STYLE_ID=mapbox/streets-v11
```

The Mapbox **public** token (`pk.*`) is required for map functionality. `.env` is gitignored but bundled into the app as an asset, so never put a secret (`sk.*`) token in it.

### 3. Firebase Configuration

The project uses Firebase. Configuration is in `lib/firebase_options.dart` (generated via FlutterFire CLI).

To regenerate:
```bash
flutterfire configure
```

### 4. Code Generation

Run build_runner for JSON serialization and Hive adapters:

```bash
dart run build_runner build --delete-conflicting-outputs
```

For continuous generation during development:
```bash
dart run build_runner watch
```

## Running the App

### Debug Mode

```bash
flutter run
```

### Release Mode

```bash
flutter run --release
```

### Specific Platform

```bash
flutter run -d chrome          # Web (development/QA only)
flutter run -d ios              # iOS Simulator (iPhone only)
flutter run -d android          # Android Emulator
flutter run -d <device_id>      # Specific device
```

### Web QA tips

The web build is handy for clicking through the app without a simulator (it hits the **production** Firebase project, so use the test accounts in `13_handoff_documentation.md` and delete any data you create):

```bash
flutter run -d web-server --web-port 8787
```

If you drive it with Playwright or similar automation, don't enable Flutter's accessibility semantics and type into the email field. The engine throws `setSelectionRange` on `type=email` inputs and the app stops responding. Use real mouse clicks and keyboard input instead. The first tap right after page load is sometimes ignored.

### List Available Devices

```bash
flutter devices
```

## Testing

### Run All Tests

```bash
flutter test
```

### Run Specific Test File

```bash
flutter test test/features/map/map_bloc_test.dart
```

### Run with Coverage

```bash
flutter test --coverage
```

## Building

### Android App Bundle (Play Store)

Requires `app/android/key.properties` (gitignored, **not created yet**). Start from the template: `cp app/android/key.properties.example app/android/key.properties`

```properties
storeFile=/absolute/path/outside/repo/kapok-upload.jks
storePassword=...
keyAlias=upload
keyPassword=...
MAPBOX_ACCESS_TOKEN=pk....
```

Create the upload keystore once and back it up somewhere safe (losing it means asking Google to reset the upload key):

```bash
keytool -genkey -v -keystore ~/keys/kapok-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

```bash
flutter build appbundle --release
```

Without `key.properties`, release builds silently fall back to the **debug** key (Play rejects these) and the Mapbox token is empty (maps won't load). Enroll in Play App Signing when uploading the first bundle. The first Gradle build downloads several GB of dependencies, so make sure there's disk space.

### Android APK (side-loading/testing)

```bash
flutter build apk --release
```

### iOS (App Store)

```bash
cd app/ios && pod install && cd ..   # after any plugin change (e.g. pointer_interceptor)
flutter build ipa --release          # or archive from Xcode
```

Bump `version:` in `pubspec.yaml` (e.g. `1.0.0+3`) before each upload. The build number must increase for every App Store Connect / Play upload.

### Web

```bash
flutter build web --release
```

## Architecture Patterns

### BLoC Pattern

The app uses `flutter_bloc` for state management:

1. **Events**: User actions or system triggers
2. **BLoC**: Processes events, interacts with repositories
3. **States**: UI-representable snapshots

```dart
// Event
class LoadTasks extends TaskEvent {
  final String teamId;
}

// BLoC handler
on<LoadTasks>((event, emit) async {
  emit(TaskLoading());
  try {
    final tasks = await taskRepo.getTasks(event.teamId);
    emit(TasksLoaded(tasks));
  } catch (e) {
    emit(TaskError(e.toString()));
  }
});

// UI consumption
BlocBuilder<TaskBloc, TaskState>(
  builder: (context, state) {
    if (state is TaskLoading) return CircularProgressIndicator();
    if (state is TasksLoaded) return TaskList(state.tasks);
    if (state is TaskError) return ErrorWidget(state.message);
    return SizedBox.shrink();
  },
)
```

### Repository Pattern

Repositories abstract data sources:

```
UI → BLoC → Repository → DataSource(s)
                      ↘ Firebase
                      ↘ Hive (offline)
```

### Offline-First

1. All writes go to Hive first
2. Writes are queued for Firebase sync
3. Reads check Hive, then Firebase if online
4. SyncService processes queue when online

## Common Development Tasks

### Adding a New Feature

1. Create feature directory: `lib/features/{feature}/`
2. Add BLoC files: `bloc/{feature}_bloc.dart`, `_event.dart`, `_state.dart`
3. Add pages: `pages/{feature}_page.dart`
4. Register BLoC in `injection_container.dart`
5. Add route in `router.dart`

### Adding a New Model

1. Create model in `lib/data/models/{model}_model.dart`
2. Add `@JsonSerializable()` annotation
3. Run `dart run build_runner build`
4. Add Firestore methods (`fromFirestore`, `toFirestore`)

### Adding a New Service

1. Create service in `lib/core/services/{service}_service.dart`
2. Use singleton pattern
3. Register in `injection_container.dart`
4. Initialize in `main.dart` if needed

### Adding Localized Strings

1. Open `lib/core/localization/app_localizations.dart`
2. Add getter for new string
3. Add translations in `_getString()` map for 'en' and 'es'

## Known Constraints

### Platform-Specific

- **Web**: `InternetAddress.lookup` not available; assumes connectivity means internet access
- **iOS**: Requires location permission prompt customization in Info.plist
- **Android**: Requires location permissions in AndroidManifest.xml

### Feature Limitations

| Feature | Limitation |
|---------|------------|
| Push Notifications | Deferred; infrastructure not implemented |
| Profile Pictures | Upload not implemented |
| Privacy Policy / Terms of Service | Full drafts in `lib/core/constants/`, pending legal review; need a hosted URL for the store listings |
| Analytics events | `AnalyticsService` helpers exist but aren't called; only automatic Firebase analytics |
| Analytics page, Map test page, Edit Task page | Exist as routes but aren't linked from the UI |

Note: Edit Team is fully implemented via `edit_team_page.dart` (Phase 5.2).

### Settings Page — Remaining Sections

Current sections are: **Location**, **Language**, **Appearance (Theme)**, **Data** (Clear Cache), **About** (App Version, tagline, Privacy Policy, Terms of Service), then **Sign Out** and **Delete Account**. Removed over time: Notifications, Privacy (analytics/crash toggles), Feedback & Support, Sync, Export Data, Administrator Permissions.

### Implemented Changes (Phases 1–7)

High-level summary of changes applied to the app during the Phase 1–7 sprints — useful context when reading code that differs from older docs:

- **UI consistency:** curved blue header block on all AppBars, equal `KapokLogo` spacing, dark-mode-safe filter chips on the Tasks page, centered sub-page titles.
- **Text/content:** "disaster relief" → "disaster response" globally; About page text refreshed (Kapok Icon, Tech Roots, Technology, Legal); theme option "System" → "Default".
- **About / Settings structural:** About page is the post-first-login landing page; "A Fair Resolution, LLC" section removed; Key Features bullets use a hanging indent; App Version + tagline added to About and Settings; Notifications, Privacy, and Feedback & Support sections removed from Settings.
- **Feature removals & map:** due date / overdue UI removed (field preserved on the model); all active map markers are blue (`AppColors.primary`), completed markers grey, priority shown via stars; per-page help overlays corrected.
- **Feature implementations & bug fixes:** Share Team Code via `share_plus`; full-screen Edit Team page; `removeMember` Firestore transaction fixed to use `transaction.get()`; task edit bugs fixed (assigned-to dropdown state, double-pop on save, form state reset); Spanish locale switching fixed (removed `MaterialApp` `ValueKey`); team join confirmation snackbar verified.
- **Permissions & admin:** team members may only edit tasks assigned to them; leaders/admins can edit any; permissions enforced in UI and at the repository layer. New Administrator Permissions page under Settings → About and a role-aware permissions table on the Profile page. _(The Administrator Permissions page was later removed; the Profile permissions table remains.)_
- **Additional fixes:** task detail page map shows a blue pin on mobile via `tasks: [widget.task]` + `onMobileControllerReady`; Settings → Sync now re-fetches teams and tasks from Firebase after running the sync queue. _(Settings → Sync was later removed; the Tasks page refresh button now re-fetches.)_

### October 2026 QA & Store-Readiness Fixes

From a full click-through on web plus a code-level App Store / Play Store review:

- **Task delete never reached Firestore**: the transaction wrote before reading. Now reads the team first.
- **Offline task deletes were dropped**: `SyncService` didn't handle `delete_task_and_update_team`. Now it does.
- **Edit Task / Create Task dropdowns froze the form**: the assignee items' `Row` + `Expanded` sat in unbounded width. Fixed with `isExpanded: true`.
- **Team detail narrowed the global task list**: it now reloads all of the user's teams on exit.
- **Create Task address was never saved**: it's now passed through `CreateTaskRequested.address`.
- **Map pins**: they now persist across offline-progress states, refresh after task create/edit/delete, and render on web once the controller is ready.
- **Duplicate FAB hero tags**: fixed.
- **Web only**: Crashlytics is skipped (no web implementation). The Mapbox GL canvas now resizes with its container. The Create Task form is wrapped in `PointerInterceptor`.
- **Location denied**: the map falls back to the default center instead of showing an error (App Review guideline 5.1.1).
- **Account deletion**: checks for a recent sign-in *before* deleting data (no half-deleted accounts). The leader guard now uses `isActive` (it queried a non-existent `active` field). Closed teams the user led are skipped. A refused deletion no longer wipes the visible data.
- **UI**: team task rows show the stars once; unassigned tasks read "Assigned to none"; one untranslated Settings string is now localized; onboarding no longer mentions due dates.
- **Content**: Emma W. added to Acknowledgements (between Darrell M. and Sha B.). Privacy Policy / Terms contact set to kapok@afairresolution.com; the analytics opt-out claim was removed.
- **iOS**: now iPhone-only (`TARGETED_DEVICE_FAMILY = 1`).
- **Firestore rules**: added an owner-only `mapSnapshots/{userId}` rule (in the repo, **not yet deployed**).

### Offline Limitations

- Team join/leave requires online (transaction safety)
- Initial map download requires online
- Team code verification requires online

## Debugging Tips

### Logger

The app includes a custom logger:

```dart
import 'package:kapok/core/utils/logger.dart';

Logger.info('Message', tag: 'TAG');
Logger.error('Error', tag: 'TAG', error: e);
Logger.debug('Debug info', tag: 'TAG');
Logger.network('Network event');
```

### Network Testing

Toggle offline mode for testing:

```dart
NetworkChecker.instance.setTestModeOverride(true);  // Force offline
NetworkChecker.instance.setTestModeOverride(false); // Force online
NetworkChecker.instance.setTestModeOverride(null);  // Use real network
```

### BLoC Debugging

Add `BlocObserver` for logging state changes:

```dart
Bloc.observer = MyBlocObserver();
```

## Dependencies Update

```bash
flutter pub upgrade
flutter pub outdated
```

## Clean Build

```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

## Performance Profiling

```bash
flutter run --profile
```

Use DevTools: `flutter pub global activate devtools`

## Firestore Rules Deployment

Teammates sometimes edit rules directly in the Firebase Console, so the live ruleset can drift from `firebase/firestore.rules`. Deploying the repo file blindly could wipe those edits. Before every deploy:

1. Open **Firebase Console → Firestore Database → Rules** for `build-kapok` and copy the published rules into a scratch file (e.g. `/tmp/live.rules`).
2. Diff: `diff --strip-trailing-cr /tmp/live.rules firebase/firestore.rules` (the console copy uses CRLF line endings).
3. Merge any live-only clauses into the repo file and commit.
4. Optionally test in the **Rules Playground** in the console.
5. Deploy: `firebase deploy --only firestore:rules` (from the repo root; `.firebaserc` points at `build-kapok`).

## CI/CD Notes

`.github/workflows/ci.yml` runs on pushes and PRs to `main` and `test`. It installs Flutter 3.35.4, creates `app/.env` from `.env.example`, then runs `flutter analyze` (fails on errors) and `flutter test`.

There is no release pipeline yet. Store builds are made locally (see **Building** above). A future `build.yml` could produce the AAB/IPA on version tags and upload them to Play Internal Testing / TestFlight.
