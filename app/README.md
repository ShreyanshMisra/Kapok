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
5. `flutter clean`
6. `flutter run`

When prompted, select `2` to develop in Chrome, or alternatively choose the
iOS Simulator / Android Emulator if you have them installed.

## Identifiers

- iOS bundle ID: `org.afairresolution.kapok`
- Android applicationId / namespace: `org.afairresolution.kapok`
- Kotlin package: `org.afairresolution.kapok`

If you ever rename these, you must also re-register the platform in Firebase
Console (`build-kapok` project → Project settings → Your apps), re-download
the config files above, and update `lib/firebase_options.dart`.

## Mapbox token

The Android manifest reads the token from a Gradle placeholder. Set it in one
of two places before running on Android:

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