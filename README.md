# Kapok

Kapok is a mobile app (built with **Flutter** & **Firebase**) for coordinating volunteer disaster relief teams, developed for the **National Center for Technology and Dispute Resolution**.

## Structure
- `/app` – Flutter mobile app (iOS/Android/Web)
- `/firebase` – Firebase configuration & Firestore rules
- `/docs` – Design, architecture, and planning docs

## Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest version)
- [Firebase CLI](https://firebase.google.com/docs/cli) (optional, for deploying backend)
- Dart SDK (bundled with Flutter)
- Chrome browser for quickly running the app 
- [Android Emulator](https://docs.flutter.dev/platform-integration/android/setup) (if you have a Windows computer)
- [iOS Simulator](https://docs.flutter.dev/platform-integration/ios/setup) (if you have a MacBook)

## Setup & Run
1. `cd app`
2. `flutter pub get`
3. `flutter clean`
4. `flutter run`

When prompted, select `2` to develop in Chrome, or alternatively choose the iOS Simulator / Android Emulator if you have them installed.

We can also use `flutter run -d chrome`.  