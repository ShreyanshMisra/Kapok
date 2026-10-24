# Kapok

## Setup & Run

1. `cd app`
2. Copy `.env.example` to `.env` and fill in the Mapbox token.
3. Drop the platform-specific Firebase config files into place (they are
   `.gitignore`d on purpose — each developer downloads their own from the
   Firebase Console for the `build-kapok` project):
   - `app/ios/Runner/GoogleService-Info.plist`
   - `app/android/app/google-services.json`
4. `flutter pub get`
5. `flutter run` and pick a device: the iOS Simulator (iPhone), an Android
   emulator, or Chrome (web is for development/QA only).

Full setup, build, and release notes are in `docs/12_development_notes.md`.

## Identifiers

- iOS bundle ID: `com.afairresolution.kapok`
- Android applicationId / namespace: `com.afairresolution.kapok`
- Kotlin package: `com.afairresolution.kapok`

If you ever rename these, you must also re-register the platform in Firebase
Console (`build-kapok` project → Project settings → Your apps), re-download
the config files above, and update `lib/firebase_options.dart`.

## Mapbox token

The Android manifest reads the token from a Gradle placeholder. The build
looks for it in `android/key.properties` first (copy
`android/key.properties.example`; the same file holds release signing), then in
either of these:

- `~/.gradle/gradle.properties`:
  ```
  MAPBOX_ACCESS_TOKEN=pk.eyJ1...
  ```
- or export it in the shell before `flutter run`:
  ```
  export MAPBOX_ACCESS_TOKEN=pk.eyJ1...
  ```

The same token in `app/.env` powers iOS, web, and runtime calls to the
Mapbox Geocoding API.