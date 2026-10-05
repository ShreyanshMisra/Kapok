# Changelog

All notable changes to Kapok are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

The version line in `app/pubspec.yaml` (`MAJOR.MINOR.PATCH+BUILD`) is the source
of truth; update it in the same PR as the changelog entry.

## [Unreleased]

### Beta pre-flight (2026-10-05)

- **Dependencies:** removed unused `permission_handler`, `flutter_local_notifications`, `app_links`, `url_launcher`, `cached_network_image`, `flutter_spinkit`, `pdf`. Upgraded all remaining packages to latest compatible versions (Firebase iOS SDK 12.19, Mapbox 11.31 / `mapbox_maps_flutter` 2.31).
- **iOS:** deployment target 14.0 → 15.0 (Firebase iOS SDK 12 minimum); added `PrivacyInfo.xcprivacy`; `ITSAppUsesNonExemptEncryption=false` (skips export-compliance prompt per upload); `UIRequiresFullScreen` so the portrait-only iPad build passes validation.
- **Android:** release builds sign with the upload key from `android/key.properties` (template: `key.properties.example`); fixed the `key.properties` path used for `MAPBOX_ACCESS_TOKEN`; removed unused `FOREGROUND_SERVICE`, `POST_NOTIFICATIONS`, `VIBRATE`, and external-storage permissions.
- **Firestore rules:** non-leader members may remove themselves from a team's `memberIds` — previously Leave Team and Delete Account were denied for regular members. Repo rules re-synced with the live ruleset first (it carried console-only clauses for leadership transfer and leader/admin `teamId` clearing). Deployed to `build-kapok` and verified with the Rules test API.
- **App identifier:** final ID is `com.afairresolution.kapok` (matches the App Store Connect record — Apple ID `6807118290`, SKU `kapok-afairresolution`). iOS, macOS, Android `applicationId`/`namespace`, and Kotlin package updated.
- **Firebase apps:** registered iOS + Android apps for `com.afairresolution.kapok` in `build-kapok` (iOS `1:673387486415:ios:da00b9b173e27a85e9ebba`, Android `1:673387486415:android:c2f6a79597cc74b6e9ebba`); `firebase_options.dart` and `app/firebase.json` point at them. Config files are local-only (gitignored). Legacy `com.example.*` and interim `org.afairresolution.*` app records are unused.
- **iOS signing:** Runner target uses automatic signing with team A Fair Resolution, LLC (`9M48UX3QW7`).
- **iOS launch screen:** replaced the transparent placeholder `LaunchImage` with the Kapok icon (160pt) on the existing brand-blue background, matching the Android splash.
- **Firebase packages capped** below the FlutterFire releases that require Flutter ≥ 3.38 (`FlutterSceneLifeCycleDelegate`): core 4.5.0, auth 6.2.0, Firestore 6.1.3, Firebase iOS SDK 12.9. Lift after a Flutter SDK upgrade.
- **Task list:** cards show team and assignee *names* prominently with the raw ID as muted secondary text; names for teams/users outside the local cache (e.g. admins) are fetched once from Firestore. Deleted accounts display "Deleted user".
- **About:** copyright year 2006 → 2026.
- **Fixes:** `ConnectivityResult` switch made forward-compatible (new `satellite` value broke compilation); stale `map_bloc_test` expectations + hanging tearDown; removed inaccurate "end-to-end encrypted" claim from About.
- **CI:** pinned Flutter 3.35.4, creates `.env` from template, format check is advisory.


### Added

- Acknowledgements page linked from About → Technology, listing project leaders, inspirations, and contributors (EN + ES).
- "Do not enter any person's name in the task" PII reminder below the Create Task button.
- Always-visible horizontal scrollbar on the Profile permissions table so off-screen columns are obvious on small devices.
- Store-readiness evaluation in `docs/15_store_readiness_evaluation.md`.
- Critical-path unit tests covering enums (`UserRole`, `TaskPriority`, `TaskStatus`, `TaskCategory`), `UserModel`, the `Logger`, and EN/ES localization completeness.
- `integration_test/` scaffold with a smoke test and a README explaining how to run against the Firebase emulator suite.
- GitHub Actions CI workflow (`.github/workflows/ci.yml`) running format check, analyze, and tests on pushes and PRs to `main` and `test`.
- `CHANGELOG.md` (this file).
- Privacy Policy + Terms of Use drafts in `lib/core/constants/`, surfaced in Settings via a new full-page `LegalDocumentPage` (replaces the old "content will be implemented here" stub dialogs). Marked clearly as drafts pending legal review.
- Account deletion: typed-confirmation flow in Settings that anonymizes the user's authored / assigned tasks (`createdBy` / `assignedTo` → `deleted_user`), removes them from team `memberIds`, deletes the Firestore user doc, clears the Hive cache, and deletes the Firebase Auth user. Blocks deletion with a clear error if the user still leads an active team.
- `flutter_native_splash` configured for Android using `AppColors.primary` (#013576) and `assets/images/kapok_icon.png`. iOS keeps its custom `LaunchScreen.storyboard`.
- README in `app/` documenting the new Firebase config + Mapbox token setup steps.

### Changed

- Replaced 10 unguarded `print()` calls in `lib/main.dart` with the existing `Logger` so startup messages are stripped from release console output.
- Standardized iOS deployment target to **14.0** across `Runner.xcodeproj` and `Podfile` (was inconsistent: some configs at 13.0, others at 15.6).
- Renamed iOS bundle ID and Android `applicationId`/`namespace` from `com.example.kapok*` to `org.afairresolution.kapok` (later finalized as `com.afairresolution.kapok`). Kotlin `MainActivity` package relocated to the matching path. **Mobile Firebase Auth/Firestore will fail at runtime until the apps are re-registered in Firebase Console under the new identifiers — see the banner comment at the top of `lib/firebase_options.dart`.**
- Android Mapbox token is now injected via Gradle `manifestPlaceholders` from (in order) `app/android/key.properties`, `MAPBOX_ACCESS_TOKEN` env var, or `gradle.properties`. The literal `YOUR_MAPBOX_ACCESS_TOKEN` placeholder is gone.
- `.gitignore` now explicitly covers `GoogleService-Info.plist`, `google-services.json`, `key.properties`, and Android keystores. The iOS Firebase plist has been removed from the git index (still on disk locally); future developers download their own from Firebase Console per the README.

### Fixed

- `lib/core/services/network_checker.dart` no longer references the removed `ConnectivityResult.satellite`, which had been preventing `test/features/map/map_bloc_test.dart` from compiling.

### Removed

- Dead duplicate `lib/kapok_app.dart` (the live app uses `lib/app/kapok_app.dart`). Removed the only `avoid_print` lint hit in production code.

## [1.0.0] – Initial private build

The first end-to-end build of Kapok. Functionality summary:

- Email/password authentication via Firebase Auth, with optional anonymous mode for first-run onboarding.
- Role-based access control: `admin`, `teamLeader`, `teamMember`.
- Team lifecycle: create, join via code, view members, transfer leadership, leave, delete.
- Task lifecycle: create with location + priority + category, assign, edit, mark complete, delete.
- Mapbox-powered map with task pins, geocoding, reverse geocoding, and offline tile caching.
- Offline-first Hive cache layered under Firestore for tasks and teams.
- English + Spanish localization throughout.
- Crashlytics + Firebase Analytics (privacy-controlled).
- About page with mission, icon story, key features, technology, and legal sections.

[Unreleased]: https://github.com/ShreyanshMisra/Kapok/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/ShreyanshMisra/Kapok/releases/tag/v1.0.0
