# Firebase Configuration

## Overview

The Kapok application uses Firebase as its backend-as-a-service platform, providing authentication, database, storage, and other essential services. This document covers the complete Firebase setup and configuration process.

## Firebase Services Used

### Core Services
- **Firebase Authentication** - User authentication and authorization
- **Cloud Firestore** - NoSQL document database
- **Firebase Storage** - File storage and management
- **Firebase Hosting** - Web hosting (future use)

### Additional Services
- **Firebase Analytics** - User behavior tracking
- **Firebase Crashlytics** - Error reporting and crash analysis
- **Firebase Performance** - App performance monitoring
- **Firebase Functions** - Serverless backend logic (future use)

## Project Setup

### 1. Firebase Project Creation

```bash
# Login to Firebase
firebase login

# Create new project
firebase projects:create build-kapok

# Set as active project
firebase use build-kapok
```

### 2. Firebase CLI Initialization

```bash
# Initialize Firebase in project root
firebase init

# Select services:
# - Firestore: Configure security rules and indexes
# - Storage: Configure security rules
# - Emulators: Set up local development environment
```

## Firestore Configuration

### 1. Database Structure

The Firestore database is organized into the following collections:

```
firestore/
├── users/                 # User profiles and authentication data
├── teams/                 # Team information and membership
├── tasks/                 # Task data with geolocation
├── sync_queue/            # Offline sync operations
└── app_settings/          # Application configuration
```

### 2. Security Rules

**Firestore Rules** (`firebase/firestore.rules`):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Team data access based on membership
    match /teams/{teamId} {
      allow read, write: if request.auth != null && 
        (resource.data.memberIds[request.auth.uid] != null || 
         resource.data.leaderId == request.auth.uid);
    }
    
    // Task access based on team membership
    match /tasks/{taskId} {
      allow read, write: if request.auth != null && 
        (resource.data.teamId in get(/databases/$(database)/documents/users/$(request.auth.uid)).data.teamIds);
    }
    
    // Sync queue for offline operations
    match /sync_queue/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 3. Database Indexes

**Firestore Indexes** (`firebase/firestore.indexes.json`):

```json
{
  "indexes": [
    {
      "collectionGroup": "tasks",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "teamId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "createdAt",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "tasks",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "assignedTo",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "taskCompleted",
          "order": "ASCENDING"
        }
      ]
    },
    {
      "collectionGroup": "teams",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "teamCode",
          "order": "ASCENDING"
        }
      ]
    }
  ],
  "fieldOverrides": []
}
```

## Firebase Storage Configuration

### 1. Storage Rules

**Storage Rules** (`firebase/storage.rules`):

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // User profile images
    match /users/{userId}/profile/{fileName} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Task attachments
    match /tasks/{taskId}/attachments/{fileName} {
      allow read, write: if request.auth != null && 
        resource.metadata.teamId in get(/databases/$(database)/documents/users/$(request.auth.uid)).data.teamIds;
    }
    
    // Team documents
    match /teams/{teamId}/documents/{fileName} {
      allow read, write: if request.auth != null && 
        (resource.metadata.teamId in get(/databases/$(database)/documents/users/$(request.auth.uid)).data.teamIds);
    }
  }
}
```

### 2. Storage Structure

```
storage/
├── users/
│   └── {userId}/
│       └── profile/
│           └── profile_image.jpg
├── tasks/
│   └── {taskId}/
│       └── attachments/
│           ├── image1.jpg
│           └── document.pdf
└── teams/
    └── {teamId}/
        └── documents/
            └── team_manual.pdf
```

## Authentication Configuration

### 1. Authentication Providers

Enable the following authentication providers in Firebase Console:

- **Email/Password** - Primary authentication method
- **Google Sign-In** - Optional social authentication
- **Anonymous** - For guest access (if needed)

### 2. Authentication Rules

```javascript
// Custom claims for role-based access
// Admin: { role: 'admin' }
// Team Leader: { role: 'team_leader', teamId: 'team_id' }
// Team Member: { role: 'team_member', teamId: 'team_id' }
```

## FlutterFire Configuration

### 1. FlutterFire CLI Setup

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure FlutterFire
flutterfire configure

# Select platforms:
# - Android
# - iOS
# - Web (optional)
```

### 2. Generated Configuration

The FlutterFire CLI generates `lib/firebase_options.dart`:

```dart
// File generated by FlutterFire CLI
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Unsupported platform');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'your-android-api-key',
    appId: 'your-android-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'build-kapok',
    storageBucket: 'build-kapok.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'your-ios-api-key',
    appId: 'your-ios-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'build-kapok',
    storageBucket: 'build-kapok.firebasestorage.app',
    iosBundleId: 'com.example.kapokApp',
  );
}
```

## Firebase Emulators

### 1. Emulator Setup

```bash
# Start Firebase emulators
firebase emulators:start

# Available emulators:
# - Firestore: http://localhost:8080
# - Storage: http://localhost:9199
# - Auth: http://localhost:9099
# - Functions: http://localhost:5001
```

### 2. Emulator Configuration

**Firebase Configuration** (`firebase.json`):

```json
{
  "firestore": {
    "rules": "firebase/firestore.rules",
    "indexes": "firebase/firestore.indexes.json"
  },
  "storage": {
    "rules": "firebase/storage.rules"
  },
  "emulators": {
    "auth": {
      "port": 9099
    },
    "firestore": {
      "port": 8080
    },
    "storage": {
      "port": 9199
    },
    "ui": {
      "enabled": true,
      "port": 4000
    }
  }
}
```

### 3. Development Configuration

```dart
// Use emulators in development
if (kDebugMode) {
  await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
}
```

## Environment Configuration

### 1. Development Environment

```bash
# Set development environment
firebase use --add build-kapok-dev

# Configure emulators for development
firebase emulators:start --project build-kapok-dev
```

### 2. Production Environment

```bash
# Set production environment
firebase use --add build-kapok-prod

# Deploy to production
firebase deploy --project build-kapok-prod
```

## Security Best Practices

### 1. API Key Security

- **Android**: API keys are safe to include in client apps
- **iOS**: API keys are safe to include in client apps
- **Web**: Use domain restrictions for API keys

### 2. Database Security

- Implement proper Firestore security rules
- Use authentication for all database operations
- Validate data on both client and server side

### 3. Storage Security

- Implement storage security rules
- Validate file types and sizes
- Use authentication for file access

## Monitoring and Analytics

### 1. Firebase Analytics

```dart
// Track custom events
await FirebaseAnalytics.instance.logEvent(
  name: 'task_created',
  parameters: {
    'task_severity': severity,
    'team_id': teamId,
  },
);
```

### 2. Firebase Crashlytics

```dart
// Report custom errors
FirebaseCrashlytics.instance.recordError(
  error,
  stackTrace,
  reason: 'Task creation failed',
);
```

### 3. Firebase Performance

```dart
// Track custom traces
final trace = FirebasePerformance.instance.newTrace('task_creation');
await trace.start();
// ... perform task creation
await trace.stop();
```

## Deployment

### 1. Firestore Rules Deployment

```bash
# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Firestore indexes
firebase deploy --only firestore:indexes
```

### 2. Storage Rules Deployment

```bash
# Deploy Storage rules
firebase deploy --only storage
```

### 3. Complete Deployment

```bash
# Deploy all Firebase services
firebase deploy
```

## Troubleshooting

### Common Issues

#### 1. Authentication Issues

```bash
# Check authentication configuration
firebase auth:export users.json

# Verify API keys
firebase projects:list
```

#### 2. Firestore Issues

```bash
# Check Firestore rules
firebase firestore:rules:get

# Test rules locally
firebase emulators:start --only firestore
```

#### 3. Storage Issues

```bash
# Check storage rules
firebase storage:rules:get

# Test storage locally
firebase emulators:start --only storage
```

### Debug Commands

```bash
# View Firebase project info
firebase projects:list

# Check current project
firebase use

# View project configuration
firebase projects:list --json
```

## Future Enhancements

### 1. Firebase Functions

- Serverless backend logic
- Automated task processing
- Push notifications
- Data validation and sanitization

### 2. Firebase Extensions

- Resize Images
- Delete User Data
- Translate Text
- Send Email

### 3. Advanced Features

- Real-time collaboration
- Offline sync optimization
- Advanced analytics
- A/B testing