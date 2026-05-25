# Kapok – App Store & Google Play Readiness Evaluation

**Date:** 2026-05-25
**App version:** `1.0.0+1` (`app/pubspec.yaml`)
**Target stores:** Apple App Store, Google Play Store
**Status:** Not ready for submission. Multiple blockers across signing, identifiers, secrets, and policy.

---

## Executive Summary

Kapok is functionally substantial — auth, teams, tasks, map, analytics, two-language localization, offline caching, and Crashlytics are all wired up. However, **the Android + iOS release configurations are still on Flutter defaults** (debug signing, example bundle ID, placeholder Mapbox token, no production signing identity). Before either store will accept a submission, a focused remediation pass is required.

| Area | State | Severity to ship |
| --- | --- | --- |
| Code & feature completeness | Mostly complete; ~12 TODOs in Mapbox source layer | Low–Med |
| iOS release config | Bundle ID `com.example.kapokApp`; deployment target inconsistent (13.0 + 15.6); no distribution signing | **Blocker** |
| Android release config | Package `com.example.kapok_app`; release uses debug keystore; Mapbox token unset | **Blocker** |
| Secrets & key hygiene | `GoogleService-Info.plist` committed; `.env` correctly ignored; no obvious secrets in `lib/` | High |
| Privacy & legal | Privacy Policy / ToS are localized stubs; no hosted URLs; no in-app data-deletion explanation | **Blocker** |
| Testing | 6 test files + new critical-path additions in this pass; no integration_test/ on device runner | Med |
| CI/CD | None until this pass | Med |
| Crash & analytics | Crashlytics + Firebase Analytics wired; Crashlytics assertion fires on web only (non-issue for mobile builds) | Low |
| Accessibility / i18n | EN + ES localized; Semantics labels present; full a11y audit pending | Low–Med |
| App store assets (icons, splash) | iOS + Android icons + iOS splash present; Android relies on default Flutter splash | Low |
| Store metadata (screenshots, descriptions, ratings questionnaires) | Not started | High |

The fastest path to a beta build for TestFlight / Play internal-testing is roughly **2–4 engineering days** of focused config work after the items in §2 are resolved. A polished public release adds **another 1–2 weeks** for legal, marketing assets, and a real beta test cycle.

---

## 1. Methodology

This evaluation combined:

- File-level inspection of `app/pubspec.yaml`, `app/ios/Runner/Info.plist`, `app/ios/Runner.xcodeproj/project.pbxproj`, `app/android/app/build.gradle.kts`, `app/android/app/src/main/AndroidManifest.xml`, `app/lib/main.dart`, and the `lib/core`, `lib/features`, `lib/data` trees.
- `git ls-files` to confirm which sensitive files are tracked.
- `flutter analyze` across the changed surface.
- Cross-referencing Apple's [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/) and Google Play's [Developer Program Policies](https://play.google.com/about/developer-content-policy/) for required disclosures (location, data deletion, privacy labels).

No code changes were made as part of this evaluation — findings are documented for the team to triage and act on. The accompanying test-suite additions (§7) and CI workflow (§8) are the only file changes in this commit.

---

## 2. Blockers (must resolve before any store submission)

### 2.1 Bundle / package identifiers are still examples

- `PRODUCT_BUNDLE_IDENTIFIER = com.example.kapokApp` — `app/ios/Runner.xcodeproj/project.pbxproj`
- `applicationId = "com.example.kapok_app"` — `app/android/app/build.gradle.kts:31`
- `namespace = "com.example.kapok_app"` — `app/android/app/build.gradle.kts:13`

Apple and Google both forbid `com.example.*` identifiers on submission. Pick a reverse-DNS prefix the LLC controls (e.g. `org.afairresolution.kapok` or `com.afairresolution.kapok`) and apply it consistently in:

- iOS: `project.pbxproj` (all three configurations — Debug, Release, Profile)
- Android: `build.gradle.kts` `applicationId` **and** `namespace`, plus the Firebase `google-services.json` package_name
- Firebase Console: register the new bundle ID + package name and re-download `GoogleService-Info.plist` / `google-services.json`

### 2.2 Android release builds use the debug signing key

`app/android/app/build.gradle.kts:38-43`:

```kotlin
buildTypes {
    release {
        // TODO: Add your own signing config for the release build.
        // Signing with the debug keys for now, so `flutter run --release` works.
        signingConfig = signingConfigs.getByName("debug")
    }
}
```

Play Store will reject any AAB signed by the debug keystore. Required steps:

1. Generate an upload keystore (`keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`).
2. Store the keystore **outside** the repo (e.g. `~/keys/kapok-upload.jks`) and add credentials to `~/.gradle/gradle.properties` or a CI secret store. **Never commit it.**
3. Read credentials from `key.properties` (gitignored) per [Flutter signing docs](https://docs.flutter.dev/deployment/android#signing-the-app).
4. Enroll in [Play App Signing](https://support.google.com/googleplay/android-developer/answer/9842756) so Google manages the final signing key.

### 2.3 iOS distribution signing is not configured

`project.pbxproj` only carries `CODE_SIGN_IDENTITY = "iPhone Developer"` with automatic signing. For App Store Connect you need:

- An Apple Developer Program enrollment (~$99/year) registered to A Fair Resolution, LLC.
- A distribution certificate and an App Store provisioning profile for the chosen bundle ID.
- Either keep Automatic signing (Xcode managed) **with** a paid team selected, or set up manual signing — pick one and apply it to **Release** and **Profile** configs.

### 2.4 Mapbox access token is still a placeholder on Android

`app/android/app/src/main/AndroidManifest.xml:29-31`:

```xml
<meta-data
    android:name="com.mapbox.token"
    android:value="YOUR_MAPBOX_ACCESS_TOKEN" />
```

Maps will fail at runtime on Android release builds. Two acceptable patterns:

- **Build-time substitution** (recommended): replace with `android:value="${MAPBOX_DOWNLOADS_TOKEN}"` and inject via `manifestPlaceholders["MAPBOX_DOWNLOADS_TOKEN"] = System.getenv("MAPBOX_DOWNLOADS_TOKEN")` in `build.gradle.kts`.
- **Read at runtime**: load the token from `.env` and pass it to `MapboxOptions.setAccessToken` before any map is constructed.

Mapbox also requires a **separate** secret `DOWNLOADS_TOKEN` (with `DOWNLOADS:READ` scope) in `~/.gradle/gradle.properties` to fetch the SDK during build. Verify that is set on every machine that will produce release builds, including CI.

### 2.5 iOS deployment target is inconsistent

`project.pbxproj` shows `IPHONEOS_DEPLOYMENT_TARGET = 13.0` (Debug/Release/Profile for some targets) and `15.6` for others (lines 499, 517, 629, 680, 700, 723). Pick one — recommend **`14.0`** as the lowest still receiving security updates and supported by current Firebase + Mapbox SDKs — and apply it everywhere. Then run `cd ios && pod deintegrate && pod install` so CocoaPods regenerates.

### 2.6 Privacy Policy and Terms of Service are not real

`app/lib/features/profile/pages/settings_page.dart` opens stub dialogs ("Privacy Policy content will be implemented here…"). Apple's App Privacy section, Google Play's Data Safety form, and California / EU residents all require a **hosted, dated, plain-language** privacy policy URL before submission. Required content checklist:

- What personal data is collected: email, password (hashed by Firebase Auth), display name, user role, team membership, task content authored, geolocation when creating tasks, device language preference.
- Who it is shared with: Firebase / Google Cloud, Mapbox (geocoding only, never user identity), Crashlytics.
- Retention period and account-deletion process (with steps user follows).
- Children's policy (Kapok is not directed at children — state explicitly to satisfy Play's Target Audience questionnaire).
- A contact email at A Fair Resolution, LLC.
- Last-updated date.

Same goes for Terms of Service. Host both on a stable URL (e.g. `https://afairresolution.com/kapok/privacy`) and load them in-app via `url_launcher` or an in-app webview — replace the existing stub dialogs.

### 2.7 Sensitive Firebase config committed to git

`git ls-files` shows `app/ios/Runner/GoogleService-Info.plist` is tracked. The Android `google-services.json` is **not** tracked (good — it lives on disk only). Apple's GoogleService-Info file contains a real `API_KEY`. While Firebase iOS API keys aren't catastrophic on their own (they're embedded in any compiled app), best practice is:

1. Restrict the key in Google Cloud Console (Firebase project → APIs & Services → Credentials) to only the bundle identifier you ship.
2. Move the file out of source control if the repo is or will be public. If the repo is private and stays private, restricting the key is sufficient.

Also confirm `.gitignore` covers anything new: `app/.env`, `app/android/app/google-services.json`, and any keystore are already either ignored or absent. Audit again after every Firebase reconfiguration.

---

## 3. High-priority cleanup (should land before public beta)

### 3.1 `print()` calls in `lib/main.dart` run in release builds

`lib/main.dart` has 10 unguarded `print()` calls (lines 21, 25, 27, 28, 29, 30, 31, 55, 56, 57). `print` is **not** stripped from release builds; only `debugPrint` (which downgrades to a no-op under `kReleaseMode`) is. These add noise to device logs and may be flagged by static review. Two-line fix per site:

```dart
if (kDebugMode) {
  print("✅ Environment variables loaded");
}
```

…or replace with `debugPrint` and a structured logger (the project already has `lib/core/utils/logger.dart` — use it).

### 3.2 Mapbox source has 11 method stubs — dead code, safe to delete

`lib/data/sources/mapbox_source.dart` defines a `MapboxSource` class with 11 unimplemented methods (geocoding, reverse geocoding, directions, search, tile URL, static map URL, etc.) that return hard-coded New York placeholders. Audit shows:

- **No active callers.** Its only references in the repo are a commented-out import and a commented-out DI registration in `lib/injection_container.dart` (lines 18, 68). Nothing in `lib/features/**`, `lib/data/repositories/**`, or any widget imports it.
- **Functionality already exists elsewhere.** Forward + reverse geocoding are implemented in `lib/core/services/geocode_service.dart`, which calls Mapbox's HTTP API directly (with a local Hive cache). Map rendering, tile URLs, and styles are handled by the `mapbox_maps_flutter` SDK via `lib/features/map/`.
- **Risk if uncommented:** the constants block embeds the literal string `'YOUR_MAPBOX_API_KEY'`, so any caller would hit the placeholder rather than the real token.

**Recommended action:** delete `lib/data/sources/mapbox_source.dart` along with the commented references in `injection_container.dart`. Do **not** advertise features in the App Store description (Apple Review Guideline 2.3.10) that aren't actually delivered by the shipped code paths. None of the methods in `MapboxSource` would deliver a feature today.

### 3.3 Android lacks a branded splash screen

iOS has `LaunchScreen.storyboard` + `LaunchImage` asset set. Android falls back to the default Flutter splash (black/white). For parity, add [`flutter_native_splash`](https://pub.dev/packages/flutter_native_splash) and configure with the Kapok logo:

```yaml
dev_dependencies:
  flutter_native_splash: ^2.4.0

flutter_native_splash:
  color: "#0E7C7B"   # match primary
  image: assets/images/icon/Kapok_Icon_Light.png
  android_12:
    image: assets/images/icon/Kapok_Icon_Light.png
    color: "#0E7C7B"
```

Then run `dart run flutter_native_splash:create`.

### 3.4 Pre-existing build break in `network_checker.dart`

`flutter test` currently fails to compile `test/features/map/map_bloc_test.dart` because `lib/core/services/network_checker.dart:174` references `ConnectivityResult.satellite`, which no longer exists in the `connectivity_plus` enum. The whole `map_bloc_test.dart` file fails to load as a result. Remove or replace the `satellite` case (the modern enum is `wifi`, `mobile`, `ethernet`, `vpn`, `bluetooth`, `other`, `none`). All other tests pass — this is the only red in CI today.

### 3.5 Account deletion is incomplete

`auth_repository.dart` has a "TODO: Implement local cache clearing" comment. Google Play **requires** an in-app account deletion path *and* a publicly-available URL where users can request deletion without installing the app (Data Safety form, since 2024). The current `firebase_service.dart` deletes the Firebase Auth user and the Firestore user doc, but:

- Hive cache is not cleared.
- Outstanding tasks the user authored are not anonymized or reassigned (PII may persist in other users' views).
- There is no UI for a user to download their data prior to deletion (GDPR Article 15 — nice-to-have if you ever ship in the EU).

Action: complete the cache clear, decide on a task-anonymization policy (e.g. `createdBy = "deleted_user"`), and add an Edit-Profile-screen "Delete Account" button with a typed-confirmation gate.

---

## 4. App store metadata you don't have yet

For both stores you will need to prepare:

### Apple App Store Connect

- App icon at 1024×1024 (PNG, no alpha, no rounded corners).
- Screenshots for **at least** 6.7" iPhone (iPhone 15 Pro Max) and 12.9" iPad Pro (3rd gen+) if iPad-supported. **At least 3, ideally 5**, per device class.
- Primary category (recommend **Productivity** or **Utilities**; possibly **Reference**) + secondary.
- Age rating questionnaire — Kapok will land at **4+** unless you have user-generated content the team can't moderate; if you keep tasks user-generated, declare it and answer "no offensive content" honestly.
- Privacy questions: declare *Contact Info → Email Address*, *Location → Precise Location*, *User Content → Other User Content*, *Identifiers → User ID*, *Usage Data → Product Interaction* (analytics), *Diagnostics → Crash Data*.
- Promotional text (≤170 chars), description (≤4000 chars), keywords (≤100 chars), support URL, marketing URL (optional), copyright line.

### Google Play Console

- App icon 512×512.
- Feature graphic 1024×500 (required, displayed at top of listing).
- 2–8 phone screenshots, optional 7" and 10" tablet sets.
- Short description (80 chars), full description (4000 chars).
- Data Safety form (matches the App Privacy disclosures above).
- Content rating questionnaire (IARC).
- Target audience and content (declare 18+ or specify age band; do **not** mark child-directed).
- Privacy Policy URL — Play **requires** this even before you can start internal testing.
- Government / public safety apps face stricter review — Kapok is borderline; expect more scrutiny if you describe it as official.

---

## 5. Build, version, and release process

Right now the only way to produce a build is `flutter build apk`/`flutter build ios` on a developer's laptop. That doesn't scale:

- **Version management:** `pubspec.yaml` has `1.0.0+1`. Adopt a convention — `MAJOR.MINOR.PATCH+BUILD` where `BUILD` increments every CI run. A script like `scripts/bump_build.sh` or a Fastlane action makes this routine.
- **Changelog:** create `CHANGELOG.md` (Keep a Changelog format) and update it with every release.
- **Release notes:** Apple and Google both need short per-release notes. Source them from the changelog.
- **Beta channels:** wire up TestFlight (iOS) and a Play Internal Testing track before public release.
- **Crash monitoring after release:** define an on-call rotation that watches Crashlytics for the first 72 hours of each release. Currently nobody owns this.

---

## 6. Accessibility, internationalization, and inclusivity

The app has solid bones here, but a few items the stores will check (and that reviewers care about):

- **Screen reader smoke test:** turn on VoiceOver (iOS) and TalkBack (Android) and walk through the auth → home → create task flow. Anything that reads as "button button button" needs `Semantics(label: ...)`.
- **Dynamic Type:** verify the app respects iOS Dynamic Type up to ~200%. Long Spanish strings already stress narrow layouts; check the task list and Acknowledgements page in Spanish + XXL accessibility text.
- **Color contrast:** the primary green and the success/error colors in `app_colors.dart` look fine, but run an automated check (Stark, Able, or Lighthouse on the web build) to confirm WCAG AA on text.
- **Localization completeness:** `app_localizations.dart` is two parallel maps. Add a unit test (one is included in this pass) that asserts every English key has a Spanish counterpart so future PRs can't silently drift.

---

## 7. Test suite

Existing tests (6 files, ~1000 LOC):

```
app/test/
├── widget_test.dart
├── integration/critical_flows_test.dart
├── data/models/task_model_test.dart
├── features/map/map_bloc_test.dart
├── features/teams/team_permission_test.dart
└── features/teams/bloc/team_bloc_remove_member_test.dart
```

This pass adds critical-path coverage in these areas (see `app/test/`):

- **Enums** — `core/enums/user_role_test.dart`, `task_priority_test.dart`, `task_status_test.dart`, `task_category_test.dart` (round-trip + tolerant `fromString` parsing).
- **Models** — `data/models/user_model_test.dart` (JSON ↔ object, Firestore Timestamp + ISO string parsing, accountType→userRole migration, equality contract).
- **Services** — `core/services/logger_test.dart` (level filtering, output formatting).
- **Localization** — `core/localization/app_localizations_completeness_test.dart` (every English key has Spanish; no empty strings).

### 7.1 What's still missing (out of scope for this pass — pick up next)

| Area | Why it matters | Suggested file |
| --- | --- | --- |
| `AuthBloc` flows | Sign-in, sign-up, sign-out, password reset — this is the gate to the rest of the app | `test/features/auth/bloc/auth_bloc_test.dart` |
| `TaskBloc` create/update/delete | Mutations against Firestore — high risk during sync failures | `test/features/tasks/bloc/task_bloc_test.dart` |
| Offline cache | Hive boxes get out of sync with Firestore; needs replay testing | `test/data/services/offline_cache_test.dart` |
| Firestore security rules | The repo doesn't include rules tests — separate `firebase emulators:exec` setup | `firebase/firestore.rules.test.js` |
| Widget tests for Create Task | Form validation, location picker fallback, role-based assignee filtering | `test/features/tasks/pages/create_task_page_test.dart` |
| Golden / screenshot tests | Catch unintended visual changes (light/dark theme, EN/ES) | `test/golden/` |
| Integration tests on a real device | Boots full app + Firebase emulator, walks through create → assign → complete | `app/integration_test/full_flow_test.dart` (scaffold added in this pass) |

### 7.2 How to run

```bash
cd app
flutter test                                  # all unit + widget tests
flutter test test/features/auth               # one subtree
flutter test --coverage                       # produces coverage/lcov.info
flutter test integration_test/                # run on attached device or emulator
```

Generate an HTML coverage report:

```bash
brew install lcov
genhtml coverage/lcov.info -o coverage/html && open coverage/html/index.html
```

---

## 8. CI/CD

This pass adds `.github/workflows/ci.yml`. It runs on pushes and PRs to `main` and `test`:

1. Cache Flutter SDK.
2. `flutter pub get`.
3. `flutter analyze` — fail on any **error** (info / warning still surface).
4. `flutter test` — fail on first failure.

Recommended next:

- A second workflow (`build.yml`) that runs on tags `v*` and produces an Android AAB and an iOS archive, uploads them to TestFlight + Play Internal track via Fastlane.
- A `secrets` job that runs `gitleaks` against PRs so a Firebase key never lands in `lib/`.

---

## 9. Submission checklist

Track this in your project board and walk it bottom-up.

### Pre-flight (apply once)

- [ ] Pick and apply production bundle ID + package name. Re-register Firebase apps.
- [ ] Generate Android upload keystore; configure `key.properties`; switch release build to it.
- [ ] Enroll in Play App Signing.
- [ ] Apple Developer Program: enrollment (LLC, D-U-N-S if not yet), distribution cert, App Store provisioning profile.
- [ ] Standardize `IPHONEOS_DEPLOYMENT_TARGET` to `14.0` (or chosen value).
- [ ] Replace Mapbox placeholder in `AndroidManifest.xml` with build-time injection.
- [ ] Restrict Firebase API keys in Google Cloud Console.
- [ ] Move / decide on tracking status of `GoogleService-Info.plist`.
- [ ] Host real Privacy Policy + Terms of Service; replace stub dialogs.
- [ ] Complete account-deletion flow (cache clear + task anonymization + UI).
- [ ] Add Android branded splash via `flutter_native_splash`.
- [ ] Remove or guard `print()` calls in `main.dart`.

### Per-release

- [ ] Bump `version` in `pubspec.yaml` and write a changelog entry.
- [ ] `flutter analyze` — zero errors, zero new warnings.
- [ ] `flutter test` — green.
- [ ] Smoke test on the lowest supported iOS device + an Android device.
- [ ] Pull store screenshots (5 per device class) from a real device against the current build.
- [ ] Update App Store / Play Store metadata (description, what's-new, screenshots, age rating).
- [ ] Submit to TestFlight + Play Internal Testing first; let team dogfood for ≥48 hours.
- [ ] Promote to public.

### Post-release

- [ ] Watch Crashlytics for 72 hours.
- [ ] Tag the release commit (`v1.0.0`) and push the tag.
- [ ] Archive build artifacts.

---

## 10. References

- Apple App Store Review Guidelines — https://developer.apple.com/app-store/review/guidelines/
- App Store Connect Help — https://help.apple.com/app-store-connect/
- Google Play Developer Program Policies — https://play.google.com/about/developer-content-policy/
- Play Console Data Safety form — https://support.google.com/googleplay/android-developer/answer/10787469
- Flutter Build & Release Docs — https://docs.flutter.dev/deployment
- Firebase API Key Restrictions — https://firebase.google.com/docs/projects/api-keys
- Mapbox Token Best Practices — https://docs.mapbox.com/help/troubleshooting/how-to-use-mapbox-securely/
