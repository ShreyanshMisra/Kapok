# Kapok Project Overview

## Project Mission

**Kapok** is a disaster relief volunteer coordination application built for the **National Center for Technology and Dispute Resolution (NCTDR)**. The app serves as a mobile-first platform to help coordinate volunteer teams during disaster response operations.

## Core Objective

The primary goal of Kapok is to provide a comprehensive, offline-first mobile application that enables:

- **Task Management**: Create, read, update, and delete disaster relief tasks with geolocation support
- **Team Coordination**: Organize volunteers into teams with role-based access control
- **Real-time Mapping**: Visualize tasks and team locations on interactive maps
- **Offline Capability**: Full functionality even without internet connectivity
- **Multi-language Support**: English and Spanish localization

## Key Technology Stack

### Frontend & Mobile Development
- **Flutter** (Dart) - Cross-platform mobile development framework
- **Material Design 3** - Modern UI/UX design system
- **BLoC Pattern** - Predictable state management
- **GetIt** - Dependency injection container

### Backend & Database
- **Firebase** - Backend-as-a-Service platform
  - **Firestore** - NoSQL document database
  - **Firebase Auth** - User authentication
  - **Firebase Storage** - File storage
- **Hive** - Local NoSQL database for offline-first functionality

### Maps & Location Services
- **Mapbox GL** - Interactive mapping and geolocation
- **Geolocator** - Location services and permissions
- **Geocoding** - Address and coordinate conversion

### Development Tools
- **JSON Serialization** - Code generation for data models
- **Build Runner** - Code generation automation
- **Flutter Lints** - Code quality and style enforcement

## Supported Platforms

- **Android** - Primary target platform
- **iOS** - Secondary target platform
- **Web** - Future consideration (not in initial scope)

## Core Features

### 1. Task Management System
- Create tasks with severity levels (1-5)
- Assign tasks to team members
- Track task completion status
- Geolocation-based task placement
- Offline task creation and editing

### 2. Team Organization
- Three user roles: Admin, Team Leader, Team Member
- Team creation with unique codes
- Role-based permissions and access control
- Team member management

### 3. User Roles & Specializations
- **Account Types**: Admin, Team Leader, Team Member
- **Specializations**: Medical, Engineering, Carpentry, Plumbing, Construction, Electrical, Supplies, Transportation, Other

### 4. Mapping & Navigation
- Interactive map with task markers
- Real-time location tracking
- Offline map support
- Task creation via map interaction

### 5. Offline-First Architecture
- Local data storage with Hive
- Background sync when online
- Conflict resolution strategies
- Network status awareness

### 6. Internationalization
- English and Spanish language support
- Dynamic language switching
- Localized content and UI elements

## Project Structure

```
Kapok/
├── app/                    # Flutter application
│   ├── lib/               # Source code
│   ├── android/           # Android-specific files
│   ├── ios/               # iOS-specific files
│   └── pubspec.yaml       # Dependencies
├── firebase/              # Firebase configuration
├── docs/                  # Technical documentation
└── README.md              # Project overview
```

## Development Phases

### Phase 1: Foundation (Current)
- Project setup and architecture
- Core models and services
- Firebase integration
- Basic UI framework

### Phase 2: Authentication & Team Management
- User authentication system
- Team creation and management
- Role-based access control

### Phase 3: Task Management & Mapping
- Task CRUD operations
- Mapbox integration
- Geolocation services

### Phase 4: Offline Sync & Background Services
- Offline-first implementation
- Background data synchronization
- Conflict resolution

### Phase 5: UI Polish & Localization
- Language toggle implementation
- UI/UX improvements
- Performance optimization

### Phase 6: Advanced Features
- Firebase Functions integration
- Push notifications
- Analytics and reporting

## Target Users

### Primary Users
- **Disaster Relief Coordinators** - Manage overall response operations
- **Team Leaders** - Coordinate specific volunteer teams
- **Volunteers** - Execute assigned tasks and report progress

### Use Cases
- **Natural Disasters** - Hurricane, earthquake, flood response
- **Emergency Situations** - Search and rescue operations

## Getting Started

1. Review the [Project Setup Guide](02_project_setup.md)
2. Understand the [Architecture Overview](01_architecture.md)
3. Explore the [App Structure](04_app_structure.md)
4. Follow the [Development Guidelines](05_models_and_data_flow.md)