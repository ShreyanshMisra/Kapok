# Kapok – App Store & Google Play Readiness Evaluation

**Date:** 2026-10-24 (replaces the 2026-05-25 evaluation)
**App version:** `1.0.0+2` (`app/pubspec.yaml`)
**Plan:** iOS (App Store) first, Android (Google Play) after
**Status:** iOS is code-ready, pending the items in §2. Android's configuration is in place but has never been built for release (signing deferred).

---

## Executive Summary

Since the May evaluation, all of its code/config blockers have been resolved: production identifiers, Android signing plumbing, Mapbox token injection, deployment target, privacy policy and terms text, account deletion, Android splash, and the `print()` cleanup. A code-level review on 2026-10-24 (no simulator/emulator) found and fixed four more issues App Review would likely hit (§3). What remains is mostly **non-code**: hosting the legal pages, deploying Firestore rules, store listing content, and (for Android) creating the upload keystore.

| Area | State | Severity to ship |
| --- | --- | --- |
| iOS identifiers & signing | `com.afairresolution.kapok`, team `9M48UX3QW7`, automatic signing; build 1.0.0+2 uploaded | Done |
| iOS config | iOS 15.0 everywhere, **iPhone only**, Xcode 26.3 / iOS 26 SDK, privacy manifest, export-compliance key | Done |
| Android identifiers & SDKs | `com.afairresolution.kapok`, minSdk 24, targetSdk 36 | Done |
| Android release signing | Wired to `key.properties`, but the file/keystore don't exist yet; falls back to debug signing | **Blocker for Play** (deferred) |
| Privacy Policy / Terms text | In-app, contact `kapok@afairresolution.com`, last updated 2026-10-24; DRAFT pending legal review | Med |
| Privacy Policy / Terms **URL** | Not hosted yet | **Blocker** (both stores) |
| Account deletion | In-app, with recent-login and team-leader safeguards | Done |
| Location-denied behavior | Map falls back to a default center | Done |
| Firestore rules | Repo has a new `mapSnapshots` rule; not deployed; live ruleset must be diffed first | High |
| Secrets hygiene | `.env`, `GoogleService-Info.plist`, `google-services.json`, `key.properties` all gitignored; `.env` only holds the public `pk.` token | Done |
| Tests / CI | 106 unit/widget tests pass; CI runs analyze + test | Low |
| Store listing content | Not started | High |

---

## 1. Methodology (2026-10-24 review)

- File-level inspection of `ios/Runner/Info.plist`, `PrivacyInfo.xcprivacy`, `GoogleService-Info.plist` (bundle ID only), `Runner.xcodeproj/project.pbxproj`, `Podfile`, `AppDelegate.swift`, the app icon set, `android/app/build.gradle.kts`, `AndroidManifest.xml`, `google-services.json` (package names only), `settings.gradle.kts`, and Flutter's default SDK levels.
- Policy-relevant code paths: account deletion, location handling, legal text, debug/test UI reachability, release logging, bundled assets.
- Verified the location-denied fix in the web build (storage cleared, geolocation denied).
- `flutter analyze` (no errors or warnings) and `flutter test` (all pass).
- **Not done:** an Android release build. This Mac has never run a Gradle build, and the first one needs several GB of disk.

## 2. Remaining Items Before Submission

### iOS (now)

1. **Host the Privacy Policy and Terms of Service** at stable public URLs (same text as `lib/core/constants/privacy_policy.dart` / `terms_of_service.dart`, after legal review). Enter them in App Store Connect, plus a **support URL**.
2. **Deploy Firestore rules** after diffing against the live ruleset (procedure in `12_development_notes.md`). Until then the `mapSnapshots` write logs a harmless `permission-denied`.
3. **Run `pod install`** before the next build (the `pointer_interceptor` plugin was added), and bump the build number (`1.0.0+3`).
4. **App Privacy answers** in App Store Connect must match `PrivacyInfo.xcprivacy`: Email, Name, User ID, Precise Location, Other User Content (app functionality, linked); Product Interaction (analytics, linked); Crash Data (not linked); no tracking.
5. **Reviewer account**: a dedicated Team Member account in a test team, plus a note that team leaders must transfer leadership before deleting their account.
6. **Screenshots** for the iPhone 6.9"/6.7" class (no iPad, since the app is iPhone-only).

### Android (after iOS)

1. Create the upload keystore and `app/android/key.properties` (template in `13_handoff_documentation.md`), including `MAPBOX_ACCESS_TOKEN`.
2. First `flutter build appbundle --release` on a machine with enough disk. Confirm it's signed with the upload key (not debug) and that maps load.
3. Enroll in Play App Signing; upload to **internal testing** first.
4. Data safety form, content rating, target audience, privacy policy URL, feature graphic and screenshots.
5. Optional hardening: make `bundleRelease` **fail** when `key.properties` or the Mapbox token is missing, instead of silently falling back.

## 3. Fixed in the 2026-10-24 Review

| Issue | Impact | Fix |
| --- | --- | --- |
| Location denied + no cached region → Map tab showed only an error screen | Likely rejection (guideline 5.1.1: apps must work without optional permissions; reviewers deny location) | `MapRepositoryImpl` falls back to the default center; `MapBloc`'s periodic movement check treats "no position" as "not moved" |
| Account deletion deleted Firestore data before `authUser.delete()`, which fails with `requires-recent-login` after ~5 min | Half-deleted accounts: data gone, login still works | Recent-sign-in check runs before any writes |
| Leader guard queried a non-existent `active` field | Leaders could delete their accounts and orphan teams | Uses `isActive` (missing = active) |
| Closed teams the user led were included in the membership batch | Firestore rules reject a leader removing themselves, so the whole deletion failed | Those teams are skipped |
| Settings reset all BLoCs before deletion | A refused deletion left empty lists and a stuck map | Resets happen only after a successful deletion (via `KapokApp`'s auth listener) |
| Privacy policy promised an in-app analytics opt-out that doesn't exist | Policy/app mismatch | Sentence removed |
| Legal contact was a placeholder | Incomplete metadata | `kapok@afairresolution.com` |

## 4. Verified OK

- **iOS**: bundle ID consistent across configs and Firebase plist; deployment target 15.0 in project and Podfile; `TARGETED_DEVICE_FAMILY = 1`; portrait only; location usage strings present (while-in-use only; the Podfile sets geolocator's `BYPASS_PERMISSION_LOCATION_ALWAYS` so the "always" API is compiled out, and the `NSLocationAlwaysAndWhenInUseUsageDescription` string is kept as a safeguard after ITMS-90683); `ITSAppUsesNonExemptEncryption = false`; no `UIBackgroundModes`; 1024px icon has no alpha; privacy manifest bundled in Resources.
- **Android**: production application ID/namespace; `google-services.json` includes the production package; foreground location only (`ACCESS_FINE`/`COARSE`), no background location; GPS feature optional; target API 36 meets Play's current requirement; Mapbox token injected via manifest placeholder.
- **Both**: in-app account deletion; email/password auth only (no Sign in with Apple requirement); test pages (`/map-test`, `/analytics`, `/edit-task`) not reachable from the UI; the logger prints only in debug builds; bundled `.env` contains only the public token; the superseded drafts in `app/assets/docs/` are **not** bundled.

## 5. Open Risks & Notes

- **UIScene lifecycle**: FlutterFire is capped below the UIScene-adopting releases until Flutter ≥ 3.38. Apple will eventually require UIScene; plan the Flutter upgrade.
- **User-generated content (guideline 1.2)**: tasks are user-written but only visible inside invite-code teams. Low risk; be ready to explain moderation (leaders can delete tasks and remove members).
- **Analytics events**: `AnalyticsService` helpers exist but aren't called; only automatic Firebase analytics are collected. Disclosures already cover analytics.
- **Dead code**: `lib/data/sources/mapbox_source.dart` (stubs) and `DataExportService` (no UI). Harmless; delete when convenient.
- **Android silent fallbacks**: see §2, Android item 5.

## 6. Store Metadata Checklist

### Apple App Store Connect
- App icon (1024×1024, no alpha): done in the asset catalog
- iPhone screenshots (≥3, ideally 5)
- Category (Productivity or Utilities), age rating questionnaire (expect 4+; declare user-generated content honestly)
- App Privacy answers (see §2)
- Promotional text (≤170), description (≤4000), keywords (≤100), support URL, privacy policy URL, copyright line

### Google Play Console
- Icon 512×512, feature graphic 1024×500, 2–8 phone screenshots
- Short (80) and full (4000) descriptions
- Data safety form, IARC content rating, target audience (not child-directed)
- Privacy policy URL (required before any testing track)

## 7. Accessibility & Localization

- Do a VoiceOver/TalkBack smoke test of sign-in → home → create task
- Check Dynamic Type at large sizes, especially Spanish on narrow layouts
- `test/core/localization/app_localizations_completeness_test.dart` ensures every English key has a Spanish translation. Onboarding slides and the legal text are English-only.

## 8. Tests & CI

`flutter test` runs 106 tests (enums, models, logger, localization completeness, map BLoC, team permissions/removal, critical-flow and widget tests). `.github/workflows/ci.yml` runs analyze + test on pushes/PRs to `main` and `test`. Gaps worth filling next: `AuthBloc` flows (including deletion), `TaskBloc` mutations, sync-queue replay, Firestore rules tests with the emulator, and an on-device integration run.

## 9. Per-Release Checklist

- [ ] Bump `version` in `pubspec.yaml` and add a `CHANGELOG.md` entry
- [ ] `flutter analyze` (no errors) and `flutter test` (green)
- [ ] `pod install`; smoke test on a real iPhone (and an Android device once Android is set up)
- [ ] Update screenshots/metadata if the UI changed
- [ ] TestFlight / Play internal testing for ≥48 hours, then promote
- [ ] Watch Crashlytics for 72 hours; tag the release commit

## 10. References

- Apple App Store Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- Google Play Developer Program Policies: https://play.google.com/about/developer-content-policy/
- Play Console Data Safety: https://support.google.com/googleplay/android-developer/answer/10787469
- Flutter deployment docs: https://docs.flutter.dev/deployment
- Firebase API key restrictions: https://firebase.google.com/docs/projects/api-keys
