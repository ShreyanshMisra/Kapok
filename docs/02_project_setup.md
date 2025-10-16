---
title: Project Setup Guide
description: Step-by-step guide for setting up the Kapok Flutter development environment
---

# Project Setup Guide

## Prerequisites

Before setting up the Kapok project, ensure you have the following installed:

### Required Software

1. **Flutter SDK** (≥ 3.9.2)
   ```bash
   # Check Flutter version
   flutter --version
   
   # If not installed, download from: https://flutter.dev/docs/get-started/install
   ```

2. **Dart SDK** (≥ 3.9)
   ```bash
   # Dart comes with Flutter
   dart --version
   ```

3. **Firebase CLI**
   ```bash
   # Install Firebase CLI
   npm install -g firebase-tools
   
   # Verify installation
   firebase --version
   ```

4. **FlutterFire CLI**
   ```bash
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Verify installation
   flutterfire --version
   ```

### Development Tools

1. **Android Studio** (for Android development)
   - Download from: https://developer.android.com/studio
   - Install Android SDK and emulator

2. **Xcode** (for iOS development - macOS only)
   - Install from Mac App Store
   - Install iOS Simulator

3. **VS Code** (recommended editor)
   - Download from: https://code.visualstudio.com/
   - Install Flutter and Dart extensions

## Repository Setup

### 1. Clone the Repository

```bash
# Clone the repository
git clone <repository-url>
cd Kapok

# Verify project structure
ls -la
```

### 2. Navigate to Flutter App

```bash
# Navigate to the Flutter app directory
cd app

# Verify Flutter project
flutter doctor
```

### 3. Install Dependencies

```bash
# Get Flutter dependencies
flutter pub get

# Verify dependencies are resolved
flutter pub deps
```

## Firebase Configuration

### 1. Firebase Project Setup

```bash
# Login to Firebase
firebase login

# Initialize Firebase in project root
cd ..  # Go back to Kapok root
firebase init

# Select the following services:
# - Firestore
# - Storage
# - Emulators
```

### 2. FlutterFire Configuration

```bash
# Navigate back to app directory
cd app

# Configure FlutterFire
flutterfire configure

# Select your Firebase project
# Choose platforms (Android, iOS)
```

### 3. Verify Firebase Setup

```bash
# Check if firebase_options.dart was generated
ls lib/firebase_options.dart

# Verify Firebase configuration
flutter run --debug
```

## Environment Configuration

### 1. Android Configuration

```bash
# Check Android setup
flutter doctor --android-licenses

# Accept all licenses
flutter doctor --android-licenses
```

### 2. iOS Configuration (macOS only)

```bash
# Check iOS setup
flutter doctor

# If Xcode issues, run:
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

### 3. Mapbox Configuration

1. Create a Mapbox account at: https://www.mapbox.com/
2. Generate an access token
3. Add token to platform-specific configuration:

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<meta-data
    android:name="com.mapbox.token"
    android:value="YOUR_MAPBOX_TOKEN" />
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>MBXAccessToken</key>
<string>YOUR_MAPBOX_TOKEN</string>
```

## Running the Application

### 1. Check Device Connection

```bash
# List connected devices
flutter devices

# Start Android emulator
flutter emulators --launch <emulator-name>

# Start iOS simulator (macOS only)
open -a Simulator
```

### 2. Run the App

```bash
# Run in debug mode
flutter run

# Run in release mode
flutter run --release

# Run with specific device
flutter run -d <device-id>
```

### 3. Hot Reload

- Press `r` in terminal for hot reload
- Press `R` for hot restart
- Press `q` to quit

## Development Workflow

### 1. Code Generation

```bash
# Generate JSON serialization code
flutter packages pub run build_runner build

# Watch for changes and auto-generate
flutter packages pub run build_runner watch

# Clean and rebuild
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### 2. Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Run tests with coverage
flutter test --coverage
```

### 3. Code Quality

```bash
# Analyze code
flutter analyze

# Format code
dart format .

# Check for issues
flutter doctor
```

## Troubleshooting

### Common Issues

#### 1. Flutter Doctor Issues

```bash
# Fix common issues
flutter doctor --android-licenses
flutter doctor --fix
```

#### 2. Dependency Issues

```bash
# Clean and reinstall
flutter clean
flutter pub get
flutter pub upgrade
```

#### 3. Firebase Issues

```bash
# Reconfigure Firebase
flutterfire configure

# Check Firebase project
firebase projects:list
```

#### 4. Build Issues

```bash
# Clean build
flutter clean
flutter pub get
flutter run
```

### Platform-Specific Issues

#### Android Issues

```bash
# Update Android SDK
flutter doctor --android-licenses

# Check Gradle version
cd android
./gradlew --version
```

#### iOS Issues (macOS only)

```bash
# Update CocoaPods
cd ios
pod install --repo-update

# Clean iOS build
flutter clean
cd ios
rm -rf Pods
pod install
```

## IDE Configuration

### VS Code Setup

1. Install extensions:
   - Flutter
   - Dart
   - Firebase
   - GitLens

2. Configure settings (`.vscode/settings.json`):
```json
{
  "dart.flutterSdkPath": "/path/to/flutter",
  "dart.enableSdkFormatter": true,
  "editor.formatOnSave": true,
  "dart.lineLength": 80
}
```

### Android Studio Setup

1. Install plugins:
   - Flutter
   - Dart
   - Firebase

2. Configure SDK paths in preferences

## Project Structure Verification

After setup, verify the project structure:

```
Kapok/
├── app/                    # Flutter application
│   ├── lib/               # Source code
│   │   ├── app/           # App configuration
│   │   ├── core/          # Core utilities
│   │   ├── data/          # Data layer
│   │   ├── features/      # Feature modules
│   │   └── main.dart      # App entry point
│   ├── android/           # Android configuration
│   ├── ios/               # iOS configuration
│   └── pubspec.yaml       # Dependencies
├── firebase/              # Firebase configuration
├── docs/                  # Documentation
└── README.md              # Project overview
```

## Next Steps

After successful setup:

1. Review the [Architecture Overview](01_architecture.md)
2. Explore the [App Structure](04_app_structure.md)
3. Understand the [Models and Data Flow](05_models_and_data_flow.md)
4. Start development following the [State Management Guide](06_state_management.md)

## Getting Help

If you encounter issues:

1. Check the [Troubleshooting](#troubleshooting) section
2. Review Flutter documentation: https://flutter.dev/docs
3. Check Firebase documentation: https://firebase.google.com/docs
4. Consult the project's issue tracker

---

*This setup guide ensures a smooth development experience for the Kapok project. Follow each step carefully and verify the setup before proceeding with development.*

