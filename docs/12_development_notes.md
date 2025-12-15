# Development Notes

## Prerequisites

- Flutter SDK ^3.9.2
- Dart SDK ^3.9.2
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

Create a `.env` file in the project root:

```
MAPBOX_ACCESS_TOKEN=your_mapbox_token_here
```

The Mapbox token is required for map functionality. Obtain one from [Mapbox](https://www.mapbox.com/).

### 3. Firebase Configuration

The project uses Firebase. Configuration is in `lib/firebase_options.dart` (generated via FlutterFire CLI).

To regenerate:
```bash
flutterfire configure
```

### 4. Code Generation

Run build_runner for JSON serialization and Hive adapters:

```bash
flutter pub run build_runner build
```

For continuous generation during development:
```bash
flutter pub run build_runner watch
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
flutter run -d chrome          # Web
flutter run -d ios              # iOS Simulator
flutter run -d android          # Android Emulator
flutter run -d <device_id>      # Specific device
```

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

### Android APK

```bash
flutter build apk --release
```

### Android App Bundle

```bash
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

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
3. Run `flutter pub run build_runner build`
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
| Privacy Policy | Content is placeholder |
| Terms of Service | Content is placeholder |
| Clear Cache | Shows success but implementation incomplete |
| Edit Team | Placeholder functionality |

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
flutter pub run build_runner build --delete-conflicting-outputs
```

## Performance Profiling

```bash
flutter run --profile
```

Use DevTools: `flutter pub global activate devtools`

## CI/CD Notes

The project does not include CI/CD configuration. For production deployment:

1. Set up secrets for `MAPBOX_ACCESS_TOKEN`
2. Configure Firebase credentials
3. Handle code signing for iOS/Android
4. Run tests before builds
