# Handoff Documentation

_Last verified against the codebase: 2026-10-24 (version `1.0.0+2`)._

## Overview

This document covers publishing Kapok to the Apple App Store and Google Play Store, the current pre-publication status, and the test accounts. The plan is **iOS first, Android after**. For the client-side business steps (D-U-N-S, developer accounts, legal), see `16_client_store_submission_guide.md`. For the detailed technical review, see `15_store_readiness_evaluation.md`.

## Test Accounts

These hit the **production** Firebase project (`build-kapok`). Delete any data you create while testing.

### Teams

| Team Name | Join Code |
|-----------|-----------|
| Team Testing A | `9BK2UP` |
| Team Testing B | `YYOMTM` |

### User Accounts

| Role | Email | Password |
|------|-------|----------|
| Team Member | `user@test.com` | `test123` |
| Team Leader | `leader@test.com` | `test123` |
| Admin | `admin@test.com` | `test123` |

### Accounts for App Review

Create **dedicated** reviewer accounts instead of sharing the ones above. Apple and Google reviewers test account deletion, and deletion is refused for leaders of active teams. Give reviewers a **Team Member** account that belongs to a test team (so the app has data to show) and explain the leader restriction in the review notes.

---

## Pre-Publication Status

| Item | Status | Notes |
|------|--------|-------|
| App identifiers | Done | `com.afairresolution.kapok` on iOS and Android |
| App icon | Done | Source `app/assets/images/kapok_icon.png`; iOS 1024px icon has no alpha |
| Splash screen | Done | iOS `LaunchScreen.storyboard`; Android via `flutter_native_splash` |
| iOS signing | Done | Automatic signing, team `9M48UX3QW7`; build 1.0.0+2 uploaded |
| iOS privacy manifest | Done | `ios/Runner/PrivacyInfo.xcprivacy` |
| iOS device family | Done | **iPhone only** (no iPad screenshots needed) |
| Location permission text | Done | `NSLocationWhenInUseUsageDescription` (+ `AlwaysAndWhenInUse`, required by the location plugin) |
| Export compliance | Done | `ITSAppUsesNonExemptEncryption = false` |
| In-app account deletion | Done | Profile → Settings → Delete Account |
| Works with location denied | Done | Map falls back to a default center |
| Privacy Policy / Terms text | Draft | In-app text in `lib/core/constants/`, contact kapok@afairresolution.com, **pending legal review** |
| Privacy Policy / Terms **URL** | **Needed** | Both stores require a public URL; host the same text |
| Support URL / email | Partly | Email is `kapok@afairresolution.com`; App Store also needs a support **URL** |
| Firestore rules deploy | **Needed** | Repo has a new `mapSnapshots` rule; diff vs. live first (`12_development_notes.md`) |
| Android release signing | **Deferred** | `android/key.properties` + upload keystore not created yet (after iOS) |
| Store listing content | **Needed** | Screenshots, descriptions, privacy/data-safety forms, ratings |

### Content to Prepare

1. App description (short and long)
2. iPhone screenshots (6.9"/6.7" class) and Android phone screenshots
3. Play Store feature graphic (1024×500)
4. Keywords (App Store)
5. Category (suggested: Productivity or Utilities)

---

## Apple App Store Publication

### Prerequisites

1. Apple Developer Program membership (organization, $99/year) — team `9M48UX3QW7`
2. Mac with **Xcode 26+** (App Store Connect requires the iOS 26 SDK)
3. App Store Connect app record (Apple ID 6807118290)

### Build Configuration

- **Bundle Identifier**: `com.afairresolution.kapok` (Debug/Release/Profile)
- **Signing**: automatic, team `9M48UX3QW7`
- **Deployment target**: iOS 15.0 (Podfile and project agree)
- **Device family**: iPhone only (`TARGETED_DEVICE_FAMILY = 1`). This is only easy to change before the first public release; Apple doesn't allow removing iPad support from a released app.
- **Version**: `pubspec.yaml` `version: 1.0.0+2`. Bump the build number (`+3`, …) for every upload.

### Build and Upload

```bash
cd app
flutter pub get
cd ios && pod install && cd ..   # needed after plugin changes (e.g. pointer_interceptor)
flutter build ipa --release
```

Then upload `build/ios/ipa/*.ipa` with Transporter or Xcode's Organizer, or archive directly in Xcode (`open ios/Runner.xcworkspace` → Any iOS Device → Product → Archive → Distribute App).

### App Store Review Considerations

- **Demo account**: required (see "Accounts for App Review")
- **Account deletion**: available in-app (guideline 5.1.1(v)); explain the team-leader restriction in the notes
- **Location**: while-in-use only, and the app still works if it's denied
- **Privacy labels**: must match `PrivacyInfo.xcprivacy` and the privacy policy (email, name, user ID, precise location, user content, product interaction, crash data; no tracking)

---

## Google Play Store Publication (after iOS)

### Prerequisites

1. Google Play Developer account (organization, $25 one-time)
2. An upload keystore (see below). Enroll in **Play App Signing** on the first upload.
3. Enough free disk space: the first Android build downloads several GB of Gradle/SDK dependencies

### Build Configuration

- **Application ID / namespace**: `com.afairresolution.kapok` (permanent after first publish)
- **SDK levels**: `minSdk` 24, `targetSdk` 36
- **Signing + Mapbox token**: `cp app/android/key.properties.example app/android/key.properties` (gitignored) and fill it in:

  ```properties
  storeFile=/absolute/path/outside/repo/kapok-upload.jks
  storePassword=<password>
  keyAlias=upload
  keyPassword=<password>
  MAPBOX_ACCESS_TOKEN=pk.<public token>
  ```

  ```bash
  keytool -genkey -v -keystore ~/keys/kapok-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
  ```

  Without this file, release builds are signed with the **debug** key (Play rejects them) and maps won't load.

### Build and Upload

```bash
cd app
flutter pub get
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`. Upload it to an **internal testing** track first.

### Play Console Setup

1. Create the app, complete the store listing
2. Content rating questionnaire, target audience (not child-directed)
3. **Data safety** form (matches the privacy policy): email, name, user ID, precise location, user-generated content, app interactions, crash logs; data deletion available in-app
4. Privacy Policy URL
5. Upload the AAB to internal testing, then promote

---

## Environment Configuration for Production

### Firebase (`build-kapok`)

1. Restrict the iOS/Android API keys to the app's bundle ID / package + signing SHA in Google Cloud Console
2. Consider App Check
3. Deploy the reviewed Firestore rules (diff against live first)
4. Crashlytics is active on iOS/Android

### Mapbox

1. Use a public `pk.*` token, URL/bundle-restricted where possible
2. Watch usage limits and billing
3. `app/.env` (iOS + Android runtime) and `key.properties`/env (Android manifest) both need it

---

## Post-Publication

- **Monitoring**: Crashlytics, Analytics, store reviews, App Store Connect / Play vitals. Watch Crashlytics for the first 72 hours after each release.
- **Updates**: bump `version` in `pubspec.yaml` (build number must always increase), build, upload, submit with release notes, and update `CHANGELOG.md`.

---

## Support Handoff

### Access to hand over
- Firebase project `build-kapok`
- Mapbox account
- Apple Developer / App Store Connect (team `9M48UX3QW7`)
- Google Play Console
- GitHub repository

### Documentation

All technical documentation is in `/docs`. Start with `01_overview.md`, `03_architecture.md`, and `12_development_notes.md` (setup, building, rules deployment, recent fixes). `14_user_manual.md` is end-user facing.

### Known Limitations

See `12_development_notes.md` → Known Constraints and `15_store_readiness_evaluation.md` → open items.
