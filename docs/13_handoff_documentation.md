# Handoff Documentation

## Overview

This document provides guidance for publishing Kapok to the Apple App Store and Google Play Store, along with pre-publication requirements and test account credentials.

## Test Accounts

The following accounts are available for testing and demonstration:

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

---

## Pre-Publication Checklist

### Required Before Submission

| Item | Status | Notes |
|------|--------|-------|
| App Icon | Complete | Located in `assets/images/kapok_icon.png` |
| Splash Screen | Complete | Implemented in splash feature |
| Privacy Policy | **Needed** | Must be hosted at a public URL |
| Terms of Service | **Needed** | Must be hosted at a public URL |
| Support Email | **Needed** | Required for store listings |
| Marketing Website | Optional | Recommended for credibility |

### Content to Prepare

1. **App Description** (short and long versions)
2. **Screenshots** for each device size (phone, tablet)
3. **Feature Graphics** (Play Store banner)
4. **App Preview Video** (optional but recommended)
5. **Keywords** for App Store Optimization (ASO)
6. **Category Selection** (suggested: Productivity or Utilities)

### Legal Requirements

- Privacy Policy URL (required by both stores)
- Terms of Service URL
- Data handling disclosures
- Location permission justification text

---

## Apple App Store Publication

### Prerequisites

1. **Apple Developer Account** ($99/year)
   - Enroll at [developer.apple.com](https://developer.apple.com/programs/enroll/)
   - Organization enrollment recommended for business apps

2. **Mac with Xcode** (latest version)

3. **App Store Connect Access**
   - Create app record at [appstoreconnect.apple.com](https://appstoreconnect.apple.com)

### Build Configuration

1. **Bundle Identifier**
   - Current: `com.kapok.app` (verify in `ios/Runner.xcodeproj`)
   - Must match App Store Connect record

2. **Signing Certificates**
   - Create Distribution Certificate in Apple Developer Portal
   - Create App Store Provisioning Profile
   - Configure in Xcode under Signing & Capabilities

3. **Version and Build Numbers**
   - Update in `pubspec.yaml`: `version: 1.0.0+1`
   - Format: `major.minor.patch+buildNumber`

### Build and Upload

```bash
# Clean and get dependencies
cd app
flutter clean
flutter pub get

# Build iOS release
flutter build ios --release

# Open in Xcode
open ios/Runner.xcworkspace
```

In Xcode:
1. Select "Any iOS Device" as build target
2. Product → Archive
3. Distribute App → App Store Connect
4. Upload

### App Store Review Considerations

- **Location Permission**: Provide clear justification in Info.plist
- **Login Required**: Provide demo account credentials to reviewers
- **Offline Features**: Document offline capabilities
- **Review Time**: Typically 24-48 hours, can be longer

### Info.plist Requirements

Ensure these keys have user-facing descriptions:
- `NSLocationWhenInUseUsageDescription`
- `NSLocationAlwaysUsageDescription` (if applicable)
- `NSCameraUsageDescription` (if adding photo features)

---

## Google Play Store Publication

### Prerequisites

1. **Google Play Developer Account** ($25 one-time fee)
   - Register at [play.google.com/console](https://play.google.com/console)

2. **Signing Key**
   - Create upload key for app signing
   - Google manages production signing key

### Build Configuration

1. **Application ID**
   - Current: `com.kapok.app` (verify in `android/app/build.gradle`)
   - Cannot change after first publication

2. **Signing Configuration**

   Create `android/key.properties`:
   ```properties
   storePassword=<password>
   keyPassword=<password>
   keyAlias=upload
   storeFile=<path-to-keystore>
   ```

   Generate keystore:
   ```bash
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

3. **Version Code**
   - Must increment with each upload
   - Set in `pubspec.yaml` or `build.gradle`

### Build and Upload

```bash
# Clean and get dependencies
cd app
flutter clean
flutter pub get

# Build Android App Bundle (recommended)
flutter build appbundle --release

# Or build APK
flutter build apk --release
```

Output locations:
- AAB: `build/app/outputs/bundle/release/app-release.aab`
- APK: `build/app/outputs/flutter-apk/app-release.apk`

### Play Console Setup

1. Create new app in Play Console
2. Complete store listing (description, screenshots, etc.)
3. Set up pricing and distribution
4. Complete content rating questionnaire
5. Complete data safety form
6. Upload AAB to production track

### Data Safety Form

Declare the following data collection:
- **Location**: Approximate and precise location for task mapping
- **Personal Info**: Name, email for account
- **App Activity**: App interactions for analytics (if enabled)

---

## Environment Configuration for Production

### Firebase

1. Verify production Firebase project is configured
2. Enable App Check for security (recommended)
3. Review Firestore security rules
4. Enable Firebase Crashlytics for production monitoring

### Mapbox

1. Ensure Mapbox access token has production permissions
2. Consider usage limits and billing for production traffic
3. Token should be restricted to app bundle IDs

### Environment Variables

Production `.env` file:
```
MAPBOX_ACCESS_TOKEN=<production_token>
```

---

## Post-Publication

### Monitoring

- **Firebase Crashlytics**: Monitor crash reports
- **Firebase Analytics**: Track user engagement
- **Store Reviews**: Respond to user feedback
- **Play Console/App Store Connect**: Monitor vitals and metrics

### Updates

1. Increment version number in `pubspec.yaml`
2. Increment build number (must always increase)
3. Build new release
4. Upload to respective stores
5. Submit for review with release notes

### Recommended Update Cycle

- **Hotfixes**: As needed for critical bugs
- **Minor Updates**: Monthly for improvements
- **Major Updates**: Quarterly for new features

---

## Support Handoff

### Technical Contacts

Provide the new team with:
- Firebase project access
- Mapbox account access
- Apple Developer account access
- Google Play Console access
- GitHub repository access

### Documentation

All technical documentation is available in the `/docs` folder:
- Architecture and code structure
- Feature documentation
- Development setup guide

### Known Limitations

Refer to `12_development_notes.md` for:
- Features marked as placeholders
- Platform-specific constraints
- Offline limitations
