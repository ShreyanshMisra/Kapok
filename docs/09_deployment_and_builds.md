---
title: Deployment and Builds
description: Comprehensive guide to building, deploying, and distributing the Kapok Flutter application
---

# Deployment and Builds

## Overview

This document provides comprehensive guidance for building, deploying, and distributing the Kapok Flutter application across different platforms. It covers build configurations, deployment strategies, and distribution methods for both development and production environments.

## Build Configurations

### Development Builds

#### Debug Builds
```bash
# Android Debug Build
flutter build apk --debug

# iOS Debug Build (macOS only)
flutter build ios --debug

# Web Debug Build
flutter build web --debug
```

#### Profile Builds
```bash
# Android Profile Build
flutter build apk --profile

# iOS Profile Build (macOS only)
flutter build ios --profile

# Web Profile Build
flutter build web --profile
```

### Production Builds

#### Release Builds
```bash
# Android Release Build
flutter build apk --release

# Android App Bundle (Recommended for Play Store)
flutter build appbundle --release

# iOS Release Build (macOS only)
flutter build ios --release

# Web Release Build
flutter build web --release
```

## Platform-Specific Builds

### Android Builds

#### Build Configuration

**android/app/build.gradle.kts**:
```kotlin
android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.kapok.disasterrelief"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
    
    buildTypes {
        release {
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
            signingConfig signingConfigs.release
        }
    }
    
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
}
```

#### Signing Configuration

**android/key.properties**:
```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=your_key_alias
storeFile=../keystore/kapok-release-key.jks
```

#### ProGuard Rules

**android/app/proguard-rules.pro**:
```proguard
# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Mapbox
-keep class com.mapbox.** { *; }

# Hive
-keep class hive_flutter.** { *; }
-keep class **$HiveFieldAdapter { *; }
```

#### Build Commands

```bash
# Clean build
flutter clean
flutter pub get

# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release

# Build with specific flavor
flutter build apk --release --flavor production
```

### iOS Builds

#### Build Configuration

**ios/Runner/Info.plist**:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleDisplayName</key>
    <string>Kapok</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>com.kapok.disasterrelief</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>kapok_app</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>UILaunchStoryboardName</key>
    <string>LaunchScreen</string>
    <key>UIMainStoryboardFile</key>
    <string>Main</string>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
    <key>UISupportedInterfaceOrientations~ipad</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationPortraitUpsideDown</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
    <key>UIViewControllerBasedStatusBarAppearance</key>
    <false/>
    <key>CADisableMinimumFrameDurationOnPhone</key>
    <true/>
    <key>UIApplicationSupportsIndirectInputEvents</key>
    <true/>
</dict>
</plist>
```

#### Build Commands

```bash
# Clean build
flutter clean
flutter pub get
cd ios && pod install && cd ..

# Build iOS
flutter build ios --release

# Build for specific device
flutter build ios --release --target-platform ios-arm64

# Build with specific configuration
flutter build ios --release --flavor production
```

### Web Builds

#### Build Configuration

**web/index.html**:
```html
<!DOCTYPE html>
<html>
<head>
  <base href="$FLUTTER_BASE_HREF">
  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <meta name="description" content="Kapok - Disaster Relief Coordination App">
  <meta name="apple-mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black">
  <meta name="apple-mobile-web-app-title" content="Kapok">
  <link rel="apple-touch-icon" href="icons/Icon-192.png">
  <link rel="icon" type="image/png" href="favicon.png"/>
  <title>Kapok</title>
  <link rel="manifest" href="manifest.json">
  <script>
    window.flutterConfiguration = {
      "apiKey": "YOUR_FIREBASE_API_KEY",
      "authDomain": "build-kapok.firebaseapp.com",
      "projectId": "build-kapok",
      "storageBucket": "build-kapok.firebasestorage.app",
      "messagingSenderId": "673387486415",
      "appId": "YOUR_WEB_APP_ID"
    };
  </script>
</head>
<body>
  <script src="flutter.js" defer></script>
</body>
</html>
```

#### Build Commands

```bash
# Build web
flutter build web --release

# Build with specific base href
flutter build web --release --base-href /kapok/

# Build with web renderer
flutter build web --release --web-renderer html
```

## Firebase Configuration

### Firebase Hosting

**firebase.json**:
```json
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ],
    "headers": [
      {
        "source": "**/*.@(js|css)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=31536000"
          }
        ]
      }
    ]
  }
}
```

### Deployment Commands

```bash
# Deploy to Firebase Hosting
firebase deploy --only hosting

# Deploy to specific project
firebase deploy --only hosting --project build-kapok-prod

# Deploy with specific target
firebase deploy --only hosting:kapok-web
```

## App Store Distribution

### Google Play Store

#### App Bundle Generation

```bash
# Generate signed app bundle
flutter build appbundle --release

# Verify app bundle
bundletool build-apks --bundle=build/app/outputs/bundle/release/app-release.aab --output=app.apks
```

#### Play Console Configuration

1. **App Information**:
   - App name: Kapok
   - Short description: Disaster Relief Coordination App
   - Full description: Comprehensive disaster relief coordination platform

2. **Content Rating**: Complete content rating questionnaire

3. **App Access**: Set up app access and pricing

4. **Store Listing**:
   - Upload screenshots for different device sizes
   - Add feature graphic and app icon
   - Complete store listing details

#### Release Management

```bash
# Build for internal testing
flutter build appbundle --release --flavor internal

# Build for alpha testing
flutter build appbundle --release --flavor alpha

# Build for beta testing
flutter build appbundle --release --flavor beta

# Build for production
flutter build appbundle --release --flavor production
```

### Apple App Store

#### Archive Generation

```bash
# Build iOS archive
flutter build ios --release
cd ios
xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Release -destination generic/platform=iOS -archivePath build/Runner.xcarchive archive
```

#### App Store Connect Configuration

1. **App Information**:
   - App name: Kapok
   - Subtitle: Disaster Relief Coordination
   - Category: Productivity

2. **App Store Review Information**:
   - Contact information
   - Demo account credentials
   - Review notes

3. **Version Information**:
   - Version number: 1.0.0
   - Build number: 1
   - Release notes

#### TestFlight Distribution

```bash
# Upload to TestFlight
xcrun altool --upload-app -f build/Runner.xcarchive -u "your-apple-id" -p "app-specific-password"
```

## CI/CD Pipeline

### GitHub Actions

**.github/workflows/build.yml**:
```yaml
name: Build and Deploy

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.9.2'
        channel: 'stable'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Run tests
      run: flutter test
    
    - name: Run analysis
      run: flutter analyze

  build-android:
    needs: test
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.9.2'
        channel: 'stable'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Build APK
      run: flutter build apk --release
    
    - name: Build App Bundle
      run: flutter build appbundle --release
    
    - name: Upload APK
      uses: actions/upload-artifact@v3
      with:
        name: apk
        path: build/app/outputs/flutter-apk/app-release.apk
    
    - name: Upload App Bundle
      uses: actions/upload-artifact@v3
      with:
        name: app-bundle
        path: build/app/outputs/bundle/release/app-release.aab

  build-ios:
    needs: test
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.9.2'
        channel: 'stable'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Install CocoaPods
      run: cd ios && pod install
    
    - name: Build iOS
      run: flutter build ios --release --no-codesign
    
    - name: Upload iOS build
      uses: actions/upload-artifact@v3
      with:
        name: ios-build
        path: build/ios/iphoneos/Runner.app

  build-web:
    needs: test
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.9.2'
        channel: 'stable'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Build Web
      run: flutter build web --release
    
    - name: Deploy to Firebase
      uses: FirebaseExtended/action-hosting-deploy@v0
      with:
        repoToken: '${{ secrets.GITHUB_TOKEN }}'
        firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
        channelId: live
        projectId: build-kapok
```

### GitLab CI

**.gitlab-ci.yml**:
```yaml
stages:
  - test
  - build
  - deploy

variables:
  FLUTTER_VERSION: "3.9.2"

test:
  stage: test
  image: cirrusci/flutter:3.9.2
  script:
    - flutter pub get
    - flutter test
    - flutter analyze
  only:
    - merge_requests
    - main
    - develop

build-android:
  stage: build
  image: cirrusci/flutter:3.9.2
  script:
    - flutter pub get
    - flutter build apk --release
    - flutter build appbundle --release
  artifacts:
    paths:
      - build/app/outputs/flutter-apk/app-release.apk
      - build/app/outputs/bundle/release/app-release.aab
  only:
    - main
    - develop

build-ios:
  stage: build
  image: cirrusci/flutter:3.9.2
  script:
    - flutter pub get
    - cd ios && pod install && cd ..
    - flutter build ios --release --no-codesign
  artifacts:
    paths:
      - build/ios/iphoneos/Runner.app
  only:
    - main
    - develop

deploy-web:
  stage: deploy
  image: node:16
  script:
    - npm install -g firebase-tools
    - firebase deploy --only hosting --token $FIREBASE_TOKEN
  only:
    - main
```

## Environment Configuration

### Build Flavors

**lib/main.dart**:
```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/kapok_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase based on flavor
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const KapokApp());
}
```

**lib/flavors.dart**:
```dart
enum Flavor {
  development,
  staging,
  production,
}

class FlavorConfig {
  static Flavor? appFlavor;
  
  static String get name {
    switch (appFlavor) {
      case Flavor.development:
        return 'Development';
      case Flavor.staging:
        return 'Staging';
      case Flavor.production:
        return 'Production';
      default:
        return 'Unknown';
    }
  }
  
  static String get apiBaseUrl {
    switch (appFlavor) {
      case Flavor.development:
        return 'https://dev-api.kapok.com';
      case Flavor.staging:
        return 'https://staging-api.kapok.com';
      case Flavor.production:
        return 'https://api.kapok.com';
      default:
        return 'https://api.kapok.com';
    }
  }
  
  static bool get isProduction => appFlavor == Flavor.production;
  static bool get isDevelopment => appFlavor == Flavor.development;
  static bool get isStaging => appFlavor == Flavor.staging;
}
```

### Environment-Specific Builds

```bash
# Development build
flutter build apk --flavor development --debug

# Staging build
flutter build apk --flavor staging --release

# Production build
flutter build appbundle --flavor production --release
```

## Performance Optimization

### Build Optimization

```bash
# Build with specific optimizations
flutter build apk --release --split-per-abi
flutter build appbundle --release --target-platform android-arm,android-arm64,android-x64
```

### Code Splitting

```dart
// Lazy load features
class FeatureRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/tasks':
        return MaterialPageRoute(
          builder: (_) => const TasksPage(),
        );
      case '/teams':
        return MaterialPageRoute(
          builder: (_) => const TeamsPage(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const NotFoundPage(),
        );
    }
  }
}
```

### Asset Optimization

```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/images/
    - assets/icons/
    - assets/fonts/
  
  # Optimize images
  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700
```

## Monitoring and Analytics

### Crash Reporting

```dart
// Initialize crash reporting
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  
  runApp(const KapokApp());
}
```

### Performance Monitoring

```dart
// Track app performance
import 'package:firebase_performance/firebase_performance.dart';

class PerformanceTracker {
  static Future<Trace> startTrace(String name) async {
    final trace = FirebasePerformance.instance.newTrace(name);
    await trace.start();
    return trace;
  }
  
  static Future<void> stopTrace(Trace trace) async {
    await trace.stop();
  }
}
```

## Security Considerations

### Code Obfuscation

```bash
# Build with obfuscation
flutter build apk --release --obfuscate --split-debug-info=build/debug-info
```

### API Key Protection

```dart
// Use environment variables for sensitive data
class ApiConfig {
  static const String apiKey = String.fromEnvironment('API_KEY');
  static const String baseUrl = String.fromEnvironment('BASE_URL');
}
```

### Certificate Pinning

```dart
// Implement certificate pinning for API calls
class SecureHttpClient {
  static HttpClient createSecureClient() {
    final client = HttpClient();
    client.badCertificateCallback = (cert, host, port) {
      // Implement certificate pinning logic
      return _isValidCertificate(cert, host);
    };
    return client;
  }
}
```

## Troubleshooting

### Common Build Issues

#### Android Build Issues

```bash
# Clean and rebuild
flutter clean
flutter pub get
cd android && ./gradlew clean && cd ..
flutter build apk --release

# Fix Gradle issues
cd android
./gradlew clean
./gradlew build
```

#### iOS Build Issues

```bash
# Clean and rebuild
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter build ios --release

# Fix CocoaPods issues
cd ios
pod deintegrate
pod install
```

#### Web Build Issues

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build web --release

# Fix web renderer issues
flutter build web --release --web-renderer html
```

### Performance Issues

```bash
# Analyze build size
flutter build apk --analyze-size

# Check for unused code
flutter build apk --tree-shake-icons
```

---

*This deployment and builds documentation provides comprehensive guidance for building, deploying, and distributing the Kapok Flutter application. Follow these patterns to ensure reliable and efficient deployment processes.*

